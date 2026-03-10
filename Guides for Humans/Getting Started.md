---
title: Getting Started with DataWizard
type: document
created: '2026-03-07'
updated: '2026-03-07'
status: active
tags:
  - DataWizard
  - setup
  - guide
---

# Getting Started with DataWizard

*Welcome. This guide is for anyone setting up DataWizard in their own Obsidian vault. Read this first, then follow the other guides in this folder.*

---

## What Is DataWizard?

DataWizard is a **local-first AI knowledge management pipeline** for Obsidian. It watches your vault, processes new content through local AI models, and keeps everything classified, enriched, and findable — without sending your data to the cloud.

**What it does:**
- Classifies notes by content type (article, seed, transcript, entity, etc.)
- Enriches notes with tags, themes, and metadata
- Builds searchable structure across your vault
- Routes content into the right place automatically

**What makes it different:**
- Everything runs locally — models, indexes, data
- Built on plain markdown — no proprietary formats
- Modular — run just the pieces you need
- Designed for knowledge-dense vaults (transcripts, books, research, long-form notes)

---

## What You'll Need

### Hardware
- **Mac with Apple Silicon** (M1/M2/M3) strongly recommended — the pipeline is optimized for unified memory architecture
- **36GB RAM minimum** for running Qwen3 32B (the primary model)
- Smaller models (Qwen3.5 MoE variants) can run on 16GB but with reduced quality

### Software
- **Obsidian** — your vault lives here
- **Ollama** — runs local AI models ([ollama.com](https://ollama.com))
- **Python 3.10+** — for pipeline scripts
- **Claude Desktop** (optional but recommended) — for AI-assisted vault editing via MCP

### Models
The default pipeline uses **Qwen3 32B** via Ollama. Pull it with:
```bash
ollama pull qwen3:32b
```

Lighter alternative (~16GB RAM):
```bash
ollama pull qwen3.5:27b
```

---

## The Setup Journey

Setting up DataWizard is a multi-step process. The guides in this folder walk you through each step:

1. **This guide** — orientation and prerequisites
2. **[[Setting Up MCP-Obsidian with Claude Desktop on Mac]]** — connect Claude to your vault so it can read and edit notes directly
3. **[[Vault Structure Guide]]** — how to organize your vault for DataWizard
4. **[[Vault Backup Setup Guide]]** — set up git + GitHub so you have version history before running any pipelines

After setup, the pipeline lives in `~/Library/CloudStorage/Dropbox/Scripts/DataWizard/` (or wherever you prefer to keep scripts). The primary script is `classify.py`.

---

## Core Concepts

### Content Types
Every note gets a `type:` field in its YAML frontmatter. DataWizard uses a taxonomy of 21 content types — seeds, articles, transcripts, entities, and more. See `_DataWizard/Content Type Taxonomy.md` for the full list.

### The Classification Pipeline
The classifier (`classify.py`) reads notes, applies deterministic rules first (fast, no AI needed), then calls the local LLM for anything ambiguous. It outputs a dry-run log you review before applying changes.

### Dry Run → Review → Apply
Nothing gets written to your vault until you approve it. Every pipeline operation produces a log file first. You review, then apply.

### Local First
No API keys. No cloud. Your notes never leave your machine.

---

## Where to Go Next

- **Connect Claude to your vault:** `[[Setting Up MCP-Obsidian with Claude Desktop on Mac]]`
- **Understand the full architecture:** `_DataWizard/01 - Project/01 - Architecture v0.3.md`
- **See the content type taxonomy:** `_DataWizard/Content Type Taxonomy.md`
- **Read the Universal AI Protocol:** `_DataWizard/AI + LLMs - START HERE - DataWizard - Universal Protocol.md`
