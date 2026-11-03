## 1. Pin and skills

- [x] 1.1 `openspec/cli.pin` = `1.16.0`; checked by `cat openspec/cli.pin` and `openspec --version` agreeing
- [x] 1.2 Skills generated with `openspec init --tools claude,codex --profile custom` (propose, explore, continue, apply, update, ff, sync, archive, bulk-archive, verify) into `.claude/skills/` and `.agents/skills/`; `.claude/` and `.agents/` added to `.github/infra-paths`; checked by `grep generatedBy` and `check-commit-kinds.sh`

## 2. Rules

- [x] 2.1 `openspec/config.yaml`: `rules.specs`, `rules.tasks`, `operations.apply` / `operations.archive` guidance pointing at `AGENTS.md`; checked by `openspec instructions specs|tasks|apply` showing them
- [x] 2.2 `AGENTS.md`: the pin and its bump order, the skills, `openspec new change`, the `openspec` check; checked by reading it against this change

## 3. CI

- [x] 3.1 `ci.yml`: `openspec` job running the pinned CLI — strict validation, Purpose placeholder, `.openspec.yaml` in active changes, `generatedBy` against the pin, open non-`[human]` archived tasks; checked by running each step locally, and on a scratch tree that breaks each rule once
- [x] 3.2 The job is green on the branch; checked on GitHub Actions

## Workflow follow-up

- Sync the spec, archive the change as the last commit of the branch, merge into `master`.
