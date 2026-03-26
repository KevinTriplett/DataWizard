
# DataWizard

> A local-first AI knowledge management system for Obsidian.

---

## What Is DataWizard?

DataWizard teaches AI agents how to work in your Obsidian vault - reading, writing, organizing, and enriching your notes automatically.

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

## Quick Start

### 1. Install Obsidian

Download from https://obsidian.md (free). Create a new vault or open an existing one.

### 2. Install the DataWizard Seed

Open Terminal (Cmd + Space, type "Terminal", hit Enter) and run this command. Replace the path with your vault location:

```bash
cd ~/path/to/your/vault && \
curl -sL https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip -o /tmp/dw-seed.zip && \
unzip -qo /tmp/dw-seed.zip -d /tmp/dw-seed && \
mkdir -p _DataWizard/Seed && \
cp -R /tmp/dw-seed/DataWizard-main/* _DataWizard/Seed/ && \
rm -rf /tmp/dw-seed /tmp/dw-seed.zip && \
echo "DataWizard Seed installed to _DataWizard/Seed/"
```

To find your vault path: open Finder, navigate to your vault folder, press Cmd+Option+C to copy the full path.

You should see "DataWizard Seed installed" and a new `_DataWizard/Seed/` folder in your vault.

### 3. Set up MCP

MCP connects Claude to your Obsidian vault so it can read and write files directly. The full guide is in your Seed at `_DataWizard/Seed/Guides/Connecting Obsidian to Claude Desktop on Mac.md`, but here are the essential steps:

**Check your Node.js version** (needed for MCP). In Terminal:
```bash
node --version
```
- "command not found" - install Node.js first: `brew install node` (install Homebrew from https://brew.sh if needed)
- v24 or below - use Smithery (one command, easier)
- v25 or above - use Manual Config (Smithery has a known bug on v25+)

**Smithery (Node v24 and below):**
```bash
npx -y @smithery/cli install @bitbonsai/mcpvault --client claude
```
When prompted, paste your vault path.

**Manual Config (Node v25+):**
```bash
open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
```
If the file doesn't exist:
```bash
mkdir -p ~/Library/Application\ Support/Claude && \
echo '{}' > ~/Library/Application\ Support/Claude/claude_desktop_config.json && \
open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
```
Replace contents with (substituting your vault path):
```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": [
        "@bitbonsai/mcpvault@latest",
        "/Users/YOURUSERNAME/path/to/your/vault"
      ]
    }
  }
}
```

**After either method:** Force Quit Claude Desktop (Apple menu - Force Quit - Claude) and reopen. Check Settings - Developer for a green "obsidian" badge.

### 4. Back up your vault

Before going further, make sure your vault is backed up. The recommended method is a private git repository.

If you already have backups set up, skip ahead. If not, your Seed includes a setup guide at `_DataWizard/Seed/Guides/Git Backup Setup - Claude-Guided Walkthrough.md`. You can ask Claude to walk you through it after completing step 5.

### 5. Create a Claude Project

1. In Claude Desktop, create a new Project
2. Go to Settings - Project Instructions
3. Open `_DataWizard/Seed/Project Instructions - Copy-Paste into Claude.md` in Obsidian
4. Copy the block between the ``` fences and paste it into Project Instructions
5. Fill in the Home folder line (e.g., `_DataWizard/`)

### 6. Start working

Open a conversation in your new Claude Project. Claude will orient itself by reading your Seed and project files, then it's ready to help you set up your first project, classify notes, or whatever you need.

---

## Updating

DataWizard checks for updates automatically. When you start a new conversation, Claude compares your local Seed version against the latest on GitHub. If there's an update available, it tells you what changed and asks if you want to update.

To update manually at any time:
```bash
bash _DataWizard/Seed/update_seed.sh
```

This downloads the latest Seed and overwrites only the Seed files. Your project content (session logs, Workshop docs, action items) is never touched.

---

## What's in the Seed

```
_DataWizard/Seed/
  VERSION.md                              - Version numbers and update instructions
  Project Instructions - Copy-Paste into Claude.md  - Project Instructions to paste into Claude
  README.md                               - This file
  update_seed.sh                          - Install/update script
  Protocols/
    DataWizard Universal Protocol.md      - Full AI operational rulebook
    Protocol Summary.md                   - Quick reference
    Content Type Taxonomy.md              - 20 content types for classification
  Skills/
    project-guidelines/SKILL.md           - Creating/updating 0.0 files
    research/SKILL.md                     - Systematic research from triage
    repo-research/SKILL.md                - Deep diving into reference repos
    transcript-harvest/SKILL.md           - Harvesting from transcripts
    document-harvest/SKILL.md             - Harvesting from articles and docs
    session-handoff/SKILL.md              - Writing handoff briefings
  Agents/
    Harvest Agent.md                      - Content harvesting agent instructions
  Guides/
    Connecting Obsidian to Claude Desktop on Mac.md
    Git Backup Setup - Claude-Guided Walkthrough.md
    Vault Backup Setup Guide.md
    Vault Structure Guide.md
    Federation Guide.md
    Editing the Claude Desktop Config.md
    Human Onboarding Doc Template.md
  Vault Config.md                         - User-specific paths and settings
```

---

## For AI Agents

If a user shares this README or the GitHub link with you, your job is to help them get DataWizard set up. Follow the Quick Start steps above.

**Key points:**
- The Seed should be installed locally in the vault, not read from GitHub
- All protocols, skills, and guides are in `_DataWizard/Seed/` - read them via MCP
- The only GitHub fetch is VERSION.md for update checks during orientation
- Always get user approval before writing to the vault
- If the user already has a Seed installed, check if it needs updating before starting

**If the Seed is already installed:**
Read `_DataWizard/Seed/VERSION.md` locally and compare against the GitHub version. If an update is available, offer it before proceeding.

**If the Seed is NOT installed:**
Give the user the install command from step 2 above, customized with their vault path. Wait for them to confirm it worked, then continue with MCP setup.

---

## Troubleshooting

**"No servers added" in Developer settings:**
Check JSON syntax in the config file, verify the vault path exists, and Force Quit Claude Desktop (not just Cmd+Q).

**MCP server shows but isn't connecting:**
Run `node --version` and `npx --version` in Terminal. Make sure Obsidian is running.

**Permission errors:**
System Settings - Privacy & Security - Files and Folders. Ensure Claude Desktop has access to your vault.

**Tools disappear mid-conversation:**
Start a new conversation. Check that Obsidian is still running.

**Seed install shows errors:**
Run the install command again. If it persists, download the ZIP manually from https://github.com/andrewalan11/DataWizard and unzip into `_DataWizard/Seed/`.

---

*Created by Andrew Hasse. Open source and free to use.*
