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

This is the local development copy. If you're a new user, you don't need this file — just paste `https://github.com/andrewalan11/DataWizard` into a Claude conversation and Claude will walk you through everything.

---

## For Vault Developers

This is the working copy of the DataWizard Seed. Edit protocols here, then push to GitHub:

```bash
~/Library/CloudStorage/Dropbox/Scripts/DataWizard/sync-datawizard-seed.sh
```

The published Seed at GitHub is what all users and Claude instances read from. Your local copy is your development workspace.

### Project Instructions (current version)

This is the universal block that gets pasted into every Claude Project. It fetches the protocol from GitHub so users always get the latest version:

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
If you haven't oriented yet this thread, fetch and read the
Universal Protocol before doing any vault work:

https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/DataWizard%20Universal%20Protocol.md

After reading it once, proceed normally.

## Project Context
At the start of the first conversation, ask the user:
"What project are we working on?"

Then find the project folder in the vault and look for a
guidelines file (typically named "0.0 Project Guidelines.md").
If none exists, follow the Universal Protocol's bootstrap
section to help the user create one.
```

---

*Part of DataWizard vault infrastructure.*
