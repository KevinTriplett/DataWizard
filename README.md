
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

3. **Set up MCP.** This connects you to their Obsidian vault so you can read and write files directly. Try to fetch the full setup guide first:

   `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Guides/Connecting%20Obsidian%20to%20Claude%20Desktop%20on%20Mac.md`

   If you can't fetch it, here are the essential steps:

   **Prerequisites:** Node.js must be installed. Check with `node --version` in Terminal. If not installed: `brew install node` (install Homebrew first if needed from https://brew.sh).

   **Setup (manual config — most reliable method):**

   a. Find the vault path — in Finder, navigate to the Obsidian vault folder, press Cmd+Option+C to copy the full path.

   b. Open the Claude Desktop config file in Terminal:
   ```bash
   open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```
   If the file doesn't exist, create it first:
   ```bash
   mkdir -p ~/Library/Application\ Support/Claude && \
   echo '{}' > ~/Library/Application\ Support/Claude/claude_desktop_config.json && \
   open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

   c. Add this to the file (merge with existing content if any), replacing the vault path:
   ```json
   {
     "mcpServers": {
       "obsidian": {
         "command": "npx",
         "args": [
           "@mauricio.wolff/mcp-obsidian@latest",
           "/Users/YOURUSERNAME/path/to/your/vault"
         ]
       }
     }
   }
   ```

   d. **Force Quit Claude Desktop** (Apple menu → Force Quit → Claude) and reopen. A normal Cmd+Q may not reload the config.

   e. Verify: go to Settings → Developer — you should see "obsidian" with a green "running" badge.

   f. Test: start a new conversation and try "What folders are in my vault?"

   **Troubleshooting:**
   - "No servers added" → check JSON syntax (no trailing commas), verify vault path exists, Force Quit and reopen
   - Smithery one-line install (`npx -y @smithery/cli install mcp-obsidian --client claude`) is an alternative but has a known bug on Node.js v25+ (`r.setPassword is not a function`). Use manual config instead.
   - MCP Tools plugin in Obsidian requires the "Local REST API" plugin to be installed first

4. **Create a Claude Project.** Once MCP is working, have them create a new Claude Project and paste these into the Project Instructions field:

```
# DW Project Instructions v2.1

## Tools
You have Obsidian MCP tools. Use them directly — never ask the
user to copy/paste vault content.

obsidian:read_note, obsidian:write_note, obsidian:patch_note,
obsidian:read_multiple_notes, obsidian:list_directory,
obsidian:search_notes, obsidian:get_frontmatter,
obsidian:update_frontmatter, obsidian:get_notes_info,
obsidian:move_note, obsidian:move_file, obsidian:manage_tags,
obsidian:delete_note, obsidian:get_vault_stats

## Working Rules (always follow)
1. WRITE TO VAULT: For new content, write directly to the vault
   as .md — never draft markdown in chat (it's hard to read
   there). Share your plan first, get approval, then write to
   vault. The user will read it in Obsidian.
2. EDITS TO EXISTING DOCS: When editing an existing file, show
   the proposed changes in chat first as plain text (not
   markdown). Once approved, write to vault.
3. RE-READ BEFORE WRITING: In shared projects (Relay), always
   re-read the file immediately before writing. Another user or
   agent may have changed it since your last read.
4. CHUNK: Break multi-step plans into chunks. Present each
   chunk, get approval, execute, check in before next chunk.
5. VERIFY: After any write/patch/move, confirm success before
   retrying. Silent success + retry = duplicate content.
6. ASK: When uncertain about anything — placement, naming,
   scope — ask rather than assume.
7. HARVEST DISCIPLINE: When harvesting from transcripts or
   source files, treat each source as one atomic unit:
   (a) Segment first — add ## headers before extracting
   (b) Harvest content into destination docs
   (c) Update source YAML (harvest_status, harvested_into)
   Complete all three before moving to the next source.
   See Protocol Sections 7 and 9.

## Orientation (once per thread)
1. Fetch version check:
   https://raw.githubusercontent.com/andrewalan11/DataWizard/main/VERSION.md
2. Read 0.0 Project Guidelines (frontmatter only)
3. Compare datawizard_protocol_version against VERSION.md
   - Match → fetch protocol summary:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Protocol%20Summary.md
   - Mismatch or no guidelines → fetch full protocol:
     https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/DataWizard%20Universal%20Protocol.md
4. Compare DW Project Instructions version against VERSION.md
   — flag if user needs to re-paste
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

5. **Ask about collaboration.** "Are you collaborating on a project with others?" If yes:
   - Help them install the **Obsidian Relay** plugin (Community Plugins → Browse → search "Relay")
   - Tell them: "Ask your project admin for the Relay server key and paste it here."
   - Walk them through entering the key in the Relay plugin settings
   - Once connected, the shared project folder will sync to their vault automatically

6. **Start a new conversation** in that Claude Project. From there, the AI will fetch the protocols from GitHub and can bootstrap any project.

7. **Post-install feedback.** Once setup is complete and the user has confirmed everything is working, ask: "Would you like me to generate a quick report on how the install went? I can note any issues we hit, steps that were confusing, and suggestions for improving the DataWizard setup process." If yes, generate a brief report covering: what worked smoothly, what was confusing or required troubleshooting, any errors encountered, and suggestions for improving the setup instructions. The user can share this report with the DataWizard maintainer to improve the onboarding experience.

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

### Direct File URLs (for AI agents)

If you're an AI reading this README and need to fetch any file, here are the raw URLs:

**Core Files:**
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/VERSION.md`
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/COPY%20INTO%20CLAUDE%20PROJECT.md`

**Protocols:**
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/DataWizard%20Universal%20Protocol.md`
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Protocol%20Summary.md`
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Content%20Type%20Taxonomy.md`
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Protocols/Human%20Onboarding%20Doc%20Template.md`

**Guides:**
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Guides/Connecting%20Obsidian%20to%20Claude%20Desktop%20on%20Mac.md`
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Guides/Git%20Backup%20Setup%20%E2%80%94%20Claude-Guided%20Walkthrough.md`
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Guides/Vault%20Backup%20Setup%20Guide.md`
- `https://raw.githubusercontent.com/andrewalan11/DataWizard/main/Guides/Vault%20Structure%20Guide.md`

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
