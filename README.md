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

Steps 1-5 happen in this guide. Step 6 happens in a conversation with Claude after the connection is live.

---

## Step 1: Install Obsidian

Download Obsidian from https://obsidian.md (free) and install it.

---

## Step 2: Create a Vault

Open Obsidian. It will ask you to create or open a vault. Create a new vault.

**Important: choose a local folder on your computer.** Do not put your vault in a cloud-synced folder (Dropbox, iCloud, Nextcloud, OneDrive, Google Drive). Cloud sync services can interfere with Obsidian's file indexing and cause files created outside Obsidian to not appear. Use a regular local folder -- for example, `/Users/yourname/My Vault` or `/Users/yourname/Documents/My Vault`.

If you want cloud backup, DataWizard uses git for that (Claude will help you set it up later). Git is more reliable than file sync for a vault because it tracks changes intentionally rather than syncing everything continuously.

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

Node.js powers the connection between Claude and your vault. Check if you already have it by running this in Terminal:

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

This step tells Claude Desktop where your vault is so it can read and write your notes. We'll do this by editing a configuration file.

**If your config file already has content** (common if you use Claude Desktop features like Cowork), the command below will add the vault connection without overwriting your existing settings. If the file doesn't exist yet, it will create it.

Paste this command into Terminal, replacing `/Users/yourname/My Vault` with your actual vault path:

```bash
CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
VAULT_PATH="/Users/yourname/My Vault"

mkdir -p "$(dirname "$CONFIG_FILE")"

if [ ! -f "$CONFIG_FILE" ] || [ ! -s "$CONFIG_FILE" ]; then
  echo "{}" > "$CONFIG_FILE"
fi

node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8'));
if (!config.mcpServers) config.mcpServers = {};
config.mcpServers.obsidian = {
  command: 'npx',
  args: ['@bitbonsai/mcpvault@latest', '$VAULT_PATH']
};
fs.writeFileSync('$CONFIG_FILE', JSON.stringify(config, null, 2));
console.log('Done! Obsidian MCP added to Claude Desktop config.');
console.log('Vault path: $VAULT_PATH');
"
```

You should see "Done! Obsidian MCP added to Claude Desktop config."

**Now restart Claude Desktop:**

1. Go to the **Apple menu** () in the top left of your screen
2. Click **Force Quit**
3. Select **Claude** and click **Force Quit**
4. Reopen Claude Desktop

**Verify it's connected:**

1. In Claude Desktop, go to **Settings** (gear icon)
2. Click **Developer**
3. You should see **"obsidian"** listed with a green badge

If you see the green badge, the connection is live. If not, see Troubleshooting below.

**Tip:** Keep Obsidian running in the background whenever you're using Claude with your vault.

---

## Step 7: Finish Setup with Claude

The connection is live. Now Claude can do the rest.

Open a new conversation in Claude Desktop and say:

> **"Set up DataWizard"**

Claude will walk you through the rest of the setup interactively:
- Verify that every tool in the connection works correctly
- Help you create a Claude Project with DataWizard instructions
- Explain how to keep things in sync and collaborate with others
- Offer to set up git for backup and collaboration

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
  VERSION.md                              - Version numbers and update instructions
  Project Instructions - Copy-Paste into Claude.md  - Instructions to paste into Claude
  README.md                               - This file
  update_seed.sh                          - Install/update script
  SKILLS.md                               - Available skills catalog
  Protocols/
    DataWizard Universal Protocol.md      - Full AI operational rulebook
    Protocol Summary.md                   - Quick reference
    Content Type Taxonomy.md              - Content types for classification
  Skills/                                 - See SKILLS.md for full catalog
    install-wizard/SKILL.md               - Interactive post-install setup
    project-guidelines/SKILL.md           - Creating and updating project docs
    session-closer/SKILL.md               - End-of-session log and handoff
    git-onboarding/SKILL.md               - Interactive git setup walkthrough
    research-tracking/SKILL.md            - Tracking research to prevent duplicates
    tools-research/SKILL.md               - Evaluating external tools and repos
    design-harvest/SKILL.md               - Planting research into design docs
    transcript-harvest/SKILL.md           - Harvesting transcripts into project docs
    document-harvest/SKILL.md             - Harvesting articles into project docs
    harvest-router/SKILL.md               - Routing content to the right project
  Agents/
    Harvest Agent.md                      - Content harvesting agent instructions
  Scripts/
    classify.py                           - Note classification script
    segment_transcript.py                 - Transcript segmentation script
    route_notes.py                        - Note routing script
    claude-paths.sh                       - Path resolution utility
  Guides/
    Git Guide.md                          - Master git reference (shell + 9 sections)
    Git Guide/                            - Section files for the Git Guide
    Vault Structure Guide.md
    Federation Guide.md
    Filename Safety.md
    Editing the Claude Desktop Config.md
    MCP Reliability and Write Verification.md
    Harvest Workflow Guide.md
    Human Onboarding Doc Template.md
  Vault Config.md                         - User-specific paths and settings
```

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
- MCP connection uses the `@bitbonsai/mcpvault` package -- this is the only supported method

---

## Troubleshooting

**"No servers added" in Developer settings:**
Check that the config command ran without errors. Open the config file to verify it looks correct:
```bash
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```
You should see an `mcpServers` section with your vault path. If not, run the Step 6 command again. Then Force Quit Claude Desktop (not just Cmd+Q) and reopen.

**MCP server shows red / not connecting:**
Run `node --version` and `npx --version` in Terminal to verify they work. Make sure Obsidian is running.

**Permission errors:**
Go to System Settings - Privacy and Security - Files and Folders. Ensure Claude Desktop has access to your vault directory.

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
