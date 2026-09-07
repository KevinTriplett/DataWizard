#!/usr/bin/env bash
#
# Install the DataWizard commit guard into a clone's .git/hooks/.
# Run this ONCE per clone -- git hooks live in .git/hooks/, which is not synced,
# so every operator on a shared repo has to install it on their own machine.
#
# Usage:
#   bash install-git-hooks.sh [path-to-repo]
#
# With no argument it installs into the repo containing the current directory.
#
# Re-run after a Seed update to pick up an updated hook.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hook_src="$script_dir/hooks/pre-commit"

repo="${1:-$(git rev-parse --show-toplevel 2>/dev/null || true)}"
if [ -z "${repo:-}" ] || [ ! -d "$repo/.git" ]; then
  echo "Not a git repository: ${repo:-<none>}" >&2
  echo "Pass the repo path explicitly:  bash install-git-hooks.sh /path/to/repo" >&2
  exit 1
fi
if [ ! -f "$hook_src" ]; then
  echo "Hook source not found: $hook_src" >&2
  exit 1
fi

# Keep the SYNC-BLOCKED.md breadcrumb out of git (per-clone, no tracked-file edit)
exclude="$repo/.git/info/exclude"
mkdir -p "$repo/.git/info"
touch "$exclude"
grep -qxF 'SYNC-BLOCKED.md' "$exclude" || echo 'SYNC-BLOCKED.md' >> "$exclude"

# core.hooksPath guard: when a repo routes hooks to a tracked folder (the
# shared-team alternative in Git Guide 10.0), git ignores .git/hooks/ entirely,
# so copying there would report "Done" while changing nothing that runs.
# Refuse and say where the live hook is instead (found on a maintainer repo, DW S336).
hooks_path="$(git -C "$repo" config core.hooksPath 2>/dev/null || true)"
if [ -n "$hooks_path" ]; then
  case "$hooks_path" in /*) live="$hooks_path/pre-commit" ;; *) live="$repo/$hooks_path/pre-commit" ;; esac
  echo "NOT installed: this repo sets core.hooksPath=$hooks_path, so git ignores .git/hooks/." >&2
  echo "The hook git actually runs is: $live" >&2
  echo "Update that tracked file to match $hook_src (commit it in the repo), or unset core.hooksPath first." >&2
  exit 2
fi

hooks_dir="$repo/.git/hooks"
mkdir -p "$hooks_dir"
cp "$hook_src" "$hooks_dir/pre-commit"
chmod +x "$hooks_dir/pre-commit"

echo "Installed commit guard  -> $hooks_dir/pre-commit"
echo "Excluded SYNC-BLOCKED.md via .git/info/exclude"
echo
echo "Done. The guard now runs on every commit in this clone."
