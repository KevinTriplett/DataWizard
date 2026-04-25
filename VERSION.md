
seed: 1.0.0
protocol: 1.7
project_instructions: 3.4

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

Compare the seed value above against your local
_DataWizard/Seed/VERSION.md. If they don't match, tell
the user what changed (read the What's New section) and ask:
  "Your Seed is v[local] but v[current] is available.
  Here's what's new: [summary]. Want to update?"

If yes, tell them to run:
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

Your version is in the header of your pasted instructions
(e.g., "v2.8" or "v2.8-local"). Compare against the
project_instructions value above (ignore "-local" suffix).

If they don't match, tell the user:
  "Your Project Instructions are v[yours] but the current
  version is v[current]. Want me to fetch the latest so
  you can update?"
If yes, fetch the full file from:
  https://raw.githubusercontent.com/andrewalan11/DataWizard/main/COPY%20INTO%20CLAUDE%20PROJECT.md
Print the paste block (between the ``` fences) in full so
the user can copy it into Settings - Project Instructions.
Remind them to keep their Home folder line.
If no, continue with current instructions.
