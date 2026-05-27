
seed: 1.1.0
protocol: 1.7
project_instructions: 4.0

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
  cp -R /tmp/dw-seed/DataWizard-main/* _DataWizard/Seed/ && \
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
  _DataWizard/Seed/Project Instructions - Copy-Paste into Claude.md
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
