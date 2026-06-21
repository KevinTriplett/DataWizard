---
title: MCP Reliability and Write Verification
type: guide
scope: seed
created: '2026-05-03'
updated: '2026-06-21'
edit_log:
  - "DW-S191 2026-06-21: planted sandbox git-write limitation"
---
# MCP Reliability and Write Verification

> Guide for Claude instances using the Obsidian MCP (Local REST API) to write vault content. Covers known failure modes, verification protocol, and concurrency practices.

## Known Issues

As of May 2026, the Obsidian MCP has intermittent reliability issues when multiple Cowork instances access the same vault simultaneously. Three failure modes have been observed:

**Ghost writes.** `write_note` returns "Successfully wrote note" but the file never appears on the filesystem. The MCP may then serve the ghost content back via `read_note` and `list_directory` from its cache, making it appear as though the write succeeded even on verification. This has been confirmed with `write_note`, `patch_note`, and `update_frontmatter` -- all three can return success without persisting.

**Phantom reads.** `read_note` and `list_directory` return content for files that do not exist on the filesystem. This was observed when one instance read a full session log entry (with correct frontmatter and internally consistent content) for a file that was not present on disk. The phantom content was also visible in `list_directory` results.

**Stale reads.** After a successful `patch_note`, a subsequent `read_note` on the same file may return the pre-patch version. This may overlap with the phantom read issue (the MCP serving cached pre-patch content).

**Frontmatter wipe via merge: false.** `update_frontmatter` with `merge: false` replaces the entire frontmatter -- any field you omit is deleted. Always use `merge: true` (the default) unless intentionally replacing the full schema. If you must use `merge: false`, re-read frontmatter first and include every field.

## What Triggers These Issues

**Concurrent MCP access** is the confirmed trigger. All observed failures occurred on a day when 6+ Cowork instances were running simultaneously on the same vault, writing to the same project folder. Single-instance sessions have not exhibited these issues.

**Git state interference** can compound the problem. If the vault contains a git repo in an unusual state (stuck rebase, detached HEAD), the MCP reads the filesystem working directory, which may not reflect the expected branch state. Files that are committed but not checked out will be invisible to the MCP.

## Verification Protocol

After any critical write operation (`write_note`, `patch_note`, `update_frontmatter`), verify the write landed using this hierarchy:

### Tier 1: Filesystem Tools (Preferred)

Use the `Read`, `Glob`, or `Grep` tools to check the file directly on the filesystem. These bypass the Obsidian MCP entirely and read the actual disk state.

- **For `write_note`:** Use `Glob` to confirm the file exists at the expected path, then `Read` to spot-check content (e.g., verify the frontmatter title matches).
- **For `patch_note`:** Use `Read` on the patched file and confirm the patched text is present.
- **For `update_frontmatter`:** Use `Read` on the file and confirm the frontmatter field was updated.

If filesystem tools cannot reach the vault (common in Cowork -- the vault path may not be connected), request access via `request_cowork_directory` at the start of the session. This is especially important when running concurrent instances.

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

**Short-name embeds are more resilient than full-path embeds.** `![[4.0 The Ecosystem]]` is safer than `![[_Metamorphic Media/Metamorphic Media Shared/Metamorphic Media - Vision Document/4.0 The Ecosystem]]`. When content is reorganized, full-path embeds break silently. Worse, Obsidian may resolve a broken full-path embed to a same-named file in a different project -- the MMM Vision shell was embedding Flow Funding's `4.0 The Ecosystem` instead of its own because the full path had gone stale. Short-name embeds resolve by filename proximity, which is more resilient to reorganization. Use short-name embeds unless disambiguation is genuinely needed (multiple files with the same name across the vault). (Source: MMM S08)

**`search_notes` can false-negative on exact titles.** A search for an exact note title can return content matches in other files while missing the note itself, even when the file exists and `list_directory` shows it. During an MMM link audit, searching "Foraging in High-Dimensional Data @ DISI" returned files that *mention* the phrase but not `_Clippings/Foraging in High-Dimensional Data @ DISI 2025.md` itself -- leading to a false "broken link" finding that was only caught by a later `list_directory` on `_Clippings/`. Rule: before reporting a wikilink as broken or a file as missing, verify with `list_directory` on the expected folder (or a filesystem `Glob`), not search alone. Search confirms presence; it cannot confirm absence. (Source: MMM S12)

**Sandbox bash cannot delete files on the vault FUSE mount.** From the Cowork sandbox, `rm`/unlink fails with "Operation not permitted" on the Regen Vault (a FUSE mount -- `.fuse_hidden*` files are the tell), though `touch`, create, `mv`/rename, and truncate-write all work. To archive or relocate vault files, use `obsidian:move_note` (it runs with Obsidian's full filesystem access), not bash `cp`+`rm` (which aborts at the first delete). When stamping an archive banner on a file with YAML frontmatter, insert it AFTER the closing `---` (e.g. `patch_note` in front of the first body line) -- prepending breaks the frontmatter. (Source: DW S182)

**Git working-tree ops fail from the sandbox; run them in Terminal.** Because the sandbox can create but not delete or overwrite files on the vault FUSE mount (above), any git operation that touches the working tree or index - `pull`, `checkout`, `branch`, `commit`, even `git status` when there are uncommitted changes - fails partway and leaves stale lock files it cannot unlink (`.git/index.lock`, `.git/ORIG_HEAD.lock`, `.git/objects/maintenance.lock`), sometimes plus a stray untracked file and harmless `tmp_obj_*` cruft from a fetch. Read-only inspection on a clean tree (`git log`, `git status` with no changes, `git fetch` for inspection) is fine. Run all working-tree git ops via a Terminal command on the user's Mac (Working Rule 15) or via DW Save; if a sandbox attempt already left locks, the recovery command removes the lock files first, then runs the real op. (Source: DW S188, S189)

## Incident Reference

These issues were diagnosed in DW Session 65 (2026-05-03). The investigation found:

- 4 confirmed ghost writes across 4 separate Cowork instances on 2026-05-02
- All affected session log writes or shell patches
- All occurred during a period with 6+ concurrent instances
- No content files (harvests, design docs, quest files) were lost -- only session documentation
- Retrying the write after a failed verification succeeded in all cases
- A separate git issue (stuck interactive rebase from a sync script using `--rebase`) compounded the problem by making committed files invisible in the working directory

The sync script was fixed (`git pull --no-rebase`) and the MCP verification protocol was established to prevent recurrence.
