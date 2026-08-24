---
created: 2026-08-18
edit_log:
  - DW-S273 2026-08-18 - created from the Cowork Build Environment Guide FR (VC
    S23-S34 build cluster + Weave sandbox/network items + DW S221-S230
    device-bridge items + RW S51 staged-path item); seeded from the field-tested
    VibeCut Build Environment Notes
  - "DW-S284 2026-08-24 - Shell quirks: Write-tool overwrite-unread refusal as
    concurrency guard (S208); zsh inline-comment handoff gotcha (S204)
    (meta-learning review S198-S209)"
  - "DW-S284 2026-08-24 - Device Bridge: Cowork folder connections are
    exact-path, no sibling exposure, break on move (S216; meta-learning review
    S210-S220)"
  - DW-S284 2026-08-24 - zsh handoff bullet extended with the bash heredoc
    delivery recipe (S252; meta-learning review S247-S255)
operator: Andrew
scope: seed
title: Cowork Build Environment
type: guide
updated: 2026-08-24
---
# Cowork Build Environment

> Guide for Claude instances building real codebases from inside Cowork -- a mounted folder plus a Linux sandbox. Covers the git-on-mount build workflow, language toolchains, shell and file-tool quirks, network workarounds, rendering, and the device bridge.
>
> **Scope.** Obsidian MCP failure modes, FUSE-mount write/delete restrictions, and the general write-verification protocol live in **MCP Reliability and Write Verification** -- this guide cross-references rather than restates them. Chrome MCP and web-page reading recipes live in **Chrome MCP and Web Tool Behaviors**.
>
> Part of the **Platform and Environment Behaviors** guide cluster -- see `GUIDES.md`.

Field provenance: the core cluster was re-learned session after session across a real Electron-app build (the git-on-mount lock failure alone recurred six times before becoming routine). This guide is the standing home so the next build session finds these without re-deriving them.

## Git on a Cowork-Mounted Folder

The MCP Reliability guide documents the underlying restriction (the sandbox can create but not unlink files on the mount, so working-tree git ops orphan lock files). Build-workflow consequences:

- **Clear locks after every commit batch.** Commits can succeed while leaving stale `.git/index.lock`, `HEAD.lock`, and tmp object files that `rm` refuses ("Operation not permitted"). Clear via the file-delete permission path (e.g. `allow_cowork_file_delete` + `rm`, or the rename-aside fallback in the MCP Reliability guide), then verify with `git fsck`. Make this routine, not incident response. (Source: VC S27-S33, 6 recurrences)
- **The sandbox has no GitHub credentials and can never `git push`.** Pushes must run on the user's machine. A session log claiming commits were "pushed" is only trustworthy if the push actually ran there -- verify with `git status -sb` (ahead/behind), never assume. One session found three commits marked "pushed" that had never reached origin. (Source: VC S31)
- **`git commit -am` only stages modified tracked files** -- new files stay untracked and silently uncommitted. Use `git add -A`. One first-try commit left a whole session's new files behind. (Source: VC S34)
- **Cloning into a Dropbox-synced folder fails** ("unable to unlink .git/config.lock") because Dropbox locks files mid-sync. Clone to `/tmp` first, then `cp -R` into place. (Source: VC S24)

## Node / npm / Electron

- **Never share `node_modules` across platforms.** `npm install` in the Linux sandbox against a Mac-mounted `node_modules` strips the other platform's os/cpu-gated native deps (rollup/esbuild), breaking the Mac side until `npm ci`. Verify builds in an isolated `/tmp` copy (below); a `tsc` typecheck needs no natives and runs safely on the mount. (Source: VC S33)
- **Backgrounded installs die.** Each bash call runs in its own `bwrap --unshare-pid --die-with-parent` namespace, so `npm ci &` dies when the call returns. Run long installs foreground; the npm cache persists across calls, so they converge in 1-2 passes. (Source: VC S31)
- **Dev watchers miss external edits on the mount.** electron-vite's dev watcher kept serving a stale build after files were edited via file tools. Restart the dev server after edits; for main/preload changes do a clean restart (`rm -rf out node_modules/.vite && npm run dev`). (Source: VC S30, S34)

## Python and Packages

- **`pip` has no package index from the sandbox in some configurations (HTTP 403).** numpy is typically preinstalled; graph/scientific extras (`networkx`, `igraph`, `scipy`) may not be installable. Hand-roll in numpy or write the script for local (native) execution. Packages installed on the user's machine are invisible -- the sandbox is an isolated Linux environment. (Source: Weave, 2026-06/08. Other configurations allow installs -- probe before planning around the restriction.)
- **`str.lstrip("www.")` strips a character *set*, not a prefix** -- it corrupted `weave-...` to `eave-...` and silently poisoned dedup keys. Use `re.sub(r"^www\.", "", s)`. Dry-run-before-apply is what caught it. (Source: DW S224)

## Shell and File-Tool Quirks

- **bash `timeout_ms` caps at 45000, and a validation failure rejects the ENTIRE call** -- including any file writes packed into the same command string. Write files with the Write tool, not heredocs, when a call might fail validation. (Source: Weave, 2026-06/08)
- **The Edit tool requires a prior Read-tool read.** A `cat` via bash does not register; the Edit fails. (Source: VC S23)
- **The Write tool refuses to overwrite an existing file it has not Read** -- but creates genuinely new files without complaint. This is a feature under concurrency: it is what stopped one session from clobbering a sibling session's freshly written claim stub. Treat the refusal as a signal to re-read (the file may have changed under you), not as an error to force past. See the concurrency practices in the MCP Reliability guide. (Source: DataWizard, 2026-06)
- **No trailing `#` comments in commands handed to the user's Terminal.** zsh interactive shells (the macOS default) do not honor inline `#` comments unless `INTERACTIVE_COMMENTS` is set; bash does. A handed-off command like `git pull  # then verify` reaches zsh with `#`, `then`, `verify` as arguments, and zsh also breaks on `()` inside a pasted comment line. Put explanations on their own line above the command, and hand multi-line blocks over as a heredoc - `bash <<'SH'` ... `SH` - so the whole block runs under bash regardless of the operator's interactive shell. (Source: DataWizard, 2026-06, 2026-08)
- **`bash wc -w` returns 0 for cloud-synced files** the mount serves as cloud-only placeholders. Use `obsidian:get_notes_info` for sizes instead. (Source: VC S32)
- **Staged large-file paths do not survive a session interruption/reclaim.** A staged tool-results directory was gone after a session gap; re-fetching was cheap and deterministic. Re-fetch instead of hunting for the old path. (Source: RW S51)

## Network and GitHub Data

- **WebFetch rate-limits (HTTP 429).** Space calls out; lean on WebSearch snippets when throttled. (Source: Weave, 2026-06/08)
- **GitHub REST via web fetch is unreliable:** `api.github.com` returns empty content in some Cowork configurations, and unauthenticated REST shares a rate-limited egress (60/hr, often exhausted). Reliable paths, in order: `raw.githubusercontent.com` for file content (fetches even when the API is throttled), the repo's HTML pages for stars/forks/issues/license, Chrome `get_page_text` on an org's `/repositories` page for listings, or a user-run `gh api ... | paste`. For pulling a repo's files wholesale, a shallow `git clone --depth 1` beats fetching (see tools-research). (Source: VC S25; Weave, independent)
- **GitBook sources are agent-friendly:** append `.md` to any page URL for clean markdown; `llms.txt` is a full index; `?ask=` answers questions against the docs. (Source: Weave, 2026-06/08)
- **Filing GitHub issues via pre-filled `issues/new?title=&body=` URLs** (URL-encode the body, open in the user's authed browser, human submits) is a robust, low-brittleness alternative to JS form-filling -- and keeps the irreversible public action on a third party's repo in human hands. The `return_to` param survives a login redirect. (Source: DW S230)

## Rendering (HTML to PDF)

- **Use WeasyPrint, not headless Chromium.** Headless Chromium / Playwright segfaults in the Cowork sandbox. WeasyPrint (via pip, where installable) renders HTML to PDF faithfully, including `@font-face`. Caveat: WeasyPrint ignores page breaks *inside* flex containers -- keep break-sensitive content out of flex layouts. (Source: RW S31.5)

## Device Bridge

- **`device_commit_files` rejects an explicit `expectedMtimeMs: null`** -- omit the field entirely when no mtime guard is wanted. (Source: DW S229)
- **`Control_Chrome` proxy: `list_tabs` is reliable; `get_page_content` intermittently errors** ("Google Chrome is not running") even with a tab open. Verify page state via `list_tabs` URL params instead of retrying. (Source: DW S230)
- **Cowork connects folders individually, by exact path.** Connecting a parent folder does not expose its siblings, and moving or renaming a connected folder on disk breaks its connection until it is re-added in the desktop app. If a session suddenly cannot see a folder it could see before, check whether the folder moved before debugging the tools. (Source: DataWizard, 2026-07)

## Verification Discipline for Builds

- **Minimum verification for a handoff = typecheck + build + smoke test.** Typecheck plus production build cannot catch runtime init failures; a headless jsdom component-init test reproduced an app black-screen in seconds. Include a mounted-component smoke test. (Source: VC S27)
- **The isolated `/tmp` verification loop:** copy the source minus `node_modules` to `/tmp`, `npm ci --ignore-scripts` (skip heavy binaries, e.g. `ELECTRON_SKIP_BINARY_DOWNLOAD=1`), then run tests + typecheck + build there. The host machine never runs unverified code, and its `node_modules` stays pristine. (Source: VC S28, S33)
- **Cloud-green is not host-green for environment-coupled globals.** A suite passing on the sandbox's Node can fail on the host's newer Node (e.g. Node 25+ ships built-in `localStorage` globals that shadow jsdom's in test workers). Verify env-coupled globals on the actual host runtime, not only in the cloud. (Source: VC S64)
- **Unit + component green is not app-works.** Hundreds of passing pure-function and component tests can coexist with an app that crashes on first real interaction, because nothing renders the real app against real state. Keep an integration/smoke tier that does. (Source: VC S62)
- **Verify your writes actually landed.** The recurring failure shape: an operation reports success but the work did not persist -- no push creds (commits never reach origin), `commit -am` skipping untracked files, stale-lock-blocked commits. Before trusting a git/build write: `git status -sb` (ahead/behind + untracked), `git fsck` (lock/object health), and confirm the push ran on the host. Mirrors Working Rule 5 and the MCP Reliability guide's verification protocol. (Source: VC S27-S34, cross-cutting)

## See Also

- **MCP Reliability and Write Verification** -- FUSE-mount restrictions, Obsidian MCP failure modes, write verification
- **Chrome MCP and Web Tool Behaviors** -- driving external sites, client-rendered page reading
- **Git Hook and CI Behaviors** -- where guard/automation scripts run across a repo's environments
- **Cowork Scheduled Tasks** -- unattended-run requirements
