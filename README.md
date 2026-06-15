# DataWizard

> A local-first AI knowledge management system for Obsidian.

---

## What Is DataWizard?

DataWizard teaches Claude how to work in your Obsidian vault -- reading, writing, organizing, and enriching your notes using consistent protocols. The goal is not to read everything yourself. It's to build a system that reads for you, remembers for you, and retrieves what matters when you need it.

What it does: classifies notes by content type, enriches them with tags and metadata, processes transcripts into searchable companion notes, routes content into the right place, manages multi-project infrastructure, coordinates multiple AI agents in the same vault, and saves everything with one keystroke.

Core principles: local-first, markdown-native, modular pipelines, progressive enrichment, draft-then-approve collaboration.

---

## Before You Start

Here's what we're going to do, step by step:

1. **Install Obsidian** -- the app where your notes live
2. **Create a vault** -- a folder on your computer for your notes
3. **Install the DataWizard Seed** -- protocols and skills that teach Claude how to work in your vault
4. **Install Node.js** -- a runtime that powers the connection between Claude and Obsidian
5. **Connect Claude to your vault** -- so Claude can read and write your notes
6. **Finish setup with Claude** -- Claude will verify the connection, set up your project, and walk you through the rest

Steps 1-6 happen in this guide. Step 7 happens in a conversation with Claude after the connection is live.

**You don't need any coding, terminal, or git experience.** Every step below is copy-and-paste, and Claude handles the technical parts for you. If you *are* comfortable with the command line or git, feel free to adapt these steps -- nothing here requires doing it exactly this way.

---

## Step 1: Install Obsidian

Download Obsidian from https://obsidian.md (free) and install it.

---

## Step 2: Create a Vault

Open Obsidian. It will ask you to create or open a vault. Create a new vault.

**Important: choose a local folder on your computer.** Do not put your vault in a cloud-synced folder (Dropbox, iCloud, Nextcloud, OneDrive, Google Drive). Cloud sync services can interfere with Obsidian's file indexing and cause files created outside Obsidian to not appear. Use a regular local folder -- for example, `/Users/yourname/My Vault` or `/Users/yourname/Documents/My Vault`.

If you want cloud backup, just ask Claude to set it up when you're ready -- it handles everything for you. (DataWizard uses git under the hood, which saves changes more reliably than continuous file sync. You don't need to know git to benefit from it; if you already do, you're welcome to set up backup your own way.)

---

## Step 3: Find Your Vault Path

You'll need the full path to your vault folder for the next steps. Here's how to find it:

1. Open **Finder**
2. Navigate to your vault folder
3. Press **Cmd + Option + C** -- this copies the full path to your clipboard

The path will look something like: `/Users/yourname/My Vault`

Paste it somewhere you can grab it easily (a note, a text file, or just keep it on your clipboard). You'll need it twice: once to install the Seed, and once to connect Claude.

---

## Step 4: Install the DataWizard Seed

The Seed is the core of DataWizard -- protocols, skills, and guides that teach Claude how to operate in your vault. It lives locally inside your vault so Claude can read it directly.

Open **Terminal** (press Cmd + Space, type "Terminal", hit Enter). A window will appear with a blinking cursor.

Paste this command, replacing `/Users/yourname/My Vault` with your actual vault path from Step 3:

```bash
cd "/Users/yourname/My Vault" && \
curl -sL https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip -o /tmp/dw-seed.zip && \
unzip -qo /tmp/dw-seed.zip -d /tmp/dw-seed && \
mkdir -p _DataWizard/Seed && \
cp -R /tmp/dw-seed/DataWizard-main/. _DataWizard/Seed/ && \
rm -rf /tmp/dw-seed /tmp/dw-seed.zip && \
echo "DataWizard Seed installed to _DataWizard/Seed/"
```

You should see "DataWizard Seed installed to _DataWizard/Seed/" in Terminal.

**Note:** The `_DataWizard` folder won't appear in Obsidian's sidebar -- this is expected. Obsidian hides folders that start with an underscore. Claude can still read it fine through the connection we'll set up next.

---

## Step 5: Install Node.js

Node.js powers the `mcp-remote` bridge that connects Claude Desktop to the Local REST API plugin (Step 6). Check if you already have it by running this in Terminal:

```bash
node --version
```

If you see a version number (like `v20.11.0`), you're good -- skip to Step 6.

If you see "command not found," install it:

**First, check for Homebrew:**

```bash
brew --version
```

If "command not found," install Homebrew first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

It will ask for your Mac password. When you type, nothing appears on screen -- that's normal. Just type your password and press Enter.

**Important:** After Homebrew installs, it shows "Next steps" commands at the bottom. You must run those commands. They look like:

```bash
echo >> /Users/YOURUSERNAME/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/YOURUSERNAME/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Then install Node.js:**

```bash
brew install node
```

Verify it worked:

```bash
node --version
```

You should see a version number.

---

## Step 6: Connect Claude to Your Vault

Claude reaches your vault through the **Local REST API & MCP Server** Obsidian plugin, which exposes your vault over both a REST API and a built-in MCP (Model Context Protocol) server. Your LLM client connects to that MCP server.

> This replaces the older `@bitbonsai/mcpvault` method and any separate "MCP server + REST API plugin" combo -- the Local REST API plugin now provides both in one.

### 6a. Install the Local REST API & MCP Server plugin

1. In Obsidian: **Settings -> Community plugins -> Browse**
2. Search for **Local REST API & MCP Server** (by *coddingtonbear*), then **Install -> Enable**
3. Open **Settings -> Local REST API & MCP Server** and **copy your API Key** -- you'll need it below
4. Note the ports it shows: **27123 (HTTP)** and **27124 (HTTPS)**. The HTTPS cert is self-signed and many Operating Systems reject it, so these instructions use the **HTTP** port `27123` on localhost (safe, since it never leaves your machine).

### 6b. Connect Claude Desktop

Claude Desktop talks to the plugin through the `mcp-remote` bridge (this is why Node.js was installed in Step 5). Paste this into Terminal, replacing `YOUR_API_KEY` with the key from step 6a:

```bash
CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
API_KEY="YOUR_API_KEY"

mkdir -p "$(dirname "$CONFIG_FILE")"
if [ ! -f "$CONFIG_FILE" ] || [ ! -s "$CONFIG_FILE" ]; then echo "{}" > "$CONFIG_FILE"; fi

node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8'));
if (!config.mcpServers) config.mcpServers = {};
config.mcpServers.obsidian = {
  command: 'npx',
  args: [
    'mcp-remote@latest',
    'http://127.0.0.1:27123/mcp/',
    '--header',
    'Authorization: Bearer $API_KEY'
  ]
};
fs.writeFileSync('$CONFIG_FILE', JSON.stringify(config, null, 2));
console.log('Done! Obsidian MCP added to Claude Desktop config.');
"
```

Then **Quit and reopen Claude Desktop** (Obsidian menu -> Quit, don't just close the window), and verify under **Settings -> Developer** that **obsidian** shows as running/green.

**Tip:** Obsidian must be running for the connection to work -- the Local REST API server only runs while Obsidian is open.

### 6c. Connect a different LLM / MCP client

*Most people connect Claude Desktop (6b) and can skip this section -- it's here for those who want to use a different MCP-capable client.*

Any MCP-capable client connects to the same endpoint. Two patterns:

- **Stdio clients (most desktop apps, e.g. Claude Desktop):** run the bridge
  `npx mcp-remote@latest http://127.0.0.1:27123/mcp/ --header "Authorization: Bearer YOUR_API_KEY"`
- **Clients that support remote HTTP MCP directly:** point them at `http://127.0.0.1:27123/mcp/` and send header `Authorization: Bearer YOUR_API_KEY` (use the `27124` HTTPS URL only if your client accepts the self-signed cert).

> **Prefer chatting inside Obsidian?** The **Claude Sidebar** and **Claudian** community plugins embed Claude Code in a side panel. They use the vault directly and do **not** need this Local REST API / MCP setup -- a separate path from the Claude Desktop method above.

---

## Step 7: Finish Setup with Claude

The connection is live. Now Claude can do the rest.

Open a new conversation in Claude Desktop and say:

> **"Set up DataWizard"**

Claude will walk you through the rest of the setup interactively:
- Verify that every tool in the connection works correctly
- Help you create a Claude Project with DataWizard instructions
- Explain how to keep things in sync and collaborate with others
- Offer to set up automatic backup and collaboration for you (no git knowledge needed)

This is the last step. After this, you're up and running.

---

## Updating

Seed updates are user-initiated -- orientation checks your local Seed's VERSION.md but does not contact GitHub. To update at any time:

```bash
bash _DataWizard/Seed/update_seed.sh
```

This downloads the latest Seed and overwrites only the Seed files. Your project content (session logs, action items, workshop docs) is never touched.

---

## What's in the Seed

```
_DataWizard/Seed/
  README.md              - This file
  VERSION.md             - Version numbers and update instructions
  Project Instructions - Copy-Paste into Claude.md - Instructions to paste into Claude
  update_seed.sh         - Install/update script
  SKILLS.md              - Skills catalog (the authoritative list of all skills)
  Protocols/             - Operating rules: Conventions Registry, YAML Schema, Editorial Principles, Anti-Patterns, Content Type Taxonomy, Quest Lifecycle
  Skills/                - One folder per skill; SKILLS.md is the catalog
  Agents/                - Agent instruction files
  Scripts/               - Classification, segmentation, routing, sync, and converter scripts
  Config/                - Default configuration (enrichment_defaults.yaml)
  Guides/                - Setup and reference guides (Git Guide, Vault Structure Guide, Filename Safety, Federation Guide, Seed Install and Update, MCP Reliability, Cowork Scheduled Tasks, and more)
```

One file you may see referenced that is NOT in the shipped Seed: `Vault Config.md` (user-specific paths and settings). It is deliberately kept out of the shared Seed so each vault keeps its own. (For the technically inclined: it's listed in `.gitignore`.) If a guide or skill asks for it and it doesn't exist yet, create it at `_DataWizard/Seed/Vault Config.md` with the paths it asks about.

---

## For AI Agents

If a user shares this README or the GitHub link with you, help them get DataWizard set up. Follow the steps above.

Key points:
- The Seed should be installed locally in the vault, not read from GitHub
- All protocols, skills, and guides are in `_DataWizard/Seed/` -- read them via MCP
- Orientation reads the local Seed's VERSION.md only -- no GitHub fetch. Updates run via update_seed.sh when the user asks
- Always get user approval before writing to the vault
- If the user already has a Seed installed, check if it needs updating before starting
- After MCP is connected, load the `install-wizard` skill to complete setup interactively
- MCP connection uses the **Local REST API** Obsidian plugin (by coddingtonbear), which exposes the vault's MCP server; clients bridge to it via `mcp-remote` (see Step 6). This replaces the older `@bitbonsai/mcpvault` package.

---

## Troubleshooting

**"No servers added" in Developer settings:**
Check that the config command ran without errors. Open the config file to verify it looks correct:
```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```
You should see an `mcpServers` section with an `obsidian` entry running `mcp-remote` against `http://127.0.0.1:27123/mcp/`. If not, run the Step 6 command again. Then Force Quit Claude Desktop (not just Cmd+Q) and reopen.

**MCP server shows red / not connecting:**
Run `node --version` and `npx --version` in Terminal to verify they work. Then check the Obsidian side: the **Local REST API** plugin is installed and enabled, Obsidian is running, and the API key in your config matches the one in **Settings -> Local REST API**. Confirm you're using the HTTP URL `http://127.0.0.1:27123/mcp/` (the HTTPS port `27124` uses a self-signed cert that many clients reject).

**Authentication / 401 errors:**
The API key in your Claude config doesn't match the plugin. Copy a fresh key from **Settings -> Local REST API**, re-run the Step 6 command with it, then Force Quit and reopen Claude Desktop.

**Tools disappear mid-conversation:**
Start a new conversation. Check that Obsidian is still running and the server shows green in Settings - Developer.

**Seed install shows errors:**
Run the install command from Step 4 again. If it persists, download the ZIP manually from https://github.com/andrewalan11/DataWizard and unzip into `_DataWizard/Seed/`.

**Config file already had content and something broke:**
The Step 6 command merges safely with existing config content. But if something went wrong, you can view your current config with:
```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```
Check that the JSON is valid (matching braces, no trailing commas). You can paste it into https://jsonlint.com to verify. If it's broken, the simplest fix is to restore from a backup or rebuild it manually.

---

*Created by Andrew Hasse. Open source and free to use.*
