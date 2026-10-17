# homebrew-tap: agent index

This is the Homebrew tap for Nock Technologies' two CLI products. Users install
from it with:

```bash
brew install nocktechnologies/tap/nocklock
brew install nocktechnologies/tap/nockguard
```

Homebrew maps the tap name nocktechnologies/tap to this repo
(nocktechnologies/homebrew-tap). The repo is public. It holds no product code:
each formula builds a tagged source tarball of its product repo with Go.

Read `docs/HANDOFF.md` before you start. Add to it before you finish.

## What is here

| Path | What it is |
|---|---|
| `Formula/nocklock.rb` | NockLock formula: builds one binary, `nocklock`. |
| `Formula/nockguard.rb` | NockGuard formula: builds two binaries, `nockguard` and `nockguard-wall`. |
| `.coderabbit.yaml` | Turns CodeRabbit auto-review off. Gander (nock-review) is the reviewer here. |
| `scripts/check-agents-paths.py` | Fails when this file names a repo path that git does not track. |
| `docs/HANDOFF.md` | Pod notes: what changed, what bit us, what is still open. |
| `docs/archive/` | Dated handoffs and retired docs. |
| `CLAUDE.md` | Imports this file for Claude Code. Claude-only notes go there, nothing else. |

There is no changelog, roadmap or architecture doc for the tap itself. The
git log is the changelog (one commit per formula bump). Product changelogs,
roadmaps and designs live in the product repos.

## The one job: bump a formula after a product release

A formula changes only after its product has tagged and published a release.
The product's release runbook owns the trigger and the post-merge smoke:
step 6 of docs/runbooks/release.md in nocktechnologies/nocklock or
nocktechnologies/nockguard.

To bump a formula:

1. Confirm the tag `v<X.Y.Z>` exists on the product repo and points at the
   released main commit.
2. Download the source tarball from the formula's own repo (`<formula>` is
   `nocklock` or `nockguard`) and hash it:

   ```bash
   curl -fsSL -o /tmp/src.tar.gz \
     https://github.com/nocktechnologies/<formula>/archive/refs/tags/v<X.Y.Z>.tar.gz
   sha256sum /tmp/src.tar.gz
   ```

   Check that the URL you hashed is the new `url` line of the formula you are
   bumping, so one product's hash never lands in the other's formula.

   Download it twice, or re-derive the hash already in the formula with the
   same method, and say which in the PR body.
3. Change exactly two lines in the formula: `url` (the new tag) and `sha256`.
   Nothing else, and keep the blank line between them.
4. Branch, commit, open a PR on `main`. Title and squash subject:
   `<formula> <X.Y.Z> (<short summary of the release>)`. The body gives the tag,
   the commit it points at, the hash and how it was computed.
5. After merge, on a Mac (the Mac mini): `brew update`, then install or
   upgrade, `brew test nocktechnologies/tap/<formula>`, `<formula> version`,
   and the product smoke from that product's release runbook. Record the tap
   commit and results in the release handoff.

## Build and test

`brew` is not installed on the Linux build box, so formula checks run on a
Mac with Homebrew:

```bash
brew style nocktechnologies/tap
brew audit --formula nocktechnologies/tap/nocklock
brew install --build-from-source nocktechnologies/tap/nocklock
brew test nocktechnologies/tap/nocklock
```

The docs check runs anywhere with Python 3 and git, from any directory:

```bash
python3 scripts/check-agents-paths.py
```

Run it before every PR that touches this file. It checks backtick spans and
links, not fenced code. In prose, write tap names, product-repo paths and
version strings without backticks, or with a `<placeholder>`. CI runs the same
check on every PR and push to main:
[.github/workflows/agents-paths.yml](.github/workflows/agents-paths.yml), one
job on a GitHub-hosted runner (free on this public repo), read-only, no
secrets. It is the only workflow. Never add a self-hosted runner here.

## Rules an agent cannot guess

- **The URL tag is the version.** Neither formula has a `version` stanza;
  Homebrew parses it from the tarball URL. Change `url` and `sha256`
  together, never one alone.
- **Hash the tarball you downloaded.** The `sha256` is of GitHub's
  `archive/refs/tags/v<X.Y.Z>.tar.gz`, not of a release asset. NockGuard also
  publishes per-platform archives with a `SHA256SUMS` file; those hashes are
  for the archives and do not go in this formula.
- **The two test blocks check different strings.** NockLock prints
  `NockLock v<version>`; NockGuard prints `nockguard v<version>`. Do not
  normalise the case in either `test do` block.
- **The version gets into each binary differently.** NockLock injects it at
  build time with `-X github.com/nocktechnologies/nocklock/internal/version.Version=#{version}`
  in the formula's ldflags; drop that and `nocklock version` prints
  `NockLock (dev)`, so `brew test` fails. NockGuard hardcodes it in its own source (cmd/nockguard/main.go
  in the product repo), so its formula has no `-X` flag. If that string was
  not bumped before the tag, `brew test` fails; fix it in the product, not
  here.
- **NockGuard installs two binaries.** `nockguard-wall` is built with
  `output: bin/"nockguard-wall"` and the test checks it is executable. Keep
  both `go build` lines.
- **Each formula is bumped alone.** One formula per PR, even when both
  products release on the same day.
- **No formula logic changes in a bump PR.** A `url` and `sha256` bump is
  Tier 0. Anything else (build flags, deps, tests) is its own card.
- **Linux gets only the CLI.** On Linux, Homebrew installs just the binary;
  NockLock's network fence and privileged helper need the source install in
  its setup docs. Do not add Linux packaging here.
- **The worktree may hold an untracked dotenv symlink.** Dispatch worktrees
  link one into the crm-mira checkout. The repo has no gitignore file, so stage
  files by name; never `git add -A`.

## Branches, review and merge

- Default branch: `main`. There is no `next` branch here, unlike the product
  repos. Every change is a PR from a fresh branch onto `main`.
- Gander reviews (Opus and Sol lenses). Rowan gates and squash-merges at the
  reviewed head. Builders do not merge their own PRs.
- Commit messages and PR text carry no agent, model or tool attribution.
- Release gates for tap bumps come from the product's release owner (for
  example Mira's approval of the full release sequence, tap included).

## Pod

The NockLock/NockGuard pod owns this repo.
