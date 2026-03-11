---
type: project-doc
title: DataWizard Quickstart
status: active
created: '2026-03-11'
updated: '2026-03-11'
tags:
  - protocol
  - AI-collaboration
  - DataWizard
  - onboarding
---

# DataWizard

**AI-assisted knowledge management for Obsidian.** Give this file to Claude (or any AI assistant) and it will walk you through setting up everything from scratch.

---

## For Humans: What Is This?

DataWizard is a protocol system that teaches AI agents how to work in your Obsidian vault. Once set up, your AI can read, write, organize, and enrich your notes — classifying content, processing transcripts, managing projects, and maintaining your knowledge system.

It's local-first, markdown-native, and designed so that you set it up once and your AI handles the rest.

---

## Quick Setup (5 minutes)

### 1. Install Obsidian
Download from https://obsidian.md — it's free. Create a new vault or open an existing one.

### 2. Download DataWizard
**Option A (easiest):** Click **Code → Download ZIP** above, unzip, and move the contents into a folder called `_DataWizard/Seed/` in your vault.

**Option B (if you use git):**
```bash
cd /path/to/your/vault
git clone https://github.com/andrewalan11/DataWizard.git _DataWizard/Seed
rm -rf _DataWizard/Seed/.git
```

### 3. Connect Claude to Obsidian
You need the MCP (Model Context Protocol) plugin so Claude can read and write your vault directly. See the setup guide in `_DataWizard/Seed/Guides for Humans/Connecting Obsidian to Claude Desktop on Mac.md` after downloading.

### 4. Create a Claude Project
In Claude, create a new Project and paste this into the **Project Instructions**:

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

### 5. Start a Conversation
Say "let's get started" and Claude will orient itself, ask what project you're working on, and help you set everything up.

---

## For AI Agents: Setup Guide

*If a user has given you this file and asked for help setting up, walk them through the steps above. Adapt to their experience level — ask what they already have installed before assuming anything.*

### What you're setting up:
- **Obsidian** — markdown-based note-taking app
- **DataWizard Seed** — protocols, taxonomy, and guides folder inside the vault
- **MCP connection** — so you can read/write the vault directly
- **Claude Project** — with universal instructions that work for any project

### After setup is complete:
The user will have `_DataWizard/Seed/` in their vault. Read `START HERE.md` in that folder, which will point you to the Universal Protocol. The protocol contains all operational rules for working in any DataWizard-managed vault.

### If the user mentions a specific project (e.g. "MetaMyth Relay"):
After completing the basic setup, help them create the project folder and bootstrap it per the Universal Protocol Section 18.

### If the user needs vault backup:
Walk them through the guide at `_DataWizard/Seed/Guides for Humans/Git Backup Setup — Claude-Guided Walkthrough.md`

---

## What's Inside

```
_DataWizard/Seed/
  START HERE.md                          — Entry point for vault orientation
  Protocols/
    DataWizard Universal Protocol.md     — Full AI operational rulebook (18 sections)
    Content Type Taxonomy.md             — 20 content types for note classification
    Claude Project Instructions Template.md
    START HERE For Humans Template.md
    DataWizard Quickstart.md             — This file (also serves as the GitHub README)
  Guides for Humans/
    START HERE - For Humans.md           — Human orientation guide
    Getting Started.md
    Connecting Obsidian to Claude Desktop on Mac.md
    Vault Backup Setup Guide.md
    Git Backup Setup — Claude-Guided Walkthrough.md
    Vault Structure Guide.md
```

---

## Links

- **GitHub:** https://github.com/andrewalan11/DataWizard
- **Obsidian:** https://obsidian.md
- **Claude:** https://claude.ai

---

*Created by Andrew Hasse. DataWizard is open source and free to use.*
