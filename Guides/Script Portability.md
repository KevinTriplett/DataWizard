---
title: Script Portability
type: guide
created: '2026-09-23'
updated: '2026-09-23'
operator: Andrew
status: active
edit_log:
  - "DW-S374 2026-09-23 - created (meta-learning review S324-S337): consolidates
    the scattered cross-platform script-shipping rules (ASCII-only, PowerShell
    encoding, BSD vs GNU, trace-verify)"
---

# Script Portability

> Rules for scripts that ship in the Seed to other operators. The target matrix is macOS (BSD userland, zsh), Linux (GNU userland, bash), and Windows (PowerShell 5.1). A script that runs on the author's machine has been tested against one cell of that matrix.

## ASCII-only, and why it is not cosmetic

Seed-shipped scripts are ASCII-only - no em-dashes, curly quotes, ellipsis characters, or non-breaking spaces, in code OR comments. This is a correctness rule, not a style rule: Windows PowerShell 5.1 reads a BOM-less `.ps1` file as ANSI, so a UTF-8 em dash decodes to a stray curly quote that can close a string literal early - the whole script then fails to parse, silently doing nothing. (Project field case: one em dash in a comment took down a shipped installer for every Windows adopter; DataWizard, 2026-09.)

Check before shipping: `tr -d '\0-\177' < file | wc -c` must print `0`.

## BSD vs GNU userland

macOS ships BSD versions of `sed`, `awk`, `date`, `stat`, `mktemp`; Linux ships GNU. The common traps: `sed -i` (BSD requires an explicit backup suffix argument, `sed -i ''`), `date -d` (GNU-only; BSD uses `-v`), `stat` format flags (completely different), and `readlink -f` (missing on older macOS). Write to the intersection, or branch explicitly on `uname`. Test constructs you are unsure about on both, not from memory.

## Shell dialect

Target `bash` explicitly (`#!/usr/bin/env bash`), never `sh`, and do not assume the interactive shell: macOS defaults to zsh, so anything an operator pastes into a terminal runs under zsh semantics (word-splitting differs, `**` globbing differs). Instructions handed to operators must be paste-safe under both.

## Trace-verify before shipping

Visual review passes what the runtime rejects. Before a script ships, run it end to end - on a fixture if not on live data - and read the trace, not just the exit code. For self-replacing scripts (updaters), the whole body must run inside a function so the interpreter never streams a file that is being overwritten; verification and the transition-run caveat live in [[Git Hook and CI Behaviors]] ("Self-updating scripts overwrite themselves mid-run").

## See also

- [[Filename Safety]] - the character rules for file *names* (this guide covers file *contents*)
- [[Git Hook and CI Behaviors]] - self-updating scripts, hook environments
- [[Cowork Build Environment]] - the sandbox-side quirks of building and testing scripts
