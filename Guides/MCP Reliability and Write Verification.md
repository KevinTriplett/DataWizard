---
title: MCP Reliability and Write Verification
type: guide
scope: seed
created: '2026-05-03'
updated: '2026-08-14'
edit_log:
  - "DW-S191 2026-06-21: planted sandbox git-write limitation"
  - DW-S195 2026-06-22 - joined the Platform and Environment Behaviors cluster
    (pointer)
  - DW-S198 2026-06-23 - verify-after-claim session-claiming rule
  - DW-S199 2026-06-23 - sandbox SQLite-write limitation (disk I/O error on FUSE
    mount)
  - RG-S4 2026-07-25 - planted the update_frontmatter merge:true array-wipe
    failure mode; sandbox mount-path correction to RW S53; cross-mount mv
    duplicate hazard
  - "DW-S227 2026-08-01 - Jay FR batch item a: which-server header,
    version-pinning section, search_notes positive note, move_note EISDIR entry"
  - DW-S235 2026-08-04 - transport-502 verify-before-retry section
    (must-have-changed-field verification rule)
  - DW-S243 2026-08-05 - planted 11 env-review items (bridge drops/hangs,
    read-overflow ceiling, in-app-rename drift + file-not-found-is-real,
    Glob-vs-mount caveat, device_stage_files verify path, mcpvault params, mount
    rotation + diff bulk-verify, shell-divider + edit_file gotchas, bulk-python
    frontmatter); absorbed the Rename Wikilink Drift / read_multiple_notes
    Overflow FR
  - DW-S245 2026-08-05 - device_bash vs filesystem-MCP/device_list_dir
    path-namespace split (write-verification implication)
  - "DW-S246 2026-08-05 - meta-learning review S221-S230: obsidian tools are
    .md-only, scripts via device shell / filesystem tools"
  - "DW-S253 2026-08-07 - sandbox git working-tree lock nuance: git status
    orphans index.lock; nested-repo self-heal via S252 sweep vs root no-healer;
    rename-aside recovery"
  - "DW-S257 2026-08-08 - array-wipe entry extended: transcription-drift variant
    (copy array values verbatim from the fresh read, never retype)"
  - DW-S263 2026-08-10 - patch_note session-wide bogus 'oldString cannot be
    empty' failure mode + filesystem edit_file fallback
  - RW-S68 2026-08-14 - rename-on-mount inconsistency caveat (RW S46/S67 vs DW
    S182/S253); cloud-container overflow-recovery nuance (saved tool-result
    readable by cloud Bash)
---
# MCP Reliability and Write Verification

> Guide for Claude instances using the Obsidian MCP to write vault content. Covers known failure modes, verification protocol, and concurrency practices.
>
> **Which server this describes.** The failure modes below were observed with `@bitbonsai/mcpvault` as the Obsidian MCP server. They are not specific to the Local REST API built-in MCP, which behaves differently. If you run a different Obsidian MCP server, expect a different failure profile -- treat these gotchas as calibrated to mcpvault unless noted otherwise, and pin a known-good version (see Version Pinning and npx Caching below).
>
> Part of the **Platform and Environment Behaviors** guide cluster -- see `GUIDES.md`.

## Known Issues

As of May 2026, the Obsidian MCP has intermittent reliability issues when multiple Cowork instances access the same vault simultaneously. Three failure modes have been observed:

**Ghost writes.** `write_note` returns "Successfully wrote note" but the file never appears on the filesystem. The MCP may then serve the ghost content back via `read_note` and `list_directory` from its cache, making it appear as though the write succeeded even on verification. This has been confirmed with `write_note`, `patch_note`, and `update_frontmatter` -- all three can return success without persisting.

**Phantom reads.** `read_note` and `list_directory` return content for files that do not exist on the filesystem. This was observed when one instance read a full session log entry (with correct frontmatter and internally consistent content) for a file that was not present on disk. The phantom content was also visible in `list_directory` results.

**Stale reads.** After a successful `patch_note`, a subsequent `read_note` on the same file may return the pre-patch version. This may overlap with the phantom read issue (the MCP serving cached pre-patch content).

**Frontmatter wipe via merge: false.** `update_frontmatter` with `merge: false` replaces the entire frontmatter -- any field you omit is deleted. Always use `merge: true` (the default) unless intentionally replacing the full schema. If you must use `merge: false`, re-read frontmatter first and include every field.

**Array wipe via merge: true (the sneaky one).** `merge: true` merges at the **top level of keys only**. Any array value you pass **replaces** the existing array wholesale -- it does not append. This silently destroys history on exactly the two fields agents update most often, `edit_log` and `tags`, and unlike the `merge: false` case there is no obvious "I am replacing everything" signal to make you cautious. Passing `{"edit_log": ["DW-S200 2026-07-25"]}` on a file with twenty prior entries leaves it with one.

Rule: **before stamping any array field, re-read the file's frontmatter** (`get_frontmatter` is cheapest) and pass the complete list with your new item appended. Never pass a bare one-item array to a file that may already have entries. Scalars (`updated`, `status`, `operator`) are safe to pass alone.

Verify after any array write by counting entries:

```bash
awk '/^edit_log:/{f=1;next}/^[a-z_]+:/{f=0}f&&/^  - /{c++}END{print c+0}' "file.md"
```

A count of 1 where there should be many means the array was clobbered -- restore from your pre-write read. Note that shell files legitimately carry no `edit_log` (they are exempt per [[YAML Schema]]), so 0 on a `0.2 Session Log` shell is correct, not damage. Grounding: RG S4 (2026-07-25) wiped 21 entries from `0.2 Session Log - ReWoven` and 9 from `0.3 Decision Log - ReWoven` this way. Both were recoverable **only because the full arrays happened to still be in the session's context** from reads minutes earlier -- with a fresh context, or a compaction in between, the history would have been unrecoverable short of a backup. Treat a bare array stamp as a destructive operation. And when re-supplying the full array (e.g. to append one `edit_log` entry), copy the existing values **verbatim from the fresh read** - retyping them invites transcription drift that silently rewrites history (field-caught: a paraphrased historical entry was restored only because the pre-write read was still in context; diff the written array against the read one before moving on).

## Transport 502s: Verify Before Retry, Against a Must-Have-Changed Field

When the MCP runs across a remote bridge (e.g. a cloud Cowork session proxying to a desktop MCP server), write calls can fail with an HTTP 502 from the bridge transport rather than from the MCP server itself. The 502 masks either outcome: the write may or may not have landed. Observed 4 times in one day across two projects (2026-08), affecting `write_note`, `patch_note`, and `update_frontmatter`; in all four cases verification showed the write had NOT landed and a single retry succeeded -- but a blind retry of a `patch_note` that HAD landed would duplicate content.

Rules:

- **Never retry a 502'd write blind.** Verify first (filesystem tools preferred, per the Verification Protocol above), then retry once at most.
- **Verify against a field that MUST have changed** -- the new `edit_log` entry, the patched string, the new file. Never verify against a field that may already equal the target: `updated:` on a same-day edit is a false-positive check (it already held today's date before the write). This is the observed trap: the obvious field can be the wrong field.
- A 502 whose error body names the bridge/CDN zone (not the MCP server) indicates the transport layer -- swapping the Obsidian MCP server will not remove these; the verify-before-retry discipline is the durable mitigation.

## Bridge Drops and Hangs (Remote Transport)

Distinct from a 502 on a single write, the remote bridge itself can fail in two ways, both of which take out *all* MCP calls rather than corrupting one: a **tool-registry drop** (calls return "not found" immediately, no hang) and a **multi-minute hang** on a call. Both recover by quitting Claude Desktop from the tray and relaunching. A mid-session registry drop can also recover via `RefreshMcpTools` once the desktop app reconnects, without a full relaunch. Observed ~3x in one session with no partial writes -- verify-after-write held throughout, so a dropped or hung call is an availability problem, not silent corruption. (Source: Weave, 2026-08)

## Version Pinning and npx Caching

If you run mcpvault (or any MCP server) via `npx`, note that **npx caches server versions indefinitely** -- a config that names `@bitbonsai/mcpvault` with no version can silently keep running a months-old build long after fixes ship. Several 0.12.x releases carry reliability-relevant fixes (patch_note `$`-pattern corruption fixed in 0.12.2; YAML parser swapped to the `yaml` package in 0.12.1; `.trash/` exclusion in 0.12.3), so an unpinned old build can reintroduce bugs this guide assumes are gone.

Rules:

- **Pin the version** in the MCP config (`@bitbonsai/mcpvault@0.12.5` or newer), never a bare package name.
- **Verify what is actually running** rather than trusting the config -- npx may be serving a cached build. If reliability regressions appear, clear the npx cache and reinstall the pinned version before diagnosing anything else.
- **Record the MCP server and version** in session-log frontmatter alongside `seed_version` when it matters -- it makes a stale MCP visible the way `seed_version` makes a stale Seed visible.
- Note: mcpvault's `--read-only` flag is documented but **not implemented** (upstream issue #112) -- do not rely on it to protect a vault.

**mcpvault parameter specifics.** `delete_note` requires `confirmPath` identical to `path`. `update_frontmatter` takes its payload under `frontmatter:` (not `updates:`), and `merge: true` preserves fields written by other operators -- useful under concurrency. (Source: Weave, 2026-08)

## What Triggers These Issues

**Concurrent MCP access** is the confirmed trigger. All observed failures occurred on a day when 6+ Cowork instances were running simultaneously on the same vault, writing to the same project folder. Single-instance sessions have not exhibited these issues.

**Git state interference** can compound the problem. If the vault contains a git repo in an unusual state (stuck rebase, detached HEAD), the MCP reads the filesystem working directory, which may not reflect the expected branch state. Files that are committed but not checked out will be invisible to the MCP.

## Read-Tool Overflow and Batch Ceilings

`read_multiple_notes` on a large batch overflows the tool-result ceiling and dumps the payload to a host-path file the Cowork sandbox cannot read -- so the read effectively returns nothing usable (observed at ~73KB of docs, and again with 5+ medium notes). Keep batches to **2-4 notes per `read_multiple_notes` call**, or fall back to individual `read_note` calls, which stay under the limit.

For a single large note that overflows on its own: parse the saved tool-result JSON by section header / character range, or read it with `filesystem:read_text_file` (a 55KB file read cleanly in one call) and script-parse. A note that reliably overflows on read is also a sectioning candidate (Working Rule 7). (Source: ReWoven S34; Weave, 2026-07/08) Nuance for **remote (cloud) Cowork sessions**: there the saved tool-result file lands in the *cloud container*, where the cloud `Bash` tool CAN read it -- parse the saved JSON and slice its `content` field (python `json.loads`, then string-slice). The "sandbox cannot read it" limitation applies to the on-device sandbox layout, not the cloud-container layout. (Source: RW S68)

## Verification Protocol

After any critical write operation (`write_note`, `patch_note`, `update_frontmatter`), verify the write landed using this hierarchy:

### Tier 1: Filesystem Tools (Preferred)

Use the `Read`, `Glob`, or `Grep` tools to check the file directly on the filesystem. These bypass the Obsidian MCP entirely and read the actual disk state.

- **For `write_note`:** Use `Glob` to confirm the file exists at the expected path, then `Read` to spot-check content (e.g., verify the frontmatter title matches).
- **For `patch_note`:** Use `Read` on the patched file and confirm the patched text is present.
- **For `update_frontmatter`:** Use `Read` on the file and confirm the frontmatter field was updated.

If filesystem tools cannot reach the vault (common in Cowork -- the vault path may not be connected), request access via `request_cowork_directory` at the start of the session. This is especially important when running concurrent instances. Note that `device_stage_files` cannot verify Obsidian-MCP writes when the vault path is not a Cowork-connected folder -- in that layout `obsidian:read_note` (Tier 2) is the verification path for MCP-written content. (Source: Weave, 2026-07)

**Caveat -- Glob is unreliable against the Cowork vault mount.** Directory-prefixed patterns (`folder/*`) return nothing; recursive patterns (`**/name*`) work. Glob has also returned "No files found" for freshly created folders that `list_directory` and bash `ls` both saw. Prefer `list_directory` or a bash `ls` for existence checks against the mount, and treat a Glob miss as inconclusive, not proof of absence. (Source: Weave, 2026-06/07, observed twice)

### Tier 2: Obsidian MCP Read-Back (Weaker)

If filesystem tools are genuinely unavailable, use `obsidian:read_note` to verify. This is a weaker signal because the MCP can serve cached/phantom content. To improve reliability:

- Wait briefly before the verification read (the cache may be time-limited).
- Compare specific content details, not just "file exists."
- Treat this as provisional verification, not confirmed.

### Tier 3: User Verification (Escalation Only)

If Tier 1 verification fails (file not found on filesystem after a write that returned success), retry the write once. If the retry also fails verification, flag the issue to the user. Do not silently retry more than once -- repeated ghost writes could indicate a deeper problem.

## What to Verify

Not every write needs full verification. Prioritize based on replaceability:

**Always verify (high cost if lost):**
- Session log section files (end-of-session writes)
- Session log shell patches (shared file, concurrency risk)
- Infrastructure file updates (0.x files, quest logs, action items)
- New files that represent significant work (design docs, harvest outputs)

**Spot-check (moderate cost):**
- Frontmatter updates on existing files
- Patches to content files during harvest work

**Skip verification (low cost, easily re-done):**
- Intermediate saves during iterative editing (the final save gets verified)
- Tag operations via `manage_tags`

## Concurrency Practices

When multiple instances are running on the same project:

**The session log shell is the shared hotspot.** Every instance patches `0.2 Session Log.md` (or equivalent) to add its session embed. This is the highest-risk file for concurrent write conflicts.

- Patch the shell only at session close, not earlier.
- Verify the patch landed using Tier 1 (filesystem) verification.
- If the patch fails, re-read the current shell content (it may have been modified by another instance since you last read it), then retry the patch against the current content.

**Session log section files are low-risk for collision.** Each instance writes a uniquely named file (date + session number + description). Even if two instances accidentally claim the same session number, the descriptions will differ, creating different filenames.

**Claiming a session number under concurrency: verify-after-claim, then go above.** Two safeguards for two cases:

- *Simultaneous claims* (neither thread has written its stub when both list the folder) defeat any look-before-you-leap rule. Make the claim collision-evident: stamp the stub with a short random `claim_id`, write it, then re-read it from disk. If the on-disk `claim_id` is not yours, you lost the race -- increment to the next free identifier and rewrite. This promotes the S197 manual recovery into the protocol (PI Orientation Step 3).
- *Sequential near-collisions* (you can see the other thread's stub): take the next number above the highest existing entry *and* above any `in-progress` stub another instance has claimed -- even if that leaves a gap. A burned number is harmless; reusing one, or back-filling a gap below a live higher-numbered session, invites cross-references that point at the wrong session. (Observed S195: S192 complete, S193 burned, an in-progress S194 side quest live -- the main-arc thread claimed S195.)

Pair both with **deferring the shell embed to session close** -- only the closer touches the 0.2 shell, once -- which removes the second collision surface. Grounding: the S196/S197 simultaneous collision was caught only because post-write verification re-read the stub. Full design: [[Session Claiming Under Concurrency]]. (DW S195, S197)

**Content files can conflict if two instances harvest to the same destination.** If you know another instance is running and may be editing the same synth doc sections, coordinate via the user or avoid overlapping destinations.

## Pattern from the Wild: Drift Detection on Apply and Undo

The concurrency guidance above (re-read current content before retrying a patch) can be systematized into an explicit drift check. The open-source `istefox-dt-mcp` connector (DEVONthink 4 MCP server, MIT) implements a transferable version worth borrowing for any MCP-based batch-write workflow:

- **Dry-run-by-default writes.** Every write defaults to `dry_run=true`: preview the change, get a `confirm_token`, then apply. Each apply is reversible via an `audit_id`, with an append-only SQLite audit log. This is the same dry-run-then-apply discipline DW uses for classify.py, independently arrived at by a separate project -- a useful external validation.
- **3-state drift detection on undo.** Before reverting, the tool classifies each record as `no_drift` (safe), `already_reverted` (skip silently), or `hostile_drift` (externally modified after the apply -- skip and surface the diff rather than overwrite). An explicit `--force` overrides.

The takeaway for DW: when an operation might be undone or re-applied later, record enough state at apply time to detect whether the target changed in the interim. For Obsidian MCP work this is the stronger version of the "re-read before retrying" rule -- compare against a captured snapshot and flag on unexpected drift instead of assuming the file is unchanged.

*Source: Reddit r/devonthink (2026-05), `github.com/istefox/istefox-dt-mcp`. Evaluated DW Session 88 (Chunk 5 triage).*

## Obsidian Behavioral Gotchas

These are not MCP bugs but Obsidian behaviors that agents need to account for.

**`move_note` does NOT auto-update wikilinks.** When you rename or relocate a note via `move_note`, Obsidian's MCP does not update wikilinks in other files that reference the moved note. After any rename or move, you must manually search the vault for references to the old path/name and patch them. Search vault-wide, not just within the current project -- wikilinks without paths can resolve across projects. (Source: MMM S08)

**In-app renames and MCP moves drift in opposite directions.** Obsidian's *in-app* rename auto-updates inbound wikilinks across the vault; MCP `move_note` does not. Mixing the two -- an in-app rename plus an MCP move -- and then running a `replaceAll` link cleanup double-suffixes the links (the in-app half already fixed them, the `replaceAll` fixes them again). Rule: after any rename, grep the *current on-disk* link text before a `replaceAll` cleanup, so you only rewrite links that are actually stale. (Source: ReWoven S30; VibeCut S23, independent)

**"File not found" is not always the known glitch -- it can be a real rename.** The reflex to retry through the intermittent read glitch (where `read_note` fails on a path `list_directory` shows) masks the case where a human renamed or moved the note mid-session. Re-list the folder before retrying: a genuine rename shows up under the new name, the glitch shows the file still there. (Source: Weave, 2026-08)

**`move_note` can throw `EISDIR` and wedge the session (mcpvault).** A `move_note` call can fail with an `EISDIR` ("illegal operation on a directory") error; once it does, the session sometimes degrades -- subsequent MCP calls hang or fail until the server/session is restarted. This has been reproduced independently multiple times and is a likely cause of mid-session wedges that get misattributed to other causes (e.g. malformed frontmatter). No mcpvault release has a per-call timeout to bound it (an upstream feature request). Fallbacks, in order: (1) pin >= 0.12.5 first, to rule out already-fixed bugs; (2) do not retry more than once -- a wedged MCP will not clear by hammering it; (3) do the move another way -- `move_note` from a fresh session, a Terminal `mv` (then fix wikilinks by hand, since move does not update them), or directly in Obsidian; (4) if wedged, restart the MCP server/session.

**Obsidian MCP tools are `.md`-only -- route scripts through the device shell or filesystem tools.** `read_note` on a `.sh` returns "Access denied," and `write_note` refuses non-markdown targets (a `.ps1` was rejected). Use the device shell or `filesystem` tools on the mount path for scripts and other non-`.md` files; reserve obsidian tools for markdown. Relatedly, `filesystem:write_file` is the reliable path for writing large Python scripts to the vault. (Source: DW S221, S227)

**Short-name embeds are more resilient than full-path embeds.** `![[4.0 The Ecosystem]]` is safer than `![[_Metamorphic Media/Metamorphic Media Shared/Metamorphic Media - Vision Document/4.0 The Ecosystem]]`. When content is reorganized, full-path embeds break silently. Worse, Obsidian may resolve a broken full-path embed to a same-named file in a different project -- the MMM Vision shell was embedding Flow Funding's `4.0 The Ecosystem` instead of its own because the full path had gone stale. Short-name embeds resolve by filename proximity, which is more resilient to reorganization. Use short-name embeds unless disambiguation is genuinely needed (multiple files with the same name across the vault). (Source: MMM S08)

**`search_notes` can false-negative on exact titles.** A search for an exact note title can return content matches in other files while missing the note itself, even when the file exists and `list_directory` shows it. During an MMM link audit, searching "Foraging in High-Dimensional Data @ DISI" returned files that *mention* the phrase but not `_Clippings/Foraging in High-Dimensional Data @ DISI 2025.md` itself -- leading to a false "broken link" finding that was only caught by a later `list_directory` on `_Clippings/`. Rule: before reporting a wikilink as broken or a file as missing, verify with `list_directory` on the expected folder (or a filesystem `Glob`), not search alone. Search confirms presence; it cannot confirm absence. (Source: MMM S12)

**Vault-wide `search_notes` is fine to use.** Scoping every search to a single folder out of caution is unnecessary -- there is no reliability reason to avoid vault-wide search, and it works reliably across the whole vault. Use it freely for discovery. The one real caveat is the exact-title false-negative directly above: search confirms presence, never absence -- a "no results" is not proof a note or link is missing; confirm absence with `list_directory` / `Glob`.

**Sandbox bash cannot delete files on the vault FUSE mount.** From the Cowork sandbox, `rm`/unlink fails with "Operation not permitted" on the Regen Vault (a FUSE mount -- `.fuse_hidden*` files are the tell), though `touch`, create, `mv`/rename, and truncate-write all work. To archive or relocate vault files, use `obsidian:move_note` (it runs with Obsidian's full filesystem access), not bash `cp`+`rm` (which aborts at the first delete). When stamping an archive banner on a file with YAML frontmatter, insert it AFTER the closing `---` (e.g. `patch_note` in front of the first body line) -- prepending breaks the frontmatter. (Source: DW S182) Bulk frontmatter edits via a Python script over the mount do work, and beat per-file MCP patches at scale -- the delete restriction still applies, so a script may rewrite in place but not unlink. (Source: Weave S98)

**Rename on the mount is inconsistent -- verify, don't assume.** The entry above records `mv`/rename working on the FUSE mount (DW S182), and the rename-aside lock recovery (DW S253) depends on it. But ReWoven sessions have seen the opposite: sandbox `os.rename`/`mv` failing with PermissionError while create/overwrite worked (RW S46), and a device-side session finding in-place rename failing where copy-out-then-truncate-write (`perl ... > /tmp/x && cat /tmp/x > file`) succeeded (RW S67, `device_bash` VM mount -- a different mount than the sandbox FUSE). Treat rename as environment-dependent: verify the result after any mount rename, and on failure fall back to `obsidian:move_note` (for vault notes) or copy-then-truncate-write (for any file). (RW S46, S67; surfaced RW S68 meta-learning review)

**Sandbox bash CAN reach the vault -- but only at the mount path, not the Mac path.** A correction to a belief recorded in RW S53 ("device_bash cannot see the vault"). The Cowork sandbox does mount the session's connected folders, at `/sessions/<session-id>/mnt/<folder-name>/` -- discover them with `ls mnt/` from the default working directory. Mac absolute paths (`/Users/.../Vaults/Regen Vault/...`) fail with "No such file"; mount-relative paths work. This makes bash genuinely useful for **read-only** verification, which is fast and cheap at scale: `ls | wc -l` for counts, `stat -c %s` for byte-size comparison against a pre-change directory listing, `find -size -1c` for truncation. Writes and deletes remain restricted per the two entries above. (Source: RG S4, correcting RW S53) Mount stability is not guaranteed for a whole session -- the path can rotate or lose permissions mid-session (a path that served `find` earlier later returned Permission denied for `grep`); if a bash check suddenly fails where it worked, re-discover the mount (`ls mnt/`) rather than concluding the file is gone. At scale, `diff -rq` between the mount and a reference copy plus a targeted `grep` verifies a multi-file operation (e.g. a 16-file dedup) without pulling any file into context -- the context-cheapest verification for bulk work. (Source: Weave, 2026-07/08)

**`device_bash` and the filesystem MCP address the vault by different roots.** A corollary to the mount-path entry above, and the one that bites during write verification. `device_bash` reaches the vault at the sandbox mount root (`/sessions/<id>/mnt/<folder>/`); the filesystem MCP (`filesystem:read_text_file` et al.) and `device_list_dir` reach it at the raw Mac path (`/Users/.../Vaults/...`). The two roots are not interchangeable -- a path that resolves in one tool returns "No such file" in the other. So verify an Obsidian-MCP write with the filesystem reader or `device_list_dir` on the Mac path, not `device_bash` on a `/Users/...` path: a namespace mismatch reads as a phantom missing file even when the write landed. (Source: DW S242)

**Cross-mount `mv` leaves duplicates, not a failed no-op.** Extends the delete limitation above. Each connected folder is a *separate* mount, so `mv` between two of them (e.g. `_ProjectA/...` to `_ProjectB/...`) is internally copy-then-unlink. The copy succeeds and the unlink fails -- so a chained `mv` of N files aborts partway with the sources still present **and** copies already written at the destination. The failure is not clean: you are left mid-migration with duplicates. Recovery is `obsidian:move_note` with `overwrite: true`, which replaces the stray copy and removes the source in one operation. For any multi-file relocation, skip bash entirely and use `move_note` from the start -- issued in parallel, 20 calls per message block is comfortable. (Source: RG S4)

**Sandbox bash cannot write SQLite databases on the vault FUSE mount.** Plain file create/overwrite/truncate works (above), but opening a SQLite db on the mount for writing fails with `sqlite3.OperationalError: disk I/O error` -- FUSE does not support the byte-range locking and journaling (`-wal`/`-shm`/`-journal`) SQLite needs. Reads are fine: copy the db to a sandbox-writable dir (e.g. the outputs folder) and read the copy. Consequence: any SQLite-backed tool (e.g. `dw_ops.db`) must run its **writes natively on the user's machine**, never from the Cowork sandbox; a sandbox session participates by queueing changes (markdown / intake) for a native process to ingest. Verified S199 by probe -- bash `CREATE`/`OVERWRITE` ok, `rm` and SQLite write both fail. (Source: DW S199)

**Git working-tree ops fail from the sandbox; run them in Terminal.** Because the sandbox can create but not delete or overwrite files on the vault FUSE mount (above), any git operation that touches the working tree or index - `pull`, `checkout`, `branch`, `commit`, even `git status` when there are uncommitted changes - fails partway and leaves stale lock files it cannot unlink (`.git/index.lock`, `.git/ORIG_HEAD.lock`, `.git/objects/maintenance.lock`), sometimes plus a stray untracked file and harmless `tmp_obj_*` cruft from a fetch. Read-only inspection on a clean tree (`git log`, `git status` with no changes, `git fetch` for inspection) is fine. Run all working-tree git ops via a Terminal command on the user's Mac (Working Rule 15) or via DW Save; if a sandbox attempt already left locks, the recovery command removes the lock files first, then runs the real op. (Source: DW S188, S189) **S253 nuance:** even `git status` (index refresh) can orphan an `index.lock`; a lock orphaned in a **nested repo listed in the sync config self-heals** on the next run via the S252 `datawizard-sync.sh` stale-lock sweep, but the **root repo has no healer**, so a root orphan silently blocks all auto-commits until cleared - a live footgun. Recovery without a Terminal: **rename the lock aside** (`mv .git/index.lock .git/index.lock.stray.delete-me`), since rename works on the FUSE mount where unlink fails, then have the user `rm` it later. (DW S253)

**`patch_note` does not match inside YAML frontmatter.** `patch_note` operates only on the markdown body, not the frontmatter block. A patch whose `oldString` targets a frontmatter field (e.g. a skill's `description:`, or any `key: value` line above the closing `---`) returns `matchCount: 0` / "String not found" even when the text is visibly present. Use `update_frontmatter` (merge: true) for frontmatter edits; reserve `patch_note` for body content. (Source: DW S198)

**`patch_note` also fails on a shell's `---` divider.** A patch whose `oldString` targets the `---` horizontal rule separating embed sections in a shell file returns "target not found." Use a filesystem Edit with a unique text anchor (include neighboring text), or anchor the patch on adjacent body text rather than the bare divider. (Source: Weave, 2026-07)

**`patch_note` can fail session-wide with a bogus "oldString cannot be empty".** Observed: every `patch_note` call in a session returned `"oldString cannot be empty"` even though non-empty, exact-match `oldString` values were supplied (verified against fresh reads), across multiple files and repeated attempts. Reads, `write_note`, and `update_frontmatter` worked normally in the same session; a bridge reconnect did not clear it. When this signature appears, stop retrying `patch_note` (the error is spurious, not a matching problem) and fall back to the local filesystem MCP's `edit_file` on the real vault path -- it makes surgical, diff-verified edits reliably (same fallback as the vault-script editing pattern above). Small files can alternatively go through a re-read + full `write_note` overwrite. (Source: DW S263)

**`filesystem:edit_file` can insert text inline when the anchor starts mid-line.** If the match anchor begins partway through a line, the inserted header text lands inline rather than on its own line. Dry-run first and include the preceding text in the anchor so the insertion point is unambiguous. (Source: Weave, 2026-07)

## Incident Reference

These issues were diagnosed in DW Session 65 (2026-05-03). The investigation found:

- 4 confirmed ghost writes across 4 separate Cowork instances on 2026-05-02
- All affected session log writes or shell patches
- All occurred during a period with 6+ concurrent instances
- No content files (harvests, design docs, quest files) were lost -- only session documentation
- Retrying the write after a failed verification succeeded in all cases
- A separate git issue (stuck interactive rebase from a sync script using `--rebase`) compounded the problem by making committed files invisible in the working directory

The sync script was fixed (`git pull --no-rebase`) and the MCP verification protocol was established to prevent recurrence.
