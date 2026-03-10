---
title: START HERE
type: project-doc
created: '2026-03-07'
updated: '2026-03-08'
status: active
tags:
  - protocol
  - AI-collaboration
  - DataWizard
---

# START HERE

Welcome to DataWizard — a protocol system for AI-assisted knowledge management in Obsidian.

---

## Step 1: Set Up Your AI

Copy the block below and paste it into your **Claude Project Instructions** (or equivalent system prompt for your AI agent). This is the only setup your AI needs.

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
Infer the active project from the Claude Project name.
Find the project folder and look for a guidelines file
(typically named "0.0 Project Guidelines.md").
If none exists, follow the Universal Protocol's bootstrap
section to help the user create one.
```

Once pasted, start a conversation and your AI will read the protocols and help you set up your first project.

---

## Step 2: Read the Guides (Humans)

If you want to understand the system yourself before working with AI:

- **[[Getting Started]]** — Quick start guide
- **[[Vault Structure Guide]]** — How the vault is organized
- **[[Connecting Obsidian to Claude Desktop on Mac]]** — MCP setup
- **[[Vault Backup Setup Guide]]** — Git backup configuration

These are in the `Guides for Humans/` folder.

---

## Step 3: Read the Protocol (Optional)

The full operational rulebook your AI follows is here:

→ **[[DataWizard Universal Protocol]]** in `Protocols/`

You don't need to read this to get started — your AI knows it. But if you want to understand how the system works, it's all there.

---

*Part of DataWizard vault infrastructure.*
