---
created: 2026-06-11
description: "Stamp a block ID (^bN documents, ^tN transcript turns) on the
  source paragraph or turn a citation points to -- on-cite, sparse,
  byte-faithful. Any same-vault markdown doc is a citable source; the citation
  unit is the unit the claim rests on (a paragraph/turn takes a block stamp; a
  whole section takes a section anchor). Idempotent: reuse any existing trailing
  block ID, else the next unused integer; never re-stamp or renumber. Batch via
  stamp_blocks.py. Triggers on: 'stamp block ids', 'add a citation anchor',
  'stamp this block'."
edit_log:
  - DW-S166 2026-06-11
  - "DW-S202 2026-06-25 - reframed bulk -> on-cite stamping:
    next-unused-integer, partial-is-normal, bulk demoted to legacy"
  - "DW-S293 2026-08-26 - v2: non-source exclusion retired for the evidence-unit
    rule (any same-vault doc citable; unit follows the claim); added reach rule,
    stamp-before-cite, verify-after-claim collision guard, ID tolerance (any
    trailing block ID), metadata exemption, and the stamp_blocks.py script twin
    + manifest contract"
  - "DW-S293 2026-08-26 - v2 rules folded from S294 review:
    only-real-stamps-count (next-unused), tight-list/wrapped-item and
    fence-adjacent placement, per-row read-modify-write wording (matching the
    stamp_blocks.py D1 fence fix + the list/link-ref fixes)"
name: block-stamper
type: skill
updated: 2026-08-26
version: "2.0"
---
# Block Stamper Skill

**Status:** Active (Seed)

## Overview

Stamp a block ID on a source-file paragraph or transcript turn so it becomes addressable via Obsidian's native `^block-id` syntax -- giving a citation a clickable breadcrumb back to the exact passage.

**Stamping is on-cite, not in bulk.** A block gets an ID only when something actually cites it. Sources accumulate IDs sparsely, only where they have been referenced. This is a utility skill: the synthesis and enrichment passes call it at the moment they cite a passage.

**Any markdown document in the same vault is a citable source.** The old "never stamp companion notes, MOCs, infrastructure, or non-source content" exclusion is retired. What replaces it is a granularity rule, not a document-class rule (see The Evidence Unit): a paragraph or turn takes a block stamp whatever file it lives in; a whole section (a MOC listing, an infrastructure section, a guide section read as a whole) takes a section anchor instead. Frontmatter, headings, and boilerplate still never get a block ID -- those are mechanical exclusions (see What Does NOT Get a Block ID).

**Writes are byte-faithful.** A stamp is a one-line append that changes no content. It is exempt from birth-metadata ceremony (no `updated:` bump, no `edit_log` entry on the stamped file), and it must not reflow the file -- append the ID to the target line only, with no end-of-line normalization, whitespace change, or frontmatter re-dump. This keeps a stamp the minimal diff a downstream updated-field reconciliation treats as a non-body change.

Citation canon: the Conventions Registry citation section. Full spec: [[Citation Mechanism - Block-Level Provenance]] and the synthesis-provenance design plan.

## When to Use

- At cite time -- a synthesis or enrichment pass references a specific paragraph or transcript turn that has no ID yet
- Called by corpus-enrichment, transcript-harvest, document-harvest, and any synthesis pass (design docs, reports, reviews, plant records) as a stamp-on-cite step
- User says "stamp this block", "add a citation anchor here", "give this paragraph a block ID"

### When NOT to Use

- The target block already carries a block ID -- reuse it, never add a second (ID Tolerance below)
- The unit the claim rests on is a whole section, not a paragraph -- use `[[File#Header]]` (The Evidence Unit)
- The target is a section header (already addressable via `[[File#Header]]`), frontmatter, or other mechanical exclusion
- The file is out of reach (Reach below): a read-only mount, another vault, a PDF, or a doc a collaborator has visibly claimed mid-edit today

## Reach

A stamp is in reach on **any document in the same vault**, regardless of who owns it -- do not fall back to a coarser section anchor out of politeness toward a collaborator's file. Out of reach, where the citation uses a section anchor instead:

- read-only mounts
- other vaults
- PDFs and other non-markdown sources
- a document a sibling instance has visibly claimed mid-edit **today** (an in-progress session stub, or a file another operator is actively editing) -- never stamp into an open stub; it is renamed at close and the link would break

## The Evidence Unit -- block vs section

The citation unit is **the unit the claim rests on**, not the document's class:

- A **paragraph or transcript turn** that a claim rests on takes a block stamp (`^bN` / `^tN`), whatever file it lives in -- a companion, a design doc, a session-log section file, a report, a Seed guide.
- A **whole section** that a claim genuinely synthesizes takes the section anchor `[[File#Header]]` (the Registry's section-anchor fallback, case 1).

Document classes only indicate where whole-section is *usually* the true unit: MOCs, the 0.x shells and trackers, and guide/infrastructure sections lean section-anchor; but one Key Pointers line or one guide paragraph cited as the specific evidence still takes a block stamp. Two clarifications:

- **Session-log section files are content**, not "shell" infrastructure -- they are primary sources and are block-stamped like any source.
- **Decision Log entries are section-anchor by nature** -- each is a heading, so `[[Decision Log#D112]]` already hits the exact unit; do not block-stamp inside a D-entry.

## Content Type Detection

| Content Type | Block Prefix | How to Detect |
|---|---|---|
| Article / document / prose | `^b` | Default. No speaker turns, not a transcript. |
| Transcript (meeting, interview, podcast) | `^t` | Has speaker turns (`**Name**:` pattern), or a `transcript` / `voice-memo` value in the `type:` frontmatter |
| Voice memo | `^t` | `type: voice-memo-transcript` in frontmatter, or single-speaker transcript format |

When in doubt, use `^b`. The prefix signals **content shape, not document class**; numbering is a single file-local integer sequence shared across both prefixes.

## Stamping Rules

### What Gets a Block ID

- Every substantive prose paragraph (2+ sentences, or one sentence making a specific claim) that a citation points at
- Each speaker turn in a transcript (the full turn, not each sentence within it)
- Individual list items when they contain the substantive claim being cited
- Blockquotes that contain the substantive content being cited

### What Does NOT Get a Block ID (mechanical exclusions)

- Section headers (`#`, `##`, ...) -- already addressable via `[[File#Header]]`
- YAML frontmatter
- Empty lines, horizontal rules (`---`)
- Tables (the whole table is cited by its section, or a specific cell is out of scope)
- Image embeds (`![[image]]`, `![alt](url)`)
- Fenced code blocks
- Callout wrappers (`> [!note]` -- stamp the content inside, not the wrapper)
- Navigation boilerplate (breadcrumbs, "Part of" lines, TOC links)
- Very short transitional lines ("See below.", "As follows:") carrying no independent claim
- Bold-only section dividers (`**Section Name**` with no prose)

### Numbering

- **Next unused integer in the file** -- scan for existing `^bN`/`^tN`, assign the highest + 1. IDs are *sparse*, so `^b9` is a stable handle, not "the 9th block."
- **Only real stamps count toward next-unused.** A `#^bN` that appears inside a wikilink citation is a reference to *another* file's block, never a stamp in this file; do not let it advance the sequence.
- Block IDs are appended at the **end of the paragraph's (or turn's) last line**, separated by a single space.
- One block ID per paragraph; never mid-paragraph.
- **Never renumber** to fill gaps -- IDs are permanent handles.

### Placement

The block ID goes at the very end of the paragraph's **last** line, after all content, inline formatting, and parenthetical references. For a multi-line paragraph or a wrapped list item, that is the last physical line, never the first.

- **Tight lists:** in a list with no blank line between items, every item is its own block; stamp the item you cited, and a wrapped item on its *last* line.
- **A paragraph directly followed by a code fence** (no blank line between) keeps its stamp on its last prose line -- the line *before* the fence. Never place a stamp on a fence line: a closing ` ``` ` cannot carry trailing text, so a stamp there reopens the code block and breaks the document below it.

```
Reich discovered the orgasm function by studying energy pulsation
blocked in the armoured working class of post-WW1 Vienna. ^b7
```

Transcript turn:

```
**Kevin**: I had a really good call with some of the community
organizers and developers for the Holo movement. ^t1
```

### ID Tolerance and Idempotency

- **Reuse any existing trailing block ID.** Before stamping, check the target line's end. If it already carries a block ID -- an instance-minted integer (`^b7`) **or** a human-minted Obsidian ID (`^3f9a2c` from "Copy link to block") -- reuse that ID in the citation and stop. Two IDs on one line break both, so never add a second.
- Also recognize Obsidian's **standalone** block ID: a whole line that is only `^id` (Obsidian mints these for tables and multi-paragraph blocks). Reuse it; do not add another.
- **Partial stamping is the normal state.** Most files are sparsely stamped. Never "complete" a file.

## The Stamping Process (on-cite)

### Stamp before cite

Work out every block the citing document will point at, stamp the sources and verify the stamps landed, **then** write the citing document. Partial failure then leaves harmless orphan stamps (an ID nobody points at yet), never dangling citations (a link with no stamp) that break the reader path.

### One block, by hand (MCP fallback)

1. Locate the exact source paragraph or turn being cited.
2. Check its last line for an existing block ID -- reuse if present (ID Tolerance).
3. Pick the prefix (content type) and the next unused integer.
4. Append ` ^bN` at the very end of the block's last line -- `patch_note` with the block's last line as a unique `oldString` -> the same line + ` ^bN`. Never touch frontmatter or headers, and never reflow the line.
5. **Verify after claim** (collision guard): re-read the file; confirm the ID appears **exactly once** and on the intended line. If it appears twice (a sibling stamped the same integer in the same window), take the next unused integer and re-stamp -- legal because the citing document is not written yet, so a seconds-old uncited stamp is yours to move.

### A batch, or several blocks across files (the script twin)

For a citing document that draws on more than a block or two, hand off to **`stamp_blocks.py`** (Seed/Scripts) instead of round-tripping the MCP. Build a manifest -- a JSON list of rows `{"file", "locate", "id"?, "prefix"?}` where `locate` is the first words of the target paragraph and `id` defaults to `"next"`. The script stamps each row in a byte-faithful read-modify-write (a second row on the same file re-reads after the first write, so the numbering stays correct), verifies, and reports per row: `stamped <id>`, `reused <id>`, `not-found`, `ambiguous`, or `refused:<why>`.

```
# dry-run first, then apply and verify
python3 stamp_blocks.py --manifest cite-manifest.json --root <vault> --dry-run
python3 stamp_blocks.py --manifest cite-manifest.json --root <vault> --verify
```

Under Cowork the script runs through the device shell; in Claude Code and GitHub Actions it runs natively. The skill is the behavioral spec and the pure-MCP fallback for a one-off stamp; the script is the batch executor and its behavior matches this skill exactly:

- `locate` identifies the **paragraph**; the stamp goes on the paragraph's **last** line.
- Zero matches -> `not-found`; more than one -> `ambiguous`; both skip the row and exit non-zero. It never picks the first match.
- Headings, frontmatter, tables, fences, horizontal rules, and the other mechanical exclusions are refused, not stamped.
- Reuse recognizes any existing trailing block ID (integer or human-minted) and reports `reused`.
- A re-run over already-stamped blocks is a no-op (every row `reused`); the file is byte-identical.

## Metadata exemption

Stamping a document does **not** bump its `updated:` field and does **not** add an `edit_log` entry -- the content did not change. This holds whether you stamp by hand or via the script (the script writes byte-faithfully so the diff is the single appended ID). Error-tracking that a bump might have given is covered by the verify-after-claim re-read and, at session close, a local citation-resolution lint over every document the session wrote.

## Edge Cases

- **Bold-text section dividers** (`**Bold**` used instead of `## Header`): not paragraphs; do not stamp. Block IDs on the surrounding paragraphs become the citation path for such sections. Note it in the report.
- **Very short files (<200 words):** still stampable; even a few IDs help.
- **Files with no substantive paragraphs** (thin clippings): report "no substantive content to stamp" and skip.
- **Mixed content:** stamp the prose; skip code blocks, tables, and embeds.
- **Human-minted IDs:** first-class -- reuse them, and cite them like any other (`[[File#^3f9a2c]]`).

## Common Mistakes

- **Falling back to a section anchor out of politeness** toward a collaborator's file. Any same-vault doc is in reach; the section anchor is for whole-section claims, not for foreign files.
- **Stamping a whole-section claim at the block level** (false precision) -- if the claim rests on the section, use `[[File#Header]]`.
- **Re-stamping / a second ID on a line.** Always check for an existing trailing ID first and reuse it.
- **Renumbering** to fill gaps. Block IDs are permanent.
- **Stamping the first line** of a multi-line paragraph. It goes on the last line.
- **Forgetting the space.** `text^b1` does not resolve; must be `text ^b1`.
- **Bumping `updated:` or writing an `edit_log` line** for a stamp. A stamp is not a content edit.
- **Reflowing the file** (EOL normalization, YAML re-dump). Append to the target line only.
- **"Completing" a sparse file.** Sparse is correct under on-cite stamping.

## Bulk Pre-Stamp (Legacy, Optional)

The original model stamped every substantive paragraph up front. This is superseded by on-cite stamping and is not the default -- it clutters sources with unused IDs and created the bulk re-stamp failure mode. Use it only for a deliberate, explicitly requested full pre-stamp, processing files one at a time (stamp, verify, next) with a per-batch summary.

## See Also

- [[Citation Mechanism - Block-Level Provenance]] -- full design canon (block IDs, on-cite stamping, lifecycle, precision)
- the Conventions Registry citation section -- the citation-format canon (block default, section-anchor fallback, glyph display)
- the synthesis-provenance design plan -- the extension of block citation to all generated documents (obligation tiers, evidence board, export patterns)
- `stamp_blocks.py` (Seed/Scripts) -- the batch script twin of this skill
- corpus-enrichment / transcript-harvest / document-harvest skills -- primary callers
