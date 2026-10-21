# msdf-atlas-gen — agent guide

Independent fork of `Chlumsky/msdf-atlas-gen` (the MSDF font atlas generator: a C++ library and the standalone `msdf-atlas-gen` executable, built on the `msdfgen` submodule). Its consumers pin it by commit or download a published build; they do not dictate how it is worked on. This file is the source of truth here; `README.md` (from upstream) describes the program, its options and the CMake build.

## Workflow
No pull requests: this fork is worked on solo. Work lives on branches and lands on `master` by rebase or merge; the only mandatory gate is green checks (see *Checks*) on the exact tree that lands. Work is scheduled by baton — load the `/baton` skill before filing or picking up an issue, or changing an issue's status, labels, `footprint` or blockers.

An issue runs the same seven steps, in order:

1. **OpenSpec change.** Branch `change/<ISSUE-KEY>-<openspec-name>` from `origin/master` — one task, one branch — and write the change under `openspec/changes/`. Skip the OpenSpec change — here and in step 3 — when the work is mechanical, i.e. nothing the project history needs a record of (docs, renames, config, a bug fix that returns behaviour to what a spec already states). Anything else that touches behaviour is not mechanical — the change is mandatory. A missing spec is never a reason to skip: when `openspec/specs/` does not yet cover the behaviour the task touches, the change adds that spec as a new capability, so the next task has it to work against. A skip is never silent: the report on the issue carries the line `OpenSpec skipped: <reason>`. The other steps stay. An issue labeled `gate:spec` stops here: push the artifacts, post a short plan on the issue, add `needs-human`; continue once the maintainer swaps it for `spec:approved`.
2. **Implement** the tasks.
3. **Test.** Verify the implementation against the change, then sync its specs and archive it as the **last commit of the branch** (never a separate push to `master`), rebase onto current `master` and run the checks. Unless the task is trivial (mechanical, or a few obvious lines), finish with a cross-review of the whole branch diff before the checks — `/ai-brainstorm:ai-review`, a judge from another model family — and fix or rebut its findings until clean.
4. **Human QA — only if the change has it.** Steps only a human can do are written `- [ ] N.M [human] …` in `tasks.md`; agents never tick them. If there are any, post them on the issue as a checklist a human can follow cold, add `needs-human` and stop; continue once the maintainer removes the label. No `[human]` tasks → skip.
5. **Merge** into `master`: `git merge --ff-only` for a single commit or a short linear series, `git merge --no-ff` for a multi-commit change. Push `master`. If `master` moved since the checks ran, rebase and run them again first.
6. **Clean up**: delete the branch (local and remote) and its worktree.
7. **Set the issue done.**

The maintainer decides architecture and end-user behaviour, nothing else — steps 1 (`gate:spec`) and 4 are the only points where an agent waits for a human. Work without an issue: mechanical edits may go straight to `master`.

## Commits
- Every commit is **code** (library and executable sources, the submodule pins, CMake files, `vcpkg.json`, `README.md`, `CHANGELOG.md` — anything that exists upstream) or **infrastructure** (the paths listed in `.github/infra-paths`, absent from upstream: this file, `openspec/`, our CI, scripts and build recipe). Never both — CI rejects a mixed commit.
- OpenSpec artifacts (proposal, tasks, specs, archive) never share a commit with code.
- Code commit messages are written as for upstream `Chlumsky/msdf-atlas-gen`: a plain imperative summary of the change, no mention of consumers or their paths.
- An upstream PR is a cherry-pick of one task's code commits; keep them self-contained — they must build without the infrastructure commits.
- Changing the list of infrastructure paths is an infrastructure commit.

## Checks
Before pushing:
- `bash .github/scripts/check-commit-kinds-test.sh` — self-test of the commit-kind check.
- `bash .github/scripts/check-commit-kinds.sh origin/master..HEAD` — the check on your branch.
- For code commits and for changes to the build recipe: `git submodule update --init`, then `.github/build-linux.sh` (needs docker; the first run builds Skia through vcpkg and takes a while, later runs reuse the vcpkg binary cache). It builds what CI publishes and fails if the binary lacks Skia or needs a shared library other than glibc's. Upstream has no test suite: smoke-test the result on a font, e.g. `build/linux64/bin/msdf-atlas-gen -font <file.ttf> -type msdf -format png -imageout atlas.png -json atlas.json`, and look at the atlas.

## Builds
`.github/workflows/binaries.yml` publishes the standalone executable for Linux x86_64 for every push to `master`, as `msdf-atlas-gen-linux64-<key>.tar.gz` (the `msdf-atlas-gen` binary and `LICENSE.txt`) in the single `builds` release. The binary is built with Skia (needed for glyphs with overlapping contours) in a manylinux_2_28 container: FreeType, libpng, Skia, libstdc++ and libgcc are linked statically, only glibc ≥ 2.28 is needed at run time. The recipe is `.github/build-linux.sh`; it pins the container image and the vcpkg commit.

`<key>` is the **build key**: the last commit in the history that touches code or the build recipe `.github/build-linux.sh` — the one infrastructure path that changes the binary. An infrastructure push keeps the key and builds nothing; `msdf-atlas-gen -version` names the key commit (`MSDF-Atlas-Gen v1.4.0+<7-char key>`). A published file is never replaced, and the rule changes only through `openspec/specs/binary-builds`.

A consumer that pins commit `C` finds its build like this, in a clone with the history of `C`:

```bash
infra=$(git show "$C:.github/infra-paths" | sed -e '/^#/d' -e '/^$/d' -e '/^\.github\/build-linux\.sh$/d' -e 's/^/:(top,exclude,literal)/')
key=$(git log -1 --format=%H "$C" -- . $infra)
curl -fLO "https://github.com/GeTechG/msdf-atlas-gen/releases/download/builds/msdf-atlas-gen-linux64-$key.tar.gz"
```

and pins the sha256 of that file.

## Specs
`openspec/` holds this fork's own specs (`openspec/specs/`). Behaviour or rule changes go through `openspec/changes/`.
