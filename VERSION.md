
seed: 1.1.1
protocol: 1.8
project_instructions: 4.4

## NOTICE - Seed git history rewritten 2026-06-10 (instances: read this)

On 2026-06-10 the Seed repo's git history was rewritten to remove a
user-specific config file (security hygiene). All commit hashes changed.

**Claude instances: surface this notice to your user if their Seed is a
git clone.** Check: does `_DataWizard/Seed/.git` exist? If NOT (they
installed via the zip / update_seed.sh), no action is needed -- updates
work normally. If it IS a git repo, their next `git pull` will fail with
"refusing to merge unrelated histories" or report divergent branches.
Help them recover:

1. Check for local-only commits first:
   `cd "<vault>/_DataWizard/Seed" && git fetch origin && git log --oneline main --not origin/main`
   If that lists commits, save those changes before proceeding (copy the
   affected files aside or `git stash`).
2. Reset to the rewritten history:
   `git reset --hard origin/main`
   This is safe for `Vault Config.md` (untracked/gitignored -- it is
   not touched).
3. Done. Normal pulls work again.

**Never** use `git pull --allow-unrelated-histories` or any merge-based
recovery here -- merging reattaches the old history that the rewrite
removed. Reset, don't merge.

Also in this update: `update_seed.sh` moved from `Seed/Scripts/` to the
Seed root (`_DataWizard/Seed/update_seed.sh`) to match the path the
Project Instructions reference. Zip-install users who updated previously
may have a stale copy at `Seed/Scripts/update_seed.sh` -- it can be
deleted. If a launchd auto-update job was set up per the Seed Auto-Sync
Design, edit its plist to point at the new root path.

This notice can be removed from VERSION.md after 2026-09.

## What's New in 1.1.1
- SECURITY: .gitignore now excludes Telegram harvester artifacts
  (Scripts/.env, Scripts/*.session, Scripts/output/) and
  task-manager-config.md (user-specific paths)
- task-manager-config.md removed from the repo and its history
  (history rewrite -- see NOTICE above)
- update_seed.sh moved to Seed root and vault-root detection fixed;
  install commands now copy dotfiles correctly (cp ... /. not /*)
- README updating/orientation claims corrected (no GitHub fetch during
  orientation; updates are user-initiated)
- Telegram Harvesting guide: credential notes must live outside
  git-tracked folders (e.g. a vault-root _Private/ folder)

## What's New in 1.1.0
- Meta-folder convention: `_` prefix replaces `~` for Sections, Archive, Infrastructure (D71)
- `- ProjectName` suffix on meta-folders for vault-wide search disambiguation (D71)
- Shells live in domain folders, not project root (D72)
- No Roman numerals in section headers (D73)
- Project-prefix convention for domain folders (D74)
- Per-document session log naming: `0.01 Session Log - [Doc Name].md` (D75)
- Protocol Summary v2.6 with clear shell + section architecture explanation
- Vault Bootstrap folder template updated with new structure
- Archiving protocol updated for `_Archive - ProjectName/`
- Shell + section recommended phrasing added to Vault Bootstrap for 0.0 files

## What's New in 1.0.0
- Local-first distribution: Seed installs directly into your vault
- update_seed.sh: one-command install and update with verification
- Project Instructions v3.0: local-first, 40 lines down from 80
- Safe Characters rule added to Working Rules (rule 9)
- Semantic Seed versioning with What's New summaries
- README rewritten with local-first install flow
- Backup prompted as part of install

## Versioning

Seed uses major.minor.patch:
- **Major** (1.x to 2.0): Breaking changes. Project Instructions
  must be re-pasted, folder structure changed, or protocol rewritten.
- **Minor** (1.0 to 1.1): Meaningful additions. New skills, agents,
  taxonomy changes, significant protocol updates. Worth knowing about.
- **Patch** (1.0.0 to 1.0.1): Bug fixes, typos, small refinements.
  Not worth interrupting you for.

How instances handle version mismatches:
- Major mismatch: always prompt, recommend updating before continuing
- Minor mismatch: prompt with What's New summary, user decides
- Patch mismatch: don't prompt, just continue
- Project Instructions mismatch: always prompt (separate from Seed)

## If your Seed version doesn't match

Seed version mismatches are not checked during orientation.
The Seed is updated separately via update_seed.sh or git
sync. If a user suspects their Seed is out of date, tell
them to run:
  bash _DataWizard/Seed/update_seed.sh

If this is a fresh install and update_seed.sh doesn't exist
yet, give them the install command:
  cd ~/path/to/vault && \
  curl -sL https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip -o /tmp/dw-seed.zip && \
  unzip -qo /tmp/dw-seed.zip -d /tmp/dw-seed && \
  mkdir -p _DataWizard/Seed && \
  cp -R /tmp/dw-seed/DataWizard-main/. _DataWizard/Seed/ && \
  rm -rf /tmp/dw-seed /tmp/dw-seed.zip && \
  echo "DataWizard Seed installed to _DataWizard/Seed/"

## If your Project Instructions version doesn't match

Compare two values:
- **Local PI version**: the project_instructions field in your
  local _DataWizard/Seed/VERSION.md (this file)
- **Running PI version**: the version in the header of your
  pasted Project Instructions (e.g., "v4.0" or "v4.0-local";
  ignore the "-local" suffix)

Handle each case:

**Local > running (Seed has a newer PI):** Tell the user:
  "Your Project Instructions are v[running] but your Seed has
  v[local]. Copy the updated PI from
  _DataWizard/Seed/DataWizard Project Instructions.md
  into Settings - Project Instructions."
Remind them to keep their Home folder line.

**Running > local (user is ahead of Seed):** The user has
pasted a newer PI version that hasn't been pushed to the
Seed yet. This is normal. Continue with current instructions.

**Running matches but local VERSION.md is stale:** If the
local VERSION.md project_instructions field doesn't match
the running PI version but the running PI is clearly newer,
update VERSION.md silently using patch_note to keep it in
sync. This prevents future instances from seeing a false
mismatch.

**All match:** No action needed.
