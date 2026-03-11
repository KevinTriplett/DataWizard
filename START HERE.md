---
tags:
  - protocol
  - AI-collaboration
  - DataWizard
type: project-doc
title: START HERE
status: active
created: '2026-03-07'
updated: '2026-03-11'
---

# DataWizard — START HERE

Welcome to DataWizard — an AI-powered protocol system for Obsidian.

---

## Step 1: Paste This Into Claude

Copy the block below and paste it into your **Claude Project Instructions**. This is the only setup you need to do. Claude handles everything from here.

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

---

## Step 2: Start a Conversation

Open your Claude Project and say "let's get started." Claude will read the protocols, ask what project you're working on, and guide you from there.

---

## For Humans Who Want to Know More

Setup guides and documentation are in the `Guides for Humans/` folder:

- **[[Getting Started]]** — Prerequisites and setup walkthrough
- **[[Connecting Obsidian to Claude Desktop on Mac]]** — MCP setup
- **[[Git Backup Setup — Claude-Guided Walkthrough]]** — Vault backup
- **[[Vault Structure Guide]]** — How the vault is organized

The full AI protocol is in `Protocols/DataWizard Universal Protocol.md` — you don't need to read it, but it's there if you're curious.

---

*DataWizard is open source. GitHub: https://github.com/andrewalan11/DataWizard*
