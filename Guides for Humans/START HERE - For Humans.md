# Welcome to DataWizard

*A quick orientation for working on this project*

---

## What Is This?

DataWizard is a **local-first knowledge management pipeline** — a modular system that watches for new data across multiple sources, processes it through local AI models, and makes everything searchable and queryable. All data, indexes, and models live on your machine.

The goal is not to read everything yourself. It's to build a system that reads for you, remembers for you, and retrieves what matters when you need it.

**What DataWizard does:**
- Ingests content from multiple sources (web clips, transcripts, PDFs, bookmarks, YouTube)
- Processes each through a local AI pipeline: classify → segment → enrich → harvest → link
- Builds a searchable knowledge graph across all vaults
- Extracts lexicon candidates — distinctive phrases and framings worth preserving
- Routes everything into the right place in Obsidian automatically

**Core principles:** local-first, markdown as universal format, modular pipelines, prompts as portable `.md` files, progressive enrichment, confidence-based metadata.

---

## What Are All These Documents?

| Document | What's In It | When You'd Use It |
|---|---|---|
| **DataWizard Overview** | Project vision, current status, module map, hardware context | You need a snapshot of where the project is and what it does |
| **Architecture v0.3** | Full technical design — pipelines, data flow, components | You're building or debugging a pipeline module |
| **Enrichment Pipeline Spec** | Detailed spec for all content types and enrichment passes | You're writing a pipeline script or prompt |
| **Transcript Processing Spec** | Transcript-specific pipeline: segmentation, companion notes, meme harvesting | You're building or running Steps 2–4 on a transcript |
| **Chunking Strategy** | Three-tier chunking architecture with RAPTOR for books | You're building the RAG/vector search layer |
| **Content Type Taxonomy** | 21 active content types with YAML conventions | You're classifying a note or updating `classify.py` |
| **Decision Log** | Every key architectural decision with rationale | You need to understand why something was built a certain way |
| **Session Log** | Reverse-chronological work log | You're picking up after a break — start here |
| **Research Log** | Tools, models, and community findings | You're researching a new component |
| **Review Queue** | Notes and batch operations waiting for human review | You need to process pending classification or migration tasks |

---

## How to Resume a Session

1. **Read the Session Log** (`_DataWizard/00 - Project/04 - Session Log.md`) — the most recent entry tells you exactly where you left off and what's next.
2. **Check the Decision Log** (`03 - Decision Log.md`) for any open questions that may be relevant.
3. **Check the Review Queue** (`Review Queue.md`) for any pending human-review items.
4. **Scan the Overview** (`00 - DataWizard Overview.md`) "Current Status" block for a quick project snapshot.

---

## Key File Locations

```
_DataWizard/
  00 - Project/
    00 - DataWizard Overview.md     ← project snapshot and module map
    01 - Architecture v0.3.md       ← full technical architecture
    02 - Research Log.md            ← tools and community research
    03 - Decision Log.md            ← all design decisions with rationale
    04 - Session Log.md             ← start here when resuming
  01 - Research/
    Enrichment Pipeline Spec.md     ← full pipeline spec
    Transcript Processing Spec.md   ← transcript Steps 2–4
    Chunking Strategy.md            ← three-tier RAG architecture
    [other research docs]
  Content Type Taxonomy.md          ← 21 active types, YAML conventions
  Review Queue.md                   ← pending human-review items
  AI + LLMs - START HERE - DataWizard - Universal Protocol.md  ← universal AI protocol (vault-wide)

~/DataWizard/                       ← pipeline code (to be created)
~/Library/CloudStorage/Dropbox/Scripts/  ← existing scripts
```

---

## For Your AI — Copy Into Project Instructions

Paste this block into your Claude Project Instructions before starting a session. This is the only setup your AI needs — the vault docs handle everything else.

```
## Tools
You have Obsidian MCP tools. Use them directly — never ask the
user to copy/paste vault content.

obsidian:read_note, obsidian:write_note, obsidian:patch_note,
obsidian:read_multiple_notes, obsidian:list_directory,
obsidian:search_notes, obsidian:get_frontmatter,
obsidian:update_frontmatter, obsidian:get_notes_info,
obsidian:move_note, obsidian:move_file, obsidian:manage_tags,
obsidian:delete_note, obsidian:get_vault_stats

## This Project
DataWizard — vault infrastructure, pipeline architecture, and
the enrichment system. Work here includes pipeline development,
content taxonomy, protocol docs, and project scaffolding.

## Orientation (once per thread)
If you haven't read this yet this thread, read it before
doing any vault work:
1. _DataWizard/AI + LLMs - START HERE - DataWizard - Universal Protocol.md

After reading it once, proceed normally — no need to re-read
within the same thread.
```
