---
name: session-closer
description: >-
  Use at the end of every session to write the session log entry. Triggers on:
  'let's wrap up', 'close out the session', 'write the session log', 'we're done
  for today', end of any work session. Also triggers when the user says 'let's
  pick up where we left off' in a new thread and there's no log entry for the
  previous session.
type: skill
updated: '2026-08-26'
version: '4.6.3'
edit_log:
  - DW-S158 2026-06-08
  - DW-S159 2026-06-08
  - DW-S161 2026-06-09
  - DW-S167 2026-06-10
  - DW-S168 2026-06-11
  - DW-S183 2026-06-14 - repointed archived Protocol Summary refs (D99)
  - DW-S186 2026-06-15
  - "DW-S196 2026-06-22 - v4.0 ceremony diet: D88 thresholds table, D98
    session-lite tier, D93 protocol-version drop, orphan 3.7 + Step 2.5 edit_log
    fixes, S179 stub guard, renumber"
  - "DW-S198 2026-06-23 - v4.1: defer shell embed to close + strip claim_id
    (verify-after-claim)"
  - "DW-S211 2026-06-29 - v4.2: Active Threads ledger maintenance (D105);
    in-place + entry pointer, legacy in-entry roster kept as fallback"
  - "DW-S235 2026-08-04 - v4.2.1: Step 2.6 no-ledger fallback made explicit and
    mandatory (mode-selector line + REQUIRED lead-in; field failure in a
    multi-operator project)"
  - "DW-S235 2026-08-04 - v4.2.1 (cont.): Step 3.12 re-flag merge rule (flag_for
    is a shared unread-queue; never overwrite pending state)"
  - "DW-S243 2026-08-05 - v4.2.2: Step 3.5 header-variant tolerance note (###
    Findings learnings-equivalent)"
  - "DW-S250 2026-08-06 - v4.3.0: Step 3.10 threshold nudges retired ->
    pending-review-report surfacing only; cadence numbers moved to Review
    Automation guide (D114 supersedes D88 home)"
  - "DW-S258 2026-08-08 - v4.4.0: Step 4.5 next-session recap + suggested-model
    send-off, delivered just before the thread name (Step 5 unchanged)"
  - "DW-S258 2026-08-08 - v4.4.1: Step 5 presents the thread name in a fenced
    code block (renders as a one-click-to-copy box in chat)"
  - "DW-S270 2026-08-15 - v4.5.0: Step 3 stub overwrite + move_note rename
    replaces delete_note (no destructive-op permission prompt); rename
    verification step added"
  - "DW-S272 2026-08-18 - v4.6.0: flag anatomy at set-time + budget +
    defer-keeps-name (3.12); expiry pass (new 3.13, sole automatic writer of
    expired-unread); sweep-trace carry-forward (Step 3 + Output Format);
    approval-gate restated to lean form (Steps 2-4: files-touched + What's next
    only, three judgment-class stop-and-asks kept); KY_06 hardening (3.9
    add-not-offer + orphan sweep excl. in-progress stubs; parallel-instance
    whole-window listing + collision recovery; 4 Common Mistakes)"
  - DW-S279 2026-08-18 - generic-names sweep of the two 3.12 examples (C2, Seed
    depersonalization; Flag Surfacing Chain B2)
  - "DW-S284 2026-08-24 - v4.6.1: Step 3.5 gains the Environment / tool-behavior
    triage class routing to the Platform and Environment Behaviors cluster (S216
    support-session failure mode; meta-learning review S210-S220)"
  - "DW-S284 2026-08-24 - v4.6.2: What's next standing-proposals rule - check
    before carrying, strike on resolution (S248; meta-learning review
    S247-S255)"
  - "DW-S289 2026-08-26 - v4.6.3: Step 4 gains the Tool inventory bullet (designed / built / live rows in the project's 0.6 Registry; a designed-but-unbuilt tool is inventoried too) - the structural fix for a tool being re-designed in a collaborator project because the existing one was not on any reader's path"
---

# Session Closer Skill

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

- **Lite close** -- for sessions with no new conventions, no harvest, and few file touches. Do only: the log entry (What happened / Learnings-if-any / What's next), frontmatter validation (Step 2.5), write + embed (Step 3, including the section-shell sync), metadata verification (Step 3.8), and the thread name (Step 5). Skip the knowledge-transfer / convention / residual triage (Steps 3.5-3.7), the pending-review report check (Step 3.10), the file-size check (Step 3.11), the team-flag prompt (Step 3.12), and the flag expiry pass (Step 3.13) -- the lite preconditions make these no-ops. You may still check off an action item you completed.
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

- **Touched this session:** patch its block -- update `status:`, set `last:` to this session, refresh `next:`, append this session to `history:`.
- **Untouched:** leave the block unchanged.
- **Resolved this session:** cut the block and write a one-liner under the current `#### YYYY-MM` heading in the Resolved archive (`Active Threads Resolved - {Project}.md`), creating the month heading if new. Format: `- T# <name> - resolved S### -> <where it landed>`.
- **New arc this session:** add a `### T{N}` block (next free number) with all fields; set `home:` to its durable backstop (an empty `home:` flags an arc with no task-level home -- a coverage gap).

Patch in place and verify each change landed (Working Rule 5). The ledger lists **all** open arcs regardless of this session's focus -- do **not** deduplicate it against "What's next" (that vantage-dependence is the carry-forward flicker the ledger fixes; D105). In the session-log entry, the roster is replaced by a one-line pointer (see Output Format).

**Legacy in-entry roster (projects without a ledger) -- REQUIRED, not optional.** If the project has no Active Threads ledger, you MUST maintain the in-entry roster inside the session-log entry, described below. (Field failure, 2026-07, multi-operator project: three consecutive closes correctly detected the missing ledger, then dropped the roster entirely -- leaving that operator's open arcs invisible to the rest of the team.)

Read the previous session's "Active quest threads" section (if it exists). For each thread:
- If work was done on it this session, update its status and remaining work
- If no work was done, carry it forward unchanged
- If it was completed this session, remove it
- If a new multi-session workstream emerged this session, add it

Each thread entry includes: a bold numbered name, session history in parentheses (which sessions touched it), 2-3 sentences on remaining work, and key doc paths. This section lives after "What's next" in the output format.

If the previous session has no quest threads section (pre-S158 entries), scan the last 5-7 session logs to identify active threads and bootstrap the section. This is a one-time cost -- subsequent sessions just carry forward and update.

**Deduplication rule.** Do not include a thread that is already a Priority item or side task in "What's next." Quest threads exist for workstreams that are NOT the immediate focus -- things the next instance might forget about because they're not on the priority list. If every active thread is already covered in "What's next," omit the quest threads section entirely.

The quest threads section prevents long-running workstreams from falling off the radar when they aren't the active focus. "What's next" is the immediate handoff; quest threads are the background map of parallel work that isn't currently prioritized.

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

1. Verify birth metadata is present (type, created, updated, operator, edit_log). Birth metadata should already exist from creation time (Working Rule 12); if any field is missing, add it now as a fallback.
2. Verify `updated:` reflects today's date (YYYY-MM-DD)
3. Append this session's identifier to `edit_log:` (solo-operator: `"DW-S70 2026-05-23"`; multi-operator: `"WV_2026-06-10_AA_01"` -- date is embedded in the ID). Deduplicate -- if the session already appears, don't add it again.
4. For shell files whose sections were edited: bump the shell's `updated` field (but no `edit_log` on shells)

Use `update_frontmatter` for efficiency -- it merges without requiring a full re-read.

**Scope:** `edit_log` is required on section files, recommended on infrastructure files (0.x) and standalone docs. Shell files are exempt -- they are assembly surfaces whose edit history is captured by their sections' logs. See the [[YAML Schema]] edit_log section for the full convention.

This step catches metadata drift at the source rather than requiring periodic remediation passes.

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

List the project's Learning Reports folder (`{home}/Workshop - {ProjectName}/Learning Reports/` for full-convention projects; `{home}/Learning Reports/` for flat). For any report file with `status: pending-review` (`Meta-Learning Report - *`, `Health Audit Report - *`, `Content Interests Report - *`), add one line to "What's next":

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

Use the human operator's first name (e.g. `Alice`, `Ben`, `Cara`). This field powers the "Recent Team Activity" section of the team dashboard and makes authorship queryable via Bases/Dataview.

**Team flag prompt (multi-operator projects only).** If the project has more than one operator, present the user with a list of files created or substantially updated this session. Pre-select:
- Any file created this session with `priority: high`
- New synthesis documents, analyses, or research notes
- Any file that substantially updates a shared canonical doc (design docs, strategy docs, etc.)

**In Cowork (AskUserQuestion available):** Use `AskUserQuestion` with `multiSelect: true` to present candidates as selectable options. Each option's `label` is the file's display name; `description` summarizes what changed this session. Pre-selected items should appear first in the options list with "(Recommended)" appended to the label. This lets the operator click rather than type. If the operator has indicated a preference against AskUserQuestion, fall back to the text-list approach below.

**In Chat or when AskUserQuestion is unavailable:** Ask in prose: "Which of these should be flagged for team attention -- meaning other operators should read it before their next session?" List the candidates with numbered options for easy selection.

For each file the user selects:
1. Add `flag: YYYY-MM-DD` (today's date) to its frontmatter
2. Add `flag_by: FirstName` (the operator's first name)
3. Add `flag_for:` as a YAML list of the operators who need to see it (e.g. if Alice flags it: `flag_for: [Ben, Cara]`) -- narrow it to the people it is actually relevant to
4. Set `flag_note:` to a one-line statement of **the decision needed and what is blocked until it is made** (the content requirement -- [[YAML Schema]] Team Coordination Fields; "please review the tiers" fails, "approve or amend the tiers -- outreach proceeds in listed order on silence" passes). Fold a long note per the same guidance so it cannot break frontmatter parsing
5. Optionally set `flag_due:` (date a response is needed by) and `flag_default:` (what happens on silence after the due date). Ask for these on anything time-sensitive -- they are what let the expiry pass (Step 3.13) turn silence into a decision

**Flag budget: at most 2-3 new flags per close.** Forcing triage keeps the queue meaningful; a flag on everything trains operators to skip the sweep. If more than three files feel flag-worthy, pick the ones that genuinely need another operator's eyes before their next session.

**Re-flagging a file that already carries an unresolved flag: merge, never overwrite.** Union the existing `flag_for` list with the new recipients (preserving names who haven't dismissed yet), keep or combine the `flag_note` so both notices survive, and update `flag`/`flag_by` to the newer flagging. `flag_for` is a shared unread-queue -- overwriting it silently erases other operators' pending notifications. (Field catch, 2026-08: a re-flag would have erased two operators' unread state on a Decision Log flag; the closing session merged instead.)

**On ungraceful session close** (context exhausted before the user can confirm): auto-flag any `priority: high` files created this session using `flag_by: "FirstName (auto)"` and `flag_for:` listing all other team operators. The human can review and remove auto-flags in a subsequent session.

**Team read dismiss (multi-operator projects only).** When the operator handles a file whose `flag_for` contains their name, update the flag by their response: **acting on it** removes their name from `flag_for` (`update_frontmatter`); a **conscious defer** keeps their name and sets `flag_status: deferred`, so the item re-surfaces due-first at their next orientation rather than vanishing (defer is not dismissal -- F3 of the Flag Surfacing Chain). When the `flag_for` list empties through handling, all operators have seen the item -- anyone can then clear the `flag`, `flag_by`, `flag_note`, `flag_for`, and any `flag_due`/`flag_default`/`flag_status` fields to remove it from the dashboard entirely.

**Solo operators:** Apply the `operator` field as usual. Skip the team flag prompt and team read tracking -- there are no other operators to notify. The field is still useful if the project gains team members later.

### Step 3.13: Flag expiry pass (multi-operator projects only, full closes)

> Solo projects and lite closes skip this step. **Scope: only flags set on or after the Flag Surfacing Chain ship date (Seed 1.3.0 -- see VERSION.md's What's New).** Flags that predate delivery are a pre-existing backlog handled by a dedicated triage session; never mass-expire them here (at rollout, entire per-person queues are older than any age threshold -- expiring them would stamp `expired-unread` on flags that were never deliverable).

Scan the project for live flags (`flag` present, `flag` date on/after the ship date) that are **not** already `flag_status: deferred`. A deferred flag was consciously read (F3 put that on the record) -- never overwrite it. A flag in scope is **expired** when:

- it carries a `flag_due` and today is past `flag_due` (silence became a decision at the deadline the flagger set), OR
- it has no `flag_due` and its `flag` date is more than **21 days** old (the backstop so undated flags still eventually resolve).

For each expired flag, do one of:

- **Refresh** -- if the ask is still live, re-stamp `flag` to today and set or update `flag_due` and a real `flag_note`, so it re-enters the queue with a fresh clock.
- **Expire** -- set `flag_status: expired-unread`, clear the `flag_for` names, and record in the `flag_note` that the `flag_default` (if any) is now in effect.

This pass is the **only automatic writer of `flag_status: expired-unread`** and the only automatic name-clearer -- the orientation sweep is read-only (PI Orientation Step 6 / [[Orientation Flag Sweep - Query Spec]]). It runs at close because close already patches shared surfaces. Dated flags expire on the flagger's own deadline; undated flags get the 21-day backstop; deferred flags are exempt (already read). An `expired-unread` flag is itself the record that delivery failed.

### Step 4: Update related infrastructure files

Check whether the session produced work that belongs in other files:
- **Action items**: Check off completed items, add new ones. Optional but recommended. See the triage guidance below when the backlog needs cleanup.
- **Decision log**: If decisions were made during the session (agreements, vision refinements, commitments, technical choices, scope changes), they belong as separate entries in the Decision Log. Note them in "What happened" and point to the Decision Log entry.
- **Harvest ledger**: If harvesting was done during the session, verify the Harvest Ledger was updated as part of the harvest checklist. If not, update `0.4 Harvest Ledger - [Project].md` now.
- **Tool inventory** (projects that keep one in their 0.6 Registry): if the session *designed* a tool or surface (a design doc now exists), *built* one (code now exists), or brought one *live*, add or update its row with the new state. A designed-but-unbuilt tool belongs in the inventory as much as a live one -- the inventory exists so a later instance in any project can ask "does something like this already exist?" before designing it again. If the built tool needs a native actor to go live, add its gate-queue row in the same pass.

Write the changes directly. Exception: a Decision Log entry is judgment-class -- show its text and get approval before writing it (Step 2). Action items, the harvest ledger, and shell updates are written directly.

#### Action items triage guidance

Session-close action item updates are incremental -- check off what's done, add what's new. But every ~30 sessions (matching the health audit cadence), the action items file benefits from a full triage pass. When doing a triage:

1. **Work in reverse-chronological order.** Start from the most recent items and work backwards. The newest items represent the current state of play, which makes it easy to spot older items that have been overtaken by events.

2. **Group by conversation partner** when the project involves recurring calls with the same people. Action items from calls with the same person overlap heavily -- grouping by partner makes duplicates immediately visible and produces a cleaner, more actionable list.

3. **Expect ~1/3 staleness.** Roughly a third of accumulated action items will be stale -- not explicitly resolved, just no longer relevant. This is normal. Flag them for removal rather than carrying them forward indefinitely.

Full triage is a periodic activity, not a session-close requirement. The session-closer's job is incremental maintenance; the triage patterns above apply when the backlog has grown unwieldy. (RW S9, S142)

### Step 4.5: Next-session recap and suggested model

Just before suggesting the thread name, give a brief, action-oriented recap -- never a generic "nice work, see you next time." Two or three sentences at most, spoken in chat only (not written to the vault):

- **Next up:** one line naming the single most valuable thing to pick up next session. Pull it from "What's next" Priority 1 -- the specific task with its key file path, not a vague topic.
- **Suggested model:** name the Claude model tier that best fits that task, with a 3-5 word reason. Match model to task shape -- a high-capability reasoning model (Opus-tier) for deep design, synthesis, architecture, or hard debugging; a faster model (Sonnet-tier) for mechanical, harvest, or well-specified execution work. Keep it tier-generic (Opus-tier / Sonnet-tier) rather than pinning a version number, which goes stale.

Keep it tight -- the recap and model line are the last thing the user reads before the thread name, so they should land as a clear "here's where to restart and what to run it on."

### Step 5: Suggest final thread name

Suggest a final thread name for the session. Solo-operator format: `checkmark ProjectAbbrev SNN - brief description` (e.g., `√ DW S43 - Weave git migration final stage`). Multi-operator format: `checkmark PROJ_YYYY-MM-DD_INITIALS_NN - description` (e.g., `√ WV_2026-06-10_AA_01 - session ID convention update`). The checkmark prefix signals the session is complete. Base the description on what actually happened, not the provisional name from orientation.

Present the final thread name on its own line inside a fenced code block (triple backticks) with nothing else in the block, so it renders as a one-click-to-copy box in chat.

This step is intentionally last. The thread name is the signal that all session-close work is complete -- the user copies it, and the session is done.

## Output Format

The entry is a section file in the session log folder. Solo-operator example: `0.2 Session Log - Project/13.0 Session 29 - Brief Title.md`. Multi-operator example: `Session Log - Weave Project/WV_2026-06-10_AA_01 - Brief Title.md`.

**Frontmatter (solo-operator):**
```yaml
title: "Session N - Brief Descriptive Title"
type: project-doc
parent: "[[0.2 Session Log - Project]]"
section: N
created: YYYY-MM-DD
updated: YYYY-MM-DD
operator: FirstName
seed_version: "[seed: from VERSION.md]"
```

**Frontmatter (multi-operator):**
```yaml
title: "WV_2026-06-10_AA_01 - Brief Descriptive Title"
type: project-doc
parent: "[[0.2 Session Log]]"
section: "WV_2026-06-10_AA_01"
created: YYYY-MM-DD
updated: YYYY-MM-DD
operator: FirstName
seed_version: "[seed: from VERSION.md]"
```

**Content structure:**

```markdown
*Part of the [[0.2 Session Log - Project]]*

## Session N: YYYY-MM-DD (Brief Title)          ← solo-operator
## WV_2026-06-10_AA_01: Brief Title              ← multi-operator

*Orientation sweep trace (carried verbatim from the claim stub, PI Orientation Step 6): `flag sweep [PI v4.6]: N surfaced, M handled, K deferred | stubs: P stale, Q reconciled | intake: R new`. Solo projects carry the `n/a (solo)` form; a missing line means the sweep did not run -- do not omit it.*

### What happened

[Narrative of what was accomplished. Dense but readable. Group related work
under bold topic headers. Include file paths for anything created or modified.]

**Files created:** [list with full paths]
**Files updated:** [list with full paths]
**Files archived/moved:** [list if applicable]
**Status:** complete | in progress — [what's pending]

### Learnings

Each learning is a discrete, standalone observation -- a fact that's useful on its
own without needing the rest of the session context. (This is the "observational
memory" pattern: discrete facts are 4-10x more token-efficient and more searchable
than conversation summaries.)

- **category**: Description of the learning with enough context that a future
  instance searching for this topic would find it useful. Reference the source
  (decision, tool, research, conversation) that produced the insight.

Categories: pattern-confirmed, pattern-discovered, tool-behavior,
decision-validated, assumption-invalidated, edge-case,
routing-heuristic, harvest-pattern

If no learnings this session, write: "No new learnings this session."

### What's next

[Write this as if briefing a new team member who has read the 0.0 but nothing
else. This section is the handoff — it must be specific enough that the next
instance can start working immediately.]

**"What's next" is a direction, not a contract.** The items listed here are the
best guess at what's most valuable to do next, based on where this session ended.
They are NOT commitments. The next session may go in a completely different
direction if the user wants to follow a thread, go deep on something unexpected,
or if the work naturally evolves. Sessions that spend their entire context on one
deep task (a handbook deep-read, a design discussion, a complex refactor) are
just as productive as sessions that tick off five items. Never rush through work
or cut corners to get through the list. There's always a next session.

Include:
- **Specific file paths** to read first (not just topic names)
- **Why this work matters** — one sentence connecting to the larger arc
- **What depends on what** — sequence and causal chain
- **Prioritization** — what's the main focus vs side tasks
- **Key documents** — list the 3-5 most important files for the next instance
  to read, with a phrase explaining what each contains

Adapt detail to the work type:
- Research/harvest: what sources, what to extract, where output goes
- Build/migration: what spec to follow, what success looks like
- Design: what prior decisions constrain the space, what the deliverable is
- Debugging: what's broken, what was tried, where the evidence is

### Active threads

Open parallel arcs live in the Active Threads ledger: [[Active Threads - {Project}]]
(maintained in place at close -- not duplicated in the entry). For projects without
a ledger, keep the roster inline here instead -- see Step 2.6 for the legacy format
(bold numbered name, session range, 2-3 sentences of remaining work, key doc paths).
```

## Structured Format for Complex Sessions

For sessions with many moving parts (multi-file refactors, long research batches, architecture changes across several docs), the narrative "What happened" can optionally be replaced with a structured format based on the AI Agent Handbook's compaction template. This makes the session log entry function as a structured state snapshot that's easier for the next instance to parse.

Use the structured format when: the session touched 5+ files, made multiple independent decisions, or spanned multiple work phases. Use the narrative format for simpler sessions.

```markdown
### What happened (structured)

**Active goal:** [One sentence: what were we trying to achieve this session?]

**Key decisions:**
- [What was decided] -- [why / what alternatives were rejected]
- [What was decided] -- [why]

**Artifacts modified:**
- `path/to/file.md` -- [what changed and why, 1-2 sentences]
- `path/to/other.md` -- [what changed and why]

**Current state:** [What's done, what's in progress, what's blocked]

**Errors and resolutions:** [Any problems hit and how they were solved, or "None"]

**Critical context:** [Anything else a fresh instance needs to know that doesn't fit above]
```

The "Files created/updated" lists and "Status" line still apply on top of either format. The Learnings and What's Next sections are unchanged.

## Writing the Title

The session title should capture the main theme in 3-8 words. Use plain hyphens, not em-dashes. Good titles: "Session Closer Skill, Reddit Triage". Bad titles: "Various tasks and cleanup" (too vague).

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
- **Reporting a clean version-control state as if it answered "is the vault up to date."** Committed, pushed, and conflict-free says nothing about whether documents still describe reality -- trackers, indexes, and dashboard-feeding frontmatter (`deadline`, `next_action`, `status`, `stage`) can be days stale inside a perfectly clean tree. When asked whether things are current, check the *documents* and say which ones you checked.
- **Writing a correction banner that enumerates what it fixed without verifying each location.** "Sections 1, 6, 9, and 10 are corrected below" is a claim; if one was missed the banner is worse than none -- it stops the next reader from checking the very place the error survives. Verify every location you name, or describe the correction without enumerating.
- **Trusting a companion or summary doc's account of a conversation.** Compressions invent certainty: a synthesis reading "X told A and B" may rest on a transcript line "I've told them," which does not establish who heard it. For anything that shapes how you approach a person or commitment, read the source, not the summary.
- **Fragmenting one continuous session into multiple entries.** If work resumes after a close on the same day, amend the existing entry (retitling if its scope grew) rather than opening a second -- a split handoff is harder to follow. Start a new entry only when the day rolls over, or when the work is a genuinely separate workstream and the earlier entry is already committed.

## Relationship to Other Files

- **Session log shell** (`0.2 Session Log - Project.md`): Add an embed reference (`![[section filename]]`) to the shell after creating the section file.
- **Action items**: Check off completed items, add new ones. Optional but recommended.
- **Decision log**: Decisions belong as separate numbered entries. The session log references them but doesn't replace them.
- **Harvest ledger**: If harvesting was done, update `0.4 Harvest Ledger - [Project].md` with source, destinations, and agent. Source YAML should already be updated as part of the harvest checklist.

## Synthesis Check

Before closing, verify two things:

1. **Cross-cutting synthesis.** If this session involved multi-item analysis (research batches, triage passes, cross-doc comparisons), have the cross-cutting findings been captured? Synthesis degrades across context boundaries but mechanical execution doesn't. If the thinking hasn't been written down yet (as an integration memo, design doc update, or explicit "Learnings" entry), capture it now -- before the session log, not after.

2. **Knowledge transfer completeness.** The session log is a handoff document, not a knowledge store. Detailed findings, patterns, tool evaluations, and architectural implications belong in design docs, skills, and tracking files where future instances will encounter them during task-specific work. If a finding only exists in the session log, it will likely be missed -- future instances read the last 2-3 session entries for orientation, then work from design docs and skills. Always ask: "would a future instance working on [relevant topic] find this in the doc they'd naturally read?" If not, plant it there.

See [[Context and Session Management]] for the rationale.
