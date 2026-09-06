# DataWizard

> Prompts and scripts that teach your AI assistant to work in your Obsidian vault.

---

## What Is DataWizard?

DataWizard is a set of prompts and a few scripts that teach your AI assistant how to work in your Obsidian vault -- and how to leave breadcrumbs so that you and future conversations can find your way back through the vault to the source.

The problem: every new AI conversation starts with a blank slate. DataWizard solves this by giving the AI a structured place to read and write -- your vault -- and teaching it to leave a trail. Session logs, metadata, structured notes, project files. Every conversation adds to the trail, and every new conversation reads it to pick up where the last one left off.

What it does: classifies notes by content type, enriches them with tags and metadata, processes transcripts into searchable notes, routes content to the right projects, manages multi-project infrastructure, and saves everything with one keystroke.

It's not a product or an app. It's just well-organized markdown files and a playbook that teaches the AI how to use them. Local-first, open source, and designed primarily for Claude but compatible with any AI that supports MCP.

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

**Mac or Windows?** This guide covers both. Where a step differs, you'll see a **Mac** block and a **Windows** block -- just follow the one for your computer.

---

## Step 1: Install Obsidian

Download Obsidian from https://obsidian.md (free) and install it.

---

## Step 2: Create a Vault

Open Obsidian. It will ask you to create or open a vault. Create a new vault.

**Important: choose a local folder on your computer.** Do not put your vault in a cloud-synced folder (Dropbox, iCloud, Nextcloud, OneDrive, Google Drive). Cloud sync services can interfere with Obsidian's file indexing and cause files created outside Obsidian to not appear. Use a regular local folder -- for example, `/Users/yourname/My Vault` (Mac) or `C:\Users\yourname\My Vault` (Windows).

If you want cloud backup, just ask Claude to set it up when you're ready -- it handles everything for you. (DataWizard uses git under the hood, which saves changes more reliably than continuous file sync. You don't need to know git to benefit from it; if you already do, you're welcome to set up backup your own way.)

---

## Step 3: Find Your Vault Path

You'll need the full path to your vault folder for the next steps. Here's how to find it:

**Mac:**

1. Open **Finder** and navigate to your vault folder
2. Press **Cmd + Option + C** -- this copies the full path to your clipboard

The path will look like: `/Users/yourname/My Vault`

**Windows:**

1. Open **File Explorer** and navigate to your vault folder
2. Click the address bar (or **Shift + right-click** the folder -> **Copy as path**)

The path will look like: `C:\Users\yourname\My Vault`

Paste it somewhere you can grab it easily -- you'll need it twice: once to install the Seed, and once to connect Claude. (If Claude is helping you install, just give it this path once and it will fill in both commands for you, so you never have to edit them yourself.)

---

## Step 4: Install the DataWizard Seed

The Seed is the core of DataWizard -- protocols, skills, and guides that teach Claude how to operate in your vault. It lives locally inside your vault so Claude can read it directly.

**Mac** -- open **Terminal** (press Cmd + Space, type "Terminal", hit Enter). Paste this, replacing `/Users/yourname/My Vault` with your actual vault path from Step 3:

```bash
cd "/Users/yourname/My Vault" && \
curl -sL https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip -o /tmp/dw-seed.zip && \
unzip -qo /tmp/dw-seed.zip -d /tmp/dw-seed && \
mkdir -p _DataWizard/Seed && \
cp -R /tmp/dw-seed/DataWizard-main/. _DataWizard/Seed/ && \
rm -rf /tmp/dw-seed /tmp/dw-seed.zip && \
echo "DataWizard Seed installed to _DataWizard/Seed/"
```

**Windows** -- open **PowerShell** (press the Start button, type "PowerShell", hit Enter). Paste this, replacing `C:\Users\yourname\My Vault` with your actual vault path:

```powershell
cd "C:\Users\yourname\My Vault"
Invoke-WebRequest -Uri "https://github.com/andrewalan11/DataWizard/archive/refs/heads/main.zip" -OutFile "$env:TEMP\dw-seed.zip"
Expand-Archive -Path "$env:TEMP\dw-seed.zip" -DestinationPath "$env:TEMP\dw-seed" -Force
if (!(Test-Path "_DataWizard\Seed")) { New-Item -ItemType Directory -Path "_DataWizard\Seed" -Force }
Copy-Item -Path "$env:TEMP\dw-seed\DataWizard-main\*" -Destination "_DataWizard\Seed\" -Recurse -Force
Remove-Item -Path "$env:TEMP\dw-seed.zip", "$env:TEMP\dw-seed" -Recurse -Force
Write-Host "DataWizard Seed installed to _DataWizard\Seed\"
```

You should see the "installed" confirmation.

**Note:** The `_DataWizard` folder won't appear in Obsidian's sidebar -- this is expected. Obsidian hides folders that start with an underscore. Claude can still read it fine through the connection we'll set up next.

---

## Step 5: Install Node.js

Node.js powers `mcpvault`, the small program that connects Claude to your vault (Step 6). Check if you already have it by running this in your terminal (Terminal on Mac, PowerShell on Windows):

```bash
node --version
```

If you see a version number (like `v20.11.0`), you're good -- skip to Step 6. If you see "command not found," install it.

### Mac

First, check for Homebrew:

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

Then install Node.js:

```bash
brew install node
```

### Windows

Download the **LTS** installer from https://nodejs.org and run it (accept the defaults), or run this in PowerShell:

```powershell
winget install OpenJS.NodeJS.LTS
```

Close and reopen PowerShell afterward so it picks up the new `node` command.

### Verify (either OS)

```bash
node --version
```

You should see a version number.

---

## Step 6: Connect Claude to Your Vault

Claude reaches your vault through **mcpvault**, a lightweight Obsidian MCP server that reads your vault folder directly. There's no plugin to install and no API key to copy -- it just needs the path to your vault (the one from Step 3). It runs via `npx` and is pinned to a known-good version (`@0.12.5`) for reliability. The same package works on Mac and Windows; only the config file location and the shell differ.

### 6a. Connect Claude Desktop -- Mac

Paste this into Terminal, replacing `/Users/yourname/My Vault` with your vault path:

```bash
CONFIG_FILE="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
VAULT_PATH="/Users/yourname/My Vault"

mkdir -p "$(dirname "$CONFIG_FILE")"
if [ ! -f "$CONFIG_FILE" ] || [ ! -s "$CONFIG_FILE" ]; then echo "{}" > "$CONFIG_FILE"; fi

node -e "
const fs = require('fs');
const config = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8'));
if (!config.mcpServers) config.mcpServers = {};
config.mcpServers.obsidian = {
  command: 'npx',
  args: ['@bitbonsai/mcpvault@0.12.5', '$VAULT_PATH']
};
fs.writeFileSync('$CONFIG_FILE', JSON.stringify(config, null, 2));
console.log('Done! Obsidian MCP added to Claude Desktop config.');
"
```

Then **Force Quit and reopen Claude Desktop** (Apple menu -> Force Quit -> Claude -- a normal quit sometimes doesn't reload the config).

### 6b. Connect Claude Desktop -- Windows

Paste this into **PowerShell**, replacing `C:\Users\yourname\My Vault` with your vault path:

```powershell
$config = "$env:APPDATA\Claude\claude_desktop_config.json"
$vault = "C:\Users\yourname\My Vault"

if (!(Test-Path $config)) { New-Item -ItemType File -Path $config -Force | Out-Null; "{}" | Set-Content $config }
$json = Get-Content $config -Raw | ConvertFrom-Json
if (-not $json.mcpServers) { $json | Add-Member -NotePropertyName mcpServers -NotePropertyValue (@{}) -Force }
$json.mcpServers | Add-Member -NotePropertyName obsidian -NotePropertyValue (@{ command = "npx"; args = @("@bitbonsai/mcpvault@0.12.5", $vault) }) -Force
$json | ConvertTo-Json -Depth 10 | Set-Content $config
Write-Host "Done! Obsidian MCP added to Claude Desktop config."
```

Then fully quit Claude Desktop -- right-click its icon in the taskbar / system tray and choose **Quit** (or end **Claude** in Task Manager) -- and reopen it.

### 6c. Verify

On either OS, open **Settings -> Developer** and confirm **obsidian** shows as running/green. Start a new conversation and try: *"What folders are in my Obsidian vault?"* If Claude lists your folders, you're connected.

**Tip:** Keep Obsidian running in the background for the most reliable connection.

### 6d. Connect a different LLM / MCP client

*Most people connect Claude Desktop (6a / 6b) and can skip this -- it's here for those who want to use a different MCP-capable client.*

Any stdio MCP client runs the same command: `npx @bitbonsai/mcpvault@0.12.5 "/path/to/your/vault"`. Point your client at that and it gets the full set of vault tools.

> **Prefer chatting inside Obsidian?** The **Claude Sidebar** and **Claudian** community plugins embed Claude Code in a side panel. They use the vault directly and do **not** need this MCP setup -- a separate path from the Claude Desktop method above.

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

**Mac:**

```bash
bash _DataWizard/Seed/update_seed.sh
```

**Windows:**

```powershell
powershell -ExecutionPolicy Bypass -File "_DataWizard\Seed\update_seed.ps1"
```

This downloads the latest Seed and overwrites only the Seed files. Your project content (session logs, action items, workshop docs) is never touched.

**Set-and-forget option:** add `--install-autosync` (Mac) or `-InstallAutosync` (Windows) to the command above to install a daily automatic check (6:00 by default, with catch-up when the machine wakes or logs in -- it does not need to be awake at the scheduled hour). Full details, options, and how to remove it: `Guides/Seed Install and Update.md`.

---

## What's in the Seed

```
_DataWizard/Seed/
  README.md              - This file
  VERSION.md             - Version numbers and update instructions
  DataWizard Project Instructions.md - Instructions to paste into Claude (or @import for Claude Code)
  update_seed.sh         - Install/update script (Mac/Linux)
  update_seed.ps1        - Install/update script (Windows)
  SKILLS.md              - Skills catalog (the authoritative list of all skills)
  Protocols/             - Operating rules: Conventions Registry, YAML Schema, Editorial Principles, Anti-Patterns, Content Type Taxonomy, Quest Lifecycle
  Skills/                - One folder per skill; SKILLS.md is the catalog
  Scripts/               - Classification, segmentation, routing, sync, and converter scripts
  Config/                - Default configuration (enrichment_defaults.yaml)
  Guides/                - Setup and reference guides (Git Guide, Vault Structure Guide, Filename Safety, Federation Guide, Seed Install and Update, MCP Reliability, Cowork Scheduled Tasks, and more)
```

One file you may see referenced that is NOT in the shipped Seed: `Vault Config.md` (user-specific paths and settings). It is deliberately kept out of the shared Seed so each vault keeps its own. (For the technically inclined: it's listed in `.gitignore`.) If a guide or skill asks for it and it doesn't exist yet, create it at `_DataWizard/Seed/Vault Config.md` with the paths it asks about.

---

## For AI Agents

If a user shares this README or the GitHub link with you, help them get DataWizard set up. Follow the steps above.

**Helping someone install? Get their vault path first.** Ask the user where their Obsidian vault lives (or where they want DataWizard installed) and whether they're on **Mac or Windows**. Then generate the Step 4 (Seed install) and Step 6 (connect) commands with their path already filled in, so they only copy and paste -- they should never have to edit a command by hand. It's the same vault path in both steps: ask once, reuse it.

Key points:
- The Seed should be installed locally in the vault, not read from GitHub
- All protocols, skills, and guides are in `_DataWizard/Seed/` -- read them via MCP
- Orientation reads the local Seed's VERSION.md only -- no GitHub fetch. Updates run via update_seed.sh (Mac) or update_seed.ps1 (Windows) when the user asks, or automatically if the user has installed auto-sync (`--install-autosync` / `-InstallAutosync`)
- Always get user approval before writing to the vault
- If the user already has a Seed installed, check if it needs updating before starting
- After MCP is connected, load the `install-wizard` skill to complete setup interactively
- MCP connection uses **mcpvault** (`@bitbonsai/mcpvault`, version-pinned), a filesystem-based Obsidian MCP server that takes the vault path directly (see Step 6). No Obsidian plugin or API key is required.

---

## Troubleshooting

**"No servers added" in Developer settings:**
Check that the config command ran without errors, and that your vault path is correct and the folder exists. View the config file to verify it looks right:
- Mac: `cat ~/Library/Application\ Support/Claude/claude_desktop_config.json`
- Windows (PowerShell): `type "$env:APPDATA\Claude\claude_desktop_config.json"`

You should see an `mcpServers` section with an `obsidian` entry running `npx` against `@bitbonsai/mcpvault`. If not, run the Step 6 command again, then fully quit Claude Desktop (Force Quit on Mac; tray -> Quit or Task Manager on Windows) and reopen.

**MCP server shows red / not connecting:**
Run `node --version` and `npx --version` to verify they work. Confirm the vault path in your config is correct and the folder exists, and that Obsidian is running.

**Permission errors:**
Make sure Claude Desktop is allowed to read your vault folder. On Mac: System Settings -> Privacy & Security -> Files and Folders, and grant Claude access. On Windows: make sure the vault isn't in a restricted system location and that the path has no typos.

**Tools disappear mid-conversation:**
Start a new conversation. Check that Obsidian is still running and the server shows green in Settings -> Developer.

**Seed install shows errors:**
Run the install command from Step 4 again. If it persists, download the ZIP manually from https://github.com/andrewalan11/DataWizard and unzip into `_DataWizard/Seed/`.

**Config file already had content and something broke:**
The Step 6 command merges safely with existing config content. But if something went wrong, view your current config (see the commands above). Check that the JSON is valid (matching braces, no trailing commas) -- you can paste it into https://jsonlint.com to verify. If it's broken, the simplest fix is to restore from a backup or rebuild it manually.

---

*Created by Andrew Hasse. Open source and free to use.*
