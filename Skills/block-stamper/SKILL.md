---
name: block-stamper
description: "Stamp a block ID (^bN documents, ^tN transcripts) on a source
  paragraph or transcript turn at the moment a citation points to it -- on-cite,
  not in bulk (S201 canon). Idempotent: reuse an existing ID, else assign the
  next unused integer; never re-stamp or renumber. Called by corpus-enrichment,
  transcript-harvest, document-harvest when they cite a passage. Triggers on:
  'stamp block ids', 'add a citation anchor', 'stamp this block'."
type: skill
version: "1.1"
created: 2026-06-11
updated: 2026-06-25
edit_log:
  - DW-S166 2026-06-11
  - "DW-S202 2026-06-25 - reframed bulk -> on-cite stamping (S201 canon):
    next-unused-integer, partial-is-normal, bulk demoted to legacy"
---
# Block Stamper Skill

**Status:** Active (Seed)

## Overview

Stamp a block ID on a source-file paragraph or transcript turn so it becomes addressable via Obsidian's native `^block-id` syntax -- giving a citation a clickable breadcrumb back to the exact passage.

**Stamping is on-cite, not in bulk (S201 canon).** A block gets an ID only when something actually cites it -- during enrichment or harvest -- so sources accumulate IDs sparsely, only where they have been referenced. This is a utility skill: the downstream skills (corpus-enrichment, transcript-harvest, document-harvest) call it at the moment they cite a passage. A whole-document pre-stamp is retained as an optional legacy mode (see Bulk Pre-Stamp below). Citation canon: [[Conventions Registry]]. Full spec: [[Citation Mechanism - Block-Level Provenance]].

## When to Use

- At cite time -- an enrichment or harvest pass references a specific paragraph or transcript turn that has no ID yet
- Called by corpus-enrichment, transcript-harvest, or document-harvest as a stamp-on-cite step
- User says "stamp this block", "add a citation anchor here", "give this paragraph a block ID"
- (Legacy) a deliberate whole-file pre-stamp -- rarely needed; see Bulk Pre-Stamp (Legacy) below

### When NOT to Use

- The target block already carries an ID -- reuse it, never re-stamp (re-stamping breaks live citations, S173)
- The target is a section header (already addressable via `[[File#Header]]`), a companion note, MOC, infrastructure file, or any non-source content
- File is in an archive folder

## Before You Start

1. Read this skill fully.
2. Determine the content type of the source file (article, transcript, or voice memo). This determines the block ID prefix.
3. Locate the specific block being cited and check whether it already has an ID.

## Content Type Detection

| Content Type | Block Prefix | How to Detect |
|---|---|---|
| Article / document / clipping | `^b` | Default. No speaker turns, not a transcript. |
| Transcript (meeting, interview, podcast) | `^t` | Has speaker turns (`**Name**:` pattern), or `type: transcript` / `type: meeting-transcript` in frontmatter |
| Voice memo | `^t` | `type: voice-memo` in frontmatter, or single-speaker transcript format |

When in doubt, use `^b` (article default).

## Stamping Rules

### What Gets a Block ID

- Every substantive prose paragraph (2+ sentences or one sentence making a specific claim)
- Each speaker turn in a transcript (the full turn, not each sentence within it)
- Individual list items when they contain substantive claims (not navigation lists, TOCs, or simple enumerations)
- Blockquotes that contain substantive content

### What Does NOT Get a Block ID

- Section headers (`#`, `##`, etc.) -- already addressable via `[[File#Header]]`
- YAML frontmatter
- Empty lines
- Horizontal rules (`---`)
- Image embeds (`![[image]]`, `![alt](url)`)
- Callout wrappers (`> [!note]` etc. -- stamp the content inside, not the wrapper)
- Navigation boilerplate (breadcrumbs, "Part of" lines, TOC links)
- Very short transitional lines ("See below.", "As follows:", "For example:") that carry no independent claim
- Lines that are purely formatting (bold-only section dividers like `**Section Name**` with no prose)

### Numbering

- **Next unused integer in the file** -- scan for existing `^bN`/`^tN`, assign the highest + 1. Under on-cite stamping IDs are *sparse*, so `^b9` is a stable handle, not "the 9th block."
- Articles: `^b1`, `^b2`, `^b3`, ... Transcripts: `^t1`, `^t2`, `^t3`, ...
- Block IDs are appended at the **end of the paragraph's (or turn's) last line**, separated by a space
- One block ID per paragraph -- never mid-paragraph
- **Never renumber** to fill gaps -- IDs are permanent handles

### Placement

The block ID goes at the very end of the paragraph, after all content including inline formatting, citations, and parenthetical references:

```
Reich discovered the orgasm function by studying energy pulsation
blocked in the armoured working class of post-WW1 Vienna. ^b7
```

For transcript turns:

```
**Kevin**: I had a really good call with some of the community
organizers and developers for the Holo movement. ^t1
```

For list items with substantive claims:

```
- Commons-based peer production enables collaborative work at
  planetary scale without corporate intermediaries ^b12
```

### Idempotency

- **Never re-stamp a block that already has an ID.** Before stamping the target paragraph/turn, check whether its last line already ends with a `^bN`/`^tN`; if so, reuse that ID and stop.
- **Partial stamping is the normal state, not an error.** Under on-cite stamping most files are sparsely stamped (only cited blocks carry IDs). Never "complete" a file or flag it as unusual for being partly stamped.
- Block IDs are assigned once and never renumbered. New stamps always take the next unused integer in the file (never reused, never back-filled).

## The Stamping Process (on-cite)

You are stamping **one block** -- the paragraph or transcript turn a citation is about to point at.

### Step 1: Locate the target block

From the citing pass, identify the exact source paragraph or transcript turn being cited. Read enough of the source to find it unambiguously (filesystem Read as fallback if the file is large and the MCP overflows).

### Step 2: Check whether it's already stamped

Look at the end of the block's last line. If it already ends with a `^bN`/`^tN`, **reuse that ID** in the citation -- do not add another. Done.

### Step 3: Pick the prefix and the next integer

Prefix by content type (`^b` document, `^t` transcript -- see Content Type Detection above). Scan the file for existing `\^[bt]\d+` IDs and take the next unused integer (highest + 1; never reuse, never back-fill).

### Step 4: Append the ID

Add ` ^bN` (a space, then the caret ID) at the very end of the block's last line, after all content and punctuation. Use `patch_note` with the block's last line as a unique oldString -> the same line + ` ^bN`. Never touch frontmatter or headers.

### Step 5: Verify

Re-read the line, confirm the ID is present, and confirm the citation `[[File#^bN]]` resolves. Report the file, the block, the prefix, and the ID assigned (new or reused).

## Edge Cases

**Bold-text section dividers:** Some sources use `**Bold Text**` as section dividers instead of `## Markdown Headers`. These are NOT paragraphs and should NOT get block IDs. However, they also aren't addressable via `[[File#Header]]` (Obsidian only resolves real markdown headers). Block IDs on surrounding paragraphs become the only citation path for these sections. Note this in the report.

**Very short files (<200 words):** Still stampable. Even a few block IDs are useful for citation precision.

**Files with no substantive paragraphs:** Possible for very thin clippings (just a title and a link). Report "no substantive content to stamp" and skip.

**Mixed content:** Some files have prose paragraphs interspersed with code blocks, tables, or embedded content. Stamp the prose; skip the non-prose.

## Common Mistakes

- **Stamping headers.** Headers are already addressable. Don't add block IDs to them.
- **Stamping inside YAML.** Never touch frontmatter content.
- **Re-stamping.** Always check the target block for an existing ID first; reuse it.
- **Renumbering.** Block IDs are permanent. Never renumber to fill gaps.
- **Putting block ID on the wrong line.** It goes on the LAST line of a multi-line paragraph, not the first.
- **Forgetting the space.** `text^b1` won't resolve in Obsidian. Must be `text ^b1` with a space before the caret.
- **Stamping companion notes.** Only stamp source files, never companions or other DW infrastructure.
- **"Completing" a sparse file.** Under on-cite stamping, a file with only some blocks stamped is correct, not unfinished. Don't fill in the rest.

## Bulk Pre-Stamp (Legacy, Optional)

The original model stamped *every* substantive paragraph in a file up front, before enrichment. **This is superseded by on-cite stamping (S201)** and should not be the default -- it created the bulk re-stamp failure mode (S173) and clutters sources with unused IDs. Use it only for a deliberate, one-off full pre-stamp when explicitly requested.

If pre-stamping a whole file: walk it paragraph by paragraph applying the What Gets / What Does Not rules, assign the next unused integer to each unstamped substantive block (never re-stamp, never renumber), then verify. When stamping a batch, process files one at a time (stamp, verify, next) and report a per-batch summary (files processed, blocks stamped, files skipped and why).

## See Also

- [[Conventions Registry]] -- the citation-format canon (on-cite stamping, glyph display)
- [[Citation Mechanism - Block-Level Provenance]] -- full design doc for the citation system
- corpus-enrichment skill -- primary consumer; stamps + cites blocks in companion notes
- transcript-harvest skill -- stamps + cites turns in harvest destinations
- document-harvest skill -- stamps + cites blocks in harvest destinations
- [[Rabbit Whole RAG - Corpus Architecture]] -- RAG layer computes chunk coordinates independently; a block ID aligns with a chunk where one is stamped (decoupled, S201)
