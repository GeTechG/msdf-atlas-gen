## ADDED Requirements

### Requirement: A build is named by its build key
The build key of a commit SHALL be the last commit in its history that touches a code path (any path not listed in `.github/infra-paths`) or the build recipe `.github/build-linux.sh`. The `Binaries` workflow SHALL publish the Linux x86_64 standalone executable of a pushed `master` head as `msdf-atlas-gen-linux64-<key>.tar.gz` in the `builds` release, where `<key>` is the full SHA of the head's build key.

#### Scenario: Infrastructure commit on top of a code commit
- **WHEN** one push brings a code commit and, on top of it, a commit that changes only `AGENTS.md`
- **THEN** the build is published under the SHA of the code commit

#### Scenario: Build recipe changes
- **WHEN** a commit changes `.github/build-linux.sh`
- **THEN** that commit is the build key, although the path is infrastructure

#### Scenario: Workflow file changes
- **WHEN** a commit changes only `.github/workflows/binaries.yml`
- **THEN** the build key stays the same and no new file is published

### Requirement: The build is the key commit
The workflow SHALL build the tree of the key commit, so that `msdf-atlas-gen -version` of the published executable names the key commit by its 7-character abbreviated SHA after the upstream version.

#### Scenario: Version of a build published from an infrastructure head
- **WHEN** the head of the push is an infrastructure commit and its build key is `539502a6…`
- **THEN** the published executable reports a version ending in `+539502a`

### Requirement: The build runs on a plain Linux and handles overlapping contours
The published executable SHALL be built with Skia, SHALL link FreeType, libpng, Skia and the C++ runtime statically, and SHALL need no shared library other than those of glibc 2.28 or newer. The build SHALL fail rather than publish an executable that misses Skia or needs another shared library.

#### Scenario: Fresh Linux machine
- **WHEN** the archive is unpacked on an x86_64 Linux with glibc 2.28 or newer and no extra packages
- **THEN** `msdf-atlas-gen -version` runs and reports `& Skia`

### Requirement: One file per key, never replaced
The workflow SHALL build nothing when a file for the key is already published, and SHALL NOT replace a published file: consumers pin its checksum and the build is not bit-reproducible. Runs for one key SHALL be serialised, so that two pushes with the same key yield one build; runs for different keys SHALL NOT cancel one another.

#### Scenario: Key already published
- **WHEN** a push to `master` has a build key whose file is in the `builds` release
- **THEN** the run ends after the lookup, without building or uploading

#### Scenario: Two pushes with one key in quick succession
- **WHEN** an infrastructure push arrives while the build of the preceding code push is running
- **THEN** its run waits for that build and then finds the file published
