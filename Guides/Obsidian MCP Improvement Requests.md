---
title: Obsidian MCP Improvement Requests
type: reference
created: '2026-06-04'
updated: '2026-06-04'
scope: cross-project
maturity: working
---
# Obsidian MCP Improvement Requests

Feature requests and workarounds for the Obsidian MCP server, collected from cross-project usage.

## patch_note Parameter Naming

**Issue:** The `patch_note` tool requires `oldString` and `newString` parameters. Passing `content`, `target`, or other intuitively-named params throws a validation error with no fallback or helpful error message. The camelCase naming is inconsistent with what most users guess on first attempt.

**Workaround:** Always use exactly `oldString` and `newString`. No aliases exist.

**Request:** Either add parameter aliases or improve the validation error to show the expected parameter names.

*Source: EM S7*

## Backslash-Escaped String Matching in patch_note

**Issue:** Patching strings that contain backslash-escaped characters (e.g., `\n`, `\"`, `\\`) can fail to match even when the string appears visually correct. The escaping context between the JSON request body and the file content causes mismatches that are difficult to debug.

**Workaround:** Use a shorter unique prefix or suffix of the target string that avoids the escaped section entirely. If the unique substring doesn't contain any backslash sequences, the match succeeds reliably.

**Request:** Improve string matching to handle common escape sequences, or document the exact escaping rules for patch content.

*Source: EM S7*
