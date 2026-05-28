---
title: Obsidian Bases Reference
type: project-doc
created: '2026-05-28'
updated: '2026-05-28'
edit_log:
  - DW-S117 2026-05-28
---

# Obsidian Bases Reference

Quick reference for Bases behaviors discovered during DW dashboard builds.

## Column Control

The `order` array in a Bases view controls both **which columns appear** AND their **left-to-right sequence**. Properties not listed in `order` don't appear as columns at all. The `properties` section with `displayName` only sets header labels, not visibility. (S111)

## Row Height

Row height is controlled by the `--bases-table-row-height` CSS variable on `.bases-tbody`, set inline by JS at 30px. Override with `!important` in a CSS snippet, but only to a fixed value -- no dynamic row sizing. A bases-title-wrap.css snippet exists in the DataWizard project folder. (S111)

## Reliable Date Column

`file.mtime` works as a Bases column and always has a value, making it a reliable fallback when `updated` frontmatter is missing. Displays with full timestamp (date + time). (S111)

## Filtering Heterogeneous Collections

For collections with inconsistent `type` values (e.g., Weave transcripts with 3+ type values plus files with no frontmatter), **folder-based filtering is more reliable than type-based filtering**. Use `from` with folder path rather than `where type = X`. (S111, S112)

## Sort Directive

`sort: - property: X, direction: desc` syntax exists but was not confirmed to affect default sort order in testing. May be silently ignored. Test before relying on it. (S111)
