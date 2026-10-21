## 1. Project rules

- [x] 1.1 `AGENTS.md`: workflow, commits, checks, builds
- [x] 1.2 `.github/infra-paths`, `check-commit-kinds.sh` and its self-test, `CI` workflow

## 2. Build

- [x] 2.1 `CMakeLists.txt`: `MSDF_ATLAS_VERSION_SUFFIX` appended to the reported version
- [x] 2.2 `.github/build-linux.sh`: Skia build in a pinned manylinux_2_28 container with a pinned vcpkg, static dependencies, checks for Skia and shared libraries
- [x] 2.3 `binaries.yml`: build key, skip when published, build the key commit, publish without replacing

## 3. Verification

- [x] 3.1 Local build: `-version` names the commit and Skia, `ldd` shows only glibc
- [x] 3.2 The binary bakes an MSDF atlas (`-type msdf -format png -json`) from a TTF on this machine; glyphs with overlapping contours have no artifacts
- [x] 3.3 The key rule on a throwaway history: code + infrastructure on top, `binaries.yml` edit, recipe edit

Publication on GitHub (both workflows green after the merge to `master`, the file of the key in the `builds` release, the downloaded file working) is verified after step 5 and reported on the issue.
