# Connecting Obsidian to Claude Desktop on Mac

**A step-by-step guide using MCP-Obsidian**  
*Last updated: March 2026*

---

## What This Does

This guide walks you through connecting your Obsidian vault to the Claude Desktop app using MCP (Model Context Protocol). Once set up, Claude can search, read, create, and manage notes in your Obsidian vault directly from conversations.

There are three ways to set this up, from easiest to most manual:

1. **MCP Tools Plugin** — Install from Obsidian, auto-configures everything (5 min)
2. **Smithery CLI** — One terminal command + restart (5 min)
3. **Manual Setup** — Edit config file yourself (10-15 min)

---

# Method 1: MCP Tools Plugin (Easiest)

This is an Obsidian community plugin that handles everything automatically — no terminal required.

> **Note:** This plugin requires the **Local REST API** community plugin to be installed and enabled first. If you see "Local REST API (Required)" marked with a red ✗ in the MCP Tools settings, install that plugin before proceeding.

## Steps

1. Open **Obsidian**
2. Go to **Settings → Community Plugins**
3. Click **Browse** and search for **"MCP Tools"**
4. Install and **Enable** the plugin
5. The plugin will ask permission to:
   - Install the server binary
   - Modify your Claude Desktop configuration
6. Grant permission and follow the prompts
7. **Restart Claude Desktop**

That's it! The plugin auto-configures Claude Desktop for you.

## Verify It Works

1. Open Claude Desktop
2. Go to **Settings → Developer**
3. You should see the MCP server listed and running
4. Start a new conversation and try: *"What folders are in my Obsidian vault?"*

---

# Method 2: Smithery One-Line Install (Easy)

Smithery is a platform for installing MCP tools with a single command.

## Prerequisites

- **Node.js** installed (check with `node --version` in Terminal)
- If not installed, see [Installing Node.js](#installing-nodejs-if-needed) below

## Steps

1. Open **Terminal**
2. Run this command:

```bash
npx -y @smithery/cli install mcp-obsidian --client claude
```

> **Known issue (Node.js v25+):** If you see `r.setPassword is not a function`, this is a Smithery bug with newer Node.js versions. Skip to Method 3 (Manual Setup) instead.

3. When prompted, enter the **full path to your Obsidian vault**  
   (e.g., `/Users/yourusername/Documents/My Vault`)

4. **Restart Claude Desktop** completely — use **Force Quit** (Apple menu →  → Force Quit → Claude), then reopen

5. Go to **Settings → Developer** — you should see "obsidian" listed

---

# Method 3: Manual Setup (Most Control)

This method gives you full control over the configuration. Use this if the other methods don't work or if you want to understand what's happening under the hood.

## Prerequisites

- **Claude Desktop app** installed on your Mac
- **Node.js** installed (we'll check for this below)
- **An Obsidian vault** on your Mac

---

## Step 1: Check for Node.js

Open **Terminal** and run:

```bash
node --version
```

- If you see a version number (like `v20.11.0`), **skip to Step 2**.
- If you see "command not found", see [Installing Node.js](#installing-nodejs-if-needed) below.

---

## Step 2: Find Your Obsidian Vault Path

1. Open **Finder**
2. Navigate to your Obsidian vault folder
3. Press **Cmd + Option + C** to copy the full path

It will look something like:
```
/Users/yourusername/Documents/My Obsidian Vault
```

Save this path — you'll need it in the next step.

---

## Step 3: Edit the Claude Desktop Config File

### Option A: Use Terminal (Recommended)

```bash
open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**If the file doesn't exist**, create it first:

```bash
mkdir -p ~/Library/Application\ Support/Claude && \
echo '{}' > ~/Library/Application\ Support/Claude/claude_desktop_config.json && \
open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### Option B: Use Claude Desktop Settings

1. Open **Claude Desktop**
2. Click **Claude** in the menu bar → **Settings**
3. Click **Developer** in the sidebar
4. Click **"Edit Config"**

---

### If the file is empty or just has `{}`

Replace everything with this (substituting your vault path):

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

**Real example:**
```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": [
        "@mauricio.wolff/mcp-obsidian@latest",
        "/Users/USERNAME/Vaults/Regen Vault"
      ]
    }
  }
}
```

---

### If the file already has content

Merge the `mcpServers` section into the existing file. For example:

**Before:**
```json
{
  "preferences": {
    "menuBarEnabled": true
  }
}
```

**After:**
```json
{
  "preferences": {
    "menuBarEnabled": true
  },
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

⚠️ **IMPORTANT:** No trailing commas! The JSON must be valid or Claude Desktop will ignore it.

**Save the file** with `Cmd + S`.

---

## Step 4: Restart Claude Desktop

1. **Force Quit:** Go to the Apple menu () → **Force Quit** → select **Claude** → click **Force Quit**
2. **Reopen** Claude Desktop
3. Go to **Settings → Developer**
4. You should see **"obsidian"** with a green "running" badge 🎉

> **Why Force Quit?** A normal Cmd+Q sometimes doesn't reload the config file. Force Quit ensures Claude picks up your changes.

---

## Step 5: Test the Connection

Start a new conversation and try:

> "Show me what folders are in my vault"

> "Search my vault for any notes"

> "Create a test note called Hello World"

**TIP:** Keep Obsidian running in the background for reliable connections.

---

# Installing Node.js (If Needed)

## Check if Homebrew is installed

```bash
brew --version
```

If you see "command not found", install Homebrew first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

It will ask for your Mac password. When typing, **nothing appears on screen** — that's normal.

⚠️ **IMPORTANT:** After installation, run the "Next steps" commands that Homebrew shows you. They look like:

```bash
echo >> /Users/YOURUSERNAME/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/YOURUSERNAME/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## Install Node.js

```bash
brew install node
```

Verify it worked:

```bash
node --version
```

You should see a version number.

---

# What Claude Can Do With Your Vault

| Action | Description |
|--------|-------------|
| **Search notes** | Full-text search across your entire vault |
| **Read notes** | View the content of any markdown file |
| **Read multiple notes** | Read several notes at once for comparison |
| **Create notes** | Create new markdown files in any folder |
| **Update notes** | Modify existing notes (overwrite, append, or prepend) |
| **Patch notes** | Make targeted edits using find-and-replace |
| **Move notes** | Reorganize markdown files within your vault |
| **List directories** | See your folder structure |
| **Manage tags** | Add, remove, or list tags on notes |
| **Manage frontmatter** | Read and update YAML frontmatter metadata |
| **Get vault stats** | See statistics about your vault |
| **Delete notes** | Remove notes (with confirmation) |

---

# Current Limitations

- **Cannot move or manage PDF files** or other non-markdown files
- **Works with local vaults only** — no cloud sync support
- **MCP connection can drop mid-conversation** — start a new conversation to refresh
- **Obsidian should be running** for reliable connections

---

# Troubleshooting

## "No servers added" in Developer settings

1. Check JSON syntax (no trailing commas, matching brackets)
2. Verify the vault path exists
3. **Force Quit** Claude Desktop (Apple menu → Force Quit → Claude) and reopen — a normal Cmd+Q may not reload the config

## MCP server shows but isn't connecting

1. Verify Node.js: `node --version`
2. Verify npx: `npx --version`
3. Test manually:
   ```bash
   npx @mauricio.wolff/mcp-obsidian@latest "/path/to/your/vault"
   ```

## Permission errors

Go to **System Settings → Privacy & Security → Files and Folders** and ensure Claude Desktop has access to your vault directory.

## Tools disappear mid-conversation

This is normal with local MCP servers:
- Start a new conversation to reload tools
- Check that Obsidian is still running
- Verify the server shows "running" in Settings → Developer

## JSON syntax errors

Common mistakes:
- Trailing comma: `["item1", "item2",]` ← remove final comma
- Missing comma between sections
- Mismatched brackets

Use [jsonlint.com](https://jsonlint.com) to validate your JSON.

---

# Quick Reference

**Config file:**  
`~/Library/Application Support/Claude/claude_desktop_config.json`

**Open in Terminal:**
```bash
open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**Minimum config:**
```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": [
        "@mauricio.wolff/mcp-obsidian@latest",
        "/path/to/your/vault"
      ]
    }
  }
}
```

---

# Additional Resources

- **MCP Tools Plugin:** Search "MCP Tools" in Obsidian Community Plugins
- **Smithery:** [smithery.ai](https://smithery.ai)
- **MCP-Obsidian website:** [mcp-obsidian.org](https://mcp-obsidian.org/)
- **GitHub:** [github.com/bitbonsai/mcp-obsidian](https://github.com/bitbonsai/mcp-obsidian)

---

*Created collaboratively with Claude Desktop — the very tool this guide helps you set up!*