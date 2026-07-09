---
title: Conventions Registry
type: protocol
created: '2026-06-13'
updated: '2026-07-09'
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
---

The single home for DataWizard's structural and formatting conventions. When a convention is stated here, every other document points to this entry instead of restating it.

## Link, don't restate

**Rule:** Every convention has exactly one canonical home. Everywhere else links to it rather than repeating it. A rule stated in two places will drift; a rule stated once and linked to cannot.

This registry is that home for the conventions below. Skills, guides, and project docs that touch these topics should link here (e.g., "companion naming: see the Conventions Registry") rather than carrying their own copy. The same principle governs the rest of the Seed: the YAML Schema owns field definitions, the Filename Safety guide owns the character map, the session-closer owns cadence numbers, the Content Type Taxonomy owns `type:` values. When you find a convention restated somewhere, replace the copy with a pointer.

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
- Empty folders can't be deleted via MCP (the vault FUSE mount blocks it); when files are moved out, the human deletes the empty folder manually in Obsidian.

**Example:** `0.2 Session Log - DataWizard.md` is a shell of `![[...]]` embeds; each entry is a file in `_Sections - DataWizard/Session Log/`, numbered from `1.0`.

---

## Companion notes

**Rule:** Enrichment output goes in separate companion notes, never in-place edits to the source. Companions use the `c_` prefix with **no space**: `c_source-title.md`. They live under `_Companions/`, with subfolders mirroring the source folder names (`_Companions/_Clippings/` for sources in `_Clippings/`). Every companion is `type: companion`; corpus-mode enrichment is marked by a `corpus_context:` field, not by a different type. (D83, S179)

**Example:** source `_Clippings/biophysical-orgonomy.md` produces `_Companions/_Clippings/c_biophysical-orgonomy.md` with `type: companion`.

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

(14.0 salvage, D87)

**Example:** `Old Strategy.md`, superseded by `Strategy v2.md`, moves to `xArchive - ProjectName/Old Strategy.md` (filename kept) with the banner.

---

## Citation format

**Rule:** cite with a trailing parenthetical wikilink whose anchor deep-links to a `##` heading (or a `^block-id`) in the source:

```
([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]])
```

With speaker attribution:

```
([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]] — Speaker)
```

No-header fallback (cite the note title only):

```
([[NoteTitle|YYYY-MM-DD — Note Name]])
```

Rules: citations go at the **end** of a statement; one per claim is usually enough; ISO dates; the `#anchor` must exactly match a heading in the source (this is why transcripts are segmented before harvesting).

**Source tags (optional):** for documents that cite many sources repeatedly, register short uppercase tags (`[MAR3]`, `[SP]`) in the project's source-reference doc and use them inline. Tags supplement wikilink citations, they don't replace them. Adopt only when full wikilinks become unwieldy.

**Block-ID anchors (standard).** Section (`##`) anchors are the default granularity. When a citation must point at a *specific paragraph or transcript turn* - the breadcrumb from a synthesis or harvest claim back to its exact source - that block gets an Obsidian block ID and the citation targets it:

```
([[SourceFileName#^b7|§]])        document block (glyph display)
([[SourceFileName#^t15|@22:15]])  transcript turn (timestamp display)
```

Conventions: `^bN` for document blocks, `^tN` for transcript turns. The visible label is a `§` glyph for blocks and the `@mm:ss` timestamp for transcript turns; multiple blocks in one bullet repeat the glyph, each its own link (`(§, §)`). Blocks are stamped **on cite, not in bulk** - during enrichment or harvest, only where something actually references them - so sources accumulate IDs only where they have been cited, and header-less prose (bold dividers, no `##`) goes straight to block-level. Assign the next unused integer per file; never renumber, and never re-stamp a block that already has an ID (re-stamping breaks live citations - S173). IDs are sparse, so `^b9` is a stable handle, not "the 9th block." Block IDs are hidden in Obsidian reading mode and are the human breadcrumb layer; where a RAG index exists a block ID aligns with its chunk coordinate, but the index computes full coordinates independently. Whole-section synthesis uses the section-anchor form. Full spec: [[Citation Mechanism - Block-Level Provenance]].

**Example:** `regenerative finance shifts the unit of account ([[2026-03-04 Strategy Call#Unit of Account|2026-03-04 — Unit of Account]] — Jordan).`

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
- **Commit-moment rule:** every thread class anchors tracking updates to its own commit moment - normal sessions at close; perpetual threads at the batch/cursor write (they never close).
- **Orientation follows the pointer:** when the active arc's ledger row points at a State Board, orientation reads the board. Pointer-following is reliable only when a protocol step forces it.
- **Hand-maintained canonical surfaces get machine drift-checks** - they lack the generated-view protection knowledge surfaces have (lint checks; reconsolidation passes carry the diff until a check exists).
- **Retirement is detected, not scheduled:** a driver doc whose board is all-terminal but whose `status:` is still active triggers a retirement ceremony in the next reconsolidation pass - reconcile the board, rehome residuals, flip status, archive satellite queue docs.
- **Model-gap findings land here:** when a reconsolidation or design review surfaces a fact class with no canonical surface (or two surfaces claiming one fact), amend this table - do not scatter the finding into tactical backlogs.

(D105, D107, D108; design: [[RTI Federation and Tracking Model - Stress Test S218]], [[RTI Federation - T1 Design Review S217]])

**Example:** the T1 arc - ledger row says the arc is active and points at [[RTI Federation - Substrate Coherence Build Plan]]'s State Board; the board holds step state; the Backlog carries a pointer item; the Native Run Queue holds the carried native tasks; "What's next" says which of these to start on and points.

---

## Cadence

**Rule:** periodic-review cadence numbers (health audit, meta-learning review, content-interest refresh) live in **exactly one place: the session-closer's thresholds table**. Every other doc describes the nudge without quoting a number. To change a cadence, edit that table; don't restate the value here. (D88)

**Example:** "Run a health audit roughly every cadence interval" - the session-closer thresholds table holds the current number.

---

## Operational one-liners

- **Bulk vault edits:** for batch YAML or filename changes, use MCP tools (`obsidian:update_frontmatter`, `obsidian:move_note`) directly rather than Obsidian plugins. Full rationale: Decision Log **D44**.
- **Check `harvest_status` before reading a source:** before harvesting or processing a source file, read its `harvest_status` (and related provenance YAML) first, so already-processed material isn't re-harvested. A cheap guard against duplicate work in the pipeline.
- **Git push before batch ops:** before running any script that bulk-moves or modifies vault files, commit and push first. `git checkout .` is then the undo if a batch run goes wrong.

---

*Birth-metadata and field definitions live in the YAML Schema; `type:` values live in the Content Type Taxonomy. This registry covers structural and formatting conventions only.*
