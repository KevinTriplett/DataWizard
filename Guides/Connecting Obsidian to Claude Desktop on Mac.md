
# Connecting Obsidian to Claude Desktop on Mac

**A step-by-step guide using MCP-Obsidian**
*Last updated: March 2026*

---

## What This Does

This guide connects your Obsidian vault to the Claude Desktop app using MCP (Model Context Protocol). Once set up, Claude can search, read, create, and manage notes in your Obsidian vault directly from conversations.

**What you'll need:**
- A Mac with Obsidian installed and a vault created
- The Claude Desktop app installed
- About 10 minutes

---

## Step 1: Open Terminal

You'll need Terminal for one command. Terminal is a built-in Mac app that lets you type commands directly to your computer — think of it as a text-based way to tell your Mac what to do.

To open it: press **Cmd + Space** to open Spotlight, type **Terminal**, and hit Enter.

A window will appear with a blinking cursor. That's where you'll paste the command in Step 3.

---

## Step 2: Check for Node.js

In Terminal, type this and press Enter:

```bash
node --version
```

- If you see a version number (like `v20.11.0`) — you're good, skip to Step 3.
- If you see "command not found" — you need to install Node.js first. See [Installing Node.js](#installing-nodejs) below, then come back here.

---

## Step 3: Install MCP-Obsidian

Copy and paste this command into Terminal and press Enter:

```bash
npx -y @smithery/cli install mcp-obsidian --client claude
```

When prompted, enter the **full path to your Obsidian vault**. To find it:
1. Open Finder and navigate to your vault folder
2. Press **Cmd + Option + C** to copy the full path
3. Paste it into Terminal when asked

The path will look something like: `/Users/yourusername/Documents/My Vault`

> **If you get an error** that says `r.setPassword is not a function`, this is a known bug with Node.js v25+. See the [Manual Setup](#manual-setup-fallback) section below instead.

---

## Step 4: Restart Claude Desktop

This is important — a normal quit sometimes doesn't reload the configuration.

1. Go to the Apple menu () → **Force Quit**
2. Select **Claude** → click **Force Quit**
3. Reopen Claude Desktop

---

## Step 5: Verify It Works

1. Open Claude Desktop
2. Go to **Settings → Developer**
3. You should see **"obsidian"** listed with a green "running" badge
4. Start a new conversation and try: *"What folders are in my Obsidian vault?"*

If Claude responds with your vault's folder structure — you're done!

**TIP:** Keep Obsidian running in the background for reliable connections.

---

## What Claude Can Do With Your Vault

| Action | Description |
|--------|-------------|
| Search notes | Full-text search across your entire vault |
| Read notes | View the content of any markdown file |
| Create notes | Create new markdown files in any folder |
| Update notes | Modify existing notes (overwrite, append, or prepend) |
| Patch notes | Make targeted edits using find-and-replace |
| Move notes | Reorganize markdown files within your vault |
| List directories | See your folder structure |
| Manage tags | Add, remove, or list tags on notes |
| Manage frontmatter | Read and update YAML metadata |
| Delete notes | Remove notes (with confirmation) |

---

## Current Limitations

- Cannot move or manage PDF files or other non-markdown files
- Works with local vaults only — no cloud sync support
- MCP connection can drop mid-conversation — start a new conversation to refresh
- Obsidian should be running for reliable connections

---

## Installing Node.js

If `node --version` said "command not found," follow these steps.

### First, check for Homebrew:

```bash
brew --version
```

If you see "command not found," install Homebrew first:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

It will ask for your Mac password. When typing, **nothing appears on screen** — that's normal.

**IMPORTANT:** After installation, run the "Next steps" commands that Homebrew shows you. They look like:

```bash
echo >> /Users/YOURUSERNAME/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/YOURUSERNAME/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Then install Node.js:

```bash
brew install node
```

Verify it worked:

```bash
node --version
```

You should see a version number. Now go back to Step 3.

---

## Manual Setup (Fallback)

Use this only if the Smithery command in Step 3 doesn't work.

### Find or create the config file

Open Terminal and run:

```bash
open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

If the file doesn't exist, create it first:

```bash
mkdir -p ~/Library/Application\ Support/Claude && \
echo '{}' > ~/Library/Application\ Support/Claude/claude_desktop_config.json && \
open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

### Edit the config

If the file is empty or just has `{}`, replace everything with this (substituting your vault path):

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

If the file already has content, add the `mcpServers` section inside the existing braces. Make sure the JSON is valid — no trailing commas, matching brackets. Use [jsonlint.com](https://jsonlint.com) to check if unsure.

Save the file with **Cmd + S**, then **Force Quit** and reopen Claude Desktop (Step 4).

---

## Troubleshooting

**"No servers added" in Developer settings:**
Check JSON syntax, verify the vault path exists, and Force Quit Claude Desktop (not just Cmd+Q).

**MCP server shows but isn't connecting:**
Run `node --version` and `npx --version` in Terminal to verify they work. Make sure Obsidian is running.

**Permission errors:**
Go to System Settings → Privacy & Security → Files and Folders and ensure Claude Desktop has access to your vault directory.

**Tools disappear mid-conversation:**
Start a new conversation. Check that Obsidian is still running and the server shows "running" in Settings → Developer.

---

## Quick Reference

**Config file location:**
`~/Library/Application Support/Claude/claude_desktop_config.json`

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

## Additional Resources

- **Smithery:** [smithery.ai](https://smithery.ai)
- **MCP-Obsidian:** [mcp-obsidian.org](https://mcp-obsidian.org/)
- **GitHub:** [github.com/bitbonsai/mcp-obsidian](https://github.com/bitbonsai/mcp-obsidian)

---

*Created collaboratively with Claude Desktop — the very tool this guide helps you set up!*
