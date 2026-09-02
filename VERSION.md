
seed: 1.6.1
protocol: 1.8
project_instructions: 4.6

## NOTICE - Seed git history rewritten 2026-06-10 (instances: read this)

On 2026-06-10 the Seed repo's git history was rewritten to remove a
user-specific config file (security hygiene). All commit hashes changed.

**Claude instances: surface this notice to your user if their Seed is a
git clone.** Check: does `_DataWizard/Seed/.git` exist? If NOT (they
installed via the zip / update_seed.sh), no action is needed -- updates
work normally. If it IS a git repo, their next `git pull` may fail with
"refusing to merge unrelated histories" or report divergent branches.

**Recovery (rewritten 2026-08-31, remote-agnostic):** do not run any
reset straight from this notice. Follow the single safe procedure in
`Seed/Guides/Git Guide/7.0 Safety and Recovery.md`, section
"Recovering a Seed Clone (Remote-Agnostic)". In brief:

0. Back up first, unconditionally: `git branch backup/pre-recovery-<date>`,
   plus `git stash -u` if the tree is dirty.
1. Identify the canonical remote BY URL
   (`github.com/andrewalan11/DataWizard`), never by the name `origin`.
   On a fork-shaped clone (`origin` = a personal fork, `upstream` =
   canonical), `reset --hard origin/main` silently rolls the Seed back
   to the fork's stale state while every check looks clean -- this
   nearly downgraded a collaborator's Seed on 2026-08-30.
2. `git fetch <canonical> --prune`
3. `git merge --ff-only <canonical>/main` -- fails closed, can never
   lose a commit. If it succeeds, you are done.
4. Only if ff-only refuses AND the guide's triage confirms unrelated
   histories from this rewrite: `git reset --hard <canonical>/main`,
   human-reviewed. No reset runs on one Claude instance's say-so --
   propose on paper and get a second instance's review first
   (Weave D39; DW D109). `Vault Config.md` is untracked/gitignored
   and is not touched either way.

**Never** use `git pull --allow-unrelated-histories` or any merge-based
recovery here -- merging reattaches the old history that the rewrite
removed. (A fast-forward is not that kind of merge: `--ff-only` creates
no merge commit and cannot reattach anything.)

Also in this update: `update_seed.sh` moved from `Seed/Scripts/` to the
Seed root (`_DataWizard/Seed/update_seed.sh`) to match the path the
Project Instructions reference. Zip-install users who updated previously
may have a stale copy at `Seed/Scripts/update_seed.sh` -- it can be
deleted. If a launchd auto-update job was set up per the Seed Auto-Sync
Design, edit its plist to point at the new root path.

This notice can be removed from VERSION.md after 2026-09. The recovery
procedure itself lives durably in Git Guide 7.0 ("Recovering a Seed
Clone (Remote-Agnostic)") and survives this notice's retirement.

## What's New in 1.6.1

**Windows updater unbroken (`update_seed.ps1`).** A single em dash on the
sync-log line made the entire script unparseable under Windows PowerShell
5.1: with no BOM, PS 5.1 reads `.ps1` files as ANSI, the em dash's bytes
(E2 80 94) decode to `a`+`euro`+curly-quote, and PowerShell accepts curly
quotes as string delimiters - the literal closes early and the parse
collapses. Shipped broken in 1.2.0 (2026-08-15), so **no Windows operator
has been able to run any Seed update or install auto-sync since** -
silently (a script that never parses writes no Sync Log line). Diagnosed
by Jay's instance (WV_2026-09-02_JC_02); verified byte-level on the
maintainer clone (DW S325).

**IMPORTANT - Windows installs at 1.6.0 or below cannot self-update to
get this fix** (the broken script IS the update path). One-time manual
re-download, from the vault root in PowerShell:

    Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/andrewalan11/DataWizard/main/update_seed.ps1 -OutFile "_DataWizard\Seed\update_seed.ps1"

then run the updater normally (add `-InstallAutosync` if the
"DataWizard Seed Update" scheduled task was never created).

**All Seed shell scripts are now pure ASCII.** Em dashes in
`update_seed.sh` and `Scripts/datawizard-*.sh` replaced too - cosmetic
there (bash tolerates UTF-8), but the same defect class. Standing rule:
scripts that ship in the Seed stay ASCII-only; a non-ASCII byte in a
BOM-less `.ps1` is a parse-time landmine on Windows.

## What's New in 1.6.0

**Operator Gate Queue codified.** The deployment-gate tracker - built-or-decided work waiting on a specific actor to bring it live - graduates from pilot to canon after two full exit ceremonies in the field. The **Conventions Registry** gains three entries: **Operator Gate Queue** (lifecycle vocabulary `designed -> built -> installed -> verified-live`, parser-first G-row schema, feeding-at-close, verify-a-gate's-live-state-before-working-it, the exit ceremony into the project registry), **Active Threads ledger row schema** (seven fields; `next:` holds current state only, ~5 lines, pointing at the driver doc or State Board - link-don't-restate applied to the ledger itself), and **Model routing** (the single home for the tier heuristic: high-capability default; highest tier for synthesis, audits, reviews, canon writes; fast tier for mechanical batches) - plus a deployment-gate row in the Tracking Model fact-class table.

**session-closer v4.7.0**: Step 4 gains the gate-queue feeding bullet (anything built but not verified-live gets a gate row when the actor is specific; `unverified` is named honestly, never pending-success); Step 4.5's model line points at the Registry instead of restating the heuristic; Step 2.6 handles sectioned ledgers (a shell of per-arc embed files - patch the arc's file, never the shell).

**New: `Seed/Templates/Operator Gate Queue - Template.md`** - a depersonalized starter queue (classes A-F, Parked, Deployed, one example row), cataloged in GUIDES.md. First template in the new `Seed/Templates/` folder.

## What's New in 1.5.0

**supervised-build skill (new).** The Coordination Patterns guide's Pattern 4 - the per-chunk review relay between a build session and a reviewer instance - codified as a skill after four field runs (the guide's own codify-on-second-use rule, overdue by two). One `SKILL.md`, two seats: the build session gets the **review gate as a hard step** (before writing chunk N, a `status: reviewed` note covering it must exist in Session Exchange; if absent, pause and ask - skipping review is a conscious operator choice on the record, never a silent omission), and the reviewer gets the verification discipline (verify on disk, never from reports; test shipped scripts by *running* them on scratch fixtures outside the vault; ask for the class rule, not the special-case fix) plus the **mandated State Board write**: a fixed five-field block (status / verified / next_gate / turn / blocking) updated after every delivered review, so a fresh instance can answer "where are we at on this arc" from the driver doc alone. The guide keeps the rationale and the transport conventions and now points at the skill; the field shape lives in the skill.

## What's New in 1.4.0

**Synthesis provenance - Phase 1: block citation extends to all generated docs.** Block-level citation (D112) now spans every document generated under DW protocols, not only companion notes - design docs, reports, decision entries, session-log entries, exchange reviews, and Seed plants. Granularity follows the **evidence unit, not the document class**: a paragraph or turn takes a block stamp (`^bN`/`^tN`), a whole section takes a section anchor.

- **Conventions Registry** citation section gains generated-docs + obligation tiers, evidence-vs-edit-provenance-root (two syntaxes, one meaning each), the reach rule and metadata exemption (a stamp does not bump `updated:` or `edit_log`), block-ID tolerance (reuse any trailing block ID, human-minted included), and "Seed text may carry block IDs."
- **block-stamper skill v2**: the non-source exclusion is retired for the evidence-unit rule; adds reach, stamp-before-cite, verify-after-claim collision guard, ID tolerance, the metadata exemption, and the script handoff.
- **`Scripts/stamp_blocks.py`** (new): an on-cite block stamper - byte-faithful (append to the target line only), stdlib, Python 3.8+, with `--manifest`/`--file`/`--dry-run`/`--verify`, atomic write, and BOM handling. The batch executor twin of the skill; runs natively in Claude Code / GitHub Actions and through the device shell under Cowork. Regression fixtures ship beside it in the consuming vault's test area.
  Block boundaries follow CommonMark element starts (heading, fence, rule, setext underline, blockquote, table row, list item), so prose directly above any of them is stamped on its own last line, never on the structural line; outcomes report the target line (`@L<n>`) because `--verify` confirms only that an ID landed where intended, not that the intended line was right.

No protocol or Project Instructions change. The extension is recorded as decision entries in the consuming vault; Phase 2 (an outward-facing one-pager as the first production customer) is the next phase.

## What's New in 1.3.1

**Auto-sync self-overwrite fix (`update_seed.sh`).** The updater
replaced itself on disk mid-run: the zip-mode `cp` and the git-mode
`merge --ff-only` both overwrite `update_seed.sh` while bash is still
reading it by byte offset, so execution resumed inside the freshly
written file -- surfacing as a spurious `UNINSTALL_AUTOSYNC: unbound
variable` at line 122 (the tell: the "Downloading..." message printed
first, the line-122 error arrived after). Fixed by wrapping the whole
script body in a `main()` function invoked on the last line, so bash
parses to EOF before any file-replacing command runs -- removing the
dependence on file size entirely. Diagnosed by Tree's instance
(DreamVault), 2026-08-20. The bash-only fix is version-gated behind
this 1.3.1 bump so zip-mode installs (which skip when versions match)
actually pick it up. Note: the *last* run of an old unwrapped script --
the one that copies 1.3.1 into place -- still crashes on its own bug
mid-copy (a one-time syntax error, and no sync-log line for that run).
That is expected and self-correcting: the Seed is already at 1.3.1, and
the next run (the new script) clears `/tmp` and logs "Already current."

**Zip-over-git self-heal.** A clone that a past zip-mode run copied
over without committing is left dirty-but-byte-identical to
`origin/main`, and the git-mode dirty guard then skipped forever
(exit 3, every run, no sync log ever written). The updater now fetches
first and, when the tree is dirty but provably lossless to reset (no
local commits ahead AND working tree already equal to `origin/main`),
self-heals with `git reset --hard origin/main`. Genuine local edits
are still refused -- now with the recovery command named in the
SKIPPED message.

`update_seed.ps1` needed no change: PowerShell parses the whole script
before executing (no self-overwrite), and it already refuses zip-sync
on a git clone.

## What's New in 1.3.0

**Team flags are deliverable as of this release.** The Flag Surfacing
Chain Phase 1 (read side) ships the machinery that surfaces `flag_for`
items to their addressees -- a system previously measured at 0% delivery
because only the write side existed.

- **Flag ship date: 2026-08-18.** The session-closer's flag expiry pass
  (Step 3.13) applies ONLY to flags set on or after this date. Flags
  that predate it are a pre-existing backlog: triage them in a dedicated
  session, never mass-expire them (they were set when delivery was
  broken -- expiring them as "unread" would falsify the record).
- **Project Instructions v4.6** -- new Orientation Step 6: the unified
  orientation sweep (flag sweep on multi-operator projects, stale-stub
  reconciliation, intake what's-new) with an unconditional compliance
  trace written into the claim stub. **Re-paste required:** copy the
  updated PI from `Seed/DataWizard Project Instructions.md` into each
  project's Cowork Settings (or refresh your CLAUDE.md import) --
  instruction shipped is not instruction loaded, and an operator whose
  surface still runs v4.5 has no working flag delivery. Instances: the
  version-mismatch protocol below handles the prompt.
- **YAML Schema Section 4** reconciled to the `flag*` cluster as
  canonical (`team_attention*` deprecated, mapping included); new
  `flag_due` / `flag_default` / `flag_status` fields and a `flag_note`
  content requirement.
- **session-closer v4.6.0** -- flag anatomy at set-time, 2-3 flag
  budget per close, the expiry pass (sole automatic writer of
  `expired-unread`), sweep-trace carry-forward, and the lean approval
  gate (write directly for routine closes; three judgment-class
  stop-and-asks kept).
- **Three new/updated guides:** `Orientation Flag Sweep - Query Spec`
  (the sweep query, four corrections, named constants),
  `Team Attention Rollout` (per-person canary live test, four-branch
  diagnosis tree, executor chain -- read this before turning flags on
  in a team project), and `Flag Queue Page Template` (per-person
  Dataview queue page, empty-due-last sort).

## What's New in 1.2.0
- One-command Seed auto-sync: `update_seed.sh --install-autosync` (Mac,
  launchd) / `update_seed.ps1 -InstallAutosync` (Windows, Task Scheduler).
  Daily check at 6:00 (configurable via --hour / -Hour) plus at login,
  with catch-up when the machine wakes - it does not need to be awake at
  the scheduled hour. Remove with --uninstall-autosync / -UninstallAutosync.
- update_seed.sh is now git-clone aware: a cloned Seed syncs via
  git fetch + fast-forward merge and is never clobbered when local
  edits or local commits exist (skip is logged instead).
- Upstream guard: a `seed_role` row containing `upstream` in Vault
  Config.md makes both scripts refuse to sync or install auto-sync
  (protects the maintainer's Seed, which pushes rather than pulls).
- session-closer v4.5.0: at close, the orientation stub is overwritten
  in place with the final entry and renamed (write + move) instead of
  deleted - no more destructive-op permission prompt for the stub.
- Seed Install and Update guide rewritten around the one-command
  auto-sync flow; README Updating section points to it.

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
