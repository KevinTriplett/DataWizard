# Welcome to DataWizard

*A quick orientation for new users — human and AI alike.*

---

## What Is This?

DataWizard is a **local-first AI knowledge management pipeline** for Obsidian. It processes your notes through local AI models — classifying, enriching, and linking content automatically — without sending anything to the cloud.

The goal is not to read everything yourself. It's to build a system that reads for you, remembers for you, and retrieves what matters when you need it.

**What DataWizard does:**
- Classifies notes by content type (article, transcript, seed, entity, etc.)
- Enriches notes with tags, themes, and metadata
- Processes transcripts into segmented, searchable companion notes
- Routes content into the right place in Obsidian automatically

**Core principles:** local-first, markdown as universal format, modular pipelines, prompts as portable `.md` files, progressive enrichment, confidence-based metadata.

---

## How to Get Started

**Step 1 — Set up your AI.** Open `_DataWizard/Seed/PASTE INTO CLAUDE.md` and copy the contents into your Claude Project Instructions. That's the only configuration your AI needs. For more detail, see `_DataWizard/Seed/START HERE.md`.

**Step 2 — Read the setup guides** (this folder):

| Guide | What It Covers |
|---|---|
| **[[Getting Started]]** | Prerequisites, hardware, models, the setup journey |
| **[[Vault Structure Guide]]** | Folder layout, YAML schema, naming conventions |
| **[[Connecting Obsidian to Claude Desktop on Mac]]** | MCP setup — connecting Claude to your vault |
| **[[Git Backup Setup — Claude-Guided Walkthrough]]** | Git + GitHub backup — step-by-step guide Claude walks you through |

**Step 3 — Start a conversation with your AI.** It will ask what project you're working on, find the right guidelines file, and orient itself. If no project exists yet, it will walk you through bootstrapping one.

---

## Folder Map

```
_DataWizard/
  Seed/                                ← shareable DataWizard kit (you are here)
    START HERE.md                      ← AI entry point — start here
    Guides for Humans/                 ← setup guides (this folder)
    Protocols/
      DataWizard Universal Protocol.md ← full AI rulebook
      Content Type Taxonomy.md         ← 20 content types
      Claude Project Instructions Template.md
      START HERE For Humans Template.md
  Workshop/                            ← R&D and vault-specific working files (not shared)
```

---

## For Your AI — Copy Into Project Instructions

Paste this block into your Claude Project Instructions (or equivalent system prompt). This is the only setup your AI needs — the vault docs handle everything else.

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

## Orientation (once per thread)
If you haven't oriented yet this thread, find and read the
Universal Protocol before doing any vault work:

1. Look for a START HERE file in the _DataWizard/Seed/ folder
2. Follow its instructions to read the Universal Protocol
3. After reading it once, proceed normally

## Project Context
At the start of the first conversation, ask the user:
"What project are we working on?"

Then find the project folder in the vault and look for a
guidelines file (typically named "0.0 Project Guidelines.md").
If none exists, follow the Universal Protocol's bootstrap
section to help the user create one.
```
