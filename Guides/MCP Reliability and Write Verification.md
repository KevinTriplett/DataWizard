---
title: MCP Reliability and Write Verification
type: guide
scope: seed
created: '2026-05-03'
updated: 2026-10-15
edit_log:
  - 'DW-S408 2026-10-15 - sectioned into shell + sections in "MCP Reliability and Write Verification/" (Seed/Guides); this edit_log is frozen - future edits log on the section files'
  - 'DW-S403 2026-10-13 - Bridge Drops: local MCP tools time out while the computer sleeps; Read-Tool Overflow: edit_file dryRun for files past the read ceiling (board intake B-0076 Evolutionary Media Commons, B-0083 MetaMyth)'
  - 'DW-S403 2026-10-13 - Obsidian gotchas: write_note append re-serialises the frontmatter (board intake B-0065, Kosmosis)'
  - 'DW-S397 2026-10-12 - get_frontmatter {} on unparseable YAML: widened from edit_log to any scalar; pointer to the YAML Schema callout (meta-learning review S363-S376)'
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
  - "DW-S273 2026-08-18 - array-wipe entry: contended-file
    clobber-by-concurrency variant (immediate re-read, concurrent-entry verify,
    filesystem edit_file for atomic append; corrects FR's patch_note
    suggestion)"
  - DW-S278 2026-08-18 - git-lock entry extended to device_bash (VM mount cannot
    unlink index.lock; git status on a dirty tree suffices to orphan one)
  - "DW-S284 2026-08-24 - SQLite entry consolidated (S199/S203/S204/S207): any
    FUSE mount fails incl. outputs, /tmp copy supports full write-validate runs
    (meta-learning review S198-S209)"
  - DW-S285 2026-08-24 - patch_note literal-backslash-n in multi-line newString
    (S233); device_stage_files re-stage returns stale snapshot, verify via live
    read (S236) (meta-learning review S231-S246)
  - "DW-S285 2026-08-24 - Read-overflow: single-file 73KB overflow +
    get_frontmatter {} + char-range slicing (S266); get_frontmatter {} on
    unparseable YAML, unquoted colon (S285 live) (meta-learning review
    S256-S266)"
  - DW-S286 2026-08-26 - Bulk Frontmatter Backfills section (insert never
    round-trip; invariant in the write path)
  - "DW-S311 2026-08-30 - Concurrency Practices: mtime CAS float-vs-int
    false-trip on the FUSE mount; prefer content guards"
  - DW-S324 2026-09-04 - unquoted-colon entry aligned to D127
    single-quote-always rule
  - "DW-S330 2026-09-04 - Known Issues: stale serving of synced-never-opened
    files (CRLF copy not on disk; WV_2026-09-02_JC_02)"
  - "DW-S332 2026-09-06 - Obsidian Behavioral Gotchas: write_note append joins
    without a newline separator (leading-newline rule + column-1 verify)"
  - "DW-S336 2026-09-07 - git-on-mount: S304/S336 extension (status orphans a
    lock on a clean tree; safe-read list)"
  - "EMC-S6 2026-09-07 - Verification Protocol Tier 1: filesystem MCP server
    outputSchema draft-07 dialect failure (all filesystem__* tools erroring,
    unrelated to vault state)"
  - "RL-S10 2026-09-19 - Bridge Drops: cloud-session lazy-loading variant
    (server reconnect drops loaded tool schemas; re-run tool_search, batch the
    reload)"
  - "RL-S12 2026-09-19 - Bridge Drops: mid-write drop is a clean failure
    (explicit not-connected error, nothing written); confirm-unwritten then
    single retry"
  - 'RW_2026-09-23_AA_01 - three additive entries: device_bash E2BIG heredoc limit, device_bash git host-key failure, search_notes fuzzy + searchFrontmatter caveat (ReWoven meta-learning review)'
  - "DW-S374 2026-09-23 - Read-overflow: ceiling keys on total file size, not
    frontmatter length (meta-learning review S301-S323)"
  - "DW-S374 2026-09-23 - Known Issues: wake-stale reads named as a class
    (meta-learning review S324-S337)"
  - 'DW-S398 2026-10-12 - device_commit_files hash checks qualified to text files (images change bytes in transit); R6 lead-seat git exception at the device-shell git practice'
  - 'DW-S400 2026-10-12 - patch_note frontmatter rider (reported otherwise on one build, re-test); table-cell wikilink pipe escape; staged files survive a bridge drop (VibeCut + ReWoven FR intake)'
---
# MCP Reliability and Write Verification

> Guide for Claude instances using the Obsidian MCP to write vault content. Covers known failure modes, verification protocol, and concurrency practices.
>
> **Which server this describes.** The failure modes below were observed with `@bitbonsai/mcpvault` as the Obsidian MCP server. They are not specific to the Local REST API built-in MCP, which behaves differently. If you run a different Obsidian MCP server, expect a different failure profile -- treat these gotchas as calibrated to mcpvault unless noted otherwise, and pin a known-good version (see Version Pinning and npx Caching below).
>
> Part of the **Platform and Environment Behaviors** guide cluster -- see `GUIDES.md`.

![[1.0 Known MCP Issues]]

![[2.0 Transport 502s - Verify Before Retry, Against a Must-Have-Changed Field]]

![[3.0 Bridge Drops and Hangs (Remote Transport)]]

![[4.0 Version Pinning and npx Caching]]

![[5.0 What Triggers These Issues]]

![[6.0 Read-Tool Overflow and Batch Ceilings]]

![[7.0 Verification Protocol]]

![[8.0 What to Verify After Writes]]

![[9.0 Bulk Frontmatter Backfills - Insert, Never Round-Trip]]

![[10.0 MCP Concurrency Practices]]

![[11.0 Pattern from the Wild - Drift Detection on Apply and Undo]]

![[12.0 Obsidian Behavioral Gotchas]]

![[13.0 MCP Incident Reference]]

