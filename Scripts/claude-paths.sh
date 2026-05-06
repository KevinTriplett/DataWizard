#!/bin/bash
# claude-paths.sh - Manage filesystem MCP paths in Claude Desktop config
# Usage:
#   claude-paths list              # show current paths
#   claude-paths add <path>        # add a path
#   claude-paths remove <path>     # remove a path
#
# After any change, restart Claude Desktop for it to take effect.

CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
BACKUP_DIR="$HOME/Library/Application Support/Claude/config-backups"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: claude-paths <command> [path]"
    echo ""
    echo "Commands:"
    echo "  list              Show current filesystem MCP paths"
    echo "  add <path>        Add a path to filesystem MCP"
    echo "  remove <path>     Remove a path from filesystem MCP"
    echo ""
    echo "After any change, restart Claude Desktop (Cmd+Q, reopen)."
}

# Check config exists
if [ ! -f "$CONFIG" ]; then
    echo -e "${RED}Error: Claude config not found at:${NC}"
    echo "  $CONFIG"
    exit 1
fi

# Check jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error: jq is required but not installed.${NC}"
    echo "Install with: brew install jq"
    exit 1
fi

COMMAND="${1:-}"
TARGET_PATH="${2:-}"

case "$COMMAND" in
    list)
        echo -e "${CYAN}Current filesystem MCP paths:${NC}"
        echo ""
        # Extract args after the server-filesystem package name
        jq -r '.mcpServers.filesystem.args[]' "$CONFIG" 2>/dev/null | \
            grep -v "^-y$" | \
            grep -v "@modelcontextprotocol/server-filesystem" | \
            while read -r path; do
                if [ -d "$path" ]; then
                    echo -e "  ${GREEN}OK${NC}  $path"
                else
                    echo -e "  ${RED}!!${NC}  $path  ${RED}(not found on disk)${NC}"
                fi
            done
        echo ""
        ;;

    add)
        if [ -z "$TARGET_PATH" ]; then
            echo -e "${RED}Error: No path provided.${NC}"
            echo "Usage: claude-paths add /path/to/directory"
            exit 1
        fi

        # Resolve to absolute path
        TARGET_PATH=$(cd "$TARGET_PATH" 2>/dev/null && pwd || echo "$TARGET_PATH")

        # Check path exists
        if [ ! -d "$TARGET_PATH" ]; then
            echo -e "${RED}Error: Directory does not exist:${NC} $TARGET_PATH"
            exit 1
        fi

        # Check if already present
        EXISTING=$(jq -r '.mcpServers.filesystem.args[]' "$CONFIG" 2>/dev/null | grep -F "$TARGET_PATH")
        if [ -n "$EXISTING" ]; then
            echo -e "${YELLOW}Path already exists in config:${NC} $TARGET_PATH"
            exit 0
        fi

        # Backup config
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
        cp "$CONFIG" "$BACKUP_DIR/claude_desktop_config.$TIMESTAMP.json"
        echo -e "${CYAN}Backup saved to config-backups/$TIMESTAMP${NC}"

        # Add path to filesystem args
        jq --arg path "$TARGET_PATH" \
            '.mcpServers.filesystem.args += [$path]' \
            "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

        echo -e "${GREEN}Added:${NC} $TARGET_PATH"
        echo ""
        echo -e "${YELLOW}Restart Claude Desktop for this to take effect (Cmd+Q, reopen).${NC}"
        ;;

    remove)
        if [ -z "$TARGET_PATH" ]; then
            echo -e "${RED}Error: No path provided.${NC}"
            echo "Usage: claude-paths remove /path/to/directory"
            exit 1
        fi

        # Check if present
        EXISTING=$(jq -r '.mcpServers.filesystem.args[]' "$CONFIG" 2>/dev/null | grep -F "$TARGET_PATH")
        if [ -z "$EXISTING" ]; then
            echo -e "${YELLOW}Path not found in config:${NC} $TARGET_PATH"
            echo ""
            echo "Current paths:"
            claude-paths list
            exit 1
        fi

        # Backup config
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
        cp "$CONFIG" "$BACKUP_DIR/claude_desktop_config.$TIMESTAMP.json"
        echo -e "${CYAN}Backup saved to config-backups/$TIMESTAMP${NC}"

        # Remove path from filesystem args
        jq --arg path "$TARGET_PATH" \
            '.mcpServers.filesystem.args = [.mcpServers.filesystem.args[] | select(. != $path)]' \
            "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

        echo -e "${GREEN}Removed:${NC} $TARGET_PATH"
        echo ""
        echo -e "${YELLOW}Restart Claude Desktop for this to take effect (Cmd+Q, reopen).${NC}"
        ;;

    *)
        usage
        exit 1
        ;;
esac
