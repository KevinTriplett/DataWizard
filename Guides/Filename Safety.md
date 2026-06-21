---
title: Filename Safety - Cross-Platform Character Map
type: guide
created: '2026-04-30'
updated: '2026-06-18'
status: active
tags:
  - protocol
  - naming-conventions
  - DataWizard
edit_log:
  - DW-S189 2026-06-18
---

# Filename Safety - Cross-Platform Character Map

Canonical reference for cross-platform filename safety. All DW filenames (notes, sections, companions, script outputs) must be valid on Windows, macOS, and Linux. This document defines the invalid characters and their replacement rules.

## Why This Matters

PDF-to-markdown extraction tooling is the primary source of bad filenames. Tabs, non-breaking spaces, question marks, and double spaces leak from PDF text into section filenames. These characters are invisible or harmless on macOS but break on Windows -- blocking git clones, causing silent file-not-found errors, and requiring expensive batch renames after the fact.

Prevention at the point of creation is orders of magnitude cheaper than cleanup after commit. The Weave repo required 138 renames in a single cleanup pass (Session 55/Weave Session 26).

## Invalid Characters

These characters must never appear in filenames:

| Character | Description | Why invalid |
|---|---|---|
| `?` | Question mark | Windows-invalid |
| `\|` | Pipe | Windows-invalid |
| `*` | Asterisk | Windows-invalid |
| `<` | Less than | Windows-invalid |
| `>` | Greater than | Windows-invalid |
| `"` | Double quote | Windows-invalid |
| `\` | Backslash | Windows path separator |
| `:` | Colon | Windows drive separator |
| `/` | Forward slash | Path separator on all platforms |
| tab | Tab character | Cross-platform hazard, common PDF artifact |
| `\xa0` | Non-breaking space | Invisible, breaks matching and git |
| `\r` | Carriage return | Invisible, breaks matching |

## Additional Rules

- **Consecutive spaces**: Collapse to a single space. Common PDF extraction artifact.
- **Trailing whitespace before extension**: Strip. Example: `My File .md` becomes `My File.md`.
- **Em-dashes** (--): Use plain hyphens (-) instead. Em-dashes cause patch_note matching failures.
- **Curly quotes** (" " ' '): Use straight quotes (' ") instead. Same patch_note issue.
- **Leading/trailing dots**: Avoid. Files starting with `.` are hidden on Unix systems.
- **Reserved Windows names**: Avoid `CON`, `PRN`, `AUX`, `NUL`, `COM1`-`COM9`, `LPT1`-`LPT9` as filenames (with or without extension).

## Replacement Rules

When sanitizing an existing filename, apply these replacements in order:

| Find | Replace with | Notes |
|---|---|---|
| tab | space | Then collapse consecutive spaces |
| `?` | (remove) | |
| `\|` | ` - ` | Preserves readability of "X | Y" patterns |
| `*` | `-` | |
| `<` | (remove) | |
| `>` | (remove) | |
| `"` | (remove) | |
| `\` | `-` | |
| `:` | ` -` | Preserves "Title: Subtitle" as "Title - Subtitle" |
| `/` | `-` | Path separator on all platforms |
| `\xa0` | space | Then collapse consecutive spaces |
| `\r` | (remove) | |
| consecutive spaces | single space | Apply after all other replacements |
| trailing whitespace before `.ext` | (strip) | |

## Where to Enforce

1. **Extraction scripts** (segment_transcript.py, PDF section extractors): Sanitize the output filename before writing the file. This is the primary prevention point.
2. **Agent file creation**: Working Rule 8 in Project Instructions covers this for Claude instances.
3. **Git pre-commit hook** (optional): Lint script that flags non-compliant filenames before they get committed. See quest [DW-Q-012] task 4.

## Reference

- Working Rule 8 (Safe Characters) in Project Instructions
- Quest: `[DW-Q-012] Cross-Platform Filename Safety`
- Weave Session 26: Windows-Invalid Filename Cleanup (the incident that prompted this)
