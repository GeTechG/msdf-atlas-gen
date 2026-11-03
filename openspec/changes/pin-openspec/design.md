## Context

The machine has one global OpenSpec CLI (`npm i -g @fission-ai/openspec@<version>`), shared by Sprout and every
fork. The repository has to say which version its artifacts and skills belong to, and CI has to check with
that version rather than whatever is current.

## Decisions

- **Pin as a one-line file.** `openspec/cli.pin` holds the bare version. The repo has no `package.json`, and
  adding one only to pin a tool would put a Node project into an upstream C++ tree. CI runs
  `npm exec --yes --package=@fission-ai/openspec@$(cat openspec/cli.pin) -- openspec …`.
- **Two generated skill trees, not a symlink.** `openspec init --tools claude,codex` writes a Claude Code
  variant into `.claude/skills/` and a Codex variant (`$skill` invocation syntax) into `.agents/skills/`.
  Committing what the generator writes keeps `openspec update` a plain regenerate-and-commit.
- **Checks inline in `ci.yml`.** One job, one step per check, each failing with a `::error::` naming what is
  wrong. Node 24 via `actions/setup-node` (OpenSpec 1.16 needs Node ≥ 22.12).
- **Archived tasks are checked by grep**, not by `openspec validate --archived`, which also reports unticked
  `[human]` tasks — those are allowed to stay open.
- **`config.yaml` guidance points at `AGENTS.md`** instead of restating its steps, so it cannot drift.

## Risks / Trade-offs

- The pin and the global install can diverge on a machine → the skills check fails in CI on the first commit
  that regenerates skills with another version; `AGENTS.md` names the bump order.
