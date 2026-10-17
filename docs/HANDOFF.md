# homebrew-tap pod notes

Read this before you start. Before you finish, add what changed, what bit you
and what is still open, and remove anything no longer true. Keep it short.
Move dated handoffs to `docs/archive/`.

## What changed

- 2026-10-17, Nock 11953: added `AGENTS.md` (agent index), `CLAUDE.md`
  (imports it), this file, `docs/archive/` and
  `scripts/check-agents-paths.py`, run in CI by
  `.github/workflows/agents-paths.yml`. No formula changed.
- 2026-10-17: Formula/nocklock.rb at v0.12.0 (PR 1),
  Formula/nockguard.rb at v0.10.0 (PR 2). Post-merge brew test and smoke
  run on the Mac mini, per each product's release runbook.

## What bit us

- The path checker flagged brew tap names inside fenced commands as missing
  repo paths, so it now skips fenced code. See `AGENTS.md` for how to write
  non-repo paths in prose.

## Still open

- Nothing from Nock 11953. The path check is the only CI; formulas are still
  checked by hand with brew audit and brew test (see `AGENTS.md`).
