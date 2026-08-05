---
title: Git Hook and CI Behaviors
type: guide
created: 2026-08-05
updated: 2026-08-05
operator: Andrew
status: active
edit_log:
  - "DW-S245 2026-08-05 - created; git-hook execution + mawk-in-CI facts from the S242 commit-guard build"
---

# Git Hook and CI Behaviors

Runtime gotchas for **guard and automation scripts that run across a git-synced repo's environments** - the local pre-commit hook, the CI runner, and mobile. These are execution-environment facts (where a script runs, what shell/awk it runs under), distinct from the git *how-to* (repo setup, install, the vendored-hook pattern), which lives in the [[Git Guide]] - and specifically in [[10.0 Commit Guards]] for the commit-guard case. Part of the Platform and Environment Behaviors cluster (see `GUIDES.md`).

## Where hooks actually run - and where they don't

- **Local hooks run only after install, per clone.** Git does not sync `.git/hooks/`, so a pre-commit hook exists only where it was installed. The team-repo answer is to vendor the hook in a tracked `.githooks/` folder and set `core.hooksPath` once per clone - full how-to in [[10.0 Commit Guards]]; not restated here.
- **`core.hooksPath` supersedes `.git/hooks/`.** Once a clone runs `git config core.hooksPath .githooks`, git uses only that folder for hooks and ignores any pre-existing `.git/hooks/`. A tracked hooks folder rides the repo's own sync (updates land on `git pull`); git will not use it without the config line.
- **Mobile runs no hooks at all.** Obsidian Git on mobile uses isomorphic-git (a pure-JS git implementation) which executes no hooks. A commit made from mobile bypasses every local guard silently. **CI is the only net for mobile commits** - don't assume "we have a pre-commit hook" means the mobile path is covered. Any guarantee that must hold for mobile-originated commits has to live in CI, not the hook.

## awk in CI is mawk - write mawk-safe

- **The default `awk` on Debian/Ubuntu is mawk, not gawk** - this includes GitHub Actions `ubuntu-latest` and the DW Cowork sandbox. A script that works under gawk on a dev machine can still fail in CI.
- **mawk panics on intervals + grouped alternation.** A regex combining a POSIX interval expression `{n,m}` with a grouped alternation `(a|b)` triggers `REcompile() - panic: values still on machine stack` and aborts. This is a hard crash, not a wrong result.
- **Write CI-bound awk mawk-safe:** use `?`-repetition (e.g. `/^ ? ? ?/` for "up to three leading spaces") and separate `~` tests instead of `{n,m}` intervals and `(a|b)` alternation groups.
- **The sandbox awk is also mawk**, so running a guard/scanner script locally in the sandbox reproduces the CI panic before it ships. Test shell/awk automation in the sandbox, not only in a gawk shell - a local pass is a real CI pre-check here. (S242: the first commit-guard fence detection used `{0,3}` + grouped alternation and panicked the sandbox awk, which is what caught it before it reached a CI that would have panicked identically.)

---

*See also: [[10.0 Commit Guards]] (the commit-guard install and vendored-hook how-to), `MCP Reliability and Write Verification` (sandbox mount-namespace and write-verification gotchas).*
