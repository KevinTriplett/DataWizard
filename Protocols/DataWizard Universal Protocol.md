---
title: DataWizard Universal Protocol
type: project-doc
created: '2026-03-07'
updated: '2026-03-07'
status: draft
tags:
  - protocol
  - AI-collaboration
  - DataWizard
---


# DataWizard Universal Protocol

*This is the master protocol for AI agents working in any DataWizard-managed vault. It is vault-agnostic — all vault-specific context lives in the START HERE file. Follow these rules everywhere.*

*If this doc contradicts a project-specific instructions file, the project-specific file takes precedence for that project. If the contradiction seems like an error, flag it to the vault owner.*

---

## 1. What This Doc Covers

- MCP tools available (Section 2)
- Orientation vs. per-session workflow (Section 3)
- Universal working principles (Section 4)
- YAML schema and field standards (Section 5)
- Log discipline — session log, harvest log, decision log (Section 6)
- End-of-harvest checklist (Section 7)
- Editorial and harvest principles + shell architecture + chunking (Section 8) *(updated)*
- Transcript preparation and chunking (Section 9)
- Citation format + source tags (Section 10) *(updated)*
- Federation workflow (Section 11)
- Multi-agent coordination (Section 12)
- Non-markdown file handling (Section 13) *(new)*
- Processing new sources by type + message log pattern (Section 14) *(new, updated)*
- What NOT to do (Section 15) *(new)*
- Naming conventions (Section 16) *(new)*
- Archiving (Section 17) *(new)*
- Vault bootstrap — what to do if START HERE is empty (Section 18) *(was Section 13)*

It does **not** cover vault-specific folder structures, project registries, content placement rules, naming conventions, or document routing tables — those live in the START HERE file and each project's own instructions file.

---

## 2. MCP Tools Available

```
obsidian:read_note / obsidian:write_note / obsidian:patch_note
obsidian:read_multiple_notes       — batch read up to 10 notes
obsidian:list_directory            — browse folder contents
obsidian:search_notes              — search by content or frontmatter
obsidian:get_frontmatter           — read YAML only (faster than full read)
obsidian:update_frontmatter        — update YAML without touching content
obsidian:get_notes_info            — file metadata (size, modified, has frontmatter)
obsidian:move_note / obsidian:move_file
obsidian:manage_tags
obsidian:delete_note               — requires human confirmation
obsidian:get_vault_stats
```

Always use these tools directly — never ask the human to copy/paste note content.

---

## 3. Orientation vs. Working Sessions

### First-Time Orientation (do once when starting on a new project)

> **Always draft for human review before writing to the vault. Share your plan, wait for approval.**

1. Read the START HERE file (you should have already — it pointed you here).
2. Read this document fully.
3. Read the project-specific instructions file (listed in START HERE's project registry).
4. Run `obsidian:list_directory` on the project folder to understand current structure.
5. Read the project MOC — every project has one and it is the single source of truth for what files exist and their status.
6. Read the harvest log (`_Harvest Log — [Doc Name].md` or `0.02 Harvest Log — [Doc Name].md`) to understand what source material has been processed and what's pending.

### Each Working Session (do every time)

1. Check the session log (`0.01 Session Log.md`) for recent changes — especially if another agent has been working.
2. Before reading any source file: check its frontmatter with `obsidian:get_frontmatter`. If `harvest_status: harvested` or `harvest_status: reviewed` is present, skip the full content read. Only read the full file if no `harvest_status` field exists.
3. Draft your plan and share it with the human before doing anything. Wait for explicit approval.

---

## 4. Universal Working Principles

**Draft-then-approve.** Always draft content for human review before writing to Obsidian. Share your plan before creating or editing documents. Wait for explicit approval — not implied or inferred.

**Verify before retry.** After any patch or write operation, confirm success via a read or search before attempting again. Silent successes followed by retries create duplicate content.

**When in doubt, ask.** If anything is unclear about document placement, content decisions, or integration choices, ask rather than assuming. A wrong edit is harder to undo than a clarifying question.

**Don't invent structure.** If a section or folder doesn't exist yet, flag it to the human rather than creating it without approval.

**Chunk large tasks.** Break complex operations into sequential smaller steps. Check in with the human at chunk boundaries rather than executing everything in one pass.

**Ask for human help when it's faster.** Some problems are quicker for a human to fix directly than for you to solve by trial and error. Don't hesitate to ask. Common examples:

- **Character encoding issues** causing `patch_note` failures. Common offenders: em-dashes (`—`), en-dashes (`–`), smart/curly quotes (`"` `"` `'` `'`), non-breaking spaces, ellipsis characters (`…` vs `...`), accented characters (é, ü, ñ), zero-width spaces. If a patch fails repeatedly and you suspect a character issue, stop and flag it — these are faster for a human to fix manually than to debug character-by-character.
- **Large files that need federating** — if a source file is too large for your context window and needs to be duplicated into a project folder, ask the human to do it in Obsidian (a single keystroke, faster than any workaround).
- **File operations that feel risky** — moves, renames, deletions. When uncertain, describe what you want done and let the human execute it.

**Confidential content stays local.** Never embed, reference, or quote content from private folders (as designated in START HERE) in shared project documents.

**Hallucination vigilance.** Statistics, citations, and attributed quotes compiled by AI agents are background context, not citable data. Flag uncertain claims for human verification before including them in documents shared with collaborators or funders.

---

## 5. YAML Schema

### What "Harvest" Means

*Harvesting* is the process of reading a source file (transcript, clipping, contributor document, federated copy) and synthesizing relevant content from it into a project document. The source file is the origin; the project document section is the destination. After harvesting, the source file's YAML is updated to record what was done and where content went.

### Content Type

All notes should carry a `type:` field. Values must match the vault's content type taxonomy, referenced in the START HERE file. Always lowercase. Single value only. When uncertain, consult the classifier decision tree in the taxonomy doc.

### Harvest Tracking

Source files use a 3-state system:

| State | YAML | Meaning |
|---|---|---|
| No `harvest_status` field | *(absent)* | Untouched — not yet reviewed |
| `harvest_status: reviewed` | present | Reviewed; nothing to harvest |
| `harvest_status: harvested` | present | Content extracted into project docs |

When `harvest_status: harvested`, always pair with destination paths, date, and agent:

```yaml
harvest_status: harvested
harvested_into:
  - "[[Target Document Name]]"
harvested_date: YYYY-MM-DD
last_agent: Claude
```

> **Wikilink format required.** Always use `[[Note Name]]` syntax (note name only, no path) in `harvested_into` values. This makes destinations clickable in the Obsidian properties panel. Obsidian resolves wikilinks by filename regardless of folder path, so the short form is sufficient and more robust than full paths.

**Never** add a blank or placeholder `harvest_status` field. Absence means untouched — that's meaningful information. Do not use `harvest_pending`.

### Federation Fields

*Federation* is the process of copying a source file from a private vault folder into a project folder so that team members and their AIs can work with it. See Section 11 for the full workflow. The following YAML fields track that process.

**On the original** (in private folders):

```yaml
federated_to:
  - _ProjectFolder/Subfolder/Filename.md
federated_date: YYYY-MM-DD
federated_note: "Full copy"
```

If later federated to a second project, append to `federated_to`.

**On the federated copy** (in the project folder):

```yaml
federated_from: _PrivateFolder/OriginalFilename.md
federated_date: YYYY-MM-DD
federated_note: "Full copy"
```

Federated copies also carry `harvest_status` / `harvested_into` tracking — same 3-state system as originals.

- ! begin edit 2026-03-08 19:30 — REVISED SUBSECTION (ai-generated consolidation)

### AI-Generated Content Fields

When a note is generated by an AI agent (rather than human-authored or web-clipped), add these YAML fields:

```yaml
tags:
  - ai-generated
generating_agent: Andrew / Claude
```

`ai-generated` is a **tag**, not a content type — the note's `type:` should reflect what the content actually *is* (resource, document, companion, etc.), not who made it. This replaces the retired `AI-written` content type (D42). The `generating_agent` field tracks authorship for provenance, using the format `Operator / Agent` (e.g. `Jay Cousins / Gemini`, `Andrew / Claude`, `Jay Cousins / DeepSeek`).

This matters in multi-agent vaults where different humans work with different AI agents. Knowing which agent produced a document helps with quality assessment and debugging.

- ! end edit 2026-03-08 19:30 — END AI-Generated Content Fields subsection

---

## 6. Log Discipline

> **Session log = maintenance diary. Harvest log = content provenance record. Decision log = architectural memory.**

Three log types serve distinct purposes. Do not conflate them.

| Log | File | Tracks | Update when... |
|---|---|---|---|
| **Session log** | `Session Log.md` | All changes to project files | Every working session, regardless of type |
| **Harvest log** | `_Harvest Log — [Doc].md` | Content provenance — what source went where | Only when new source material is processed into the doc |
| **Decision log** | `Decision Log.md` | Architectural and design decisions with rationale | When a meaningful choice is made about how the system works |

### Session Log

**Purpose:** What happened and when. The first thing to read at the start of any session — it tells you where the project left off.

**Rules:** Brief entries, 5 lines max, most recent first. Date, what changed, source if applicable. Never delete old entries. One session log per project.

### Harvest Log

**Purpose:** Where content came from. Provenance tracking for synthesized material — what source was processed, what was extracted, where it went.

**Rules:** Update when you process a new transcript, clipping, or contributor doc. Do NOT update for structural fixes, deduplication, or moving existing content around. One harvest log per destination document.

- ! begin edit 2026-03-08 14:00 — NEW SUBSECTION (Decision Log added to Section 6)

### Decision Log

**Purpose:** What was decided and why. The architectural memory of the project. When you need to know *why* a particular model was chosen, *why* a content type exists, or *what alternatives were considered*, the decision log surfaces that without digging through session history.

**When to log a decision:** Any choice that shapes how the system works, could plausibly have gone a different way, and would be useful to reference later. Not every small choice — but anything where the rationale matters.

**What NOT to log:** Routine operational choices ("I put the file in folder X"), cosmetic preferences, or decisions that are obvious from context. If you'd never need to look it up again, it doesn't need an entry.

**Entry format:**

```markdown
### D[number]: [Short title]
**Decision**: What was decided — stated clearly enough that someone reading only this sentence understands the choice.

**Rationale**: Why this option was chosen. What alternatives were considered and why they were rejected.

**Date**: YYYY-MM-DD
```

**Additional fields (use when relevant):**
- **Supersedes**: `D[number]` — if this decision replaces an earlier one
- **Resolves**: `Q[number]` — if this closes an open question
- **See**: `[[Document Name]]` — pointer to related research or analysis
- **Status note**: If the decision is provisional or depends on future testing

**Decision numbering:** Sequential IDs (`D01`, `D02`, ...). Never reuse a number — if a decision is superseded, mark the old entry as superseded and reference the new one. This preserves the full history of thinking.

**Open questions:** The decision log also tracks unresolved questions using a `Q[number]` format. When a question is resolved, mark it with `✅ Resolved → D[number]` and log the answer as a decision.

**One decision log per project.** Unlike session logs (one per project) and harvest logs (one per document), the decision log is a single file for the whole project. It's the canonical record of the project's architectural evolution.

### Decision tree — which log to update

```
New content from a source            → session log + harvest log
Structural fix or maintenance        → session log only
Content moved between documents      → harvest logs of BOTH source and destination
Meaningful design or architecture choice  → decision log + session log (brief note)
```

- ! end edit 2026-03-08 14:00 — END Decision Log subsection

---

## 7. End-of-Harvest Checklist

A harvest session is not complete until all four steps are done. If context runs out, note the incomplete state in the session log and flag to the human.

1. **Source YAML** — set `harvest_status: harvested` + `harvested_into` with paths and date + `last_agent`. Or `harvest_status: reviewed` if nothing was harvested. Do not use `harvest_pending`.
2. **Harvest log** — update `_Harvest Log — [Doc Name].md` with source, date, and sections affected.
3. **Session log** — add entry to `0.01 Session Log.md` in the destination document folder.
4. **Destination session logs** — add a brief entry to the session log of each destination document that received content.

---

## 8. Editorial Principles

These apply when synthesizing source material into project documents.

**Synthesize, don't transcribe.** The goal is clear reference prose, not a verbatim record. Rephrase conversational speech into readable sentences. Save exact quotes for moments where the specific wording carries meaning.

**Extract concepts, not conversations.** Transcripts are unfiltered personal conversations. Extract frameworks, decisions, and ideas. Leave behind personal dynamics, emotional content, casual tangents, and relationship subtext — those stay in the transcript.

**Preserve tensions.** If speakers disagree or hold conflicting views, capture both positions. Don't smooth over conflict — it is valuable strategic information. Use speaker attribution when it matters who said what.

**Preserve specificity.** Don't summarize away vivid detail, precise numbers, or distinctive language. Abstraction loses information.

**Archetypal over specific** (for outward-facing documents). Lead with general patterns; name specific frameworks and people only when the audience has gone deeper. Applies especially to story bibles and pitch materials.

**One idea per paragraph.** Each paragraph should make one clear point. This makes cross-referencing and future editing easier.

**Don't duplicate, cross-reference.** Content lives in one place. If the same material belongs in two documents, put it in the most specific home and add a pointer from the other.

**Date your context.** If a claim was accurate as of a specific date but may have changed, note it: *"As of [date]..."*

**Attribute sources.** New sections should carry a source note. Where possible, deep-link to the specific section anchor:

```
*Source: [[Filename#Section Header]], YYYY-MM-DD*
```

If no section header exists yet (e.g., the source hasn't been segmented), link to the note and add a date:

```
*Source: [[Filename]], YYYY-MM-DD*
```

**Personal names:** Follow the project-specific instructions file for rules about including names in shared documents. When in doubt, use role descriptions rather than names.

**Hallucination vigilance (editorial context):** Never include AI-generated statistics, citations, or attributed quotes without flagging them for human verification.

- ! begin edit 2026-03-08 18:30 — NEW SUBSECTION (Shell Architecture)

### Shell + Section File Architecture

For long-form documents expected to exceed ~10 sections or be collaboratively edited, use a **shell + section file** pattern:

- A **shell file** (e.g. `Project Bible.md`) contains only `![[embed]]` references to numbered section files. It is the reading view — never edit the shell directly.
- **Section files** (e.g. `1.0 What Is MetaMyth.md`, `2.0 Traction & Proof Points.md`) hold the actual content. Always edit these.
- Section files carry YAML frontmatter linking them to the parent: `type: bible-section`, `section: 1`, `parent: Project Bible`.
- Number sections sequentially. If a new section needs to go between existing ones, use decimals (e.g. `6.5`). Never renumber existing sections — other notes may link to them by filename.
- Each section begins with a standard opening line linking back to the shell: `*Part of the [[Project Bible]]*`

This pattern prevents merge conflicts in collaborative editing, enables independent versioning of sections, and keeps the reading view (shell) clean while the working files (sections) stay manageable.

**When to use this pattern:** Any document that will grow beyond ~10 sections, has multiple contributors, or needs to be read as a unified whole while being edited in pieces. Project bibles, strategy docs, and reference manuals are good candidates.

**When NOT to use it:** Short documents, personal notes, or anything that fits comfortably in a single file.

- ! end edit 2026-03-08 18:30 — END Shell Architecture subsection

- ! begin edit 2026-03-08 19:30 — NEW SUBSECTION (Content Routing Tables)

### Content Routing Tables

For projects with multiple destination documents, a **content routing table** makes explicit where each type of content belongs. This prevents content from ending up in the wrong document and gives agents an unambiguous decision tree.

**Format:** A table mapping content descriptions to destination documents, placed in the project guidelines file.

**Example (from a multi-document project):**

| Content | Goes In | NOT In |
|---|---|---|
| Mechanism design, thresholds, algorithm | Field Guide | Story Bible |
| Narrative frameworks, character sketches | Story Bible | Codex |
| Implementation scenarios, personas | Use Case Library | Story Bible |
| Technical architecture, protocol specs | Codex | Field Guide |
| Finished stories, vignettes | Story Artifacts | Story Bible |
| Action items by meeting date | Action Items doc | Field Guide |
| Open design questions | Open Questions doc | scattered across sections |

**The "NOT In" column is as important as the "Goes In" column.** It prevents the most common routing errors — content that *sounds* like it could go in two places but has a clear primary home.

**When to use:** Any project with 3+ destination documents where content could plausibly be routed to the wrong place. Single-document projects don't need this.

**Where it lives:** In the project-specific guidelines file, not in the Universal Protocol. Each project's routing table reflects its own document structure.

- ! end edit 2026-03-08 19:30 — END Content Routing Tables subsection

- ! begin edit 2026-03-08 20:15 — NEW SUBSECTION (When and How to Chunk)

### When and How to Chunk a Document

Chunking is splitting a single long document into multiple files — typically a shell file with `![[embed]]` references to numbered section files (see Shell + Section File Architecture above). This is a significant structural decision. Don't chunk by default.

**Decision tree:**

```
Is the document expected to exceed ~10 sections?
  → NO → keep as a single file

Will multiple people or agents edit different parts?
  → YES → chunk into section files (prevents conflicts)

Does the document need independent harvest tracking per section?
  → YES → chunk (each section can carry its own harvest_status)

Is the document a "living reference" that grows over time?
  → YES → chunk (new sections are added without touching existing ones)

Is the document read as a single narrative flow?
  → YES → probably keep as single file (chunking disrupts reading)

Is the document already long and hard to navigate?
  → YES → chunk retroactively (add headers first, then split)
```

**If the answer is "chunk," here's how:**

1. **Identify natural section boundaries.** Look for existing `##` headers, topic shifts, or logical groupings. Each section should be self-contained enough to edit independently.

2. **Create the shell file.** This is the reading view — it contains only `![[embed]]` references and no content of its own. Name it after the document: `[Document Name].md`.

3. **Create numbered section files.** Use the `1.0+` numbering convention (see Section 16). Each section file starts with `*Part of the [[Shell Document Name]]*` and carries YAML frontmatter with `type`, `section`, and `parent` fields.

4. **Move content from the original into sections.** Cut each section's content from the original and paste into the corresponding section file. The original becomes the shell.

5. **Verify embeds render correctly.** In Obsidian's reading view, the shell should display all sections seamlessly.

6. **Update the MOC.** Add all new section files to the project MOC with status.

**Chunk size guidance:**

- Each section file should cover one coherent topic — not too granular (one paragraph per file is overkill) and not too broad (an entire chapter with 15 sub-topics should be split further).
- A good section is 500–2000 words. Short enough to edit as a unit, long enough to be meaningful.
- If you're unsure where to split, err on the side of fewer, larger sections. You can always split later; merging is harder.

**When to chunk retroactively:**

If a single-file document has grown unwieldy (scrolling to find content, agents overwriting each other's work, harvest tracking getting confused), it's time to chunk. The process is the same as above — identify sections, create shell, split content, update MOC. Log the restructuring in the session log.

- ! end edit 2026-03-08 20:15 — END When and How to Chunk subsection

---

## 9. Transcript Preparation and Chunking

### Why Transcripts Need Special Handling

Transcripts are the densest, highest-value content type in many vaults — but structurally noisy. Three properties make them distinct from other source types:

1. **Topic shifts mid-stream.** A long conversation covers many topics, but the raw transcript has no headers marking where topics change. Without headers, companion citations can't deep-link to specific moments in the source.
2. **Speaker-attributed ideas.** Who said something matters. Enrichment must preserve speaker attribution, not smooth it away.
3. **High lexicon density.** Transcripts are where specialized language lives in its most authentic, unrehearsed form.

### Step 1: Segment Before You Harvest

Before extracting any content from a transcript, add `##` section headers at major topic shifts. This is a required step — without headers, there are no anchor targets for deep-link citations.

**Format:**
```
## Section Name (@timestamp if available)
```

**Good header examples** (specific, navigable):
- `## Threshold Design and Overflow Logic (@14:23)`
- `## Simon's Tension Around Ownership`
- `## Bonding Curves as Coordination Mechanism (@22:15)`

**Bad header examples** (too generic):
- `## Discussion`
- `## Part 3`
- `## Continued`

Keep headers descriptive enough to be meaningful as standalone navigation targets. Add them on a first read-through before extracting any content.

If the transcript is very short (under ~1,000 words), headers may not be necessary — use judgment.

### Step 2: Chunk and Route

1. **First pass: read the whole source.** Understand what's covered before routing anything.
2. **Second pass: identify chunks.** A chunk is a contiguous passage that addresses one project topic. A single section may contain multiple chunks if the conversation shifts topic; one chunk may span multiple sections if they stay on one topic.
3. **Route each chunk to the right document section.** Ask: what is this primarily about? Match to the most specific section by title. When uncertain, read the first paragraph of a candidate section to confirm fit.
4. **Multi-topic chunks:** Put primary content in the most specific section; add a brief cross-reference from the other. Don't duplicate full paragraphs.
5. **Draft all placements for human review** before writing anything to the vault.

### What Makes a Good Lexicon Candidate

When harvesting from transcripts, watch for:
- A specific phrase or framing — not a vague topic
- Says something in a distinctive way (not generic)
- Has a clear claim or idea embedded in it
- Could stand alone as a meme-seed with the right context

For additional transcript enrichment pipeline details (segmentation, companion note creation, meme harvesting), see the vault's transcript processing spec if one exists.

---

## 10. Citation Format

The following format is the recommended vault-wide standard. Projects may extend or adapt it, but new projects should default to this.

**Format:** Trailing parenthetical wikilink with deep-link section anchor.

```
([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]])
```

**With speaker attribution** (when it matters who said something):
```
([[NoteTitle#Section Header|YYYY-MM-DD — Section Name]] — Speaker)
```

**Rules:**
- Citations go at the **end** of a paragraph or statement, not the beginning
- One citation per claim is usually sufficient — don't over-cite
- Use ISO dates: `2026-03-04`, not `Mar 4`
- The deep-link anchor (`#Section Header`) must exactly match a `##` heading in the source note — this is why transcript segmentation (Section 9) is required before harvesting
- If no section header exists in the source, cite the note title only: `([[NoteTitle|YYYY-MM-DD — Note Name]])`

- ! begin edit 2026-03-08 18:30 — NEW SUBSECTION (Source Tags)

### Source Tags (optional complement)

For projects with many sources cited frequently across a large document, short source tags can complement wikilink citations. Tags are registered in the project's source reference document and used inline for quick provenance marking.

**Format:** `[TAG]` — short, uppercase, memorable abbreviation.

**Examples:**
- `[MAR3]` — March 3 strategy session transcript
- `[SP]` — The Sword Protocol document
- `[ZM msg 2026-02-20]` — Zach Marlow message, Feb 20

**Rules:**
- Tags are registered in a tag table in the project's source reference doc (e.g. `19.0 Source Documents & References.md`)
- Each tag maps to one source document — no ambiguity
- Tags supplement wikilink citations, they don't replace them. Use tags for quick inline attribution; use full wikilink citations for formal provenance.
- This system is optional — only adopt it when a project has enough sources that full wikilinks become unwieldy

- ! end edit 2026-03-08 18:30 — END Source Tags subsection

---

## 11. Federation Workflow

Federation is copying a source file from a private vault folder into a project folder so that team members and their AIs can access it.

### Core rule: full copies only

Always federate full copies. Never create summarized versions of source files — if a file is too large for an AI context window, that is a human workflow task, not a reason to degrade the copy.

**If a source file is too large for AI context:**
1. Ask the human to duplicate the note in Obsidian (fast, single operation)
2. The human places the full copy in the appropriate project Resources subfolder
3. The AI works from the full copy, reading in sections if needed

### After federating

1. Update YAML on both the original and the copy (see Section 5, Federation Fields).
2. Update the vault's source registry (location specified in START HERE) — add a row with source title, original location, destination path, date, and notes.
3. Update the project's `Works Cited & Attributions.md` if the source will be cited in project documents.
4. No `harvest_status` field needed on the copy yet — absence means untouched, which is the correct initial state.

---

## 12. Multi-Agent Coordination

Multiple AI agents may work in the same vault. The session log is the primary coordination mechanism.

- **Check the session log** before starting any session — another agent may have made recent changes
- **Log clearly enough** that another agent can understand what you did without reading every file you touched
- **When both agents need to update the same document**, coordinate through the human editor — don't write simultaneously
- **Don't assume your context is current** — if the session log shows recent activity, re-read affected files before editing them

The START HERE file lists known agents operating in the vault.

---

- ! begin edit 2026-03-08 17:30 — NEW SECTION

## 13. Non-Markdown File Handling

Vaults often contain non-markdown files: `.docx`, `.pdf`, `.txt`, `.json`, `.csv`, images, audio. These can't be directly processed by the enrichment pipeline or searched by Obsidian's full-text search.

### Conversion to markdown

When a non-markdown text file needs to enter the pipeline:

1. **Create a `.md` version** in the same folder (or the appropriate destination folder).
2. **Copy the text content** into the new file. For `.docx` and `.rtf`, extract the plain text — discard formatting markup.
3. **Add YAML frontmatter** with at minimum `type:` and `title:`. If the original has an author, date, or source URL, capture those too.
4. **Add `##` section headers** if the document has internal structure — these become deep-link targets for citations.
5. **Keep the original binary file** as an archive. Don't delete it — it may contain formatting, images, or layout that the markdown version loses.

### What to do with files the pipeline can't process

Some files (images, audio, PDFs with complex layout) can't be meaningfully converted to markdown. These should be:
- Left in place (don't move files you can't process)
- Flagged for human attention if they're in a processing queue
- Referenced from markdown notes using standard Obsidian embed syntax (`![[file.pdf]]`)

### AI agents should NOT attempt to:
- Process binary files (images, audio, video) without explicit human instruction
- Convert complex PDFs with tables, charts, or multi-column layouts — flag these for human conversion
- Delete original files after conversion

- ! end edit 2026-03-08 17:30 — END SECTION 13

---

- ! begin edit 2026-03-08 17:30 — NEW SECTION

## 14. Processing New Sources by Type

When a new source enters the vault, the processing steps depend on its content type. The steps below are the universal defaults — project-specific instructions may extend or override them.

### Transcripts (video-transcript, podcast-transcript, meeting-transcript, voice-memo-transcript)

1. **Classify** — confirm or assign the `type:` field
2. **Segment** — add `##` section headers at major topic shifts (see Section 9). This is required before any harvesting.
3. **Enrich** — create a companion note with summary, key topics, themes, tags, lexicon candidates. Companion citations deep-link to `##` sections in the source.
4. **Harvest** — dedicated meme-mining pass. Review source for distinctive phrases, framings, and claims. Candidates go to a review queue.
5. **Link** — cross-reference pass: project matching, MOC routing, person linking, wikilink suggestions.

### Articles, entities, resources, resource-lists

1. **Classify** — confirm or assign `type:`
2. **Enrich** — create companion note. Depth depends on type: articles get full summary + themes; entities get mission/programs/people extraction; resource-lists get URL extraction.
3. **Link** — cross-reference pass.

For `resource` and `resource-list` types specifically: extract URLs, check against existing vault notes, and queue new URLs for potential scraping (see project-specific scrape queue instructions if they exist).

### Seeds and seedpods

1. **Classify** — confirm or assign `type:`
2. **Tag** — add `tags:` and `themes:` in YAML. Light touch — no companion note for seeds. Seedpods may get a companion if they're rich enough.
3. **Link** — connect to related concepts, people, or projects via wikilinks or project matching.

Seeds and seedpods are the raw material for future harvesting. They should be easy to find by tag/theme but don't need deep enrichment.

### Documents

1. **Classify** — confirm `type: document`
2. **Enrich** — companion note with summary, key decisions/proposals, audience, and purpose.
3. **Link** — connect to relevant projects.

### Companions

Do not process further. Companions ARE the enrichment output. The pipeline reads companion YAML to avoid re-processing sources that have already been enriched.

### Messages

1. **Classify** — confirm `type: message`
2. **Tag** — add person name, date, key topics in YAML.
3. **Link** — connect to the person's note in `_People/` if one exists.

- ! begin edit 2026-03-08 18:30 — NEW SUBSECTION (Message Log)

### Message Log Pattern

For projects with high-volume async communication (voice notes, text messages, Claude-assisted syntheses), a consolidated **Message Log** can be more effective than one-note-per-message. The log aggregates messages by person, then by date:

```markdown
## Person Name

### YYYY-MM-DD

(raw message content here)

### YYYY-MM-DD

(raw message content here)

## Another Person

### YYYY-MM-DD

(raw message content here)
```

**When to use:** Projects where multiple collaborators send frequent short messages (WhatsApp voice notes, text threads, Claude syntheses). Individual files for each message would create noise.

**When to keep individual notes:** When messages are long, self-contained, or need their own YAML metadata (e.g. for pipeline processing).

The message log lives in the project's shared folder. Messages are cited using the person heading + date as the deep-link anchor: `([[Message Log#YYYY-MM-DD|INITIALS msg YYYY-MM-DD]])`.

- ! end edit 2026-03-08 18:30 — END Message Log subsection

- ! end edit 2026-03-08 17:30 — END SECTION 14

---

- ! begin edit 2026-03-08 17:30 — NEW SECTION

## 15. What NOT to Do

Explicit anti-patterns. If you catch yourself doing any of these, stop.

**Don't put private content in shared folders.** Private meeting notes, personal reflections, and confidential materials stay in private folders (designated in START HERE). Only transcripts and documents explicitly cleared for sharing go in shared project folders.

**Don't duplicate content across documents.** Content lives in one place. If the same material is relevant to two documents, put it in the most specific home and cross-reference from the other with a wikilink.

**Don't modify archived originals.** Files marked as originals, archives, or source copies should never be edited. Work from copies or companion notes.

**Don't change filenames that other notes link to.** Obsidian resolves wikilinks by filename. Renaming a file that's linked from other notes breaks those links. If a rename is needed, use Obsidian's built-in rename (which updates links) or flag it for the human.

**Don't add empty YAML fields as placeholders.** Absence of a field is meaningful — it means "not yet processed." Adding `harvest_status:` with no value, or `type:` with no value, creates ambiguity. Either set a real value or leave the field off entirely.

**Don't process files outside your scope.** Each project has boundaries. Don't modify files in other project folders unless explicitly instructed. If you find content that belongs elsewhere, flag it — don't move it yourself.

**Don't assume your context is current.** If the session log shows recent activity by another agent, re-read affected files before editing. Stale reads lead to overwrites.

**Don't re-run expensive operations without checking.** Before running LLM classification or enrichment on a file, check its YAML first. If it already has a valid `type:` or `harvest_status:`, it may not need reprocessing.

- ! end edit 2026-03-08 17:30 — END SECTION 15

---

- ! begin edit 2026-03-08 20:00 — NEW SECTION

## 16. Naming Conventions

### Infrastructure files (0.x series)

Every project folder uses a standard `0.x` prefix for infrastructure files. These sort to the top of the folder and are visually distinct from content files.

| Number | File | Purpose | Required? |
|---|---|---|---|
| `0.0` | `0.0 Project Guidelines.md` | Project-specific rules, scope, content routing — the first file an agent reads for this project | Always |
| `0.1` | `0.1 MOC.md` | Map of Contents — single source of truth for what exists and where | Always |
| `0.2` | `0.2 Session Log.md` | Maintenance diary — what happened and when | Always |
| `0.3` | `0.3 Decision Log.md` | Architectural memory — what was decided and why | Usually |
| `0.4` | `0.4 Harvest Log — [Doc Name].md` | Content provenance — one per destination document | When harvesting |
| `0.5` | `0.5 Action Items.md` | What needs doing | When needed |

**Rules:**
- The `0.x` series is reserved for infrastructure. Never use `0.x` for content files.
- A lightweight project starts with just `0.0`, `0.1`, and `0.2`. Add higher numbers as the project grows.
- The numbering is fixed — `0.2` is always the session log, regardless of project. This consistency helps agents navigate unfamiliar projects.

### Content section files (1.0+ series)

For shell + embed documents (see Section 8), content sections use `[section].[subsection]` numbering:

```
1.0 Introduction.md
2.0 Strategy.md
2.1 Near-Term Strategy.md
2.2 Long-Term Strategy.md
3.0 Team.md
```

**Rules:**
- Number sections sequentially starting from `1.0`
- Use `.0` for top-level sections, `.1`, `.2`, etc. for subsections
- If a new section needs to go between existing ones, use intermediate decimals (e.g. `2.5 New Topic.md`)
- **Never renumber existing sections** — other notes may link to them by filename
- Each section file begins with `*Part of the [[Shell Document Name]]*`

### Project guidelines file naming

The project guidelines file is always `0.0 Project Guidelines.md`. This replaces the older convention of `AI + LLMs - [Project] - Project Guidelines.md`. The `0.0` prefix ensures it sorts first in every project folder.

### Other file naming

- `START HERE - For Humans.md` — every project should have one. This is the human onboarding doc: what the project is, what's in the folder, how to navigate. It lives alongside the `0.x` files but is unnumbered (it's for humans, not part of the agent infrastructure). It should include a copy of the universal Claude Project Instructions block so new collaborators can paste it into their AI setup.
- Use descriptive titles, not codes or abbreviations
- Hyphens for multi-word YAML values (`meeting-note`, `video-transcript`)
- Dates in filenames use ISO format: `YYYY-MM-DD`
- No special characters that break file paths (avoid `:`, `/`, `\`, `?`, `*`)

- ! end edit 2026-03-08 20:00 — END SECTION 16

---

- ! begin edit 2026-03-10 15:45 — NEW SECTION

## 17. Archiving

When files are superseded, retired, or no longer active — archive them, don't delete them. Archived files are preserved for reference but kept out of the way.

### When to archive

- A file has been **replaced** by a newer version (e.g. old protocol doc superseded by the Universal Protocol)
- A content type or naming convention has been **retired** and the file renamed/restructured
- A document is **no longer active** but may contain useful historical context
- You're unsure whether something is still needed — archive it rather than deleting

### When NOT to archive

- Files that are just **old but still active** — an untouched seed from 6 months ago is still a seed, not an archive candidate
- Files that were **moved** to a different folder — moving is not archiving
- Files that are **stubs or empty** — delete these (with human confirmation) rather than archiving

### Where archived files live

Each project has its own archive folder using the `xArchive` prefix:

```
_ProjectFolder/xArchive/
```

The `x` prefix sorts the folder to the bottom of the file explorer, keeping it out of the way. For vault-level files not tied to a specific project, use a root-level archive:

```
_xArchive/
```

### How to archive

1. **Move the file** to the project's `xArchive/` folder (or `_xArchive/` for vault-level files). Use `obsidian:move_note` — Obsidian updates wikilinks automatically.
2. **Do NOT rename the file.** Keep the original filename so existing wikilinks still resolve.
3. **Add a note at the top of the archived file** explaining why it was archived and what replaced it:

```markdown
> ⚠️ **Archived (YYYY-MM-DD).** Superseded by [[New File Name]]. Retained for historical reference.
```

4. **Update the session log** — note what was archived and why.
5. **Update the MOC** — remove the file from active listings or move it to an "Archived" section.

### AI agents and archiving

- **Never delete files without explicit human confirmation.** When in doubt, archive.
- **Propose archiving** when you notice superseded files during a session — but always get approval before moving.
- **Don't archive files outside your project scope.** If you find a vault-level file that should be archived, flag it to the human.

- ! end edit 2026-03-10 15:45 — END SECTION 17

---

- ! begin edit 2026-03-08 19:30 — REVISED SECTION (removed circularity)

## 18. Vault Bootstrap

If you've been pointed to this protocol by a START HERE file, your project-specific context should already be loaded — either via your system prompt (Claude Project Instructions) or via the project's guidelines file.

**If you have project context** — you're ready to work. Follow the orientation steps in Section 3.

**If you don't know which project you're working on** — ask the user: "What project are we working on?" Then find the project folder in the vault and look for `0.0 Project Guidelines.md`.

**If you have NO project context** (e.g., this is a fresh DataWizard deployment with no project set up yet) — the vault needs initial setup.

### First-time vault setup

If the user has not yet pasted the universal project instructions into their Claude Project settings, **instruct them to do so before proceeding.** The instructions block is in the START HERE file at `_DataWizard/Seed/START HERE.md` under "Step 1: Set Up Your AI." Tell the user:

> "Before we get started, you'll need to paste the project instructions into your Claude Project settings. Open `_DataWizard/Seed/START HERE.md` in Obsidian — there's a code block under Step 1 that you can copy and paste. Once that's done, start a new conversation and I'll be able to orient myself automatically."

This only needs to happen once per Claude Project. After the instructions are pasted, the LLM will read the protocol and find the project context automatically in every future thread.

### Bootstrapping a new project

Once instructions are pasted, interview the vault owner to create the project infrastructure. A fully bootstrapped project has:

1. **`0.0 Project Guidelines.md`** — project-specific rules for AI agents
2. **`0.1 MOC.md`** — map of contents
3. **`0.2 Session Log.md`** — maintenance diary
4. **`START HERE - For Humans.md`** — human onboarding doc: what the project is, what's in the folder, how to navigate, and a copy of the universal Claude Project Instructions block for new collaborators to paste

Additional infrastructure files (`0.3 Decision Log`, `0.4 Harvest Log`, `0.5 Action Items`) are created as the project grows — not all are needed at bootstrap.

To create the guidelines file, ask about:

1. **Project identity** — What is this project called? What is it for? Who owns it?
2. **Folder structure** — What are the key folders? Which folders are private?
3. **Documents** — What documents exist or are planned? What's the routing table (which content goes where)?
4. **Content taxonomy** — Is there an existing content type taxonomy? If not, should we create one?
5. **Source registry** — Is there a source registry for tracking federated files?
6. **Agents** — Who else (human or AI) works in this vault?

Use the answers to draft a project guidelines file for human review. Once approved, the project is bootstrapped and ready for work.

- ! end edit 2026-03-08 19:30 — END REVISED Section 17

---

*DataWizard Universal Protocol. Vault-agnostic — do not add vault-specific details to this file.*
