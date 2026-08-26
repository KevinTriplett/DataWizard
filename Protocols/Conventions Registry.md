---
title: Conventions Registry
type: protocol
created: '2026-06-13'
updated: 2026-08-26
operator: Andrew
priority: high
maturity: working
edit_log:
  - DW-S181 2026-06-13
  - "DW-S182 2026-06-13: clarified archiving banner placement for frontmatter
    files"
  - DW-S183 2026-06-14
  - "DW-S191 2026-06-21: move_note wikilink claim corrected"
  - "DW-S197 2026-06-22: added action-items priority tiers (Urgent)"
  - "DW-S206 2026-06-28: codified the bang-prefix filename retirement"
  - "DW-S218 2026-07-09: added the Tracking Model section (D108 - one canonical
    surface per fact class)"
  - "DW-S232 2026-08-04: citation section restructured block-first (D112);
    path-qualification + fetch-before-cite + convention-flip sweep rule added"
  - "DW-S232 2026-08-04: Tracking Model sub-rule 'act at commit moment for
    state, defer decisions for evidence' (insight-capture plant)"
  - "DW-S246 2026-08-05: distribution-layer 'copied state rots' paragraph (D111)
    + Seed-depersonalization one-liner (meta-learning review S221-S230)"
  - "DW-S262 2026-08-08: added Harvest via embeddable synth note section (D116;
    Weave FR adoption) + Change-governance merge-gate (D111) + Catalogs
    conventions; fixed OPSEC/D25 miscitation"
  - "WV_2026-08-10_AA_01 2026-08-10: added Operator personal / scratch folders
    section (Weave-origin, generalized + depersonalized; DW decision-log entry
    pending)"
  - "DW-S272 2026-08-18: added File placement -- three classes + Attention
    requests live in the flag cluster (Flag Surfacing Chain, D117)"
  - "DW-S278 2026-08-18: added ID families table (task-ID pointer row),
    optimistic-claim pattern, carry-the-probe, and ceremony-placement entries
    (D119)"
  - "DW-S279 2026-08-18: added The reader-path principle (named; Flag Surfacing
    Chain B2)"
  - "DW-S278 2026-08-18: inbound notes rehomed to per-project Session Exchange
    folders; _Infrastructure is infra-only, never notes (operator ruling)"
  - "DW-S284 2026-08-24: Archiving gains the consolidate-to-one-home survivor
    diff (S191); one-liners: SQLite is local / markdown is shared (D103, D107;
    S192) + per-adopter config at the consumption surface (D96; S187)
    (meta-learning review S186-S197)"
  - "DW-S285 2026-08-24: File placement gains the Seed-owned-assets exception
    (fix upstream while hot, no FR round-trip; S235) (meta-learning review
    S231-S246)"
  - "DW-S285 2026-08-24: Decision-log conventions: decision numbers are
    project-local namespaces (S262; meta-learning review S256-S266)"
  - "DW-S285 2026-08-24: Link, don't restate gains \"Pointers carry no status\" (S285 pre-close reflection; 0.0 Key Pointer rot)"
  - "DW-S287 2026-08-26: File placement gains a pointer to the Multi-Instance Coordination Patterns guide (exchange-note anatomy + handshake, canonical there)"
---

The single home for DataWizard's structural and formatting conventions. When a convention is stated here, every other document points to this entry instead of restating it.

## Link, don't restate

**Rule:** Every convention has exactly one canonical home. Everywhere else links to it rather than repeating it. A rule stated in two places will drift; a rule stated once and linked to cannot.

This registry is that home for the conventions below. Skills, guides, and project docs that touch these topics should link here (e.g., "companion naming: see the Conventions Registry") rather than carrying their own copy. The same principle governs the rest of the Seed: the YAML Schema owns field definitions, the Filename Safety guide owns the character map, the session-closer owns cadence numbers, the Content Type Taxonomy owns `type:` values. When you find a convention restated somewhere, replace the copy with a pointer.

**Pointers carry no status.** A pointer - a 0.0 Key Pointer, a "see also", a ledger `home:` line - says *where* something lives, never *what state it is in*. "(codification pending, Backlog P3)" inside a pointer is a copy of the item's state, and it will lie the moment the item moves: one 0.0 kept announcing a convention as pending for two weeks after the Registry had adopted it. State lives at the canonical item (the Backlog line, the gate row, the frontmatter `status:`); a pointer that needs to say "pending" should instead link to the thing that is pending. (DataWizard, 2026-08.)

The same law governs the **distribution layer**: copied state rots; only pointers stay true. A value copied out of its canonical home -- a version number restated in a collaborator doc, a "pinned" claim in a README, a recommended method repeated in setup instructions -- will eventually lie, because nothing forces the copy to update when the source changes. Point at the canonical source (VERSION.md, the config itself, this registry); where a copy is unavoidable, treat it as a release artifact the convention-flip sweep (below) must reconcile. Named from three instances in one arc, then re-demonstrated inside that same arc when a "pinned >=0.12.5" claim was found false across three docs while the running config said `@latest`. (D111; S226, S227, S230)

**Example:** Before this registry, the 0.x slot table appeared in three docs with three different slot lists. Now it appears once (below); the Protocol shell, the health-audit skill, and the project-guidelines skill link to it.

---

## Infrastructure file slots (0.x)

**Rule:** Infrastructure files use a fixed `0.x` numeric prefix so they sort to the top of a project folder and occupy the same address in every project. Three tiers:

**Fixed core (0.0-0.5)** - present in every project, identical meaning everywhere:

| Slot | File | Purpose |
|---|---|---|
| 0.0 | Project Guidelines | Project brief and operational reference; first file read at orientation |
| 0.1 | MOC | Generated map of contents, for file-findability |
| 0.2 | Session Log | Maintenance diary (shell + sections) |
| 0.3 | Decision Log | Architectural memory (shell + sections) |
| 0.4 | Harvest Log | Content provenance routing index |
| 0.5 | Action Items | Tactical backlog |

**Reserved standard (0.6-0.13)** - standardized *if present*, not required:

| Slot | File |
|---|---|
| 0.6 | Registry (Git / Connector / Artifact, consolidated) |
| 0.7 | Quest Log |
| 0.8 | Health Audit Log |
| 0.9 | Quest Dashboard |
| 0.10 | Team Dashboard |
| 0.11 | Content-interest scan log |
| 0.12-0.13 | Unassigned reserve |

**Project-local (0.14+)** - free for project-specific infrastructure; record assignments in the project's 0.0.

**Why tiers:** the mandatory surface stays small for adopters, while optional infrastructure has a known address. This resolves cross-project collisions (one project's 0.8 Team Dashboard vs another's 0.8 Health Audit Log) without renaming live, link-rich files. (D84)

**Example:** This project's set is 0.0-0.5 core, plus 0.6 Registry, 0.7 Quest Log, 0.8 Health Audit Log, 0.9 Quest Dashboard, and 0.11 scan log. A lightweight adopter project might ship only 0.0-0.3.

Files are named `0.N Title - ProjectName.md`; the ProjectName suffix disambiguates across a multi-project vault.

---

## Meta-folders

**Rule:** Each project keeps three meta-folders, prefixed to sort and suffixed to disambiguate:

| Folder | Holds |
|---|---|
| `_Infrastructure - ProjectName/` | 0.x infrastructure files |
| `_Sections - ProjectName/` | section subfolders for every shell + section document |
| `xArchive - ProjectName/` | retired and superseded files |

The `_` prefix sorts active meta-folders to the top and is shell-safe (no escaping needed in zsh/bash). The `x` prefix sorts the archive to the *bottom*, where dead files belong. The `- ProjectName` suffix prevents ambiguity when several projects share one vault. (D71, D74, D87)

**Example:** `_Infrastructure - DataWizard/`, `_Sections - DataWizard/Session Log/`, `xArchive - DataWizard/`.

---

## Operator personal / scratch folders

**Rule:** An operator may keep a personal, eponymous folder at the project root as a scratchpad / notebook. It holds anything not meant for the shared vault: **ephemeral** docs (meeting- or event-scoped, stale afterward), **private** notes (not intended for anyone else to read), and **not-yet-ready** drafts (unshared work in progress). The point is less clutter in the shared vault - the personal folder absorbs low-stakes and in-progress material so the shared strategy and workflow folders stay reserved for durable, shareable content. Ephemeral items carry `maturity: ephemeral`; unfinished ones use `maturity: draft`. A note can **graduate** out of the personal folder into the wider vault when it is ready to share (move with `move_note` and fix references). Durable synthesis, companions, and decisions route to their normal shared homes directly, never via the personal folder. (Weave, 2026-08)

**Example:** an operator's `<Name>/` folder holds a meeting running-order (ephemeral), a rough idea not yet shared, and a team draft not ready for review; when the draft is ready it graduates into the appropriate shared folder.

---

## Catalogs

**Rule:** The Seed keeps two parallel catalogs, each the single index for its kind: **`SKILLS.md`** lists every skill (triggered workflows) and **`GUIDES.md`** lists every guide (operational and platform/environment references). A new skill or guide is registered in its catalog on creation; the catalog is the discovery surface, not a place to restate the item's content. Guides that retire keep an `xArchive -` filename prefix and drop out of the catalog. Protocols (this registry, the YAML Schema, the taxonomy) live in `Protocols/` and are not catalogued the same way -- they are few and cross-referenced directly.

**Example:** the Platform and Environment Behaviors guide cluster is enumerated in `GUIDES.md`; a new platform-gotcha guide is added there so instances can find it. (S195)

---

## File naming

**Rule:**

- **Content section files** (shell + section documents) use `[section].[subsection]` numbering from `1.0`: `1.0 Introduction.md`, `2.0 Strategy.md`, `2.1 Near-Term.md`. Insert between existing sections with intermediate decimals (`2.5 ...`). **Never renumber** existing sections - other notes link to them by filename. Each section file opens with `*Part of the [[Shell Name]]*`.
- **Per-document session logs** use `0.01 Session Log - [Doc Name].md`, to distinguish from the project-level 0.2.
- **Domain folders** take the project name as a prefix when the project has a dominant name (`Weave Events/`, `Weave Resources/`), clustering them in search and Finder. (D74)
- **Project guidelines** is always `0.0 Project Guidelines - ProjectName.md`.
- **START HERE files are retired** (D62). Human onboarding lives in 0.0; Claude setup lives in a Seed guide. Do not create new ones.
- **The `!` filename prefix is retired** (S116 / PI v4.0). Do not prefix note filenames with `!` to force sort order; use the `0.x` infrastructure slots or a plain descriptive title. This does not affect the `_!nbox/` intake folder or the optional inline `!!` / `!` urgency markers in 0.5 - those are a folder name and in-doc markers, not note-name sort prefixes.
- Use descriptive titles, not codes. Hyphens for multi-word YAML values (`video-transcript`). ISO dates in filenames (`YYYY-MM-DD`).

For the full cross-platform character map (forbidden characters, replacements, sanitization), see the **Filename Safety guide** - that is the one home for filename character rules. This entry covers structure and numbering only.

**Example:** a research doc that outgrows one file becomes shell `Research Notes.md` plus `_Sections - ProjectName/Research Notes/1.0 Background.md`, `2.0 Findings.md`.

---

## Shell and section architecture

**Rule:** large documents split into a *shell* (assembly surface) plus *section files* (content).

- The **shell** contains only `![[embed]]` references - never edit it directly. Section files hold the content - always edit those.
- Section files live in `_Sections - ProjectName/<ShellName>/`, a subfolder mirroring the shell's name. Section folders are siblings of shell folders, not children.
- Shells live in the domain folder appropriate to their content; lightweight projects may keep a shell at the project root.
- Numbering starts at `1.0` (`0.x` is reserved for infrastructure files). Section headers use plain numeric prefixes matching the filenames - no Roman numerals.
- Section YAML carries `parent: "[[Shell Name]]"` and `section: N` (matching the filename prefix); each section file opens with `*Part of the [[Shell Name]]*`.
- **5+ sections** in a document - create the section subfolder rather than leaving the files loose.
- **Splitting an existing file:** write the section files first and verify they landed, *then* rewrite the original as the shell. The extract exists on disk before the destructive step, so no content is ever at risk if the rewrite fails or is interrupted. (DataWizard, 2026-06)
- Empty folders can't be deleted via MCP (the vault FUSE mount blocks it); when files are moved out, the human deletes the empty folder manually in Obsidian.

**Example:** `0.2 Session Log - DataWizard.md` is a shell of `![[...]]` embeds; each entry is a file in `_Sections - DataWizard/Session Log/`, numbered from `1.0`.

---

## Companion notes

**Rule:** Enrichment output goes in separate companion notes, never in-place edits to the source. Companions use the `c_` prefix with **no space**: `c_source-title.md`. They live under `_Companions/`, with subfolders mirroring the source folder names (`_Companions/_Clippings/` for sources in `_Clippings/`). Every companion is `type: companion`; corpus-mode enrichment is marked by a `corpus_context:` field, not by a different type. (D83, S179)

**Example:** source `_Clippings/biophysical-orgonomy.md` produces `_Companions/_Clippings/c_biophysical-orgonomy.md` with `type: companion`.

---

## Harvest via embeddable synth note

**Rule:** When a harvest routes to **multiple destinations, or to a destination that is contested or not yet ready** (mid-edit under concurrent operation, or awaiting a team decision), harvest once into a single `c_` companion built from self-contained, **embeddable** `##` sections, and let each destination transclude the section it needs (`![[synth-note#Section Name]]`) rather than copying the content in. This is "link, don't restate" applied to harvest output -- the content lives in one place, propagation is by embed, and editing a section updates every doc that embeds it. When a harvest routes cleanly to a single ready destination the instance owns, direct synthesis (the standard harvest skills) is simpler -- reach for this pattern only when fan-out or a not-ready destination earns it.

**Structure of the synth note:**

- **Weave-in sections.** Each `##` section reads cleanly when transcluded on its own and carries a one-line source/provenance tag, so provenance travels with the embed.
- **Embed Map.** A table near the top: one row per weave-in section giving its destination doc, the exact `![[synth-note#Section Name]]` string to paste, and a **route** marker -- `embed` (transclude into a working doc) or `native` (write the content in directly, then keep the synth-note section as provenance). Logs, decision records, and trackers are `native` by default -- they want to be self-contained and append-only.
- **Team-download header.** A synopsis section at the very top -- 2-3 plain-language sentences on the source plus a "where it landed" list linking each destination. Flag *this synth note* for the team (a file-level flag whose `flag_note` points at the synopsis), not the raw source.
- **`embed_targets` YAML** on the synth note lists the onward destinations so the flow is machine-scannable -- the second provenance hop after the source's `harvested_into`. Field definition: [[YAML Schema]]. Provenance model: [[Harvest Provenance Architecture]].

**Workflow:**

1. **Overlap check first.** Before adding a section, check whether the destination already covers it (the target-section overlap check design-harvest uses). If it does, a cross-reference beats an embed.
2. **Harvest into the synth note** as weave-in sections, build the Embed Map, write the team-download header, and flag the synth note.
3. **Per-section sensitivity.** Mark any confidential section inline -- a confidential section is never embedded or graduated into a funder-facing or public doc, per the project's confidentiality rules.
4. **Destinations transclude when their owning thread is ready** -- placement is separated from the act of harvesting and can wait.
5. **Resolves-open-questions cross-link.** When a section closes open questions living in a destination, the embed lead-in names which items it resolves, and the resolved items are struck in place.
6. **Graduate when a destination must be self-contained** (e.g. a funder-facing export): replace the embed with native content, then retire the embed -- the synth note remains as provenance.

**Heading stability.** A section-embed breaks silently if the synth-note heading changes -- an empty transclusion still looks fine in the destination. Weave-in headings must be stable and filename-safe (no em-dashes, curly quotes, or colons -- same discipline as patch anchors, Working Rule 8). **Close step:** verify on disk (a filesystem read, not the MCP reader -- Working Rule 10) that every `##` heading in the synth note exactly matches its `![[synth-note#Section Name]]` string in every destination.

**Example:** a call harvested into `c_2026-08 Team Sync` routes a "Fundraising status" section (`embed`) into a working plan via `![[c_2026-08 Team Sync#Fundraising status]]`, and a "Decision - entity choice" section (`native`) into the Decision Log; the synth note carries `embed_targets` listing both and is flagged for the team while the raw transcript is not. (D116; validated twice -- Weave, 2026-08.)

---

## Archiving

**Rule:** when a file is superseded or retired, **move it, don't delete it** (delete only empty stubs, with human confirmation).

- **Where:** the project's `xArchive - ProjectName/` (or a vault-root `xArchive/` for vault-level files).
- **How:**
  1. Move the file with `obsidian:move_note`, then fix references by hand. **`move_note` does NOT reliably update wikilinks** (proven 3x, S189: an MOC list entry, a `related:` frontmatter field, and a manifest table row all kept the old name). After the move, grep the literal old filename vault-wide and fix every reference - `[[wikilinks]]`, frontmatter `related:` fields, and list entries; lint's broken-link check confirms. (Full behavior: [[MCP Reliability and Write Verification]] guide.) Do **not** leave the file in place with just a notice - it must move.
  2. **Keep the original filename** so existing wikilinks still resolve.
  3. Add a banner at the top of the body: `> ⚠️ **Archived (YYYY-MM-DD).** Superseded by [[New File]]. Retained for historical reference.` For files with YAML frontmatter, insert it *after* the closing `---` (e.g. via `patch_note` in front of the first body line); prepending raw text pushes the frontmatter below line 1 and breaks it.
  4. Note the archive in the session log; remove the file from active MOC listings.
- **Filename exception:** if the replacement reuses the same filename (e.g., a regenerated file), the archived copy must be renamed to avoid collision; add the reason in parentheses, e.g. `0.1 MOC - ProjectName (hand-curated, superseded SNNN).md`.
- **Don't archive:** files that are merely old but still active; files you only moved; content outside your project scope (flag those to the human).
- **Consolidating to one home:** when the archive is the retired half of a duplicate-to-one-home merge, diff the retired file against the survivor *before* archiving and carry over any load-bearing content the survivor lacks. Confirming "the duplicate is archived" is not the closeout; "the survivor carries everything" is. (A protocol demolition archived a federation-guide duplicate whose "full copies only" rule the surviving guide did not have; caught two weeks later. DataWizard, 2026-06.)

(14.0 salvage, D87)

**Example:** `Old Strategy.md`, superseded by `Strategy v2.md`, moves to `xArchive - ProjectName/Old Strategy.md` (filename kept) with the banner.

---

## Citation format

**Rule:** cite with a trailing parenthetical wikilink whose anchor deep-links into the source. For all new material the **default granularity is the block** - `^bN` for a document paragraph, `^tN` for a transcript turn - so a citation points at the specific paragraph or turn that backs the claim, not the whole section:

```
([[SourceFileName#^b7|§]])        document block (glyph display)
([[SourceFileName#^t15|@22:15]])  transcript turn (timestamp display)
```

Block-default changes *which anchor you reach for*, not *when you stamp*: stamping stays **on cite, sparse, never in bulk** - a block gets its ID only when something actually cites it, never a pre-stamp pass (S173). Assign the next unused integer per file; never renumber, and never re-stamp a block that already has an ID. IDs are sparse, so `^b9` is a stable handle, not "the 9th block." The visible label is a `§` glyph for document blocks and the cited turn's own `@mm:ss` timestamp for transcript turns (confirmed S236; the `§` fallback applies only when the turn has no derivable timestamp, e.g. an unsegmented or headerless transcript); multiple blocks in one bullet repeat the glyph, each its own link (`(§, §)`). Block IDs are hidden in Obsidian reading mode and are the human breadcrumb layer; where a RAG index exists a block ID aligns with its chunk coordinate, but the index computes full coordinates independently.

**Scope.** The block-default governs new material citing an *in-vault source at claim granularity* - companion bullets and synthesis claims. It does not govern whole-document backlinks (`source:` YAML), `harvested_into:` routing, Message Log citations, external URLs, or citations to a source the instance cannot stamp (read-only mounts, PDFs, other vaults) - those keep their own forms.

**Section-anchor fallback.** A `#Section` anchor is the named fallback, for exactly two cases: (1) the claim genuinely synthesizes a whole section (a legitimate whole-section citation, not false precision), or (2) the source is not block-addressable at cite time (an unsegmented transcript, or a source out of stamping reach). Whole-section companion synthesis uses the `§` label; harvest destinations keep their date-and-section label:

```
([[NoteTitle#Section Header|§]])                                    whole-section companion synthesis
([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]])             harvest destination
([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]] — Speaker)   harvest destination with speaker
([[NoteTitle|YYYY-MM-DD — Note Name]])                              no-header fallback (note title only)
```

Companions are block-default; **harvest destinations keep section-default with block/turn-when-specific** (their label-format precision is a separate open question). This section is the canonical statement of why the two regimes differ - skills point here rather than restating it.

Rules: citations go at the **end** of a statement; one per claim is usually enough; ISO dates; a `#anchor` must exactly match a heading in the source (this is why transcripts are segmented before harvesting). **Cite only what you have read** - a citation asserts the cited block was actually read, not recalled. **Colliding basenames:** when two files share a basename, path-qualify the link so Obsidian resolves deterministically - `([[Folder/Name#^b7|§]])`.

**Source tags (optional):** for documents that cite many sources repeatedly, register short uppercase tags (`[MAR3]`, `[SP]`) in the project's source-reference doc and use them inline. Tags supplement wikilink citations, they don't replace them. Adopt only when full wikilinks become unwieldy.

Full spec: [[Citation Mechanism - Block-Level Provenance]].

**Example:** `the unit of account shifts from currency to contribution ([[2026-03-04 Strategy Call#Unit of Account|§]]).`

---

## Message Log pattern

**Rule:** for high-volume async communication (voice notes, texts, Claude syntheses), a consolidated **Message Log** beats one-note-per-message. Aggregate by person, then by date:

```markdown
## Person Name

### YYYY-MM-DD

(raw message content)

## Another Person

### YYYY-MM-DD

(raw message content)
```

Use it when multiple collaborators send frequent short messages. Keep individual notes when a message is long, self-contained, or needs its own YAML for pipeline processing. Cite a message with the person-heading + date anchor:

```
([[Message Log#YYYY-MM-DD|INITIALS msg YYYY-MM-DD]])
```

(11.0 salvage)

**Example:** `Message Log.md` with `## Jordan` / `### 2026-02-20`, cited as `([[Message Log#2026-02-20|JL msg 2026-02-20]])`.

---

## Decision-log conventions

**Rule:** decisions are logged with sequential, never-reused IDs.

**Entry format:**

```markdown
### D[number]: [Short title]
**Decision**: What was decided, clear enough to stand alone.
**Rationale**: Why; what alternatives were rejected.
**Date**: YYYY-MM-DD
**Protocol updated:** Yes | No - [reason] | Not applicable
```

Optional fields when relevant: **Supersedes** `D[n]`, **Resolves** `Q[n]`, **See** `[[doc]]`, a status note for provisional decisions.

**Decision numbers are project-local namespaces.** `D25` in one project's log is unrelated to `D25` in another's. A cross-project note (handoff, feature request, review) that cites a decision number is citing the *source* project's log unless it says otherwise - resolve every inbound D-reference against the target project's Decision Log before acting on it, and when writing outbound, qualify the number with the project (`Weave D25`). An inbound request once cited a source-project decision as if it were the target's; the target's same-numbered decision was about something else entirely. (DataWizard, 2026-08)

- **Numbering:** sequential (`D01`, `D02`, ...); never reuse a number. Supersede by marking the old entry and referencing the new one - preserve the full history of thinking.
- **Open questions** use `Q[number]`; when resolved, mark `Resolved -> D[number]`.
- **Protocol-updated flag** (D77) on every convention-changing entry makes uncodified changes greppable (`grep "Protocol updated: No"`).
- One decision log per project, created at bootstrap.

**Which log to update:**

```
New content from a source                 -> session log + harvest log + source YAML
Structural fix or maintenance             -> session log only
Content moved between documents           -> session log (harvest log only if routing changed)
Meaningful design/architecture choice     -> decision log + session log (brief note)
```

(5.0 salvage + D77)

**Example:** D77 itself uses Decision / Rationale / Date plus `**Protocol updated:** Not applicable`, because it is a meta-convention about the log rather than a protocol-doc change.

---

## Change-governance merge-gate

**Rule:** A pull request or collaborator change that alters a **recommended tool, connection method, architecture, or operator-facing setup instruction** requires a **logged decision before merge** -- it must not ride in as a documentation edit. Merging such a change silently adopts a de facto architecture or tooling decision; the decision log is where that choice is made deliberately and greppably, not the diff. Kin to "change the value, check the rationale" (a value change is visible everywhere it is used, but its justification lives in one doc and dies silently) and to the Tracking Model's act-at-the-commit-moment discipline. (D111)

**Example:** a docs PR that switches the recommended MCP connection method is gated -- log the decision (rationale plus the alternatives rejected) first, then merge. The failure mode this guards against: an unlogged method switch that stood as a doc/reality divergence for roughly 40 sessions before anyone caught it.

---

## Priority and maturity vocabularies

**Rule:** two distinct vocabularies; do not mix them.

- **Documents** carry `priority: high | medium | low` (attention) and optionally `maturity: draft | working | polished | canonical` (how settled the content is).
- **Quests** carry `priority: 1 | 2 | 3` (1 = highest), per the Quest Lifecycle protocol.

**Example:** this registry is `priority: high`, `maturity: working`. A quest backlog item is `priority: 2`.

---

## Action-items priority tiers

**Rule:** the 0.5 Action Items file orders work by urgency tier, top to bottom: **Urgent** (drop everything - address next session at the latest; use sparingly) -> **This Session / Next Session** (the hot list) -> **Soon** (~2-5 sessions out; sub-tiered P1 / P2 / P3, P1 highest) -> **Blocked / Waiting** (note the blocker) -> **Done** (dated, with brief resolution; archive when long). An item's tier is its section; the inline `!!` / `!` markers are an optional secondary signal, not a replacement. **Urgent** is distinct from the Seed Assessment Action Plan's P0-P6 phase labels - those are project-overhaul phases, a different axis from backlog urgency.

**Example:** the S197 session-claiming-collision fix sits under Urgent; a 5-sessions-out idea sits under Soon / P3.

---

## Tracking Model

**Rule:** work tracking follows the same discipline as knowledge tracking: **one canonical surface per fact class; everything else points, nothing restates.** A fact written on two surfaces will drift (D105, D108). The registry of fact classes:

| Fact class | Canonical surface | Everything else |
|---|---|---|
| An arc exists / where its truth lives | Active Threads ledger row | session logs point |
| Step state within a driver-doc arc | the driver doc's **State Board** | ledger `next:` points; backlog item slims to a pointer |
| Tactical next 1-3 sessions | 0.5 Backlog | - |
| Recommended entry point for the next session | the session log's "What's next" (one-session TTL) | everything else in "What's next" points, never restates |
| Carried side/native task lists | a durable queue doc (e.g. a Native Run Queue) | "What's next" points |
| Stream position (perpetual threads) | the stream-state note (D107) | db mirror optional, derived |

Sub-rules:

- **State Boards:** one table per driver doc - step / status / remaining / runtime / last touched. Status is an enum (`not started | in progress | blocked | done`); commentary lives outside the Status cell. Maintained **on advance** (patch the row the moment a step's state changes), **verified** at session close - the same argument that made stamp-on-cite beat bulk-stamping.
- **Act at the commit moment for state; defer decisions for evidence.** The rule the State Board and stamp-on-cite both instantiate, generalized: state that must stay consistent with reality - display labels, version pins, board state, breadcrumbs, indexes - is updated at the moment it changes; deferring it to a later bulk pass costs in proportion to what accumulates in between. This is *not* "never defer" - *decisions* correctly wait until evidence exists (open questions, dry-run-then-apply, deferred indexing). The tell: if leaving it stale makes a live surface **lie**, it is state - act now; if acting early would commit you to an unvalidated choice, it is a decision - wait. (Named S232.)
- **Commit-moment rule:** every thread class anchors tracking updates to its own commit moment - normal sessions at close; perpetual threads at the batch/cursor write (they never close).
- **Orientation follows the pointer:** when the active arc's ledger row points at a State Board, orientation reads the board. Pointer-following is reliable only when a protocol step forces it.
- **Hand-maintained canonical surfaces get machine drift-checks** - they lack the generated-view protection knowledge surfaces have (lint checks; reconsolidation passes carry the diff until a check exists).
- **Retirement is detected, not scheduled:** a driver doc whose board is all-terminal but whose `status:` is still active triggers a retirement ceremony in the next reconsolidation pass - reconcile the board, rehome residuals, flip status, archive satellite queue docs.
- **Model-gap findings land here:** when a reconsolidation or design review surfaces a fact class with no canonical surface (or two surfaces claiming one fact), amend this table - do not scatter the finding into tactical backlogs.

(D105, D107, D108; design: [[RTI Federation and Tracking Model - Stress Test S218]], [[RTI Federation - T1 Design Review S217]])

**Example:** the T1 arc - ledger row says the arc is active and points at [[RTI Federation - Substrate Coherence Build Plan]]'s State Board; the board holds step state; the Backlog carries a pointer item; the Native Run Queue holds the carried native tasks; "What's next" says which of these to start on and points.

---

## ID families

**Rule:** Every identifier family answers three questions in one place: where a value is *defined*, what scope it must be *unique* in, and how the next one is *minted*. One row per family; a new family adds its row here at creation instead of improvising - the triad is cheap to fill while the thinking is hot and expensive to reconstruct after drift. (DataWizard, 2026-08)

| Family | Format | Definition site | Minting rule | Uniqueness scope |
|---|---|---|---|---|
| Session IDs | `SNNN` (solo) / composite (multi-operator) | session log section folder (claim stub) | optimistic claim: next free above highest entry and any in-progress stub | project |
| Decision IDs | `DNN` | decision log entry | next sequential; never reused - supersede instead | project |
| Open questions | `QNN` | decision log open questions | next sequential | project |
| Thread IDs | `TNN` | Active Threads ledger row | next free on arc open | project |
| Gate IDs | `G-NNN` | Operator Gate Queue row | next free at queue feed | project |
| Quest IDs | `XX-Q-NNN` | quest file frontmatter (`quest_id`) | next free across active quests + archive | project |
| Task IDs | `PREFIX-NNNNN` | checkbox line in the quest layer | scan-max + verify-after-mint - see the **Quest Lifecycle** protocol (canonical home) | project (scan scope = active quests + archive + quest index) |
| Intake titles (FRs, bug reports) | descriptive filename | the intake folder | filename uniqueness; descriptive, not coded | intake folder |

The Task IDs row is the worked example: its definition-site / scope / minting triad took a three-session design arc to settle after live collisions in two projects; filling the row at family creation is the cheap alternative.

**Example:** a new "experiment IDs" family gets its row (format, definition site, minting rule, scope) before the first ID is minted.

---

## Optimistic-claim pattern

**Rule:** When two sessions can contend for one resource (an ID slot, a filename, a shared row), claim it by **writing, then reading back, then retrying on loss**: write your claim, re-read to confirm your value survived, and on loss take the next free slot and re-verify. No locks, no coordinator - convergence comes from each claimant renumbering only its own claim. Named instances, each canonical in its own home: session claims (the orientation claim ceremony), MCP write verification, task-ID minting (Quest Lifecycle). Any future two-sessions-one-resource problem is answered by "apply the optimistic-claim pattern, scope = X" - not a new design session. (DataWizard, 2026-08)

**Example:** two parallel sessions both mint task ID N+1; each re-searches after writing, at least one sees the double definition, renumbers its own line, and re-verifies.

---

## Carry the probe, not the snapshot

**Rule:** A handoff, brief, or design doc that cites live state another session will act on ships the **query** (the grep/search) alongside or instead of the result, with the instruction to regenerate at execution time. A bare count is stale on arrival - in one design arc, live-state numbers went stale within hours of being written, twice. Corollary: never ship a truncated result (a `| head`-capped listing) as evidence - list the whole window or ship the probe. (DataWizard, 2026-08)

**Example:** a repair handoff says "residual counter fields: run `grep -rl '^next_task_id' <quest folder>` at execution time" rather than "4 files have residual counters."

---

## Ceremony joins existing ceremony moments

**Rule:** A new verification or bookkeeping step must attach to an existing ceremony moment - orientation, the write/mint moment, or session close - never create a new one. Individually-justified checks accrete; the ceremony diet survives only if the number of *moments* stays fixed even as checks move in and out of them. (DataWizard, 2026-08)

**Example:** task-ID uniqueness is checked at the mint moment (verify-after-mint) and at existing lint/audit cadence - not via a new session-closer step.

---

## Cadence

**Rule:** periodic-review cadence numbers (health audit, meta-learning review, content-interest refresh) live in **exactly one place: the session-closer's thresholds table**. Every other doc describes the nudge without quoting a number. To change a cadence, edit that table; don't restate the value here. (D88)

**Example:** "Run a health audit roughly every cadence interval" - the session-closer thresholds table holds the current number.

---

## Operational one-liners

- **Bulk vault edits:** for batch YAML or filename changes, use MCP tools (`obsidian:update_frontmatter`, `obsidian:move_note`) directly rather than Obsidian plugins. Full rationale: Decision Log **D44**.
- **Check `harvest_status` before reading a source:** before harvesting or processing a source file, read its `harvest_status` (and related provenance YAML) first, so already-processed material isn't re-harvested. A cheap guard against duplicate work in the pipeline.
- **Git push before batch ops:** before running any script that bulk-moves or modifies vault files, commit and push first. `git checkout .` is then the undo if a batch run goes wrong.
- **Sweep on a convention flip:** when a convention or default here changes, grep the Seed and project docs for the *old* rule's signature phrases and reconcile each hit - convert it to a pointer, fix the stale value, or consciously retain it (retention is the last resort, and record the retained ones). Patching only the sections you remember misses drift. (S225 Build 3.)
- **Seed content ships depersonalized:** the Seed goes to other users, so Seed-bound content stays generic -- no vault names, collaborator names, or operator initials. Render provenance as `(project, date)` -- e.g. `(Weave, 2026-08)` -- matching the environment guides' existing style. Frontmatter-provenance policy and the legacy sweep are tracked in the DW Backlog's Seed de-personalization sweep item. (S227, S243)
- **SQLite is local, markdown is shared:** per-project databases are gitignored, and a SQLite file on a file-sync folder (Dropbox, iCloud) with concurrent writers can corrupt - so cross-machine sharing is always text: committed rendered markdown plus a key export, never the live db. The db is a rebuildable local cache; markdown is the durable shared record; they round-trip via render / migrate scripts. Applies to every db-backed store (operational db, intake queue). (D103, D107; DataWizard, 2026-06)
- **Per-adopter config lives at the consumption surface,** never in a shipped git-tracked file - a pull clobbers it. Paths go in the gitignored `Vault Config.md`; the project home folder goes in the pasted Project Instructions or the vault-root CLAUDE.md. Same class as the Vault Config gitignore decision. (D96; DataWizard, 2026-06)

---

## File placement -- three classes

**Rule:** Files sort into three placement classes by *audience*, not by the writer's location:

- **Project infrastructure** -- the 0.x series, `Conventions/`, `Quests/`: lives in `_Infrastructure - ProjectName/`.
- **Inbound notes** -- notes FROM another project (or DW) addressed TO this project (handoffs, "Note from X - ..."): live in the target project's **`Session Exchange/`** folder (created on first use; under the project's Workshop folder when one exists, else at the project's shared root), because this project's instances are the audience. Infrastructure folders (`_Infrastructure - ProjectName/`) hold infrastructure files ONLY - never notes; a note filed there mixes audience-facing mail into the 0.x surface. (Operator ruling, DataWizard, 2026-08.)
- **Outbound items** -- feature requests, bug reports, skill requests, or handoffs addressed to ANOTHER project: file directly at the **target project's intake folder**, never in the origin's `_Infrastructure/`. The origin keeps only a session-log line recording what was filed where; a pointer stub is optional and discouraged (it becomes clutter). **Exception - Seed-owned assets:** a defect in a Seed skill, guide, protocol, or script that surfaces while working in another project is fixed upstream in the Seed directly, while the context is hot, and recorded in that project's session log - not filed as a feature request and round-tripped. The outbound-intake rule exists because another project's repo is theirs to change; the Seed is shared, so the instance that found the defect is already the right one to fix it. (Weave field reports fixed same-day in the Seed, 2026-08.)

Each project names its intake folders in its 0.0 so "the target's intake" is unambiguous; without a named intake, writers fall back to origin-side filing. **Rationale:** an item routed by the writer's convenience (file it where I am) rather than the reader's path (file it where they look) fails silently while looking like infrastructure -- the same failure class as an undelivered flag. One project accumulated eleven outbound feature requests in its own `_Infrastructure/`, unread, before the pattern was caught. (Weave pilot, 2026-08; Flag Surfacing Chain.)

**Example:** a DataWizard feature request written during a Weave session is filed in `_DataWizard/Workshop - DataWizard/Feature Requests/`, with a one-line record in the Weave session log -- not in Weave's `_Infrastructure/`.

The anatomy of a Session Exchange note - filename pattern, `audience` / `status` handshake, turn-taking - and the coordination patterns that use it live in `Guides/Multi-Instance Coordination Patterns.md` (canonical home); this entry governs placement only.

---

## The reader-path principle

**Rule:** Route every coordination artifact by the reader's path, not the writer's convenience: *artifacts routed by the writer's convenience rather than the reader's path fail silently, while looking like infrastructure.* The design test for any coordination feature -- a flag, a handoff, a request, a notice -- is: who reads this, and does their path cross it? If nothing in the reader's routine (orientation, a swept folder, a queried field) crosses the artifact, it is undelivered no matter how well it is written. Orientation is the one guaranteed choke point where a reader's path can be enforced.

This is the general principle under the two entries adjacent to it (file placement by audience; attention via the flag cluster) and under the orientation sweep itself (D117). Evidence class: one project measured its flag system at 0% delivery twice, accumulated eleven outbound feature requests unread in its own infrastructure folder, and left a five-month fork diagnosis buried in an unrelated note -- all artifacts that looked done at write time. (Flag Surfacing Chain, 2026-08; rollout guidance in `Seed/Guides/Team Attention Rollout.md`.)

---

## Attention requests live in the flag cluster, not banners

**Rule:** A request for another operator's action is carried by the `flag*` cluster (YAML Schema, Team Coordination Fields), where the orientation sweep and dashboard queries find it -- never by a prose banner or callout alone. A banner may *repeat* a flagged request for a reader already in the file, but a banner is not a delivery mechanism: nothing queries prose, so an action-request that lives only in a banner reaches no one who is not already reading that file. (Flag Surfacing Chain, 2026-08; D117.)

**Example:** a callout reading "needs sign-off from another operator" at the top of a doc does not deliver -- set `flag_for` with a `flag_note` stating the decision, and let the sweep surface it; the callout may echo it for in-file readers.

---

*Birth-metadata and field definitions live in the YAML Schema; `type:` values live in the Content Type Taxonomy. This registry covers structural and formatting conventions only.*
