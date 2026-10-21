## 1. Project rules

- [ ] 1.1 `AGENTS.md`: workflow, commits, checks, builds
- [ ] 1.2 `.github/infra-paths`, `check-commit-kinds.sh` and its self-test, `CI` workflow

## 2. Build

- [ ] 2.1 `CMakeLists.txt`: `MSDF_ATLAS_VERSION_SUFFIX` appended to the reported version
- [ ] 2.2 `.github/build-linux.sh`: Skia build in a pinned manylinux_2_28 container with a pinned vcpkg, static dependencies, checks for Skia and shared libraries
- [ ] 2.3 `binaries.yml`: build key, skip when published, build the key commit, publish without replacing

## 3. Verification

- [ ] 3.1 Local build: `-version` names the commit and Skia, `ldd` shows only glibc
- [ ] 3.2 The binary bakes an MSDF atlas (`-type msdf -format png -json`) from a TTF on this machine; glyphs with overlapping contours have no artifacts
- [ ] 3.3 The key rule on a throwaway history: code + infrastructure on top, `binaries.yml` edit, recipe edit
- [ ] 3.4 Push to `master`: both workflows green, the file of the key is in the `builds` release; the downloaded file works
