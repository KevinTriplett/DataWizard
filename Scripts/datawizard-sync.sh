#!/bin/bash
# datawizard-sync.sh — syncs all collaborative project repos via git
# Reads repo paths from ~/.datawizard-sync.conf (one path per line)
# Manual use: bind to hotkey via Obsidian Shell Commands plugin
# Safety net: schedule via launchd every 4 hours
# See datawizard-sync-setup.md for installation instructions.
#
# Notifications go through notify() below: macOS desktop notifications via
# osascript when available, otherwise the message is written to the log so
# results are never silently lost on a non-macOS shell.

LOGFILE="$HOME/.datawizard-sync.log"
CONF="$HOME/.datawizard-sync.conf"

# notify TITLE MESSAGE [SOUND]
# macOS: desktop notification via osascript. Other platforms: log the message.
# osascript is macOS-only; without this guard the calls failed silently off-Mac.
notify() {
  local title="$1"
  local message="$2"
  local sound="${3:-}"
  if command -v osascript >/dev/null 2>&1; then
    if [ -n "$sound" ]; then
      osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null
    else
      osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
    fi
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') NOTIFY [$title] $message" >> "$LOGFILE"
  fi
}

# Check for config
if [ ! -f "$CONF" ]; then
  notify "DW Sync Error" "No config found. Create ~/.datawizard-sync.conf" "Basso"
  echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: No config file at $CONF" >> "$LOGFILE"
  exit 1
fi

# Read project paths from config
PROJECTS=()
while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  PROJECTS+=("$line")
done < "$CONF"

if [ ${#PROJECTS[@]} -eq 0 ]; then
  notify "DW Sync Error" "Config file is empty. Add repo paths to ~/.datawizard-sync.conf" "Basso"
  exit 1
fi

CHANGES=0
ERRORS=0
SYNCED_NAMES=""

for DIR in "${PROJECTS[@]}"; do
  NAME=$(basename "$DIR")
  cd "$DIR" || { echo "$(date '+%Y-%m-%d %H:%M:%S') SKIP $DIR (not found)" >> "$LOGFILE"; ERRORS=$((ERRORS+1)); continue; }

  # Branch guard: only sync repos on main
  BRANCH=$(git branch --show-current)
  if [ "$BRANCH" != "main" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') SKIPPED $NAME -- on branch '$BRANCH', not main" >> "$LOGFILE"
    continue
  fi

  git add .
  if ! git diff --cached --quiet; then
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    git commit -m "auto-sync $TIMESTAMP on $(hostname -s)" >> "$LOGFILE" 2>&1
    CHANGES=$((CHANGES+1))
    SYNCED_NAMES="$SYNCED_NAMES $NAME,"
  fi

  git pull --no-rebase >> "$LOGFILE" 2>&1
  if [ $? -ne 0 ]; then
    ERRORS=$((ERRORS+1))
    notify "DW Sync Error" "Sync conflict in $NAME. Open terminal to resolve." "Basso"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR pull failed in $DIR" >> "$LOGFILE"
    continue
  fi

  git push >> "$LOGFILE" 2>&1
  if [ $? -ne 0 ]; then
    ERRORS=$((ERRORS+1))
    notify "DW Sync Error" "Push failed in $NAME. Check your connection." "Basso"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR push failed in $DIR" >> "$LOGFILE"
  fi
done

# Notifications
if [ $ERRORS -gt 0 ] && [ $CHANGES -eq 0 ]; then
  : # error notifications already sent above
elif [ $CHANGES -gt 0 ] && [ $ERRORS -eq 0 ]; then
  SYNCED_NAMES=$(echo "$SYNCED_NAMES" | sed 's/,$//' | sed 's/^ //')
  notify "DW Saved" "$SYNCED_NAMES" "Pop"
elif [ $CHANGES -eq 0 ] && [ $ERRORS -eq 0 ]; then
  notify "DW Sync" "Everything up to date"
fi
