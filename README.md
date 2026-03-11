
# DataWizard

> **Getting started?** Paste this URL into a Claude conversation and Claude will walk you through setup: `https://github.com/andrewalan11/DataWizard`

**AI-assisted knowledge management for Obsidian.** DataWizard is a protocol system that teaches AI agents how to work in your Obsidian vault — reading, writing, organizing, and enriching your notes automatically.

---

## For AI Agents Reading This Page

A user has shared this link with you. Your job is to walk them through setting up DataWizard from scratch. **They don't need to download anything.** You'll read the protocols directly from GitHub.

### Setup Flow

1. **Ask what they have.** Do they have Obsidian installed? Do they have a vault? Are they collaborating on an existing project with someone, or starting fresh?

2. **Install Obsidian** (if needed). Download from https://obsidian.md — it's free. Have them create a new vault or open an existing one.

3. **Set up MCP.** This connects you to their Obsidian vault so you can read and write files directly. Fetch the setup guide and walk them through it step by step:

   `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Guides%20for%20Humans/Connecting%20Obsidian%20to%20Claude%20Desktop%20on%20Mac.md`

4. **Create a Claude Project.** Once MCP is working, have them create a new Claude Project and paste these instructions into the Project Instructions field:

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

5. **Ask about collaboration.** "Are you collaborating on a project with others?" If yes:
   - Help them install the **Obsidian Relay** plugin (Community Plugins → Browse → search "Relay")
   - Tell them: "Ask your project admin for the Relay server key and paste it here."
   - Walk them through entering the key in the Relay plugin settings
   - Once connected, the shared project folder will sync to their vault automatically

6. **Start a new conversation** in that Claude Project. From there, the AI will fetch the protocols from GitHub and can bootstrap any project.

---

## What's in This Repo

This repo is the source of truth for the DataWizard protocol system. AI agents read these files directly from GitHub — users don't need to download them.

```
Protocols/
  DataWizard Universal Protocol.md     — Full AI operational rulebook (v1.2, 18 sections)
  Content Type Taxonomy.md             — 20 content types for classification
  START HERE For Humans Template.md    — Template for project onboarding docs
  DataWizard Quickstart.md             — Detailed setup reference
Guides for Humans/
  Connecting Obsidian to Claude Desktop on Mac.md
  Getting Started.md
  Git Backup Setup — Claude-Guided Walkthrough.md
  Vault Backup Setup Guide.md
  Vault Structure Guide.md
  START HERE - For Humans.md
```

---

## For Protocol Developers

If you're maintaining or extending the DataWizard protocol, clone this repo locally:

```bash
cd /path/to/your/vault
git clone https://github.com/andrewalan11/DataWizard.git _DataWizard/Seed
rm -rf _DataWizard/Seed/.git
```

This gives you a local working copy in your vault. Push updates with the sync script (see `_DataWizard/Workshop/Publishing DataWizard Seed.md` in the Regen Vault).

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

*Created by Andrew Hasse. Open source and free to use.*
