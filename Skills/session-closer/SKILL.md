---
name: session-closer
description: >-
  Use at the end of every session to write the session log entry. Triggers on:
  'let's wrap up', 'close out the session', 'write the session log', 'we're done
  for today', end of any work session. Also triggers when the user says 'let's
  pick up where we left off' in a new thread and there's no log entry for the
  previous session.
type: skill
updated: '2026-10-19'
origin: 'DW-S158 2026-06-08 - backfilled from the earliest edit_log entry (D127)'
version: '4.11.1'
edit_log:
  - 'DW-S424 2026-10-19 - v4.11.1: Step 3.10 also surfaces pending Look-Back Reports (session look-back scan, leak prevention fix 3)'
  - 'DW-S422 2026-10-18 - v4.11.0: landing rule - Step 4 action-items bullet made a required landing rule with one dated Waiting-on checklist; Step 2.6 ledger next: is the owed list; Step 3.5 tracking-claim verification; Step 0 lite list; output-format landing check and Waiting-on pointer; Common Mistakes bullet (leak prevention fix 1)'
  - 'DW-S422 2026-10-18 - v4.10.4: sectioned - output templates, multi-operator flag steps, no-ledger roster, triage guidance and old edit_log moved verbatim to references/; steps unchanged'
  - 'DW-S402 2026-10-13 - v4.10.3: Step 3.14 board asks posted at write time; close verifies and backfills (B-0081)'
  - 'DW-S400 2026-10-12 - v4.10.2: Step 3.8 link-resolution check (dw_lint C5 or find recipe)'
---

# Session Closer Skill

Reference files sit in `references/` beside this file. Read one only when a step says so. Claude Code / Sidecar: use the relative path. Cowork (Obsidian MCP): `_DataWizard/Seed/Skills/session-closer/references/<file>.md`.

## Overview

Writes the session log entry at the end of every work session. The session log entry is the primary handoff mechanism — the next instance reads it during orientation and picks up where this session left off. There is no separate handoff briefing. The session log IS the handoff.

## When to Use

- End of any session (user says "let's wrap up," "close out," "write the session log," "we're done")
- At a natural break point when the user wants to capture progress before continuing
- If you notice the session has done significant work and no log entry has been written yet

### When NOT to Use

- Mid-session status updates (just talk in chat)
- Updating action items only (do that as part of closing, or separately)

## Session Identifier Format

Session identifiers vary by project type. Check the project's 0.0 Project Guidelines -- if it lists multiple operators, use multi-operator format.

**Solo-operator projects:** Sequential numbering.
- Session ID: `S{N}` (e.g., `S113`)
- File name: `NN.0 Session N - Brief Title.md` (e.g., `99.0 Session 113 - Brief Title.md`)
- Heading: `## Session N: YYYY-MM-DD (Brief Title)`
- Frontmatter title: `"Session N - Brief Title"`
- Frontmatter section: `N` (integer)
- Edit log entry: `ProjectAbbrev-S{N} YYYY-MM-DD` (e.g., `DW-S113 2026-06-10`)
- Thread name: `checkmark ProjectAbbrev SNN - description`

**Multi-operator projects:** Composite ID encoding project, date, operator, and daily sequence.
- Format: `PROJ_YYYY-MM-DD_INITIALS_NN`
- `PROJ` -- project abbreviation (e.g., `WV` for Weave)
- `YYYY-MM-DD` -- session date
- `INITIALS` -- operator's initials from the operator registry in 0.0 Project Guidelines
- `NN` -- daily sequence number, always two digits, starting at `01`, present even for the first session of the day
- File name: `WV_2026-06-10_AA_01 - Brief Title.md` (session ID as prefix, no section number)
- Heading: `## WV_2026-06-10_AA_01: Brief Title`
- Frontmatter title: `"WV_2026-06-10_AA_01 - Brief Title"`
- Frontmatter section: `"WV_2026-06-10_AA_01"` (the full session ID as a string)
- Edit log entry: `WV_2026-06-10_AA_01` (date is embedded, no need to repeat)
- Thread name: `checkmark WV_2026-06-10_AA_01 - description`

To claim a session ID during orientation, list the session log folder for files matching today's date and your initials (e.g., `WV_2026-06-10_AA_*`), and pick the next NN.

Throughout this skill, examples use solo-operator format. For multi-operator projects, substitute the corresponding format from this section.

## How to Close a Session

### Step 0: Choose the close tier

Pick **lite** or **full**, and state which you chose (D98).

- **Lite close** -- for sessions with no new conventions, no harvest, and few file touches. Do only: the log entry (What happened / Learnings-if-any / What's next), the landing rule for the previous What's next (Step 4, first bullet), frontmatter validation (Step 2.5), write + embed (Step 3, including the section-shell sync), metadata verification (Step 3.8), and the thread name (Step 5). Skip the knowledge-transfer / convention / residual triage (Steps 3.5-3.7; keep the tracking-claim verification in Step 3.5, the landing rule needs it), the pending-review report check (Step 3.10), the file-size check (Step 3.11), the team-flag prompt (Step 3.12), and the flag expiry pass (Step 3.13) -- the lite preconditions make these no-ops. You may still check off an action item you completed.
- **Full close** -- everything below. Use it whenever the session established or changed a convention, did harvest, made decisions, or touched many files.

When in doubt, go full. State the chosen tier in one line before proceeding (e.g. "Closing S196 as a full close -- touched the closer skill plus several infra files").

### Step 1: Review the session

Scan the conversation for:
- What was accomplished (files created, modified, moved, decisions made)
- What was discussed but not yet acted on
- Any problems encountered and how they were resolved
- Patterns discovered, assumptions confirmed or invalidated, tool behaviors learned

### Step 2: Draft the session log entry

Follow the output format below. Write the close artifacts directly to the vault -- there is no pre-write approval gate for routine closes. The chat deliverable is exactly two things: the **files touched** (created / updated / moved) and **What's next**. Everything else -- log-entry composition, frontmatter stamping, edit_logs, ledger updates -- happens in the vault, not in chat.

**Always stop and ask first, before writing, for judgment-class items:** a Decision Log entry (it binds future sessions), a status change on someone else's work (you are speaking for another operator), or a claim about what a third party said (misattribution risk). A blanket gate everyone silently skips erodes the rules that matter (ceremony diet, S196); this restatement concentrates the gate where the write is genuinely irreversible or speaks for others. Scope: this governs the close ceremony only -- the PI Working Rules (share plan first, show edits) still govern live working sessions.

> **Harvest sessions:** For sessions that are primarily harvest work, the session log entry may already be partially written as part of the end-of-harvest checklist (which includes a session log update). In that case, the session closer adds Learnings and What's Next to the existing entry rather than writing a full entry from scratch. Check whether a partial entry already exists before drafting.

Read `references/output-format.md` now for the entry templates. Its What's next template opens with the landing check: run the Step 4 landing rule (re-read the previous What's next) before you draft, so the check is written with the entry, not patched in after.

### Step 2.5: Frontmatter validation

Before presenting the draft, verify all required frontmatter fields are present. Required fields for session log entries:

- `title` (see Session Identifier Format section for the format -- solo-operator: "Session N - Brief Title"; multi-operator: "PROJ_YYYY-MM-DD_INITIALS_NN - Brief Title")
- `type: project-doc`
- `parent` (wikilink to the session log shell)
- `section` (solo-operator: section number in the shell; multi-operator: the full session ID string)
- `created` (YYYY-MM-DD)
- `updated` (YYYY-MM-DD)
- `operator` (human operator's first name -- see Step 3.12)
- `seed_version` (the `seed:` value from `_DataWizard/Seed/VERSION.md`, read during orientation)
- `edit_log` (this session's identifier, e.g. `"DW-S196 2026-06-22"` -- required on section files)

`seed_version` is read from VERSION.md during orientation -- never hardcode it from template examples. The former `datawizard_protocol_version` pin is retired per D93; do not add it. If any field is missing from the draft, add it before proceeding. Do not present a draft with missing required fields. This is especially important for `operator`, which powers team dashboards and authorship queries but is easy to omit when pattern-matching from older session logs that predate this requirement. `seed_version` makes team Seed currency visible -- when scanning session logs, a stale Seed version is immediately apparent.

### Step 2.6: Active Threads ledger

Every close maintains the roster of open parallel arcs somewhere. There are exactly two modes, and dropping the roster is never an option: **(a) the project has a ledger** -- maintain it in place, below; **(b) no ledger exists** -- you MUST write the legacy in-entry roster (further below). Detecting that no ledger exists selects mode (b); it does not discharge the roster obligation.

If the project maintains an **Active Threads ledger** -- a vantage-independent roster of open parallel arcs kept as its own file (DataWizard: `{home}/_Sections - {Project}/Active Threads - {Project}.md`, embedded in the `0.5` action-items shell) -- maintain it **in place**. Do not regenerate it from scratch, and do not write the roster into the session-log entry. Re-read the ledger, then for each arc:

- **Touched this session:** patch its block -- update `status:`, set `last:` to this session, rewrite `next:` as the owed list (below), append this session to `history:`.
- **Untouched:** leave the block unchanged.
- **Resolved this session:** cut the block and write a one-liner under the current `#### YYYY-MM` heading in the Resolved archive (`Active Threads Resolved - {Project}.md`), creating the month heading if new. Format: `- T# <name> - resolved S### -> <where it landed>`.
- **New arc this session:** add a `### T{N}` block (next free number) with all fields; set `home:` to its durable backstop (an empty `home:` flags an arc with no task-level home -- a coverage gap).

**`next:` is the owed list.** Write `next:` as a short list of what the arc still owes: one short line per open item (a content leftover, a gate, a ruling, the next build step). Current state only. It is not a story of what this session did -- that goes in the session-log entry. An owed item stays on the list until it is done or has its own tracking line; work on one item does not push the others off. Schema: Conventions Registry, "Active Threads ledger row schema". (DataWizard, 2026-10)

Patch in place and verify each change landed (Working Rule 5). The ledger lists **all** open arcs regardless of this session's focus -- do **not** deduplicate it against "What's next" (that vantage-dependence is the carry-forward flicker the ledger fixes; D105). In the session-log entry, the roster is replaced by a one-line pointer (see Output Format).

A project's ledger may itself be sectioned (a shell of per-arc `![[embed]]` files): then each arc's block is its own section file - patch that file directly, and add or remove embed lines in the shell only when an arc opens or resolves.

**Legacy in-entry roster (projects without a ledger) -- REQUIRED, not optional.** If the project has no Active Threads ledger, you MUST maintain the in-entry roster inside the session-log entry, described below. (Field failure, 2026-07, multi-operator project: three consecutive closes correctly detected the missing ledger, then dropped the roster entirely -- leaving that operator's open arcs invisible to the rest of the team.)

Procedure: `references/no-ledger-roster.md` - read it whenever the project has no ledger.

**Standing proposals: check before carrying, strike on resolution.** A line that recurs across handoffs ("consider building skill X", "the Y refresh is still pending") is not evidence that anything happened - it is evidence that each closer copied it from the last one. Before carrying such a line forward, check whether it has resolved (a skill built, a report reviewed, a gate cleared); when it has, strike it explicitly in this entry rather than letting it drop silently, so the next reader knows it ended rather than wondering if it was lost. One proposal propagated through roughly ten handoffs after its spec was already complete. (DataWizard, 2026-08)

**Side-quest sessions.** When the session was a side quest (frontmatter `stream: side-quest`), its continuation belongs here as a named thread -- and its "What's next" must carry the *main arc* forward unchanged rather than the tangent. See the `side-quest` skill.

### Step 3: Write the close artifacts

Write the entry directly (judgment-class items excepted -- see Step 2). Then:
1. Re-read the session log shell to get the current section number and embed list
2. **If a session stub exists from orientation** (a section file with `status: in-progress` and "in progress" in the filename): **first confirm the stub is yours** -- match its `claim_id` to the one you stamped at orientation (or, if absent, its focus line and `operator`). Never overwrite a parallel instance's in-progress stub (the S178/S179 collision); if it isn't yours, leave it and claim the next available identifier. Once confirmed yours, **the stub becomes the entry -- no delete needed**: overwrite it in place with the full final entry (`write_note`, overwrite mode, complete frontmatter -- overwrite replaces the whole file, which drops `claim_id` and `status: in-progress`; the final entry never carries either, see [[YAML Schema]] Session Log Fields), then rename it to the final title with `move_note`. **Carry the sweep trace forward:** the orientation flag-sweep wrote a one-line compliance trace into the stub (PI Orientation Step 6); keep that line in the final entry (see Output Format) so it survives the overwrite -- a lost trace reads as a broken sweep, not as "nothing was waiting." Solo-operator final name: `99.0 Session 113 - Brief Title.md` (section number as prefix). Multi-operator: `WV_2026-06-10_AA_01 - Brief Title.md` (session ID as prefix). See Session Identifier Format for full details. Nothing links to the stub filename (the shell embed is added fresh in step 4), so the rename needs no link repair. If no stub exists (older claim workflow, or the stub was lost), write the new section file with the final title directly.
3. **Verify the rename landed**: re-list the session log folder and confirm the final filename exists and the "in progress" filename is gone. If the rename failed, the full entry is intact under the stub filename -- retry the rename once; if it still fails, keep the stub filename, tell the user, and use the actual on-disk filename in step 4. (A complete entry stranded under an "in progress" name cannot be double-claimed -- its `status: in-progress` and `claim_id` are gone, and claims always go above the highest identifier -- but rename it next session.)
4. Add the session embed to the shell, using the filename verified in step 3. Under verify-after-claim (PI Orientation Step 3) the stub is NOT embedded at claim, so you are normally adding the embed fresh at close -- patch it into the shell in reverse-chronological position. (Legacy fallback: if an older workflow already left a stub embed in the shell, replace it with the final filename rather than adding a duplicate.)

> **Parallel instance check:** Before writing, re-list the session log
> section folder and verify the target identifier doesn't already exist
> as a file. Solo-operator: check the section number (e.g., 38.0).
> Multi-operator: check the session ID (e.g., `WV_2026-06-10_AA_01`).
> If another instance has claimed it since orientation, increment to
> the next available number. Multiple instances may work in parallel.
> Compare stub *content*, not just filenames -- match the `claim_id`
> (or focus line) to your session before reusing or replacing any
> in-progress stub.
>
> **List the whole window, never a truncated one.** Do not claim or
> verify an identifier from `ls | head -n`, `ls -t | head -n`, or any
> listing capped for readability -- newest-first ordering hides
> same-day siblings written minutes apart, and the file already
> holding your number may sort anywhere. Filter to the date and read
> every result.
>
> **If you discover a collision after writing,** renumber *your own*
> file, never anyone else's, and update every reference in one pass:
> the filename, `section`/`title` in frontmatter, the `## ` heading,
> the shell embed, and any `edit_log` or provenance lines you already
> stamped into other files this session. A half-renamed session is
> worse than a collision -- the stale references still resolve to
> something plausible.

> **Flat-file fallback:** If the project's session log hasn't been migrated to shell + sections yet, skip the section file and embed steps. Instead, patch the entry directly into the flat session log file -- insert below the header, above existing entries.

### Step 3.5: Knowledge transfer check

**Before moving to infrastructure updates, triage each learning from this session.**

> **Header variant.** Some sessions record learnings under a `### Findings` header (with inline `finding:` / `pattern-discovered:` tags) instead of `### Learnings`. Treat it as learnings-equivalent -- triage those items the same way, and downstream meta-learning scans do too. Prefer `### Learnings` for new entries, but don't rewrite an inherited `### Findings` entry just to rename the header.

For each finding, decision, or detailed context that emerged during the session, classify it:

- **Session-log-only**: Routine or one-off (e.g., "tool X was slow today," "retried three times before patch landed"). No further planting needed.
- **Design-doc**: Technical finding that future task-specific work needs. Identify the specific target doc and plant it there. Example: an edge case discovered during a build belongs in the relevant design doc, not just the session log.
- **Skill-update**: Process improvement that should change how a skill works. Patch the skill now or add a specific action item naming the skill and what to change.
- **Protocol-update**: Convention change that affects all projects. Handled by Step 3.6 (convention-change check) -- flag it there if not already caught.
- **Environment / tool-behavior**: A platform, MCP, sandbox, git, or shell gotcha (a tool that fails in a specific way, a mount or sync limitation, an auth or permission quirk). These have a standing home -- the **Platform and Environment Behaviors** guide cluster (`Seed/GUIDES.md` lists the members: MCP Reliability, Cowork Build Environment, Git Guide troubleshooting, Chrome and web tools, scheduled tasks, and so on). Route each one to the cluster guide it fits and plant it now; a one-line entry with `(project, YYYY-MM)` provenance is enough. Support and debugging sessions produce these in batches and are the sessions most likely to close with "files updated: none" -- six environment facts from one such session sat unrouted for two months until a meta-learning review found them. Do not leave them as session-log-only.

**Insight-capture awareness.** If the insight-capture skill was invoked mid-session, its report lists what was planted and where. Use that as a starting point -- verify nothing additional surfaced since the capture ran, rather than doing a full from-scratch triage. If no insight-capture was run, do the full triage as usual.

**Planting verification.** For each learning classified as design-doc or skill-update, verify the content was actually written to the target before closing. Not just "did you think about it" but "confirm the patch landed." If planting hasn't happened yet, do it now or add a specific action item with the target file path.

**Tracking-claim verification.** Check tracking claims the same way. Every "tracked in", "queued in", "folded into" or "see `<list>`" claim in the entry (Learnings, What's next, the landing check) must resolve to a line that exists on disk now. Re-read the target file, find the line, and quote its bold title, id or first few words in the entry. If the line is not there, write it now or remove the claim. A claim written from memory is the worst leak: the log says the item is safe when no list holds it. (DataWizard, 2026-10)

**Backlinks.** When a learning is planted in a design doc or skill, note where it went in the session log's Learnings section (e.g., "See Editorial Technical Notes > Frame Rate section for full detail"). This makes the session log a discovery record that points to where the substance lives.

This is not optional. Do not ask the user -- run the triage yourself. If everything has been transferred, move on silently.

> **Harvest sessions:** In a harvest session, the entire session is knowledge transfer -- every chunk writes findings into destination documents. The triage is still valuable (verify nothing remains only in chat), but recognize that harvest sessions are inherently knowledge-transfer-complete in a way that design or build sessions aren't.

### Step 3.6: Convention-change check

**Ask yourself (and surface to the user if yes):**

"Did this session establish or change any conventions, folder
patterns, naming rules, or structural practices that differ from
what the protocol docs currently say?"

If yes, do one of:
1. Update the relevant protocol docs now (the Conventions Registry,
   YAML Schema, or whichever docs describe the old convention), OR
2. Add an explicit action item naming the *specific docs* that
   need updating -- not just "update protocol" but "update the
   Conventions Registry's X entry and the YAML Schema's Y field."

If a Decision Log entry was written this session, verify its
`Protocol updated:` flag is accurate.

This step catches drift at the source. Five weeks of undocumented
convention change (the _ prefix migration, S58-S63) is the pattern
this prevents.

### Step 3.7: Residual value check (harvest sessions)

**For sessions that included harvest work**, before closing, re-scan
each harvest source for remaining extractable value. Look for:
threads you deprioritized during the main harvest pass, tangential
insights worth capturing, content relevant to a different project
than the primary harvest target, novel language or framings not yet
flagged as lexicon candidates, and any tensions or disagreements
you may have flattened. If you find more to extract, do another
harvest pass before proceeding to infrastructure updates.

This is not optional. Instances consistently underestimate residual
value on first pass. The knowledge transfer check (3.5) asks whether
findings got planted in the right docs -- this step asks whether
you got everything out of the source material in the first place.

> **Non-harvest sessions:** Skip this step entirely.

### Step 3.8: Metadata verification

For each file modified this session (from the "Files updated" and "Files created" lists):

1. Verify birth metadata is present (type, created, updated, operator, origin, edit_log). Birth metadata should already exist from creation time (Working Rule 12); if any field is missing, add it now as a fallback. If `origin` is missing (a pre-D127 file), backfill it from the earliest edit_log entry, or from `created:` plus the file's operator when no edit_log exists.
2. Verify `updated:` reflects today's date (YYYY-MM-DD)
3. Append this session's identifier to `edit_log:` (solo-operator: `'DW-S70 2026-05-23'`; multi-operator: `'WV_2026-06-10_AA_01'` -- date is embedded in the ID). **Always single-quote the entry**; an optional short clause of a few words may follow the date -- narrative belongs in the session log entry, not here. Deduplicate -- if the session already appears, don't add it again. Then trim to the window: `edit_log` keeps only the last 5 entries -- drop the oldest in the same write (D127; skip trimming in projects whose one-time pre-D127 cleanup has not yet run). Nothing is archived at trim time: the canonical per-file history is this entry's "Files created" / "Files updated" manifest, which is **required at every close tier**.
4. For shell files whose sections were edited: bump the shell's `updated` field (but no `edit_log` on shells)

Scalars (`updated`, `status`) may go through `update_frontmatter` alone. For `edit_log:` and any other array, never pass a bare array -- `merge: true` merges top-level keys only, so a passed array replaces the existing one wholesale (silent history wipe; see the MCP Reliability guide, "Array wipe via merge: true"). Append instead: the array-append primitive (`stamp_editlog.py` in `Seed/Scripts/`, or a raw-tail insert placed after the *last line of the array* -- the line before the next top-level key, not the last `- ` line, since long entries wrap onto continuation lines); where neither is available, re-read the full array immediately before the write and pass it back verbatim with the new entry appended, then verify the entry count did not shrink.

**Scope:** `edit_log` is required on section files, recommended on infrastructure files (0.x) and standalone docs. Shell files are exempt -- they are assembly surfaces whose edit history is captured by their sections' logs. See the [[YAML Schema]] edit_log section for the full convention.

This step catches metadata drift at the source rather than requiring periodic remediation passes.

**Link resolution.** For the same files, confirm that the wikilinks and embeds added this session resolve. A link to a not-quite-right title renders like a live one and reads as "already tracked". Run dw_lint with `--stdout` and read its C5 (link resolution) findings for the files touched this session. Where dw_lint is unavailable, check each new link by hand: `find "<vault>" -name "<title>.md"` returning nothing means the link is dangling. Fix or unlink before the entry ships. (ReWoven, 2026-09)

### Step 3.9: Section-shell sync check

For each section file created or renamed this session, verify its parent shell contains a matching `![[filename]]` embed.

1. Identify the parent shell from the section's `parent:` frontmatter field
2. Read the shell and check that each new section filename appears in an `![[...]]` embed
3. **If any are missing, add them** in the appropriate position -- do not merely flag and offer. A missing embed is a silent failure, not a user preference.

**Then sweep for orphans from parallel instances.** Do not limit the check to your own files. List every section file in the folder from the last two days, **excluding in-progress stubs** (skip any file whose name contains "in progress" or whose frontmatter has `status: in-progress` -- under verify-after-claim those are deliberately unembedded until close, PI Orientation Step 3 and this skill's Step 3), and confirm each completed entry has a matching embed in the shell. Add any that are missing. (Two days fits a high-cadence multi-operator day; widen it for projects that run fewer, longer sessions, or tie it to "since the last entry visible in the shell.") Why this matters: an unembedded entry is invisible -- the shell is what orientation reads, so a section file that exists but is not embedded is never found, and the handoff fails silently while the tree looks clean and fully synced. Verify against the actual file listing, not from memory. Never edit another instance's entry *content* -- only add its embed.

This catches the most common drift pattern -- adding sections without updating the shell -- at the point of creation, plus the parallel-instance variant where one instance writes its entry and skips the patch. Skip the your-own-files check if no section files were created or renamed this session; still run the orphan sweep on a full close.

### Step 3.10: Pending review reports (full closes only)

> **Lite closes skip this step** (see Step 0). Run it only in a full close.

The session-closer does **not** compute review staleness or nudge on session/day thresholds. Detecting that a health audit, meta-learning review, or Content Interests refresh is due -- and running the scan that produces a report -- is the job of the scheduled review automation (see the **Review Automation** guide). This step's only job is to surface reports those scans have already left waiting. None of this blocks session close.

List the project's Learning Reports folder (`{infrastructure folder}/Learning Reports/` for full-convention projects, e.g. `{home}/_Infrastructure - {ProjectName}/Learning Reports/`; `{home}/Learning Reports/` for flat; canonical location: the Review Automation guide's "Report locations" section). For any report file with `status: pending-review` (`Meta-Learning Report - *`, `Health Audit Report - *`, `Content Interests Report - *`, `Look-Back Report - *`), add one line to "What's next":

"A [review type] report is waiting for your review: [filename]."

Name the file; do not summarize it. If no reports are pending, say nothing.

**Silence rule.** Outside this step -- in orientation, elsewhere in "What's next," anywhere -- never say a review is "due," "approaching," or "getting close," and never quote a cadence number. The session-closer holds no cadence numbers; they live only in the Review Automation guide (D114). Silence is the default; a named pending report is the only surfacing.

### Step 3.11: File size check

Scan the "Files updated" and "Files created" lists for files
that may be approaching MCP read limits. For any file you
touched this session that you noticed was large or slow to
read, check its size. Flag files approaching 50KB as
candidates for shell + sections migration.

If a file is already over 50KB and hasn't been sectioned,
add an action item: "Section [filename] -- currently [size],
exceeds MCP read limit."

This catches growth before overflow. Skip if no large files
were encountered this session.

### Step 3.12: Operator field and team flag prompt

**Operator field (always).** Verify `operator: FirstName` is present in the frontmatter of the following files. Birth metadata (Working Rule 12) should have set this at creation time; if missing, add it now as a fallback:
- The session log section file (always)
- Any content documents created or substantially updated this session

Use the human operator's first name (e.g. `Operator-A`, `Operator-B`, `Operator-C`). This field powers the "Recent Team Activity" section of the team dashboard and makes authorship queryable via Bases/Dataview.

Multi-operator projects: the team flag prompt and read/dismiss steps are in `references/multi-operator-flags.md`. Solo projects skip them.

**Solo operators:** Apply the `operator` field as usual. Skip the team flag prompt and team read tracking -- there are no other operators to notify. The field is still useful if the project gains team members later.

### Step 3.13: Flag expiry pass (multi-operator projects only, full closes)

Procedure: `references/multi-operator-flags.md`, section "Flag expiry pass". Solo projects skip this step.

### Step 3.14: Cross-project write check (all projects, all tiers)

Answer one question from the session's own history: **did this session create or edit any file outside this project's home folder** (another project's folders, another project's Seed, or shared canon such as a Project Instructions file, VERSION file, changelog, protocol doc, or 0.x file that belongs to a different project)?

- **No** -- done; nothing to write.
- **Yes, and it was an inbound/outbound note filed to the other project's intake or Session Exchange** -- that is the sanctioned path; just confirm the session log records what was filed where.
- **Yes, anything else** -- surface it to the operator now, before the log is finalized: name each file and say plainly that another project's canon was touched. The gate rule ("Cross-project canon write gate", Conventions Registry) says such changes belong in the owning project's intake as a proposal, not as a direct edit. With the operator, either (a) revert/move the change into a proposal at the owning project's intake, or (b) record the operator's explicit acceptance in this session's log AND leave a note in the owning project's intake so its next session reviews it. Never close silently over a cross-project canon write -- the write may be sound, but the owning project must be able to see it happened.

This check exists because the offending session is the only place with perfect knowledge of what it wrote; target-side detection (lint) is the backstop, not the primary. (DataWizard, 2026-09)

**Board (all projects, all tiers).** Each outbound item filed this session (exchange note or feature request to another project, gate row naming another project's actor) should already have its ask on the coordination board, posted in the same step that wrote the item (Conventions Registry, "Coordination board", post at write time). Verify that each outbound item has a row and post only the missing ones; every claim this session holds is released. Mac-side and Claude Code: `python3 "<scripts>/board.py" close --session <id> --ask "TO::NOTE::SUMMARY"` (globals such as `--db` before `close`). Cowork: post by hand in `_Coordination/Board.md` following its header (use `next_free`, or the next id above the highest present if a block already carries it; re-read; renumber on collision); release by editing `status` and `updated`. Record the ids in the session log. Also ask "did this session change something another project depends on, without asking it to act?" - if yes, post an ask with `intent: awareness` (statuses open -> seen | stale); tool-behavior notes that the receiving project will plant are ordinary asks (`intent: action`, the default). Rule: Conventions Registry, "Coordination board".

### Step 4: Update related infrastructure files

Check whether the session produced work that belongs in other files:
- **Action items -- the landing rule (required, every close tier).** Re-read the previous session's "What's next", and any paragraph of rulings or tasks for the operator. Every item in it ends in exactly one state:
  - **done** -- struck in the new entry, with where it landed (file, commit or gate);
  - **carried** -- it appears in the new "What's next";
  - **landed on a tracking list** -- a Backlog line, a gate row, a board ask or a ledger row. The entry quotes that line: the file and the line's bold title, its id, or its first few words.

  "Queued in X" or "tracked in Y" without the quoted line is not allowed (Step 3.5, tracking-claim verification). A demoted item (from a priority to a side remark) is still carried, and the next close must land it too. The entry records the result as the landing check (see `references/output-format.md`).

  **Rulings and small tasks for the operator** go to ONE dated `Waiting on <operator>` checklist, never to a paragraph in "What's next". The project chooses the checklist's home (typically a section of its action items or backlog). If the project has none yet, ask the operator where it goes at the first close that needs it; if no answer is at hand, open it as a section at the end of the project's action items file and say so in the entry. One line per item: a checkbox, the date added, the item and its source session. "What's next" carries only the pointer line.

  Still check off completed items and add new ones. See the triage guidance below when the backlog needs cleanup. (DataWizard, 2026-10: two look-backs found about one open item in three not where the next reader would look.)
- **Decision log**: If decisions were made during the session (agreements, vision refinements, commitments, technical choices, scope changes), they belong as separate entries in the Decision Log. Note them in "What happened" and point to the Decision Log entry.
- **Harvest ledger**: If harvesting was done during the session, verify the Harvest Ledger was updated as part of the harvest checklist. If not, update `0.4 Harvest Ledger - [Project].md` now.
- **Tool inventory** (projects that keep one in their 0.6 Registry): if the session *designed* a tool or surface (a design doc now exists), *built* one (code now exists), or brought one *live*, add or update its row with the new state. A designed-but-unbuilt tool belongs in the inventory as much as a live one -- the inventory exists so a later instance in any project can ask "does something like this already exist?" before designing it again.
- **Operator Gate Queue** (projects that keep one): scan the session's builds and decisions - anything built or decided but not verified-live where production reads it gets a gate row, but only when the actor is specific (operator-native, another project's session, a named person); work any future session can pick up stays in the action items. A build that could not be verified live is recorded as `unverified`, never pending-success. If a gate reached verified-live this session, run the exit ceremony (Deployed section, then a registry Infrastructure row with a `verify:` line). Schema, lifecycle vocabulary, and ceremony: the Conventions Registry's Operator Gate Queue entry.

Write the changes directly. Exception: a Decision Log entry is judgment-class -- show its text and get approval before writing it (Step 2). Action items, the harvest ledger, and shell updates are written directly.

Periodic full triage (every ~30 sessions): `references/action-items-triage.md`.

### Step 4.5: Next-session recap and suggested model

Just before suggesting the thread name, give a brief, action-oriented recap -- never a generic "nice work, see you next time." Two or three sentences at most, spoken in chat only (not written to the vault):

- **Next up:** one line naming the single most valuable thing to pick up next session. Pull it from "What's next" Priority 1 -- the specific task with its key file path, not a vague topic.
- **Suggested model:** name the model tier that best fits that task, with a 3-5 word reason, per the Conventions Registry's Model routing entry - the single home for the heuristic. Keep it tier-generic rather than pinning a version, which goes stale.

Keep it tight -- the recap and model line are the last thing the user reads before the thread name, so they should land as a clear "here's where to restart and what to run it on."

### Step 5: Suggest final thread name

Suggest a final thread name for the session. Solo-operator format: `checkmark ProjectAbbrev SNN - brief description` (e.g., `√ DW S43 - Weave git migration final stage`). Multi-operator format: `checkmark PROJ_YYYY-MM-DD_INITIALS_NN - description` (e.g., `√ WV_2026-06-10_AA_01 - session ID convention update`). The checkmark prefix signals the session is complete. Base the description on what actually happened, not the provisional name from orientation.

Present the final thread name on its own line inside a fenced code block (triple backticks) with nothing else in the block, so it renders as a one-click-to-copy box in chat.

This step is intentionally last. The thread name is the signal that all session-close work is complete -- the user copies it, and the session is done.

## Output Format

The entry templates (Output Format, Structured Format for Complex Sessions, Writing the Title) are in `references/output-format.md`. Read it at Step 2, before drafting the entry.

## Common Mistakes

- **Treating "What's next" as a checklist.** It's a direction, not a mandate. The next instance should feel free to spend the entire session on one deep task if that's where the value is. Rushing through items to "complete the list" produces worse work than going deep on one thing. The user values depth over breadth.
- **Vague "What's next."** "Continue the skills work" is useless. "Build the session-closer skill — read Section 6 Proposal #1 and Section 7 Proposal #11 in the Agent Architecture doc for the spec" is useful.
- **Missing file paths in "What's next."** Every "What's next" should have at least 2-3 exact paths. The incoming instance shouldn't need to search for anything.
- **No prioritization.** Without it, the next instance treats everything as equal priority. Use "Priority 1 / Priority 2" or "The main focus is X. Also when you get a chance: Y."
- **Learnings too vague.** "Learned about MCP tools" isn't searchable. "tool_search needs multi-word descriptive queries including the tool name; single words return nothing" is.
- **Forgetting the "why."** A fresh instance doesn't know why a particular task matters. One sentence of framing prevents misunderstanding.
- **Over-narrating "What happened."** This isn't a diary. Dense, scannable, focused on what a future reader needs to know.
- **Duplicating "What's next" in quest threads.** If a workstream is already a Priority item in "What's next," don't repeat it in quest threads. The quest threads section exists for background work that's NOT the immediate focus -- things the next instance might forget about because they're not on the priority list. When all active threads are already priorities, omit the section entirely.
- **Following a stale "What's next" without re-evaluating.** If the previous session's "What's next" was written because that session was low on context (not because the items are the highest-value work), a fresh session should re-evaluate priorities rather than following the stale plan. The "What's next" reflects the best guess at the time -- a fresh context window with full project awareness may see a better path (S114).
- **Letting an item leave "What's next" without landing.** An item that was a priority last session becomes a side remark, then disappears, and no list ever held it. Every item from the previous "What's next" ends done, carried, or on a tracking list whose line the entry quotes (Step 4, landing rule). "Queued in the backlog" written from memory is the same leak: re-read the list and quote the line.
- **Reporting a clean version-control state as if it answered "is the vault up to date."** Committed, pushed, and conflict-free says nothing about whether documents still describe reality -- trackers, indexes, and dashboard-feeding frontmatter (`deadline`, `next_action`, `status`, `stage`) can be days stale inside a perfectly clean tree. When asked whether things are current, check the *documents* and say which ones you checked.
- **Writing a correction banner that enumerates what it fixed without verifying each location.** "Sections 1, 6, 9, and 10 are corrected below" is a claim; if one was missed the banner is worse than none -- it stops the next reader from checking the very place the error survives. Verify every location you name, or describe the correction without enumerating.
- **Trusting a companion or summary doc's account of a conversation.** Compressions invent certainty: a synthesis reading "X told A and B" may rest on a transcript line "I've told them," which does not establish who heard it. For anything that shapes how you approach a person or commitment, read the source, not the summary.
- **Fragmenting one continuous session into multiple entries.** If work resumes after a close on the same day, amend the existing entry (retitling if its scope grew) rather than opening a second -- a split handoff is harder to follow. Start a new entry only when the day rolls over, or when the work is a genuinely separate workstream and the earlier entry is already committed.

## Relationship to Other Files

- **Session log shell** (`0.2 Session Log - Project.md`): Add an embed reference (`![[section filename]]`) to the shell after creating the section file.
- **Action items**: The landing rule at Step 4 (required). Check off completed items, add new ones; rulings and small tasks for the operator go on the dated Waiting-on checklist.
- **Decision log**: Decisions belong as separate numbered entries. The session log references them but doesn't replace them.
- **Harvest ledger**: If harvesting was done, update `0.4 Harvest Ledger - [Project].md` with source, destinations, and agent. Source YAML should already be updated as part of the harvest checklist.

## Synthesis Check

Before closing, verify two things:

1. **Cross-cutting synthesis.** If this session involved multi-item analysis (research batches, triage passes, cross-doc comparisons), have the cross-cutting findings been captured? Synthesis degrades across context boundaries but mechanical execution doesn't. If the thinking hasn't been written down yet (as an integration memo, design doc update, or explicit "Learnings" entry), capture it now -- before the session log, not after.

2. **Knowledge transfer completeness.** The session log is a handoff document, not a knowledge store. Detailed findings, patterns, tool evaluations, and architectural implications belong in design docs, skills, and tracking files where future instances will encounter them during task-specific work. If a finding only exists in the session log, it will likely be missed -- future instances read the last 2-3 session entries for orientation, then work from design docs and skills. Always ask: "would a future instance working on [relevant topic] find this in the doc they'd naturally read?" If not, plant it there.

See [[Context and Session Management]] for the rationale.
