
# DataWizard

> **Getting started?** Paste this URL into a Claude conversation and Claude will walk you through setup: `https://github.com/andrewalan11/DataWizard`

---

## What Is DataWizard?

DataWizard is a **local-first AI knowledge management system** for Obsidian. It teaches AI agents how to work in your vault — reading, writing, organizing, and enriching your notes automatically.

The goal is not to read everything yourself. It's to build a system that reads for you, remembers for you, and retrieves what matters when you need it.

**What it does:**
- Classifies notes by content type (article, transcript, seed, entity, etc.)
- Enriches notes with tags, themes, and metadata
- Processes transcripts into segmented, searchable companion notes
- Routes content into the right place in Obsidian automatically
- Manages multi-project infrastructure with consistent conventions
- Coordinates multiple AI agents working in the same vault

**Core principles:** local-first, markdown-native, modular pipelines, progressive enrichment, draft-then-approve collaboration.

---

## Getting Started

**You don't need to read documentation.** Give this link to Claude and it will walk you through everything — installing Obsidian, connecting your AI, setting up your first project.

If you prefer to understand what you're getting into first, here's the setup overview:

### What You'll Need

- **Obsidian** — free, from https://obsidian.md
- **Claude Pro** — for Claude Projects and MCP support
- **Apple Silicon Mac** recommended (M1/M2/M3) — the local AI pipeline is optimized for unified memory
- **Ollama** (optional) — for running local AI models like Qwen3 for automated classification

### The Setup Flow

1. Install Obsidian and create a vault
2. Set up MCP (connects Claude to your vault so it can read/write files)
3. Create a Claude Project and paste the DataWizard instructions
4. Start a conversation — Claude reads the protocols and helps you set up your first project
5. If collaborating: install the Relay plugin and get a server key from your project admin

Claude handles steps 2–5 for you. Just paste the GitHub link into a conversation and follow along.

### Core Concepts

**Content Types** — Every note gets a `type:` field. DataWizard uses a taxonomy of 20 content types — seeds, articles, transcripts, entities, and more.

**The 0.x Infrastructure** — Every project folder has standardized infrastructure files: `0.0 Project Guidelines`, `0.1 MOC`, `0.2 Session Log`, etc. Same numbers always mean the same thing.

**Draft → Review → Apply** — Nothing gets written to your vault until you approve it. Every operation produces a plan or log first. You review, then approve.

**Local First** — Your notes never leave your machine. The protocol system works with Claude via MCP, but all data stays in your vault.

---

## For AI Agents Reading This Page

A user has shared this link with you. Your job is to walk them through setting up DataWizard from scratch. **They don't need to download anything.** You'll read the protocols directly from GitHub.

### Setup Flow

1. **Ask what they have.** Do they have Obsidian installed? Do they have a vault? Are they collaborating on an existing project with someone, or starting fresh?

2. **Install Obsidian** (if needed). Download from https://obsidian.md — it's free. Have them create a new vault or open an existing one.

3. **Set up MCP.** This connects you to their Obsidian vault so you can read and write files directly. Fetch the setup guide and walk them through it step by step:

   `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Guides/Connecting%20Obsidian%20to%20Claude%20Desktop%20on%20Mac.md`

4. **Create a Claude Project.** Once MCP is working, have them create a new Claude Project and paste these into the Project Instructions field:

```
# DW Project Instructions v1.0

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
1. Fetch version check:
   https://raw.githubusercontent.com/andrewalan11/DataWizard/main/VERSION.md
2. Read 0.0 Project Guidelines (frontmatter only)
3. Compare datawizard_protocol_version against VERSION.md
   - Match → fetch protocol summary:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Protocol%20Summary.md
   - Mismatch or no guidelines → fetch full protocol:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/DataWizard%20Universal%20Protocol.md
4. Compare DW Project Instructions and Memory versions
   against VERSION.md — flag if user needs to re-paste
5. Read 0.2 Session Log (last 2-3 entries only)
6. Ready to work — read files only as needed

## Project Context
At the start of the first conversation, ask the user:
"What project are we working on?"

Then find the project folder in the vault and look for a
guidelines file (typically named "0.0 Project Guidelines.md").
If none exists, follow the Universal Protocol's bootstrap
section to help the user create one.
```

5. **Set up Project Memory.** Have them add this as a memory edit (Settings → Memory):

```
# DW Project Memory v1.0

## Working Rules (always follow)
1. DRAFT FIRST: Never use write_note, patch_note, or move_note without explicit human approval. Draft in chat, wait for "go ahead" or equivalent.
2. CHUNK: Break multi-step plans into chunks. Present each chunk, get approval, execute, check in before next chunk.
3. VERIFY: After any write/patch/move, confirm success before retrying. Silent success + retry = duplicate content.
4. ASK: When uncertain about anything — placement, naming, scope — ask rather than assume.
```

6. **Ask about collaboration.** "Are you collaborating on a project with others?" If yes:
   - Help them install the **Obsidian Relay** plugin (Community Plugins → Browse → search "Relay")
   - Tell them: "Ask your project admin for the Relay server key and paste it here."
   - Walk them through entering the key in the Relay plugin settings
   - Once connected, the shared project folder will sync to their vault automatically

7. **Start a new conversation** in that Claude Project. From there, the AI will fetch the protocols from GitHub and can bootstrap any project.

---

## What's in This Repo

```
COPY INTO CLAUDE PROJECT.md            — Both blocks to paste (instructions + memory)
README.md                              — This file
VERSION.md                             — Version numbers for auto-update checks
Protocols/
  DataWizard Universal Protocol.md     — Full AI operational rulebook (v1.6, 18 sections)
  Protocol Summary.md                  — Lean quick-reference (~500 tokens vs ~15K)
  Content Type Taxonomy.md             — 20 content types for classification
  Human Onboarding Doc Template.md     — Template for project onboarding docs
Guides/
  Connecting Obsidian to Claude Desktop on Mac.md
  Git Backup Setup — Claude-Guided Walkthrough.md
  Vault Backup Setup Guide.md
  Vault Structure Guide.md
```

---

## Want a Local Copy? (Optional)

By default, Claude reads the protocols directly from GitHub — you don't need to download anything. But a local copy gives you some advantages: the protocol is searchable inside Obsidian, you can link to it from other notes with `[[wikilinks]]`, and it works offline.

If you want a local copy, download the ZIP and unzip into `_DataWizard/Seed/` in your vault. Then change your project instructions to read from the vault instead of GitHub:

```
## Orientation (once per thread)
If you haven't oriented yet this thread, read the Universal
Protocol before doing any vault work:

_DataWizard/Seed/Protocols/DataWizard Universal Protocol.md

After reading it once, proceed normally.
```

The protocol includes a version check — Claude will compare your local copy against GitHub and offer to update it when a new version is available.

---

## For Protocol Developers

If you're maintaining or extending the DataWizard protocol, clone this repo locally:

```bash
cd /path/to/your/vault
git clone https://github.com/andrewalan11/DataWizard.git _DataWizard/Seed
rm -rf _DataWizard/Seed/.git
```

This gives you a local working copy in your vault.

---

*Created by Andrew Hasse. Open source and free to use.*
