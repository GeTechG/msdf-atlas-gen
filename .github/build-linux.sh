#!/usr/bin/env bash
# Builds the standalone msdf-atlas-gen for Linux x86_64 with Skia and packs it into
# out/msdf-atlas-gen-linux64.tar.gz. The build runs in a manylinux_2_28 container (glibc 2.28), so the
# binary starts on any newer Linux; FreeType, libpng, Skia, libstdc++ and libgcc are linked statically.
# Requires docker and the submodules (git submodule update --init).
# The vcpkg binary cache lives in $VCPKG_CACHE (default ~/.cache/msdf-atlas-gen-vcpkg).
set -euo pipefail
cd "$(dirname "$0")/.."

IMAGE=quay.io/pypa/manylinux_2_28_x86_64@sha256:b74a5b6f1705ecff17be8bd792589bef9b3b039766d12205720ecd2a9e919192
VCPKG_COMMIT=9eec002df1cd109f8f104cd966a763daf9751489 # vcpkg 2026.10.16

if [ "${1-}" != --inside ]; then
	[ -f msdfgen/CMakeLists.txt ] && [ -f artery-font-format/artery-font/artery-font.h ] || {
		echo "submodules missing: git submodule update --init" >&2
		exit 1
	}
	cache=${VCPKG_CACHE:-$HOME/.cache/msdf-atlas-gen-vcpkg}
	mkdir -p "$cache" out
	# -version names the commit that is built, by its 7-character abbreviated SHA
	exec docker run --rm -v "$PWD:/src" -v "$cache:/cache" -w /src \
		-e REVISION="$(git rev-parse --short=7 HEAD)" -e MTIME="$(git log -1 --format=%ct)" \
		-e OWNER="$(id -u):$(id -g)" "$IMAGE" .github/build-linux.sh --inside
fi

# Inside the container, as root: hand everything written to /src and /cache back to the caller on exit
trap 'chown -R "$OWNER" /src/build /src/out /cache 2>/dev/null || true' EXIT

dnf install -y --disablerepo=epel zip # base repositories only: an EPEL mirror outage must not fail the build
git init -q /opt/vcpkg
git -C /opt/vcpkg fetch -q --depth 1 https://github.com/microsoft/vcpkg "$VCPKG_COMMIT"
git -C /opt/vcpkg checkout -q FETCH_HEAD
/opt/vcpkg/bootstrap-vcpkg.sh -disableMetrics >/dev/null
mkdir -p /cache/archives /cache/downloads
export VCPKG_ROOT=/opt/vcpkg VCPKG_DEFAULT_BINARY_CACHE=/cache/archives VCPKG_DOWNLOADS=/cache/downloads

build=build/linux64
rm -rf "$build"
cmake -S . -B "$build" -DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_TOOLCHAIN_FILE=/opt/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-linux-release -DVCPKG_HOST_TRIPLET=x64-linux-release \
	-DMSDF_ATLAS_USE_VCPKG=ON -DMSDF_ATLAS_USE_SKIA=ON -DMSDF_ATLAS_VERSION_SUFFIX="+$REVISION" \
	-DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc"
cmake --build "$build" -j"$(nproc)"
bin=$build/bin/msdf-atlas-gen
strip "$bin"
"$bin" -version
"$bin" -version | grep -q "& Skia" || { echo "built without Skia" >&2; exit 1; }

# Only the C library and the dynamic loader may stay dynamic
extra=$(ldd "$bin" | grep -Ev '^\s*(linux-vdso|/lib64/ld-linux-x86-64)|lib(c|m|pthread|dl|rt)\.so' || true)
[ -z "$extra" ] || { echo "unexpected dynamic libraries:" >&2; echo "$extra" >&2; exit 1; }

mkdir -p out
cp LICENSE.txt "$build/bin/"
tar --sort=name --owner=0 --group=0 --numeric-owner --mtime="@$MTIME" \
	-czf out/msdf-atlas-gen-linux64.tar.gz -C "$build/bin" msdf-atlas-gen LICENSE.txt
