#!/bin/bash
# datawizard-sync.sh - DW Save: syncs all collaborative project repos via git
#
# Modes:
#   datawizard-sync.sh            sync (default): loop repos, stage/commit/pull/push
#   datawizard-sync.sh --doctor   read-only health checklist (never changes anything)
#   datawizard-sync.sh --install  one-command setup / repair (not in this version yet)
# Options:
#   --vault <path>   vault root override (normally derived from the script location
#                    or from the conf file - see resolve_vault below)
#   --auto           marks a scheduled run (launchd / Task Scheduler) in the log and
#                    status note; the installer's plist passes this
#
# Reads repo paths from ~/.datawizard-sync.conf (one path per line).
# Manual use: bind to a hotkey via the Obsidian Shell Commands plugin.
# Safety net: schedule via launchd every 2 hours.
# See datawizard-sync-setup.md for installation instructions.
#
# Feedback, three channels (most to least reliable):
#   1. <vault>/_DataWizard/DW Save Status.md - overwritten every run (a fixed-size
#      card, never appended). Written only when the vault root can be resolved.
#   2. ~/.datawizard-sync.log - the last LOG_KEEP lines; older lines rotate into
#      ~/.datawizard-sync.log.archive (full history, nothing discarded).
#   3. One result line on stdout (the Shell Commands balloon) plus a macOS desktop
#      notification via osascript when available - best effort, never load-bearing.
#
# Portability rules: pure ASCII; macOS ships bash 3.2, so no associative arrays,
# no mapfile, no case-conversion expansions. The whole body runs inside main() so bash parses the
# file to EOF before the sync loop can overwrite it (the Seed repo contains this
# script; `git pull` there replaces it mid-run otherwise - the update_seed.sh
# 1.3.1 lesson).

LOGFILE="$HOME/.datawizard-sync.log"
CONF="$HOME/.datawizard-sync.conf"
LOG_KEEP=1000
STATUS_KEEP=10
SCRIPT_PATH="${BASH_SOURCE[0]}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

ts() { date '+%Y-%m-%d %H:%M:%S'; }

log() { echo "$(ts) $1" >> "$LOGFILE"; }

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
    log "NOTIFY [$title] $message"
  fi
}

# Read the conf into PROJECTS[]. Blank lines and # comments are skipped.
# Lines beginning "exclude:" are reserved for the installer's repo discovery
# (design 4.2) and are skipped here so a regenerated conf parses unchanged.
read_conf() {
  PROJECTS=()
  [ -f "$CONF" ] || return 1
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*|exclude:*) continue ;;
    esac
    PROJECTS+=("$line")
  done < "$CONF"
  return 0
}

# Resolve the vault root, in order: --vault, the script's own location when it
# lives inside <vault>/_DataWizard/Seed/Scripts, the conf (the Seed repo's
# grandparent). Existing installs run a copy from ~/Scripts (setup doc Step 2),
# which is why the conf fallback exists. Sets VAULT_ROOT and VAULT_SOURCE
# (which rule won - reported by --doctor); returns 1 when nothing matched.
# Sets variables instead of printing so it runs in the caller's shell.
resolve_vault() {
  VAULT_ROOT=""; VAULT_SOURCE=""
  if [ -n "$VAULT_ARG" ]; then
    VAULT_SOURCE="--vault"; VAULT_ROOT="${VAULT_ARG%/}"; return 0
  fi
  local script_dir
  script_dir="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd)"
  case "$script_dir" in
    */_DataWizard/Seed/Scripts)
      VAULT_SOURCE="script location"
      VAULT_ROOT="${script_dir%/_DataWizard/Seed/Scripts}"; return 0 ;;
  esac
  local p
  for p in "${PROJECTS[@]}"; do
    p="${p%/}"
    case "$p" in
      */_DataWizard/Seed)
        VAULT_SOURCE="conf (Seed repo path)"
        VAULT_ROOT="${p%/_DataWizard/Seed}"; return 0 ;;
    esac
  done
  return 1
}

# Append one status-note table row (NAME, TEXT).
add_row() {
  local nl='
'
  [ -n "$ROWS" ] && ROWS="$ROWS$nl"
  ROWS="$ROWS| $1 | $2 |"
}

# Rotate a plain log file: when it exceeds N lines, the excess (oldest lines)
# is APPENDED to "<file>.archive" and only the last N stay in the active log.
# Nothing is ever discarded - the active log is a bounded dashboard-sized
# file, the archive is the full history (home folder, never the vault).
rotate_log() {
  local file="$1" keep="$2" n excess tmp
  [ -f "$file" ] || return 0
  n=$(wc -l < "$file" | tr -d ' ')
  [ "$n" -gt "$keep" ] || return 0
  excess=$((n - keep))
  tmp="$file.tmp.$$"
  if head -n "$excess" "$file" >> "$file.archive" 2>/dev/null \
     && tail -n "$keep" "$file" > "$tmp" 2>/dev/null; then
    mv -f "$tmp" "$file"
  else
    rm -f "$tmp"
  fi
}

# Overwrite the status note (design Section 6). Fixed-size card: last run,
# per-repo results, last error, last scheduled run, then the last STATUS_KEEP
# log lines. Never appended - it is a dashboard, not a history.
# Arguments: SUMMARY (the stdout line), OUTCOME (ok|error), RESULT_ROWS (table rows)
write_status_note() {
  local summary="$1" outcome="$2" rows="$3"
  [ -n "$VAULT_ROOT" ] || return 0
  local dir="$VAULT_ROOT/_DataWizard"
  [ -d "$dir" ] || { log "Status note skipped: $dir not found"; return 0; }
  local note="$dir/DW Save Status.md"
  local today created last_error last_sched trigger
  today=$(date '+%Y-%m-%d')
  created="$today"
  if [ -f "$note" ]; then
    created=$(grep -m1 '^created:' "$note" | sed 's/^created:[[:space:]]*//' | tr -d "'\"")
    [ -n "$created" ] || created="$today"
  fi
  last_error=$(grep ' ERROR' "$LOGFILE" 2>/dev/null | tail -n 1)
  [ -n "$last_error" ] || last_error="none recorded"
  last_sched=$(grep ' RUN scheduled started' "$LOGFILE" 2>/dev/null | tail -n 1 | cut -c1-19)
  [ -n "$last_sched" ] || last_sched="no scheduled run recorded yet"
  trigger="manual"; [ "$AUTO_RUN" = true ] && trigger="scheduled"
  local tmp="$note.tmp.$$"
  {
    printf '%s\n' "---" "title: DW Save Status" "type: project-doc" \
      "created: $created" "updated: $today" "status: $outcome" "---" ""
    printf '%s\n' "# DW Save Status" ""
    printf '%s\n' "*Written by datawizard-sync.sh on every run - a dashboard, not a history. Full log: \`~/.datawizard-sync.log\`. Problems? Run: \`bash \"$SCRIPT_ABS\" --doctor\`*" ""
    printf '%s\n' "**Last run:** $(ts) ($trigger)" "" "**Result:** $summary" ""
    printf '%s\n' "| Repo | Result |" "|---|---|"
    printf '%s\n' "$rows"
    printf '%s\n' "" "**Last error:** $last_error" "" "**Safety net (scheduled) last ran:** $last_sched" ""
    printf '%s\n' "## Last $STATUS_KEEP log lines" "" '```'
    tail -n "$STATUS_KEEP" "$LOGFILE" 2>/dev/null
    printf '%s\n' '```'
  } > "$tmp" && mv -f "$tmp" "$note"
}

# ---------------------------------------------------------------------------
# Sync mode
# ---------------------------------------------------------------------------

run_sync() {
  # --- Single-instance run guard (prevents overlapping syncs -> stale index.lock) ---
  # macOS ships no flock, so use an atomic mkdir as a mutex. A PID file lets a later
  # run reclaim the lock if an earlier run died without cleaning up (the EXIT trap
  # does not fire on SIGKILL or power loss). RUNLOCK_MAX_AGE also reclaims if the
  # recorded PID was reused by an unrelated process after a reboot. (kill -0 can
  # report a PID owned by another user as "alive" via EPERM; harmless on a
  # single-user Mac, and the age ceiling is the backstop regardless.)
  RUNLOCK="$HOME/.datawizard-sync.lock.d"
  RUNLOCK_MAX_AGE=1800   # seconds (30 min) - ~60x a normal run
  if ! mkdir "$RUNLOCK" 2>/dev/null; then
    OWNER_PID=$(cat "$RUNLOCK/pid" 2>/dev/null)
    LOCK_MTIME=$(stat -c %Y "$RUNLOCK" 2>/dev/null || stat -f %m "$RUNLOCK" 2>/dev/null || echo 0)
    case "$LOCK_MTIME" in ''|*[!0-9]*) LOCK_MTIME=0 ;; esac
    LOCK_AGE=$(( $(date +%s) - LOCK_MTIME ))
    if { [ -n "$OWNER_PID" ] && ! kill -0 "$OWNER_PID" 2>/dev/null; } || [ "$LOCK_AGE" -gt "$RUNLOCK_MAX_AGE" ]; then
      log "Reclaiming stale run-lock (PID ${OWNER_PID:-none}, age ${LOCK_AGE}s)"
      rm -rf "$RUNLOCK"
      mkdir "$RUNLOCK" 2>/dev/null || {
        log "SKIP: could not acquire run-lock"
        echo "DW Save: could not start (run-lock busy) - try again shortly"
        exit 0
      }
    else
      log "SKIP: another sync run already in progress (PID ${OWNER_PID:-unknown})"
      notify "DW Sync" "Sync already in progress - try again shortly"
      echo "DW Save: a save is already running - try again shortly"
      exit 0
    fi
  fi
  echo $$ > "$RUNLOCK/pid"
  sleep 1
  if [ "$(cat "$RUNLOCK/pid" 2>/dev/null)" != "$$" ]; then
    log "SKIP: lost run-lock claim race"
    echo "DW Save: a save is already running - try again shortly"
    exit 0
  fi
  # Ownership-checked trap: only remove the lock if we still own it, so an
  # age-ceiling-reclaimed predecessor cannot delete the successor's lock on exit.
  trap '[ "$(cat "$RUNLOCK/pid" 2>/dev/null)" = "$$" ] && rm -rf "$RUNLOCK"' EXIT
  # --------------------------------------------------------------------------------

  local trigger="manual"; [ "$AUTO_RUN" = true ] && trigger="scheduled"
  log "RUN $trigger started"

  # Check for config
  if ! read_conf; then
    notify "DW Sync Error" "No config found. Create ~/.datawizard-sync.conf" "Basso"
    log "ERROR: No config file at $CONF"
    echo "DW Save: no config file at ~/.datawizard-sync.conf - run --install"
    exit 1
  fi
  if [ ${#PROJECTS[@]} -eq 0 ]; then
    notify "DW Sync Error" "Config file is empty. Add repo paths to ~/.datawizard-sync.conf" "Basso"
    log "ERROR: config file is empty"
    echo "DW Save: config file is empty - run --install"
    exit 1
  fi

  if ! resolve_vault; then
    log "Status note skipped: vault root not found (no --vault, script not in the Seed, no Seed path in conf)"
  fi

  CHANGES=0
  ERRORS=0
  SAVED_LIST=""     # "Seed (3 files), Weave Shared (1 file)"
  ERROR_LIST=""     # "Weave Shared (sync conflict)"
  PULLED_LIST=""    # repos that received updates
  ROWS=""           # status note table rows

  local DIR NAME RESULT NFILES HEAD_BEFORE HEAD_AFTER UPSTREAM AHEAD committed pulled
  for DIR in "${PROJECTS[@]}"; do
    DIR="${DIR%/}"
    NAME=$(basename "$DIR")
    RESULT=""; committed=0; pulled=0; AHEAD=0; NFILES=0

    if ! cd "$DIR" 2>/dev/null; then
      log "SKIP $DIR (not found)"
      ERRORS=$((ERRORS+1))
      ERROR_LIST="$ERROR_LIST, $NAME (folder not found)"
      add_row "$NAME" "ERROR: folder not found"
      continue
    fi

    # --- Self-heal: clear a stale git index.lock from an interrupted prior run ---
    # Safe because the run guard above serializes sync runs, so any lock present
    # here is from a dead run or an external git process, never a sibling sync.
    LOCKFILE="$DIR/.git/index.lock"
    if [ -e "$LOCKFILE" ]; then
      LOCK_MTIME=$(stat -c %Y "$LOCKFILE" 2>/dev/null || stat -f %m "$LOCKFILE" 2>/dev/null || echo 0)
      case "$LOCK_MTIME" in ''|*[!0-9]*) LOCK_MTIME=0 ;; esac
      LOCK_AGE=$(( $(date +%s) - LOCK_MTIME ))
      if [ "$LOCK_AGE" -gt 120 ]; then
        log "Cleared stale index.lock in $NAME (age ${LOCK_AGE}s)"
        rm -f "$LOCKFILE"
      else
        log "SKIP $NAME: fresh index.lock (age ${LOCK_AGE}s), git may be active"
        add_row "$NAME" "skipped (git busy - try again shortly)"
        continue
      fi
    fi
    # ----------------------------------------------------------------------------

    # Branch guard: only sync repos on main
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ "$BRANCH" != "main" ]; then
      log "SKIPPED $NAME -- on branch '$BRANCH', not main"
      add_row "$NAME" "skipped (on branch '$BRANCH', not main)"
      continue
    fi

    git add . >> "$LOGFILE" 2>&1
    if ! git diff --cached --quiet; then
      NFILES=$(git diff --cached --name-only | wc -l | tr -d ' ')
      TIMESTAMP=$(ts)
      if git commit -m "auto-sync $TIMESTAMP on $(hostname -s)" >> "$LOGFILE" 2>&1; then
        committed=1
      else
        ERRORS=$((ERRORS+1))
        notify "DW Sync Error" "Commit failed in $NAME - check log / SYNC-BLOCKED.md" "Basso"
        log "ERROR commit failed in $DIR"
        ERROR_LIST="$ERROR_LIST, $NAME (commit blocked)"
        add_row "$NAME" "ERROR: commit failed - check SYNC-BLOCKED.md in the repo"
        continue
      fi
    fi

    HEAD_BEFORE=$(git rev-parse HEAD 2>/dev/null)
    if ! git pull --no-rebase >> "$LOGFILE" 2>&1; then
      ERRORS=$((ERRORS+1))
      # A merge conflict leaves unmerged paths; any other pull failure (offline,
      # remote gone, auth) does not - tell the two apart so an offline laptop
      # never reads as a conflict.
      if [ -n "$(git ls-files -u 2>/dev/null | head -n 1)" ]; then
        notify "DW Sync Error" "Sync conflict in $NAME. Open terminal to resolve." "Basso"
        log "ERROR pull failed in $DIR (merge conflict)"
        ERROR_LIST="$ERROR_LIST, $NAME (sync conflict)"
        add_row "$NAME" "ERROR: sync conflict - open a terminal to resolve (setup doc, Merge Conflicts)"
      else
        notify "DW Sync Error" "Could not fetch $NAME. Check your connection." "Basso"
        log "ERROR pull failed in $DIR (fetch failed - offline?)"
        ERROR_LIST="$ERROR_LIST, $NAME (could not reach GitHub)"
        add_row "$NAME" "ERROR: could not reach GitHub - check your connection, then save again"
      fi
      continue
    fi
    HEAD_AFTER=$(git rev-parse HEAD 2>/dev/null)
    [ "$HEAD_BEFORE" != "$HEAD_AFTER" ] && pulled=1

    # What the push will carry: everything ahead of upstream, which includes
    # commits from an earlier offline run, not only this run's commit - so a
    # catch-up save reports "pushed", never "up to date".
    UPSTREAM=$(git rev-parse --abbrev-ref '@{u}' 2>/dev/null)
    if [ -n "$UPSTREAM" ]; then
      AHEAD=$(git rev-list --count "$UPSTREAM..HEAD" 2>/dev/null || echo 0)
      case "$AHEAD" in ''|*[!0-9]*) AHEAD=0 ;; esac
      [ "$AHEAD" -gt 0 ] && NFILES=$(git diff --name-only "$UPSTREAM" HEAD 2>/dev/null | wc -l | tr -d ' ')
    else
      AHEAD=$committed
    fi

    if ! git push >> "$LOGFILE" 2>&1; then
      ERRORS=$((ERRORS+1))
      notify "DW Sync Error" "Push failed in $NAME. Check your connection." "Basso"
      log "ERROR push failed in $DIR"
      ERROR_LIST="$ERROR_LIST, $NAME (push failed)"
      add_row "$NAME" "ERROR: push failed - check your connection, then save again"
      continue
    fi

    if [ "$AHEAD" -gt 0 ]; then
      CHANGES=$((CHANGES+1))
      RESULT="pushed $NFILES file(s)"
      SAVED_LIST="$SAVED_LIST, $NAME ($NFILES file(s))"
    else
      RESULT="up to date"
    fi
    if [ $pulled -eq 1 ]; then
      RESULT="$RESULT, pulled updates"
      PULLED_LIST="$PULLED_LIST, $NAME"
    fi
    add_row "$NAME" "$RESULT"
  done
  cd "$HOME" 2>/dev/null || true

  SAVED_LIST="${SAVED_LIST#, }"; ERROR_LIST="${ERROR_LIST#, }"; PULLED_LIST="${PULLED_LIST#, }"

  # --- Result line (stdout -> Shell Commands balloon), desktop notification, log ---
  local SUMMARY OUTCOME="ok"
  if [ $ERRORS -gt 0 ]; then
    OUTCOME="error"
    SUMMARY="DW Save: ERROR in $ERROR_LIST - see DW Save Status.md"
    [ -n "$SAVED_LIST" ] && SUMMARY="$SUMMARY (saved: $SAVED_LIST)"
    # error notifications already sent above
  elif [ $CHANGES -gt 0 ]; then
    SUMMARY="DW Saved: $SAVED_LIST"
    [ -n "$PULLED_LIST" ] && SUMMARY="$SUMMARY (pulled updates: $PULLED_LIST)"
    notify "DW Saved" "$SAVED_LIST" "Pop"
  else
    SUMMARY="DW Save: everything up to date"
    [ -n "$PULLED_LIST" ] && SUMMARY="$SUMMARY (pulled updates: $PULLED_LIST)"
    notify "DW Sync" "Everything up to date"
  fi
  log "RUN finished: $SUMMARY"

  write_status_note "$SUMMARY" "$OUTCOME" "$ROWS"
  rotate_log "$LOGFILE" "$LOG_KEEP"
  echo "$SUMMARY"
  # Exit 0 even on repo errors, as before: the result line carries the outcome
  # and the Shell Commands plugin must not treat a reported error as a crash.
  exit 0
}

# ---------------------------------------------------------------------------
# Doctor mode (design Section 5) - read-only. Prints one line per check with
# [ok] / [FAIL] / [warn] / [info] and the fix; never writes a file, never
# touches git state (no fetch: origin/<branch> moves on push, so "last push
# landed at" reads from the local tracking ref). Exit 1 if any FAIL.
# ---------------------------------------------------------------------------

DOC_OK=0; DOC_FAIL=0; DOC_WARN=0
d_ok()   { DOC_OK=$((DOC_OK+1));     echo " [ok]   $1"; }
d_fail() { DOC_FAIL=$((DOC_FAIL+1)); echo " [FAIL] $1"; }
d_warn() { DOC_WARN=$((DOC_WARN+1)); echo " [warn] $1"; }
d_info() {                           echo " [info] $1"; }
d_head() { echo; echo "$1"; }

# file_age_secs PATH -> seconds since last modification (0 if unknown)
file_age_secs() {
  local m
  m=$(stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0)
  case "$m" in ''|*[!0-9]*) m=0 ;; esac
  [ "$m" -gt 0 ] && echo $(( $(date +%s) - m )) || echo 0
}
# human_age SECS -> "3 minutes ago" style
human_age() {
  local s="$1"
  if [ "$s" -lt 120 ]; then echo "$s seconds ago"
  elif [ "$s" -lt 7200 ]; then echo "$((s/60)) minutes ago"
  elif [ "$s" -lt 172800 ]; then echo "$((s/3600)) hours ago"
  else echo "$((s/86400)) days ago"; fi
}

# Reads the Shell Commands data.json and Obsidian hotkeys.json (python3, stdlib
# only) and prints key=value lines the bash side consumes. Kept as one helper so
# the JSON handling lives in exactly one place for --doctor and, later, --install.
inspect_plugin_config() {  # DATA_JSON HOTKEYS_JSON
  python3 - "$1" "$2" <<'PY'
import json, sys
data_path, hk_path = sys.argv[1], sys.argv[2]
FIXED_ID = "dwsave0001"; ALIAS = "DW Save"; PREFIX = "obsidian-shellcommands:shell-command-"
def combo(binds):
    out = []
    for b in binds or []:
        mods = "+".join(b.get("modifiers", []) or [])
        key = b.get("key", "")
        out.append((mods + "+" if mods else "") + key)
    return " / ".join(out)
try:
    d = json.load(open(data_path, encoding="utf-8"))
    print("data_parse=ok")
except Exception as e:
    print("data_parse=fail:%s" % e.__class__.__name__); d = None
entry = None; how = "none"; ids = []
if isinstance(d, dict):
    cmds = d.get("shell_commands") or []
    ids = [c.get("id", "") for c in cmds if isinstance(c, dict)]
    for c in cmds:
        if isinstance(c, dict) and c.get("id") == FIXED_ID: entry, how = c, "id"; break
    if entry is None:
        for c in cmds:
            if isinstance(c, dict) and c.get("alias") == ALIAS: entry, how = c, "alias"; break
print("entry_how=" + how)
if entry is not None:
    print("entry_id=" + str(entry.get("id", "")))
    psc = entry.get("platform_specific_commands") or {}
    print("entry_cmd=" + str(psc.get("darwin") or psc.get("default") or psc.get("win32") or ""))
    oh = entry.get("output_handlers") or {}
    print("entry_stdout=" + str(((oh.get("stdout") or {}).get("handler")) or ""))
    print("entry_stderr=" + str(((oh.get("stderr") or {}).get("handler")) or ""))
try:
    h = json.load(open(hk_path, encoding="utf-8"))
    print("hk_parse=ok")
except FileNotFoundError:
    print("hk_parse=missing"); h = {}
except Exception as e:
    print("hk_parse=fail:%s" % e.__class__.__name__); h = {}
if isinstance(h, dict):
    if entry is not None:
        b = h.get(PREFIX + str(entry.get("id", "")))
        print("hotkey=" + (combo(b) if b else ""))
    orphans = [k[len(PREFIX):] for k in h if k.startswith(PREFIX) and k[len(PREFIX):] not in ids]
    print("orphans=" + ",".join(orphans))
    holders = []
    for k, v in h.items():
        if entry is not None and k == PREFIX + str(entry.get("id", "")): continue
        for b in v or []:
            if set(b.get("modifiers", []) or []) == {"Mod", "Shift"} and str(b.get("key", "")).upper() == "S":
                holders.append(k)
    print("holder=" + ",".join(holders))
PY
}

run_doctor() {
  echo "DW Save doctor - $(ts)"
  echo "(read-only: this checks, it never changes anything)"
  local os; os=$(uname 2>/dev/null)
  local dir name n

  # --- 1. tools and sign-in ---
  d_head "1. Tools"
  if command -v git >/dev/null 2>&1; then d_ok "git present ($(git --version 2>/dev/null | head -n 1))"
  else d_fail "git not found - Mac: run 'xcode-select --install'; Windows: install Git for Windows"; fi
  if command -v gh >/dev/null 2>&1; then
    d_ok "gh present ($(gh --version 2>/dev/null | head -n 1))"
    if gh auth status >/dev/null 2>&1; then d_ok "signed in to GitHub (gh auth status)"
    else d_fail "not signed in to GitHub - run: gh auth login"; fi
  else
    d_fail "gh (GitHub CLI) not found - Mac: brew install gh; Windows: winget install GitHub.cli"
  fi

  # --- 2. conf ---
  d_head "2. Repo list (~/.datawizard-sync.conf)"
  local CONF_OK=0
  if ! read_conf; then
    d_fail "conf not found at $CONF - re-run --install (or create it per datawizard-sync-setup.md)"
  elif [ ${#PROJECTS[@]} -eq 0 ]; then
    d_fail "conf is empty - re-run --install"
  else
    CONF_OK=1
    for dir in "${PROJECTS[@]}"; do
      dir="${dir%/}"; name=$(basename "$dir")
      if [ ! -d "$dir" ]; then d_fail "$name: folder not found ($dir) - remove the line or re-run --install"; continue; fi
      if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then d_fail "$name: not a git repo ($dir)"; continue; fi
      if ! git -C "$dir" remote get-url origin >/dev/null 2>&1; then d_fail "$name: no 'origin' remote - nothing to push to"; continue; fi
      d_ok "$name: git repo with origin ($(git -C "$dir" remote get-url origin 2>/dev/null))"
    done
  fi

  # --- vault root (needed by 3, 4, 6, 7, 8) ---
  resolve_vault || true
  if [ -n "$VAULT_ROOT" ] && [ -d "$VAULT_ROOT" ]; then
    d_info "vault root: $VAULT_ROOT (from $VAULT_SOURCE)"
  else
    VAULT_ROOT=""
    d_warn "vault root not found (script is not inside <vault>/_DataWizard/Seed/Scripts and no Seed path in the conf) - pass --vault <path>; checks 3, 4, 6-8 skipped"
  fi
  local SEED_DIR=""
  [ -n "$VAULT_ROOT" ] && [ -d "$VAULT_ROOT/_DataWizard/Seed" ] && SEED_DIR="$VAULT_ROOT/_DataWizard/Seed"

  # --- 3. drift: repos in the vault that are not in the conf ---
  d_head "3. Repos in the vault not yet in the list"
  if [ -n "$VAULT_ROOT" ]; then
    local found=0 gitdir repo listed p
    while IFS= read -r gitdir; do
      [ -n "$gitdir" ] || continue
      repo="${gitdir%/.git}"
      case "$repo" in */.obsidian/*|*/.trash/*|*/node_modules/*|*/.obsidian|*/.trash|*/node_modules) continue ;; esac
      git -C "$repo" remote get-url origin >/dev/null 2>&1 || continue
      listed=0
      if [ "$CONF_OK" -eq 1 ]; then
        for p in "${PROJECTS[@]}"; do [ "${p%/}" = "$repo" ] && listed=1; done
      fi
      if [ "$listed" -eq 0 ]; then
        found=$((found+1))
        d_warn "$(basename "$repo") is a repo with an origin but is not in the conf ($repo) - re-run --install to add it, or add an 'exclude: $repo' line"
      fi
    done <<EOF_FIND
$(find "$VAULT_ROOT" -maxdepth 4 -name .git \( -type d -o -type f \) -prune 2>/dev/null)
EOF_FIND
    [ "$found" -eq 0 ] && d_ok "no unlisted repos found (scanned to depth 4)"
  else
    d_info "skipped (no vault root)"
  fi

  # --- 4. commit guard ---
  d_head "4. Commit guard (pre-commit hook)"
  local hook_src=""
  [ -n "$SEED_DIR" ] && [ -f "$SEED_DIR/Scripts/hooks/pre-commit" ] && hook_src="$SEED_DIR/Scripts/hooks/pre-commit"
  [ -z "$hook_src" ] && [ -f "$(dirname "$SCRIPT_ABS")/hooks/pre-commit" ] && hook_src="$(dirname "$SCRIPT_ABS")/hooks/pre-commit"
  if [ "$CONF_OK" -eq 1 ]; then
    [ -z "$hook_src" ] && d_warn "Seed copy of the hook not found (Scripts/hooks/pre-commit) - presence checked, version not compared"
    for dir in "${PROJECTS[@]}"; do
      dir="${dir%/}"; name=$(basename "$dir")
      [ -d "$dir/.git" ] || [ -f "$dir/.git" ] || continue
      local hooks_dir hp
      hp=$(git -C "$dir" config core.hooksPath 2>/dev/null)
      if [ -n "$hp" ]; then
        case "$hp" in /*) hooks_dir="$hp" ;; *) hooks_dir="$dir/$hp" ;; esac
      else
        hooks_dir="$dir/.git/hooks"
      fi
      if [ ! -f "$hooks_dir/pre-commit" ]; then
        if [ -n "$hp" ]; then
          d_fail "$name: no pre-commit hook in $hooks_dir (core.hooksPath=$hp is set, so git ignores .git/hooks and install-git-hooks.sh cannot help) - add the Seed's Scripts/hooks/pre-commit to that folder in the repo"
        else
          d_fail "$name: commit guard not installed - run: bash \"<Seed>/Scripts/install-git-hooks.sh\" \"$dir\" (or re-run --install)"
        fi
      elif [ -n "$hook_src" ] && ! cmp -s "$hook_src" "$hooks_dir/pre-commit"; then
        if [ -n "$hp" ]; then
          d_fail "$name: the hook git actually runs ($hooks_dir/pre-commit, via core.hooksPath=$hp - a tracked team hook) is a different version than the Seed's; install-git-hooks.sh writes to .git/hooks, which git ignores here - update the tracked hook in that repo instead"
        else
          d_fail "$name: commit guard is a different version than the Seed's - re-run install-git-hooks.sh (or --install)"
        fi
      else
        d_ok "$name: commit guard installed${hp:+ (via core.hooksPath=$hp)}"
      fi
    done
  else
    d_info "skipped (no repo list)"
  fi

  # --- 5. safety net ---
  d_head "5. Safety net (scheduled sync)"
  if [ "$os" = "Darwin" ]; then
    local plist="$HOME/Library/LaunchAgents/com.datawizard.sync.plist" ppath
    if [ ! -f "$plist" ]; then
      d_fail "launchd agent not installed ($plist missing) - re-run --install"
    else
      ppath=$(grep -o '<string>[^<]*datawizard-sync\.sh</string>' "$plist" 2>/dev/null | head -n 1 | sed 's/<[^>]*>//g')
      if [ -n "$ppath" ] && [ ! -f "$ppath" ]; then
        d_fail "launchd agent points at a script that does not exist ($ppath) - re-run --install"
      elif [ -n "$ppath" ] && [ "$ppath" != "$SCRIPT_ABS" ]; then
        d_warn "launchd agent runs a different copy of the script ($ppath) - a ~/Scripts copy does not self-update; re-run --install to point it at the Seed"
      else
        d_ok "launchd agent file present ($plist)"
      fi
      if launchctl print "gui/$(id -u)/com.datawizard.sync" >/dev/null 2>&1 || launchctl list 2>/dev/null | grep -q 'com.datawizard.sync'; then
        d_ok "launchd agent is loaded"
      else
        d_fail "launchd agent file exists but is not loaded - re-run --install (or: launchctl load \"$plist\")"
      fi
    fi
  else
    d_info "scheduled-sync check is macOS-only in this version (Windows Task Scheduler check ships with the PowerShell port)"
  fi
  local last_sched
  last_sched=$(grep ' RUN scheduled started' "$LOGFILE" 2>/dev/null | tail -n 1 | cut -c1-19)
  if [ -n "$last_sched" ]; then d_ok "last scheduled run: $last_sched"
  else d_info "no scheduled run recorded yet (scheduled runs are marked only when the agent passes --auto, which --install sets up)"; fi

  # --- 6. Shell Commands plugin ---
  d_head "6. Obsidian Shell Commands plugin"
  local PLUG_ID="" PLUG_HOW="none" PLUG_CMD="" PLUG_STDOUT="" HK="" ORPHANS="" HOLDER="" DATA_PARSE="" HK_PARSE=""
  if [ -n "$VAULT_ROOT" ]; then
    local obs="$VAULT_ROOT/.obsidian" pdir="$VAULT_ROOT/.obsidian/plugins/obsidian-shellcommands"
    if [ ! -d "$obs" ]; then
      d_fail "no .obsidian folder at $VAULT_ROOT - is this the vault root? (pass --vault <path>)"
    elif [ ! -d "$pdir" ]; then
      d_fail "Shell Commands plugin is not installed - in Obsidian: Settings > Community plugins > Browse > install 'Shell commands', then re-run --install"
    else
      d_ok "plugin folder present ($(grep -o '"version": *"[^"]*"' "$pdir/manifest.json" 2>/dev/null | head -n 1 | sed 's/.*: *//' | tr -d '"'))"
      if grep -q '"obsidian-shellcommands"' "$obs/community-plugins.json" 2>/dev/null; then d_ok "plugin is enabled (community-plugins.json)"
      else d_fail "plugin is installed but not enabled - re-run --install (or enable 'Shell commands' in Settings > Community plugins)"; fi
      if [ ! -f "$pdir/data.json" ]; then
        d_fail "plugin has no data.json yet (installed but never configured) - re-run --install"
      elif ! command -v python3 >/dev/null 2>&1; then
        d_warn "python3 not found - the plugin command and hotkey could not be inspected (Mac: it comes with the Xcode Command Line Tools)"
      else
        local k v
        while IFS='=' read -r k v; do
          case "$k" in
            data_parse) DATA_PARSE="$v" ;; entry_how) PLUG_HOW="$v" ;; entry_id) PLUG_ID="$v" ;;
            entry_cmd) PLUG_CMD="$v" ;; entry_stdout) PLUG_STDOUT="$v" ;; hk_parse) HK_PARSE="$v" ;;
            hotkey) HK="$v" ;; orphans) ORPHANS="$v" ;; holder) HOLDER="$v" ;;
          esac
        done <<EOF_PY
$(inspect_plugin_config "$pdir/data.json" "$obs/hotkeys.json" 2>/dev/null)
EOF_PY
        if [ "$DATA_PARSE" != "ok" ]; then
          d_fail "data.json does not parse ($DATA_PARSE) - re-run --install (it backs the file up first)"
        else
          case "$PLUG_HOW" in
            id)    d_ok "DW Save command present (id $PLUG_ID)" ;;
            alias) d_warn "DW Save command present under a pre-installer id ($PLUG_ID) - works, but re-run --install to migrate it to the fixed id dwsave0001 so repairs re-link automatically" ;;
            *)     d_fail "no DW Save command in the plugin - re-run --install" ;;
          esac
          if [ "$PLUG_HOW" != "none" ]; then
            if [ "$PLUG_STDOUT" = "notification" ]; then d_ok "result balloon on (stdout handler: notification)"
            else d_fail "result balloon off (stdout handler: ${PLUG_STDOUT:-unset}) - this is why saves feel silent; re-run --install"; fi
            local cpath
            cpath=$(printf '%s' "$PLUG_CMD" | sed -n 's/.*"\([^"]*datawizard-sync\.sh\)".*/\1/p')
            [ -z "$cpath" ] && cpath=$(printf '%s' "$PLUG_CMD" | grep -o '[^ ]*datawizard-sync\.sh' | head -n 1)
            if [ -z "$cpath" ]; then d_warn "command does not look like a datawizard-sync.sh call: $PLUG_CMD"
            elif [ ! -f "$cpath" ]; then d_fail "command points at a script that does not exist ($cpath) - re-run --install"
            elif [ "$cpath" != "$SCRIPT_ABS" ]; then d_warn "command runs a different copy of the script ($cpath) - a ~/Scripts copy does not self-update; re-run --install to point it at the Seed"
            else d_ok "command runs this script ($cpath)"; fi
          fi
        fi
      fi
    fi
  else
    d_info "skipped (no vault root)"
  fi

  # --- 7. hotkey ---
  d_head "7. Hotkey"
  if [ -z "$VAULT_ROOT" ] || [ "$DATA_PARSE" != "ok" ]; then
    d_info "skipped (plugin config not inspected)"
  else
    case "$HK_PARSE" in
      ok) : ;;
      missing) d_info "no hotkeys.json yet (no custom hotkeys in this vault)" ;;
      *) d_fail "hotkeys.json does not parse ($HK_PARSE) - re-run --install" ;;
    esac
    if [ "$PLUG_HOW" != "none" ]; then
      if [ -n "$HK" ]; then
        d_ok "DW Save is bound to: $HK  (Mod = Cmd on Mac, Ctrl on Windows; expected Mod+Shift+S)"
        case "$HK" in Mod+Shift+S) : ;; *) d_warn "that is not the documented Mod+Shift+S - fine if you chose it; a mis-captured combo (extra modifiers) is the usual cause otherwise" ;; esac
      else
        d_fail "no hotkey bound to the DW Save command - re-run --install"
      fi
    fi
    if [ -n "$ORPHANS" ]; then
      d_fail "hotkey bound to a Shell Commands entry that no longer exists (id: $ORPHANS) - the key does nothing; re-run --install"
    else
      d_ok "no orphaned Shell Commands hotkeys"
    fi
    [ -n "$HOLDER" ] && d_warn "Mod+Shift+S is also held by: $HOLDER - the installer will not steal it; choose one binding"
  fi

  # --- 8. feedback ---
  d_head "8. Feedback"
  if [ -n "$VAULT_ROOT" ]; then
    local note="$VAULT_ROOT/_DataWizard/DW Save Status.md"
    if [ -f "$note" ]; then
      d_ok "status note present, written $(human_age "$(file_age_secs "$note")") ($note)"
    else
      d_warn "no status note yet - it appears after the first save with this version"
    fi
  fi
  if [ -f "$LOGFILE" ]; then
    d_ok "log present ($(wc -l < "$LOGFILE" | tr -d ' ') lines) - last 3:"
    tail -n 3 "$LOGFILE" | sed 's/^/          /'
  else
    d_warn "no log yet at $LOGFILE - DW Save has never run on this machine"
  fi

  # --- 9. truth check ---
  d_head "9. Did the last save land on GitHub?"
  if [ "$CONF_OK" -eq 1 ]; then
    for dir in "${PROJECTS[@]}"; do
      dir="${dir%/}"; name=$(basename "$dir")
      git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
      local up ahead behind landed dirty
      up=$(git -C "$dir" rev-parse --abbrev-ref '@{u}' 2>/dev/null)
      if [ -z "$up" ]; then d_warn "$name: current branch has no upstream - nothing to compare against"; continue; fi
      landed=$(git -C "$dir" log -1 --format=%ci "$up" 2>/dev/null | cut -c1-16)
      ahead=$(git -C "$dir" rev-list --count "$up..HEAD" 2>/dev/null); behind=$(git -C "$dir" rev-list --count "HEAD..$up" 2>/dev/null)
      dirty=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      case "$ahead" in ''|*[!0-9]*) ahead=0 ;; esac; case "$behind" in ''|*[!0-9]*) behind=0 ;; esac
      if [ "$ahead" -gt 0 ]; then
        d_warn "$name: $ahead commit(s) saved locally but not yet on GitHub (last landed: $landed) - press DW Save; if it keeps failing, check your connection"
      else
        d_ok "$name: last push landed on GitHub at $landed"
      fi
      [ "$dirty" -gt 0 ] && d_info "$name: $dirty change(s) not saved yet (DW Save will pick them up)"
      [ "$behind" -gt 0 ] && d_info "$name: $behind commit(s) on GitHub not pulled yet (as of the last save)"
    done
  else
    d_info "skipped (no repo list)"
  fi

  echo
  if [ "$DOC_FAIL" -eq 0 ]; then
    echo "Result: all checks passed ($DOC_OK ok, $DOC_WARN warning(s))."
    exit 0
  else
    echo "Result: $DOC_FAIL problem(s), $DOC_WARN warning(s), $DOC_OK ok. Fix: re-run --install (or the specific action named above), then run --doctor again."
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Install mode (chunk 3) - placeholder in this version
# ---------------------------------------------------------------------------

run_install() {
  echo "DW Save: --install is not in this version of the Seed yet. Follow datawizard-sync-setup.md, or update the Seed (bash _DataWizard/Seed/update_seed.sh) and try again."
  exit 2
}

usage() {
  sed -n '2,13p' "$SCRIPT_PATH" | sed 's/^# \{0,1\}//'
}

# ---------------------------------------------------------------------------
# Entry
# ---------------------------------------------------------------------------

main() {
  MODE="sync"
  VAULT_ARG=""
  AUTO_RUN=false
  while [ $# -gt 0 ]; do
    case "$1" in
      --install) MODE="install" ;;
      --doctor)  MODE="doctor" ;;
      --auto)    AUTO_RUN=true ;;
      --vault)   shift; VAULT_ARG="${1:-}"; [ -n "$VAULT_ARG" ] || { echo "DW Save: --vault needs a path"; exit 2; } ;;
      --vault=*) VAULT_ARG="${1#--vault=}" ;;
      -h|--help) usage; exit 0 ;;
      *) echo "DW Save: unknown option '$1' (try --help)"; exit 2 ;;
    esac
    shift
  done
  SCRIPT_ABS="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd)/$(basename "$SCRIPT_PATH")"

  case "$MODE" in
    doctor)  run_doctor ;;
    install) run_install ;;
    *)       run_sync ;;
  esac
}

main "$@"
