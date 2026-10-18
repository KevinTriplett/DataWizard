---
title: VERSION History
type: guide
created: 2026-10-18
updated: 2026-10-18
operator: Andrew
origin: DW-S421 2026-10-18 - What's New entries 1.0.0 to 1.5.0 moved from VERSION.md word for word (size rotation, archivist rule)
edit_log:
  - DW-S421 2026-10-18 - created
---

# VERSION History

Older "What's New" entries of the Seed, moved here from `VERSION.md` word for word. The current version and the newer entries are in `VERSION.md`. When `VERSION.md` passes about 50 KB again, move its oldest entries to the top of the list below, newest first, and leave the pointer in `VERSION.md`.

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
