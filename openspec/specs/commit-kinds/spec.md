# commit-kinds Specification

## Purpose
Keep every commit either upstreamable code or fork infrastructure, so an upstream PR is a cherry-pick of one task's code commits.

## Requirements

### Requirement: A commit is code or infrastructure, never both
Infrastructure is the set of paths listed in `.github/infra-paths` (paths absent from upstream); every other path is code. CI SHALL reject any non-merge commit that touches both kinds.

#### Scenario: Mixed commit
- **WHEN** a commit changes `msdf-atlas-gen/main.cpp` and `AGENTS.md`
- **THEN** the `commit-kinds` CI job fails and names the commit

#### Scenario: Single-kind commit
- **WHEN** a commit changes only code paths, or only infrastructure paths
- **THEN** the check passes

### Requirement: The check proves itself
`.github/scripts/check-commit-kinds-test.sh` SHALL build a throwaway repository with a mixed commit and fail unless the check rejects it; CI runs it before the real check.

#### Scenario: The check stops rejecting mixed commits
- **WHEN** `check-commit-kinds.sh` accepts the mixed commit of the throwaway repository
- **THEN** the self-test fails, and the `commit-kinds` CI job fails before the real check runs

### Requirement: OpenSpec artifacts stay out of code commits
Proposals, tasks, spec deltas and archives live under `openspec/`, an infrastructure path, so they SHALL never share a commit with code.

#### Scenario: Change proposal alongside its implementation
- **WHEN** a task adds `openspec/changes/x/proposal.md` and changes `msdf-atlas-gen/main.cpp`
- **THEN** they land as two commits, and only the code commit is cherry-picked upstream
