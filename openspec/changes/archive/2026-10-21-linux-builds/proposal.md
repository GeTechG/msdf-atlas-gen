## Why

Sprout bakes MSDF fonts with the standalone `msdf-atlas-gen`, and upstream releases ship binaries for Windows only. The fork has to publish a Linux build itself, under a name a consumer can compute from the commit it pins, the way `GeTechG/haxe` publishes its compiler. The fork also has no rules of its own yet: no agent guide, no commit-kind check, no specs.

## What Changes

- The fork becomes an independent project: `AGENTS.md` (process, commits, checks, builds), `.github/infra-paths`, the commit-kind check with its self-test and the `CI` workflow that runs them.
- A build recipe `.github/build-linux.sh` builds the standalone executable with Skia in a pinned manylinux_2_28 container through a pinned vcpkg: FreeType, libpng, Skia, libstdc++ and libgcc static, glibc ≥ 2.28 the only run-time requirement. It refuses a binary without Skia or with other shared libraries.
- The `Binaries` workflow publishes `msdf-atlas-gen-linux64-<key>.tar.gz` in the `builds` release for every push to `master`, where `<key>` is the build key (the last commit touching code or the recipe). A key with a published file builds nothing, a published file is never replaced.
- Code: a CMake cache variable `MSDF_ATLAS_VERSION_SUFFIX` appends text to the reported version string, so the published binary's `-version` names its key commit (`v1.4.0+<7-char key>`). Default empty: upstream behaviour unchanged.

## Capabilities

### New Capabilities
- `commit-kinds`: every commit is code or infrastructure, never both; CI enforces it.
- `binary-builds`: what the build key is, and how the `Binaries` workflow builds and publishes the Linux x86_64 executable.

### Modified Capabilities

None.

## Impact

- New: `AGENTS.md`, `.github/infra-paths`, `.github/scripts/`, `.github/workflows/ci.yml`, `.github/workflows/binaries.yml`, `.github/build-linux.sh`, `openspec/`.
- `CMakeLists.txt`: the `MSDF_ATLAS_VERSION_SUFFIX` variable (one code commit).
- Consumers (Sprout, SPR-241) compute the key as in `AGENTS.md` and pin the file's sha256.
- macOS and Linux arm64 builds are out of scope.
