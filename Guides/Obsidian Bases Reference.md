---
title: Obsidian Bases Reference
type: project-doc
created: '2026-05-28'
updated: '2026-05-28'
edit_log:
  - DW-S117 2026-05-28
  - DW-S118 2026-05-28
---

# Obsidian Bases Reference

Quick reference for Bases behaviors discovered during DW dashboard builds.

## Column Control

The `order` array in a Bases view controls both **which columns appear** AND their **left-to-right sequence**. Properties not listed in `order` don't appear as columns at all. The `properties` section with `displayName` only sets header labels, not visibility. (S111)

## Row Height

**Use the built-in setting, not CSS.** Right-click the view name (e.g. "Drafts") in the Bases toolbar and select Row Height (short/medium/tall/extra tall). This is stored in the view YAML as `rowHeight: medium` and is portable -- team members opening the same file get the same row height.

Medium works well for two-line titles. Text wrapping happens automatically at medium height and above.

**Do not override row height via CSS.** Bases uses absolute positioning with virtual scrolling. CSS overrides to `--bases-table-row-height` or row positioning break the scroll engine, causing jitter and inability to scroll. This was extensively tested in S111 and S118 -- every CSS approach either failed to change row heights or broke scrolling. (S111, S118)

## Reliable Date Column

`file.mtime` works as a Bases column and always has a value, making it a reliable fallback when `updated` frontmatter is missing. Displays with full timestamp (date + time). (S111)

## Filtering Heterogeneous Collections

For collections with inconsistent `type` values (e.g., Weave transcripts with 3+ type values plus files with no frontmatter), **folder-based filtering is more reliable than type-based filtering**. Use `from` with folder path rather than `where type = X`. (S111, S112)

## Sort Directive

The sort directive works and is stored in view YAML. Use uppercase `DESC` or `ASC`:

```yaml
sort:
  - property: updated
    direction: DESC
```

Setting this via the UI (click Sort in the toolbar) writes it into the YAML, making it portable. Earlier S111 testing was inconclusive, but S118 confirmed it works -- the dashboard renders with correct default sort order. (S111, S118)
