---
title: Git Hook and CI Behaviors
type: guide
created: 2026-08-05
updated: 2026-09-06
operator: Andrew
status: active
edit_log:
  - DW-S245 2026-08-05 - created; git-hook execution + mawk-in-CI facts from the
    S242 commit-guard build
  - DW-S280 2026-08-20 - added self-updating-scripts (main() wrap for
    self-overwrite) and synced-working-tree-vs-remote compare (throwaway
    read-tree index) behaviors, from the update_seed.sh fix
  - "DW-S284 2026-08-24 - shell portability section: GNU/BSD stat chain with
    numeric guard, bash 3.2, verify with bash -x on the real script (S252;
    meta-learning review S247-S255)"
  - DW-S337 2026-09-06 - added the every-self-replacing-path verify bullet
    (zip-mode guard confirmed by run-don't-read; post-fix recurrence = unwrapped
    stale/hybrid running copy). FR item 5.
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

## Shell portability: stat, bash 3.2, and the verification harness

- **`stat` differs between GNU and BSD.** A script that ships to other machines must not assume either. Use the GNU-first fallback chain `stat -c %Y "$X" 2>/dev/null || stat -f %m "$X" 2>/dev/null || echo 0`, and validate the result is numeric before doing arithmetic on it - a silent non-numeric value turns a lock-age check into a no-op.
- **macOS `/bin/bash` is 3.2.** Anything written against bash 4+ (associative arrays, `${var,,}`, `mapfile`) fails on a stock Mac. Also expect the operator's interactive shell to be zsh.
- **Verify guard and lock logic on the real script, not only a wrapper harness.** A test harness can false-negative under bash 3.2 while the script under test is fine (or the reverse). Run `bash -x` on the actual script with the real inputs and read the trace; the harness is a convenience, not the evidence. (DataWizard, 2026-08)

## Self-updating scripts overwrite themselves mid-run

- **A script that replaces its own file on disk while still executing can crash or misbehave in ways that look unrelated to the cause.** The shell reads a script from disk incrementally, tracking position by byte offset. If the running file is replaced mid-execution - an updater that copies a new copy of itself over the old one, or a `git merge --ff-only` / `git reset` that rewrites the script file - the shell keeps reading at the same offset, now inside a different file of a different length, and resumes mid-statement in unrelated code. The classic tell: an "unbound variable" or syntax error naming a line the running code never reached, printed *after* output from a later point in the script (the error is from the new file; the execution came from the old one).
- **Fix: wrap the whole executable body in a function invoked on the last line.** `main() { ... }` then `main "$@"`. The shell must parse through to the closing brace before it can run `main`, so the entire script is in memory before any self-replacing command executes - the fix is independent of file size. No re-indentation needed; the shell ignores indentation inside the function. Keep `set -euo pipefail` (or equivalent) above the wrap so options apply, and use `exit` inside `main` as normal (status propagates through the one call frame).
- **Streamed-from-disk interpreters only.** POSIX sh/bash stream the script, so they are exposed. Interpreters that parse the whole script to an AST before executing (e.g. PowerShell) are immune and need no wrap - worth confirming per interpreter rather than wrapping reflexively.
- **The last pre-fix run is unavoidable.** A machine still running the old unwrapped script will crash on its own bug during the update that installs the wrapped version (it copies the fix into place, then resumes into it). Every run after that is safe. Nothing can retroactively protect already-installed old copies; the fix stops recurrence, it does not rescue the transition run.
- **Verify the wrap covers every self-replacing path, not just one.** A wrapped updater is safe only if the *whole* body is inside the function - both the zip-mode file copy and any git-mode `merge --ff-only` / `reset` that rewrites the script. Confirmed by running the shipped updater through an actual zip-mode self-overwrite, including a run where the running copy was longer than its replacement (a length change would expose any residual byte-offset seek): it completed cleanly, exit 0, no error. If the transient syntax error still appears on a supposedly post-fix update, the diagnosis is that the *running* (old) copy on that machine was never actually wrapped - a stale or hybrid copy predating the fix - not a regression in the current script; it self-corrects on the next run. (DataWizard, 2026-09)

## Comparing a synced working tree to the remote before a self-reset

An updater that wants to decide whether a dirty working tree is safe to hard-reset to the remote (a lossless "the tree already matches origin" case, e.g. after a prior copy-over-clone left it dirty-but-identical) must not use a plain `git diff --quiet origin/main`.

- **`git diff <commit>` only compares paths that are in the index.** Any file the remote *added* is present on disk but untracked locally, so `git diff origin/main` reports it as *deleted* - the diff is non-empty and the "already matches" check fails, refusing the exact case it was meant to allow. Since real releases usually add files, this misfires in the field even when a same-version fixture passes.
- **Correct check: diff the working tree against a throwaway index loaded from the target commit,** so every path in the target is compared (tracked or not) while the user's own extra untracked files are ignored:

```bash
tmp="/abs/path.index"; rm -f "$tmp"
GIT_INDEX_FILE="$tmp" git -C "$repo" read-tree origin/main \
  && GIT_INDEX_FILE="$tmp" git -C "$repo" diff --quiet
rm -f "$tmp"
```

- Details that matter: `GIT_INDEX_FILE` is resolved from the process cwd (not `-C`), so it must be **absolute**; `rm -f` before `read-tree` (git rejects a zero-byte index file); `git diff --quiet` with no revision compares the temp index to the working tree *and refreshes stat info*, so content is compared - `git diff-files` without a refresh would report every file as modified. The real index is never touched. Still gate the reset on "no local commits ahead" separately - a matching working tree with local commits would lose those commits on reset.

---

*See also: [[10.0 Commit Guards]] (the commit-guard install and vendored-hook how-to), `MCP Reliability and Write Verification` (sandbox mount-namespace and write-verification gotchas).*
