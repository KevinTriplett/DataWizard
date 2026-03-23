---
title: Editing the Claude Desktop Config
type: project-doc
created: '2026-03-21'
updated: '2026-03-21'
status: active
---

# Editing the Claude Desktop Config

The Claude Desktop config file controls which MCP servers Claude can use — Obsidian access, filesystem access, Fathom transcripts, and any other tools. You'll need to edit it when adding new MCP servers or granting Claude access to new folders.

## How to Find the Config File

1. Open **Claude Desktop**
2. Go to **Settings** (gear icon, bottom-left)
3. Click **Developer**
4. Click **Edit Config**
5. A Finder window opens showing `claude_desktop_config.json`

## How to Edit It

The config is a `.json` file. You can open it with any text editor:

- **TextEdit** — right-click the file → Open With → TextEdit. Works but be careful: TextEdit sometimes converts straight quotes to curly quotes, which breaks JSON. If you use TextEdit, go to TextEdit → Settings → uncheck "Smart quotes" first.
- **VS Code** — best option if you have it installed. Validates JSON syntax and highlights errors. Right-click → Open With → Visual Studio Code.
- **Terminal** — `open -a TextEdit ~/Library/Application\ Support/Claude/claude_desktop_config.json` or use `nano` / `vim` if you're comfortable with terminal editors.

## What the Config Looks Like

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["package-name", "/path/to/something"]
    }
  }
}
```

Each entry under `mcpServers` is a tool Claude can use. The `args` array usually includes paths to folders or vaults that the tool can access.

## Common Edits

### Granting Claude access to a new folder (filesystem server)

Find the `"filesystem"` block and add your folder path to the `args` array:

```json
"filesystem": {
  "command": "npx",
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "/Users/yourname/existing-folder",
    "/Users/yourname/new-folder-to-add"
  ]
}
```

Every path after `@modelcontextprotocol/server-filesystem` is a folder Claude can read and write.

### Adding a new MCP server

Add a new entry inside `mcpServers`. Follow the server's installation docs for the correct `command` and `args`. Most use either `npx` (for npm packages) or `node` (for local scripts).

## After Editing

1. Save the file
2. **Quit Claude Desktop** (Cmd+Q — not just close the window)
3. Reopen Claude Desktop
4. The new config takes effect immediately

## Troubleshooting

- **Claude can't see your files?** Check that the folder path is in the filesystem server's `args` array, and that you quit and relaunched after saving.
- **JSON syntax error?** The most common mistakes are missing commas between items, trailing commas after the last item, or curly/smart quotes instead of straight quotes. Use VS Code to validate — it underlines errors in red.
- **MCP server not connecting?** Check the Developer console in Claude Desktop (Settings → Developer) for error messages.

## Keeping a Backup

It's good practice to keep a copy of your working config somewhere safe. If you break the JSON, you can always paste the backup back in.
