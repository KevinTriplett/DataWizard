#!/bin/bash
# datawizard-sync.sh - DW Save: syncs all collaborative project repos via git
#
# Modes:
#   datawizard-sync.sh            sync (default): loop repos, stage/commit/pull/push
#   datawizard-sync.sh --doctor   read-only health checklist (never changes anything)
#   datawizard-sync.sh --install  one-command setup / repair (Mac); safe to re-run,
#                                 every step checks before it writes, backs up first
#   datawizard-sync.sh --dry-run  --install that only reports what it would change
# Options:
#   --vault <path>     vault root override (normally derived from the script location
#                      or from the conf file - see resolve_vault below)
#   --auto             marks a scheduled run (launchd / Task Scheduler) in the log and
#                      status note; the installer's plist passes this
#   --yes              install: no questions (new repos are added without asking;
#                      steps that need Obsidian quit are reported instead of waited for)
#   --exclude <path>   install: a repo found in the vault that must not be synced
#                      (remembered in the conf; repeatable)
#   --hotkey <combo>   install: hotkey to bind, e.g. Mod+Alt+S (default Mod+Shift+S;
#                      Mod = Cmd on Mac, Ctrl on Windows)
#   --interval <min>   install: minutes between scheduled saves (default 120)
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

# Read the conf into PROJECTS[] (repo paths) and EXCLUDES[] (repos found in the
# vault that are deliberately not synced - "exclude: <path>" lines, written by
# --install per design 4.2). Blank lines and # comments are skipped. Sync mode
# only uses PROJECTS; --doctor and --install use EXCLUDES too.
read_conf() {
  PROJECTS=(); EXCLUDES=()
  [ -f "$CONF" ] || return 1
  local line v
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ''|\#*) continue ;;
      exclude:*) v="${line#exclude:}"; v="${v#"${v%%[! ]*}"}"; v="${v%/}"; [ -n "$v" ] && EXCLUDES+=("$v"); continue ;;
    esac
    PROJECTS+=("${line%/}")
  done < "$CONF"
  return 0
}

# is_excluded PATH -> 0 when PATH is on the conf's exclude list
is_excluded() {
  local e
  for e in "${EXCLUDES[@]}"; do [ "$e" = "${1%/}" ] && return 0; done
  return 1
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

# The one place the Shell Commands data.json, Obsidian hotkeys.json and
# community-plugins.json are read or written (python3, stdlib only). Prints
# key=value lines the bash side consumes. Modes:
#   inspect  read-only report (used by --doctor): data_parse, entry_how, entry_id,
#            entry_cmd, entry_stdout, entry_stderr, hk_parse, hotkey, orphans, holder
#   plan     the inspect keys, then one "change=<what>" line per edit --install would
#            make and one "todo=<what>" line per thing it will not do by itself
#   apply    plan, then make the changes: back up each file it touches
#            (<file>.dwsave-backup-<timestamp>, never overwritten), write through a
#            temp file, re-parse to verify; prints "written=<file>" per file
# Arguments: MODE DATA_JSON HOTKEYS_JSON [MANIFEST_JSON COMMUNITY_PLUGINS_JSON
#            TARGET_SCRIPT HOTKEY_COMBO]
# The file byte layout is not preserved (2-space JSON, like Obsidian's own saves);
# every key that was there stays there.
plugin_config() {
  python3 - "$@" <<'PY'
import json, sys, os, time
a = (sys.argv[1:] + [""] * 9)[:9]
mode, data_path, hk_path, manifest_path, cp_path, target, combo_arg, lazy_path = a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]
FIXED_ID = "dwsave0001"; ALIAS = "DW Save"; PREFIX = "obsidian-shellcommands:shell-command-"
PLUGIN_ID = "obsidian-shellcommands"; DEFAULT_COMBO = "Mod+Shift+S"
changes = []; todos = []; infos = []; written = []

def combo(binds):
    out = []
    for b in binds or []:
        mods = "+".join(b.get("modifiers", []) or [])
        key = b.get("key", "")
        out.append((mods + "+" if mods else "") + key)
    return " / ".join(out)
def parse_combo(s):
    parts = [p.strip() for p in (s or "").split("+") if p.strip()]
    if not parts: return None
    return [{"modifiers": parts[:-1], "key": parts[-1]}]
def same_bind(x, y):
    return set(x.get("modifiers", []) or []) == set(y.get("modifiers", []) or []) and str(x.get("key", "")).upper() == str(y.get("key", "")).upper()
def holds(binds, want):
    return any(same_bind(b, want[0]) for b in (binds or []))
def load(path):
    try:
        with open(path, encoding="utf-8") as f: return json.load(f), "ok"
    except FileNotFoundError: return None, "missing"
    except Exception as e: return None, "fail:%s" % e.__class__.__name__
def backup(path):
    if not os.path.exists(path): return
    stamp = time.strftime("%Y%m%d%H%M%S")
    dst = "%s.dwsave-backup-%s" % (path, stamp)
    n = 0
    while os.path.exists(dst):
        n += 1; dst = "%s.dwsave-backup-%s-%d" % (path, stamp, n)
    with open(path, "rb") as s, open(dst, "wb") as d: d.write(s.read())
def save(path, obj):
    backup(path)
    tmp = path + ".dwsave-tmp"
    with open(tmp, "w", encoding="utf-8") as f: json.dump(obj, f, indent=2, ensure_ascii=False)
    os.replace(tmp, path)
    with open(path, encoding="utf-8") as f: json.load(f)   # verify it parses
    written.append(path)

# --- data.json: report (all modes) ---
d, d_state = load(data_path)
print("data_parse=" + ("ok" if d_state == "ok" else d_state))
entry = None; how = "none"; ids = []; cmds = []
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
h, h_state = load(hk_path)
print("hk_parse=" + h_state)
if not isinstance(h, dict): h = {} if h_state == "missing" else None
if isinstance(h, dict):
    if entry is not None:
        b = h.get(PREFIX + str(entry.get("id", "")))
        print("hotkey=" + (combo(b) if b else ""))
    orphans = [k[len(PREFIX):] for k in h if k.startswith(PREFIX) and k[len(PREFIX):] not in ids]
    print("orphans=" + ",".join(orphans))
    holders = []
    for k, v in h.items():
        if entry is not None and k == PREFIX + str(entry.get("id", "")): continue
        if holds(v, parse_combo(DEFAULT_COMBO)): holders.append(k)
    print("holder=" + ",".join(holders))
if mode == "inspect": sys.exit(0)

# --- plan: what --install would change ---
target_cmd = 'bash "%s"' % target
data_dirty = False; hk_dirty = False; cp_dirty = False; old_id = None

# community-plugins.json: enable the plugin. The Lazy Plugin Loader plugin rewrites
# this file on every launch from its own settings: "disabled" would undo an enable
# here (found live on the maintainer machine, DW S344), a delayed start keeps the
# plugin out of the file on purpose. Read its setting first.
lazy = None
if lazy_path:
    lz, lz_state = load(lazy_path)
    if isinstance(lz, dict):
        lazy = ((lz.get("desktop") or {}).get("plugins") or {}).get(PLUGIN_ID) or (lz.get("plugins") or {}).get(PLUGIN_ID)
        lazy = (lazy or {}).get("startupType") if isinstance(lazy, dict) else None
cp, cp_state = load(cp_path)
if cp_state == "missing": cp = []
if not isinstance(cp, list):
    todos.append("%s does not parse (%s) - not touched; fix it or delete it and re-run" % (cp_path, cp_state))
elif PLUGIN_ID not in cp:
    if lazy == "disabled":
        todos.append("the Lazy Plugin Loader has 'Shell commands' set to Disabled, and it rewrites community-plugins.json on every launch - enabling it here would not stick; in Obsidian: Settings > Lazy Plugin Loader > Shell commands > Instant, then re-run this installer")
    elif lazy in ("short", "long"):
        infos.append("the Shell Commands plugin is loaded by the Lazy Plugin Loader (startup: %s) - that is fine, it is left as is" % lazy)
    else:
        cp.append(PLUGIN_ID); cp_dirty = True
        changes.append("enable the Shell Commands plugin (community-plugins.json)")

# data.json: the DW Save command
if d_state == "missing":
    ver = ""
    m, m_state = load(manifest_path)
    if isinstance(m, dict): ver = str(m.get("version", ""))
    d = {"settings_version": ver, "shell_commands": []} if ver else {"shell_commands": []}
    cmds = d["shell_commands"]; data_dirty = True
    changes.append("create the plugin's data.json (settings_version %s from the installed manifest)" % (ver or "unset"))
elif d_state != "ok" or not isinstance(d, dict):
    todos.append("%s does not parse (%s) - not touched; in Obsidian, open the Shell commands settings once (the plugin rebuilds it), then re-run" % (data_path, d_state))
    d = None
if isinstance(d, dict):
    if not isinstance(d.get("shell_commands"), list):
        d["shell_commands"] = []; cmds = d["shell_commands"]; data_dirty = True
    desired = {
        "id": FIXED_ID,
        "platform_specific_commands": {"darwin": target_cmd, "default": target_cmd},
        "alias": ALIAS, "icon": "lucide-save",
        "output_handlers": {"stdout": {"handler": "notification", "convert_ansi_code": True},
                            "stderr": {"handler": "notification", "convert_ansi_code": True}},
        "output_handling_mode": "buffered", "command_palette_availability": "enabled",
    }
    if entry is None:
        new = {"id": FIXED_ID, "platform_specific_commands": {}, "shells": {}, "alias": ALIAS,
               "icon": "lucide-save", "confirm_execution": False, "ignore_error_codes": [],
               "input_contents": {"stdin": None}, "output_handlers": {},
               "output_wrappers": {"stdout": None, "stderr": None}, "output_channel_order": "stdout-first",
               "output_handling_mode": "buffered", "execution_notification_mode": None, "events": {},
               "debounce": None, "command_palette_availability": "enabled", "preactions": [],
               "variable_default_values": {}}
        new.update(desired); cmds.append(new); entry = new; data_dirty = True
        changes.append("add the DW Save command to the plugin (id %s, runs %s, result balloon on)" % (FIXED_ID, target))
    else:
        diffs = []
        cur_id = str(entry.get("id", ""))
        if cur_id != FIXED_ID:
            old_id = cur_id; diffs.append("migrate it from the pre-installer id %s to the fixed id %s" % (cur_id, FIXED_ID))
        psc = entry.get("platform_specific_commands") or {}
        # the plugin runs the darwin entry when present, else default; either is fine
        if (psc.get("darwin") or psc.get("default")) != target_cmd:
            diffs.append("point it at %s" % target)
        oh = entry.get("output_handlers") or {}
        so = (oh.get("stdout") or {}).get("handler")
        if so != "notification":
            diffs.append("turn the result balloon on (stdout handler: %s -> notification)" % (so or "unset"))
        if (oh.get("stderr") or {}).get("handler") != "notification":
            diffs.append("route errors to a notification too")
        if entry.get("alias") != ALIAS: diffs.append("restore the alias 'DW Save'")
        if diffs:
            # only the fields above are managed; icon / output mode / palette availability
            # are set on new entries and left as the user has them on existing ones
            for key in ("id", "platform_specific_commands", "alias", "output_handlers"):
                entry[key] = desired[key]
            data_dirty = True
            changes.append("update the DW Save command: " + "; ".join(diffs))
    # a leftover pre-installer duplicate next to the fixed-id entry (a half-finished migration)
    dups = [c for c in cmds if isinstance(c, dict) and c is not entry and c.get("alias") == ALIAS]
    for c in dups:
        cmds.remove(c); data_dirty = True
        changes.append("remove a duplicate DW Save command (id %s)" % c.get("id", ""))
    ids = [c.get("id", "") for c in cmds if isinstance(c, dict)]

# hotkeys.json: the binding
if h is None:
    todos.append("%s does not parse (%s) - not touched; the hotkey was not set" % (hk_path, h_state))
elif isinstance(d, dict):
    our_key = PREFIX + FIXED_ID
    want = parse_combo(combo_arg) or parse_combo(DEFAULT_COMBO)
    want_str = combo(want)
    if old_id:
        old_key = PREFIX + old_id
        if old_key in h:
            if our_key not in h:
                h[our_key] = h.pop(old_key); hk_dirty = True
                changes.append("re-link the hotkey (%s) from the old command id to %s" % (combo(h[our_key]), FIXED_ID))
            else:
                h.pop(old_key); hk_dirty = True
                changes.append("remove the old command's hotkey binding (id %s)" % old_id)
    current = h.get(our_key)
    if not current:
        holders = [k for k, v in h.items() if k != our_key and holds(v, want)]
        if holders:
            todos.append("%s is already bound to %s - the installer will not take it; unbind it in Obsidian (Settings > Hotkeys), or choose another combo: --hotkey Mod+Alt+S" % (want_str, ", ".join(holders)))
        else:
            h[our_key] = want; hk_dirty = True
            changes.append("bind %s to DW Save" % want_str)
    else:
        if combo_arg and not holds(current, want):
            holders = [k for k, v in h.items() if k != our_key and holds(v, want)]
            if holders:
                todos.append("%s is already bound to %s - the installer will not take it; DW Save stays on %s" % (want_str, ", ".join(holders), combo(current)))
            else:
                h[our_key] = want; hk_dirty = True
                changes.append("change the DW Save hotkey from %s to %s" % (combo(current), want_str))
        elif not holds(current, parse_combo(DEFAULT_COMBO)):
            infos.append("DW Save stays bound to %s (not the documented %s - pass --hotkey to change it)" % (combo(current), DEFAULT_COMBO))
    for k in list(h):
        if k.startswith(PREFIX) and k[len(PREFIX):] not in ids:
            h.pop(k); hk_dirty = True
            changes.append("remove a hotkey bound to a Shell Commands entry that no longer exists (id %s) - it did nothing" % k[len(PREFIX):])

for c in changes: print("change=" + c)
for t in todos: print("todo=" + t)
for i in infos: print("info=" + i)
if mode != "apply": sys.exit(0)

# --- apply ---
try:
    if cp_dirty: save(cp_path, cp)
    if data_dirty: save(data_path, d)
    if hk_dirty: save(hk_path, h)
except Exception as e:
    print("error=write failed: %s: %s" % (e.__class__.__name__, e)); sys.exit(1)
for w in written: print("written=" + w)
PY
}

# Read-only view (the --doctor seam; unchanged output).
inspect_plugin_config() {  # DATA_JSON HOTKEYS_JSON
  plugin_config inspect "$1" "$2"
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
        is_excluded "$repo" && { d_info "$(basename "$repo") is on the exclude list (not synced, by choice)"; listed=1; }
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
      grep -q '<string>--auto</string>' "$plist" 2>/dev/null || d_warn "the agent does not pass --auto (pre-installer plist) - scheduled runs are not marked in the log or status note; re-run --install"
      grep -q '<key>PATH</key>' "$plist" 2>/dev/null || d_warn "the agent sets no PATH (pre-installer plist) - launchd gives it /usr/bin:/bin only, so a Homebrew gh is invisible to scheduled runs; re-run --install"
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
      local lazy_state=""
      [ -f "$obs/plugins/lazy-plugins/data.json" ] && command -v python3 >/dev/null 2>&1 && lazy_state=$(python3 - "$obs/plugins/lazy-plugins/data.json" <<'PYL' 2>/dev/null
import json, sys
try:
    d = json.load(open(sys.argv[1], encoding="utf-8"))
    p = ((d.get("desktop") or {}).get("plugins") or {}).get("obsidian-shellcommands") or (d.get("plugins") or {}).get("obsidian-shellcommands") or {}
    print(p.get("startupType", "") if isinstance(p, dict) else "")
except Exception: print("")
PYL
)
      if grep -q '"obsidian-shellcommands"' "$obs/community-plugins.json" 2>/dev/null; then d_ok "plugin is enabled (community-plugins.json)"
      elif [ "$lazy_state" = "short" ] || [ "$lazy_state" = "long" ]; then d_ok "plugin is loaded by the Lazy Plugin Loader (startup: $lazy_state) - not in community-plugins.json by design"
      elif [ "$lazy_state" = "disabled" ]; then d_fail "plugin is set to Disabled in the Lazy Plugin Loader, which removes it from community-plugins.json on every launch - the hotkey does nothing until it loads; in Obsidian: Settings > Lazy Plugin Loader > Shell commands > Instant, then relaunch"
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
# Install mode (design Section 4; chunk 3) - one-command setup and repair.
# Every step checks before it writes, prints one plain line, and backs up any
# file it changes (<file>.dwsave-backup-<timestamp>, never overwritten). A
# second run on a healthy machine changes nothing and says so. --dry-run runs
# the same checks and prints what it WOULD change, writing nothing at all.
# Lines: [ok] already right  [done] changed  [dry] would change  [todo] needs
# you  [warn] left alone on purpose  [info].
# ---------------------------------------------------------------------------

INS_DONE=0; INS_TODO=0; INS_DRY=0
i_ok()   { echo " [ok]   $1"; }
i_todo() { INS_TODO=$((INS_TODO+1)); echo " [todo] $1"; }
i_warn() { echo " [warn] $1"; }
i_info() { echo " [info] $1"; }
i_head() { echo; echo "$1"; }
# i_act WHAT -> prints "[done] WHAT" and returns 0 (do it), or in --dry-run prints
# "[dry] would WHAT" and returns 1 (skip it). Use as: if i_act "..."; then <write>; fi
i_act() {
  if [ "$DRY_RUN" = true ]; then INS_DRY=$((INS_DRY+1)); echo " [dry]  would $1"; return 1; fi
  INS_DONE=$((INS_DONE+1)); echo " [done] $1"; return 0
}
# backup_file PATH -> copies PATH to PATH.dwsave-backup-<timestamp> (kept forever)
backup_file() {
  [ -f "$1" ] || return 0
  local dst="$1.dwsave-backup-$(date '+%Y%m%d%H%M%S')" n=0
  while [ -e "$dst" ]; do n=$((n+1)); dst="$1.dwsave-backup-$(date '+%Y%m%d%H%M%S')-$n"; done
  cp -p "$1" "$dst"
}
# confirm QUESTION -> 0 = yes. --yes answers yes; --dry-run answers yes (nothing is
# written anyway); otherwise asks on the terminal.
confirm() {
  [ "$ASSUME_YES" = true ] && return 0
  [ "$DRY_RUN" = true ] && return 0
  local ans
  printf '%s [y/N] ' "$1"
  read -r ans || ans=""
  case "$ans" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}
obsidian_running() { pgrep -x Obsidian >/dev/null 2>&1 || pgrep -x obsidian >/dev/null 2>&1; }

run_install() {
  local os; os=$(uname 2>/dev/null)
  local mode_word="install"; [ "$DRY_RUN" = true ] && mode_word="dry run (nothing will be written)"
  echo "DW Save $mode_word - $(ts)"

  # --- 0. where ---
  i_head "0. Vault"
  read_conf || true
  if ! resolve_vault || [ ! -d "$VAULT_ROOT" ]; then
    echo " [todo] vault root not found - run this from the Seed copy (<vault>/_DataWizard/Seed/Scripts/datawizard-sync.sh) or pass --vault <path>"
    exit 2
  fi
  if [ ! -d "$VAULT_ROOT/.obsidian" ]; then
    echo " [todo] $VAULT_ROOT has no .obsidian folder - is this the vault root? (pass --vault <path>)"
    exit 2
  fi
  i_ok "vault root: $VAULT_ROOT (from $VAULT_SOURCE)"
  local SEED_DIR="$VAULT_ROOT/_DataWizard/Seed" TARGET="$SCRIPT_ABS"
  if [ -f "$SEED_DIR/Scripts/datawizard-sync.sh" ]; then
    TARGET="$SEED_DIR/Scripts/datawizard-sync.sh"
    if [ "$TARGET" != "$SCRIPT_ABS" ]; then
      i_info "you are running a copy at $SCRIPT_ABS; Obsidian and the scheduler will be pointed at the Seed copy, which updates itself: $TARGET"
    fi
  else
    i_warn "no Seed copy of the script at $SEED_DIR/Scripts - Obsidian and the scheduler will point at this copy ($SCRIPT_ABS), which does not update itself"
  fi

  # --- 1. tools ---
  i_head "1. Tools"
  if command -v git >/dev/null 2>&1; then i_ok "git present ($(git --version 2>/dev/null | head -n 1))"
  else
    if [ "$os" = "Darwin" ]; then i_todo "git not found - run: xcode-select --install (Apple's dialog does the rest), then re-run this installer"
    else i_todo "git not found - install git, then re-run this installer"; fi
    echo; echo "DW Save install stopped: git is required."; exit 1
  fi
  if command -v gh >/dev/null 2>&1; then i_ok "gh present ($(gh --version 2>/dev/null | head -n 1))"
  elif command -v brew >/dev/null 2>&1; then
    if i_act "install the GitHub CLI with Homebrew (brew install gh - takes a minute)"; then
      if brew install gh >/dev/null 2>&1 && command -v gh >/dev/null 2>&1; then :
      else i_todo "brew install gh did not complete - run it yourself, then re-run this installer"; fi
    fi
  else
    if [ "$os" = "Darwin" ]; then i_todo "gh (GitHub CLI) not found and Homebrew is not installed - install Homebrew (brew.sh) and re-run, or install gh from cli.github.com"
    else i_todo "gh (GitHub CLI) not found - install it from cli.github.com, then re-run"; fi
  fi
  local SIGNED_IN=0
  if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then SIGNED_IN=1; i_ok "signed in to GitHub"
    elif [ "$ASSUME_YES" = true ]; then i_todo "not signed in to GitHub - run: gh auth login --web, then re-run this installer"
    elif i_act "sign you in to GitHub (gh auth login --web opens your browser)"; then
      if gh auth login --web && gh auth status >/dev/null 2>&1; then SIGNED_IN=1
      else i_todo "GitHub sign-in did not complete - run: gh auth login --web, then re-run this installer"; fi
    fi
  fi
  local HAVE_PY=0
  if command -v python3 >/dev/null 2>&1; then HAVE_PY=1; i_ok "python3 present (needed to edit the Obsidian plugin config)"
  else i_todo "python3 not found - the Obsidian wiring (step 5) is skipped; on a Mac it comes with the Xcode Command Line Tools (xcode-select --install)"; fi

  # --- 2. repos ---
  i_head "2. Repos to sync (~/.datawizard-sync.conf)"
  local HAD_CONF=0; [ -f "$CONF" ] && HAD_CONF=1
  local KEEP=() DEAD=() NEW=() EXC=() p e repo gitdir listed found_root=0
  # existing entries: kept when they still resolve to a repo with an origin
  for p in "${PROJECTS[@]}"; do
    p="${p%/}"
    if [ ! -d "$p" ]; then DEAD+=("$p (folder not found)")
    elif ! git -C "$p" rev-parse --is-inside-work-tree >/dev/null 2>&1; then DEAD+=("$p (not a git repo)")
    elif ! git -C "$p" remote get-url origin >/dev/null 2>&1; then DEAD+=("$p (no origin remote - nothing to push to)")
    else KEEP+=("$p"); fi
  done
  # exclude list: the conf's, plus --exclude, plus the vault root itself unless it is
  # already a synced entry (design 8.1 ruling: never start pushing the whole vault)
  for e in "${EXCLUDES[@]}"; do EXC+=("${e%/}"); done
  for e in "${EXCLUDE_ARGS[@]}"; do EXC+=("${e%/}"); done
  in_list() { local x="$1"; shift; local y; for y in "$@"; do [ "$y" = "$x" ] && return 0; done; return 1; }
  # discovery to depth 4 (the doctor's rule): skip .obsidian/.trash/node_modules, skip no-origin
  while IFS= read -r gitdir; do
    [ -n "$gitdir" ] || continue
    repo="${gitdir%/.git}"
    case "$repo" in */.obsidian/*|*/.trash/*|*/node_modules/*|*/.obsidian|*/.trash|*/node_modules) continue ;; esac
    git -C "$repo" remote get-url origin >/dev/null 2>&1 || continue
    in_list "$repo" "${KEEP[@]}" && continue
    if [ "$repo" = "$VAULT_ROOT" ]; then
      found_root=1
      in_list "$repo" "${EXC[@]}" || EXC+=("$repo")
      continue
    fi
    in_list "$repo" "${EXC[@]}" && continue
    NEW+=("$repo")
  done <<EOF_FIND
$(find "$VAULT_ROOT" -maxdepth 4 -name .git \( -type d -o -type f \) -prune 2>/dev/null | sort)
EOF_FIND
  for p in "${KEEP[@]}"; do i_ok "$(basename "$p") - kept ($p)"; done
  for p in "${DEAD[@]}"; do i_warn "dropped from the list: $p - the old list is kept in a backup next to the conf"; done
  [ "$found_root" -eq 1 ] && i_info "the vault itself is a git repo - it is NOT synced by DW Save (kept on the exclude list); list it in the conf yourself if you really want the whole vault pushed"
  for p in "${EXC[@]}"; do [ "$p" = "$VAULT_ROOT" ] || i_info "$(basename "$p") is on the exclude list - not synced, by choice ($p)"; done
  if [ ${#NEW[@]} -gt 0 ]; then
    echo " [info] found ${#NEW[@]} repo(s) in the vault that are not in the list yet:"
    for p in "${NEW[@]}"; do echo "          $(basename "$p")  ($(git -C "$p" remote get-url origin 2>/dev/null))  $p"; done
    [ "$DRY_RUN" = true ] && i_info "the real install asks before adding them (--yes skips the question)"
    if confirm "        Add them? Every repo on the list is committed and pushed on each save."; then
      for p in "${NEW[@]}"; do KEEP+=("$p"); done
    else
      i_warn "not added - re-run to add them later, or keep them out for good with: --exclude \"<path>\""
    fi
  fi
  if [ ${#KEEP[@]} -eq 0 ]; then
    i_todo "no repos to sync - clone a shared project into the vault (or check that its origin is set) and re-run"
  fi
  # push access, read-only: can we reach each origin with the credentials git will use?
  for p in "${KEEP[@]}"; do
    if GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND="ssh -o BatchMode=yes" git -C "$p" ls-remote --exit-code origin HEAD >/dev/null 2>&1; then
      i_ok "$(basename "$p"): GitHub reachable with your saved credentials"
    else
      i_warn "$(basename "$p"): could not reach its origin - offline, or git is not authorized to push; if you are online, run: gh auth setup-git   (lets git use your GitHub sign-in; this installer does not change git's settings itself)"
    fi
  done
  # write the conf only when its content changes
  local NEWCONF="" nl='
'
  NEWCONF="# DW Save repo list - one repo path per line; every repo here is committed, pulled and pushed on each save.${nl}# Lines starting with \"exclude:\" are repos found in the vault that are deliberately NOT synced.${nl}# Re-run 'datawizard-sync.sh --install' after cloning a new shared project; it adds the repo here (and asks first)."
  for p in "${EXC[@]}"; do NEWCONF="$NEWCONF${nl}exclude: $p"; done
  for p in "${KEEP[@]}"; do NEWCONF="$NEWCONF${nl}$p"; done
  if [ -f "$CONF" ] && [ "$(cat "$CONF")" = "$NEWCONF" ]; then
    i_ok "repo list unchanged ($CONF)"
  else
    local what="write the repo list ($CONF)"; [ "$HAD_CONF" -eq 1 ] && what="update the repo list ($CONF; the previous version is backed up next to it)"
    if i_act "$what"; then
      backup_file "$CONF"
      printf '%s\n' "$NEWCONF" > "$CONF"
    fi
  fi

  # --- 3. commit guard ---
  i_head "3. Commit guard (pre-commit hook in every synced repo)"
  local hook_src="" installer="" hooks_dir hp live marker
  [ -f "$SEED_DIR/Scripts/hooks/pre-commit" ] && hook_src="$SEED_DIR/Scripts/hooks/pre-commit"
  [ -z "$hook_src" ] && [ -f "$(dirname "$SCRIPT_ABS")/hooks/pre-commit" ] && hook_src="$(dirname "$SCRIPT_ABS")/hooks/pre-commit"
  [ -n "$hook_src" ] && [ -f "$(dirname "$hook_src")/../install-git-hooks.sh" ] && installer="$(dirname "$hook_src")/../install-git-hooks.sh"
  if [ -z "$hook_src" ]; then
    i_todo "the Seed's hook (Scripts/hooks/pre-commit) was not found - update the Seed (bash _DataWizard/Seed/update_seed.sh) and re-run; commit guard skipped"
  else
    for p in "${KEEP[@]}"; do
      hp=$(git -C "$p" config core.hooksPath 2>/dev/null)
      if [ -n "$hp" ]; then
        case "$hp" in /*) hooks_dir="$hp" ;; *) hooks_dir="$p/$hp" ;; esac
        live="$hooks_dir/pre-commit"
        if [ -f "$live" ] && cmp -s "$hook_src" "$live"; then i_ok "$(basename "$p"): commit guard installed (via core.hooksPath=$hp)"
        elif [ -f "$live" ]; then i_todo "$(basename "$p"): git runs a team hook here ($live, via core.hooksPath=$hp) and it differs from the Seed's - this installer does not edit tracked team files; update that file in the repo (copy from $hook_src)"
        else i_todo "$(basename "$p"): core.hooksPath=$hp is set but $live does not exist - add the Seed's Scripts/hooks/pre-commit there (a tracked team file; this installer does not write it)"; fi
        continue
      fi
      live="$p/.git/hooks/pre-commit"
      if [ -f "$live" ] && cmp -s "$hook_src" "$live"; then
        i_ok "$(basename "$p"): commit guard installed"
      elif [ -f "$live" ] && ! grep -q "DataWizard commit guard" "$live" 2>/dev/null; then
        i_warn "$(basename "$p"): has its own pre-commit hook (not DataWizard's) - left alone; to use the DW guard, merge $hook_src into it yourself"
      else
        local why="install the commit guard in $(basename "$p")"; [ -f "$live" ] && why="update the commit guard in $(basename "$p") to the Seed's version (old one backed up next to it)"
        if i_act "$why"; then
          backup_file "$live"
          if [ -n "$installer" ]; then bash "$installer" "$p" >/dev/null 2>&1
          else mkdir -p "$p/.git/hooks"; cp "$hook_src" "$live"; chmod +x "$live"
               mkdir -p "$p/.git/info"; touch "$p/.git/info/exclude"; grep -qxF 'SYNC-BLOCKED.md' "$p/.git/info/exclude" || echo 'SYNC-BLOCKED.md' >> "$p/.git/info/exclude"; fi
          cmp -s "$hook_src" "$live" || i_todo "$(basename "$p"): the hook did not land at $live - run: bash \"$installer\" \"$p\""
        fi
      fi
    done
  fi

  # --- 4. safety net ---
  i_head "4. Safety net (scheduled save every $INTERVAL_MIN minutes)"
  if [ "$os" != "Darwin" ]; then
    i_info "scheduled saves are set up on macOS only in this version (Windows ships with the PowerShell port) - skipped"
  else
    local plist="$HOME/Library/LaunchAgents/com.datawizard.sync.plist" label="com.datawizard.sync" want="$HOME/.dwsave-plist-want.$$"
    cat > "$want" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$label</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$TARGET</string>
        <string>--auto</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>StartInterval</key>
    <integer>$((INTERVAL_MIN * 60))</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/datawizard-sync.out</string>
    <key>StandardErrorPath</key>
    <string>/tmp/datawizard-sync.err</string>
</dict>
</plist>
PLIST
    local loaded=0 need_write=1
    if launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1 || launchctl list 2>/dev/null | grep -q "$label"; then loaded=1; fi
    [ -f "$plist" ] && cmp -s "$want" "$plist" && need_write=0
    if [ "$need_write" -eq 0 ] && [ "$loaded" -eq 1 ]; then
      i_ok "launchd agent installed and loaded ($plist)"
    else
      local ok_lint=1
      if command -v plutil >/dev/null 2>&1 && ! plutil -lint "$want" >/dev/null 2>&1; then ok_lint=0; fi
      if [ "$ok_lint" -eq 0 ]; then
        i_todo "the generated launchd plist does not validate (plutil -lint) - not installed; this is a bug in the installer, please report it with: plutil -lint \"$want\""
        want=""   # keep the file for the report
      else
        local what="install the launchd agent ($plist: runs the Seed copy with --auto every $INTERVAL_MIN min and at login)"
        if [ "$need_write" -eq 0 ]; then what="load the launchd agent (file was present but not loaded)"
        elif [ -f "$plist" ]; then what="update the launchd agent (old plist backed up next to it; adds --auto, the PATH fix, and the Seed path)"; fi
        if i_act "$what"; then
          if [ "$need_write" -eq 1 ]; then
            mkdir -p "$HOME/Library/LaunchAgents"; backup_file "$plist"; cp "$want" "$plist"
          fi
          launchctl bootout "gui/$(id -u)/$label" >/dev/null 2>&1 || true
          if ! launchctl bootstrap "gui/$(id -u)" "$plist" >/dev/null 2>&1; then launchctl load "$plist" >/dev/null 2>&1 || true; fi
          if launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1 || launchctl list 2>/dev/null | grep -q "$label"; then
            i_info "the agent runs a first scheduled save right away (RunAtLoad) - a status note appears in _DataWizard/ shortly"
          else
            i_todo "the plist was written but launchd did not load it - log out and back in, then run --doctor; if it is still not loaded: launchctl load \"$plist\""
          fi
        fi
      fi
    fi
    [ -n "$want" ] && rm -f "$want"
  fi

  # --- 5. Obsidian wiring ---
  i_head "5. Obsidian (Shell Commands plugin, DW Save command, hotkey)"
  local obs="$VAULT_ROOT/.obsidian" pdir="$VAULT_ROOT/.obsidian/plugins/obsidian-shellcommands" WIRED=0
  if [ ! -d "$pdir" ]; then
    i_todo "the Shell Commands plugin is not installed - in Obsidian: Settings > Community plugins > Browse > install 'Shell commands' (no need to enable or configure it), then re-run this installer; it finishes the rest"
  elif [ "$HAVE_PY" -eq 0 ]; then
    i_todo "python3 is needed to edit the plugin config safely - skipped (see step 1)"
  else
    i_ok "plugin folder present ($(grep -o '"version": *"[^"]*"' "$pdir/manifest.json" 2>/dev/null | head -n 1 | sed 's/.*: *//' | tr -d '"'))"
    local k v PLAN_CHANGES=() PLAN_TODOS=() PLAN_INFOS=() PLAN_ERR="" PLAN_RAN=0
    while IFS='=' read -r k v; do
      case "$k" in data_parse) PLAN_RAN=1 ;; change) PLAN_CHANGES+=("$v") ;; todo) PLAN_TODOS+=("$v") ;; info) PLAN_INFOS+=("$v") ;; error) PLAN_ERR="$v" ;; esac
    done <<EOF_PLAN
$(plugin_config plan "$pdir/data.json" "$obs/hotkeys.json" "$pdir/manifest.json" "$obs/community-plugins.json" "$TARGET" "$HOTKEY_ARG" "$obs/plugins/lazy-plugins/data.json" 2>/dev/null)
EOF_PLAN
    for v in "${PLAN_INFOS[@]}"; do i_info "$v"; done
    for v in "${PLAN_TODOS[@]}"; do i_todo "$v"; done
    if [ "$PLAN_RAN" -eq 0 ]; then
      i_todo "the plugin config could not be inspected (the python3 helper failed) - nothing was changed; run --doctor and report this"
    elif [ ${#PLAN_CHANGES[@]} -eq 0 ]; then
      i_ok "plugin enabled, DW Save command present with the balloon on, hotkey bound - nothing to change"
    else
      local go=1
      if [ "$DRY_RUN" = true ] && obsidian_running; then
        i_info "Obsidian is running - the real install asks you to quit it before making the changes below (it writes these settings back from memory otherwise)"
      elif [ "$DRY_RUN" != true ] && obsidian_running; then
        if [ "$ASSUME_YES" = true ]; then
          go=0
          for v in "${PLAN_CHANGES[@]}"; do i_todo "would $v - but Obsidian is running and would overwrite the change from memory; quit Obsidian fully (Cmd+Q) and re-run this installer"; done
        else
          echo " [info] Obsidian is running. It keeps these settings in memory and writes them back over any edit, so the changes below are only safe while it is closed."
          local tries=0 ans
          while obsidian_running && [ $tries -lt 3 ]; do
            tries=$((tries+1))
            printf '        Quit Obsidian fully (Cmd+Q), then press Enter here (or type s to skip the Obsidian step): '
            read -r ans || ans="s"
            case "$ans" in s|S) break ;; esac
          done
          if obsidian_running; then
            go=0
            for v in "${PLAN_CHANGES[@]}"; do i_todo "would $v - skipped because Obsidian is still running; quit it and re-run this installer"; done
          fi
        fi
      fi
      if [ "$go" -eq 1 ]; then
        for v in "${PLAN_CHANGES[@]}"; do i_act "$v" || true; done
        if [ "$DRY_RUN" != true ]; then
          local WROTE=() APPLY_ERR=""
          while IFS='=' read -r k v; do
            case "$k" in written) WROTE+=("$v") ;; error) APPLY_ERR="$v" ;; esac
          done <<EOF_APPLY
$(plugin_config apply "$pdir/data.json" "$obs/hotkeys.json" "$pdir/manifest.json" "$obs/community-plugins.json" "$TARGET" "$HOTKEY_ARG" "$obs/plugins/lazy-plugins/data.json" 2>/dev/null)
EOF_APPLY
          if [ -n "$APPLY_ERR" ] || [ ${#WROTE[@]} -eq 0 ]; then
            i_todo "the plugin config could not be written (${APPLY_ERR:-no file written}) - nothing was changed; run --doctor and report this"
          else
            for v in "${WROTE[@]}"; do i_info "wrote $v (previous version backed up next to it)"; done
            WIRED=1
          fi
        fi
      fi
    fi
  fi

  # --- 6. wrap up ---
  echo
  if [ "$DRY_RUN" = true ]; then
    echo "DW Save dry run: $INS_DRY change(s) would be made, $INS_TODO item(s) would need you. Nothing was written. Run with --install to apply."
    exit 0
  fi
  if [ "$WIRED" -eq 1 ]; then
    echo "Next: open Obsidian, then press Cmd+Shift+S (or your DW Save hotkey). You should see a 'DW Saved' balloon."
    echo "      If you do not, run: bash \"$TARGET\" --doctor"
  elif [ "$INS_DONE" -eq 0 ] && [ "$INS_TODO" -eq 0 ]; then
    echo "DW Save is already fully installed - nothing changed."
    exit 0
  fi
  if [ "$INS_TODO" -gt 0 ]; then
    echo "DW Save install: $INS_DONE change(s) made, $INS_TODO item(s) need you (marked [todo] above). Re-run this installer after; it only touches what is still missing."
    exit 1
  fi
  echo "DW Save install: $INS_DONE change(s) made, nothing left to do. Run --doctor any time to check."
  exit 0
}

usage() {
  sed -n '2,22p' "$SCRIPT_PATH" | sed 's/^# \{0,1\}//'
}

# ---------------------------------------------------------------------------
# Entry
# ---------------------------------------------------------------------------

main() {
  MODE="sync"
  VAULT_ARG=""
  AUTO_RUN=false
  DRY_RUN=false; ASSUME_YES=false; EXCLUDE_ARGS=(); HOTKEY_ARG=""; INTERVAL_MIN=120
  while [ $# -gt 0 ]; do
    case "$1" in
      --install) MODE="install" ;;
      --dry-run) MODE="install"; DRY_RUN=true ;;
      --doctor)  MODE="doctor" ;;
      --auto)    AUTO_RUN=true ;;
      --yes|-y)  ASSUME_YES=true ;;
      --vault)   shift; VAULT_ARG="${1:-}"; [ -n "$VAULT_ARG" ] || { echo "DW Save: --vault needs a path"; exit 2; } ;;
      --vault=*) VAULT_ARG="${1#--vault=}" ;;
      --exclude) shift; [ -n "${1:-}" ] || { echo "DW Save: --exclude needs a path"; exit 2; }; EXCLUDE_ARGS+=("$1") ;;
      --exclude=*) EXCLUDE_ARGS+=("${1#--exclude=}") ;;
      --hotkey)  shift; HOTKEY_ARG="${1:-}"; [ -n "$HOTKEY_ARG" ] || { echo "DW Save: --hotkey needs a combo like Mod+Alt+S"; exit 2; } ;;
      --hotkey=*) HOTKEY_ARG="${1#--hotkey=}" ;;
      --interval) shift; INTERVAL_MIN="${1:-}" ;;
      --interval=*) INTERVAL_MIN="${1#--interval=}" ;;
      -h|--help) usage; exit 0 ;;
      *) echo "DW Save: unknown option '$1' (try --help)"; exit 2 ;;
    esac
    shift
  done
  case "$INTERVAL_MIN" in ''|*[!0-9]*|0) echo "DW Save: --interval needs a number of minutes (got '$INTERVAL_MIN')"; exit 2 ;; esac
  SCRIPT_ABS="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd)/$(basename "$SCRIPT_PATH")"

  case "$MODE" in
    doctor)  run_doctor ;;
    install) run_install ;;
    *)       run_sync ;;
  esac
}

main "$@"
