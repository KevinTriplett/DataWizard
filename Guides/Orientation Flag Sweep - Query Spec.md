---
created: 2026-08-18
edit_log:
  - DW-S272 2026-08-18 - created (F2 query spec + constants + read-only-sweep
    decision; referenced by PI Orientation Step 6, v4.6)
  - "DW-S279 2026-08-18 - fourth correction: null-literal normalization in
    field() (live-corpus catch during the whole-build verification sweep)"
  - "DW-S289 2026-08-26 - fifth correction: read_through_frontmatter() replaces the 8 KB read cap (live catch - a 10 KB edit_log-heavy frontmatter hid the queue's only dated flag from every surface; found during the Flag Workbench review)"
  - 'DW-S330 2026-09-04 - fallback section: MCP stale-serving of synced-never-opened files (non-empty-but-wrong); flag-load-bearing reads filesystem-only (WV_2026-09-02_JC_02)'
maturity: working
operator: Andrew
seed_version: 1.2.0
title: Orientation Flag Sweep - Query Spec
type: guide
updated: 2026-09-04
---
# Orientation Flag Sweep - Query Spec

*The mechanism behind the PI Orientation sweep step. The PI states WHAT the sweep does in three sub-checks; this doc is HOW -- the query, the constants, the per-surface method -- so the PI stays short (PI real estate is scarce). Referenced by PI Orientation Step 6.*

## What the sweep is

At orientation, one step runs three conditionally-gated checks and writes a single compliance-trace line into the session claim stub. It surfaces to the current operator what is already waiting on them -- flags addressed to them, their own stale stubs, newly filed intake -- at the one lifecycle point guaranteed to run in their own session. Full behavioral rationale: the Flag Surfacing Chain design (four-link delivery chain; orientation is the reader-path choke point).

## Read-only by design (conscious deviation, pinned)

**The sweep writes nothing to any file's frontmatter. Its only write is its own trace line in the claim stub.** It surfaces flags and their defaults; it does not stamp `flag_status`. Two writers change flag state, both outside the sweep: an explicit operator response during the session (act -> remove the operator's name from `flag_for`; conscious defer -> keep the name, set `flag_status: deferred`), and the session-closer's expiry pass, which is the ONLY automatic writer of `flag_status: expired-unread` (and the only automatic name-clearer).

This is a deliberate departure from the Flag Surfacing Chain charter's F4-layer-1 note, which suggested the sweep "records `flag_status`" on overdue items. Reasons: (a) flags are multi-addressee -- one operator's sweep must not stamp status or clear names for co-addressees who have not seen the item; (b) automatic frontmatter writes at orientation, from possibly-concurrent sibling sessions, are a new race surface on shared files (the MCP-concurrency rule exists for exactly this); (c) a cheap read-only sweep is what the "PI real estate is scarce" constraint promised. Recorded in the Decision Log with the sweep-adoption entry.

## Constants

- **`STALE_STUB_DAYS = 3`** -- a session-claim stub still `status: in-progress` and older than this many days is offered for reconciliation. Rationale: long enough that same-day and next-day work-in-progress is never nagged, short enough that a genuinely dropped stub surfaces within a working week.
- **Live-sibling guard** -- never offer to reconcile a stub whose claim date is today, regardless of age arithmetic. Concurrent sessions in the same project each hold a fresh in-progress stub; the sweep must be structurally incapable of offering to reconcile a live sibling.
- **Flag budget** -- surface at most **5** flags, ordered due-first (see sort), and report the count of the remainder. A wall of flags at orientation trains operators to skip the step.

## Sub-check (a) -- flag sweep [multi-operator projects only]

Solo-operator projects skip the query and report `n/a (solo)` in the trace.

### Query (filesystem-primary; the canonical reference)

Raw-text frontmatter extraction, deliberately NOT a strict YAML parse -- so it still returns fields from files whose frontmatter fails strict parsing (an over-long or unescaped quoted `flag_note` has broken parsing in practice, after which a YAML parser returns empty silently and the flag reads as absent). Exact-match against the extracted `flag_for` list, so `operator:` and `flag_by:` never produce false positives. No result cap.

```python
import os, re

STALE_STUB_DAYS = 3

def read_through_frontmatter(p):
    """Return the file text through its closing frontmatter fence, or the
    first 8 KB if the file has no frontmatter. NO byte cap on the block:
    an edit_log-heavy frontmatter can exceed 8 KB (live catch: 10 KB on a
    project ledger carrying the queue's only dated flag), and a capped
    read silently drops the flag."""
    with open(p, encoding='utf-8-sig') as fh:
        t = fh.read(8000).replace('\r\n', '\n').replace('\r', '\n')
        if not t.startswith('---\n'):
            return t
        while not re.search(r'\n---(\n|$)', t[4:]):
            more = fh.read(8000)
            if not more:
                break
            t += more.replace('\r\n', '\n').replace('\r', '\n')
    return t

def sweep(root_dir, operator=None):
    """Return flag rows for a project tree; filter to one operator's queue if given."""
    rows = []
    for root, dirs, files in os.walk(root_dir):
        if 'xArchive' in root:
            continue
        for f in files:
            if not f.endswith('.md'):
                continue
            p = os.path.join(root, f)
            try:
                # utf-8-sig strips a BOM; CRLF/CR normalized so ^---\n matches;
                # reads to the closing fence, never to a byte cap.
                t = read_through_frontmatter(p)
            except Exception:
                continue
            m = re.match(r'^---\n(.*?)\n---', t, re.S)
            if not m:
                continue
            fm = m.group(1)
            if 'flag_for' not in fm:
                continue
            names = []
            mm = re.search(r'^flag_for:[ \t]*(\S.*)$', fm, re.M)   # inline form
            if mm:
                val = mm.group(1).strip()
                names = [n.strip(' []\'"') for n in val.split(',') if n.strip(' []\'"')]
            else:                                                   # block-list form
                # [ \t]* (not +) so zero-indent block list items are caught too.
                mb = re.search(r'^flag_for:[ \t]*\n((?:[ \t]*-[ \t]*.+\n?)+)', fm, re.M)
                if mb:
                    names = [x.strip(' \'"') for x in re.findall(r'-[ \t]*(.+)', mb.group(1))]
            def field(name):
                fmm = re.search(r'^' + name + r':[ \t]*(.*)$', fm, re.M)
                if not fmm:
                    return ''
                v = fmm.group(1).strip().strip('\'"')
                # YAML null literals (e.g. flag_due: null, written by
                # properties editors) mean "absent", not the string 'null'.
                return '' if v.lower() in ('null', '~', 'none') else v
            rows.append({'path': p, 'flag': field('flag'), 'flag_by': field('flag_by'),
                         'flag_due': field('flag_due'), 'flag_default': field('flag_default'),
                         'flag_for': names})
    if operator:
        rows = [r for r in rows if operator in r['flag_for']]
    return rows

# Sweep-step usage:
rows = sweep(project_root, operator='<current operator first name>')
# Empty flag_due sorts LAST (sentinel), then due-first, then flag date.
rows.sort(key=lambda r: (r['flag_due'] or '9999-12-31', r['flag'] or '9999-12-31'))
top = rows[:5]
remainder = len(rows) - len(top)
```

Five corrections applied over the original reference implementation: **no byte cap on the frontmatter read** (the original read the first 8,000 bytes of each file; a frontmatter block whose `edit_log` has grown past that -- 10 KB on one project's Active Threads ledger -- never reaches its closing fence, so the `^---\n(.*?)\n---` match fails and the flag is silently absent. That file carried the queue's only dated `flag_due`, addressed to four operators, and every surface missed it. `read_through_frontmatter()` reads to the fence. Live-corpus catch, 2026-08-26. Any other reader of `flag_for` -- a notice board, a dashboard script -- must be checked for a sibling cap); **CRLF/BOM normalization** (`utf-8-sig` + newline normalize, so files saved on Windows or with a BOM are not silently skipped by the `^---\n` anchor); **zero-indent block lists** (`[ \t]*` not `[ \t]+`, so a `flag_for:` list whose items sit at column 0 is parsed); **empty-due-last sort** (a sentinel high date so flags without a `flag_due` fall to the end rather than sorting ahead of dated ones); **null-literal normalization** (a YAML null literal -- `null`, `~`, `None`, as properties editors write for an empty date field -- is treated as field-absent, never as a date string; without this, a `flag_due: null` file counts as dated and sorts by the literal string, which lands last only by lexicographic luck -- an uppercase `NULL` variant would sort a phantom item to the top of every queue. Live-corpus catch, 2026-08).

Surface each of `top` with title (filename), `flag_note`, `flag_by`, `flag`, and `flag_due`; on any item past `flag_due`, show its `flag_default` (what happens on silence). Then state the `remainder` count.

### Fallback (surfaces without filesystem access)

Where an instance cannot run the script (no shell / no filesystem tool), use the MCP frontmatter search for `flag_for` as a candidate finder, then confirm each hit with `get_frontmatter`. **Treat a grep-matched file whose `get_frontmatter` returns empty as a parse failure, never as fields-absent** -- that is the silent-`{}` case above, and it is a real flag the fallback would otherwise drop. The MCP search also caps results, so on a large backlog the filesystem path is the only complete one; the fallback is a degraded mode, not an equivalent.

The degradation is not only caps and empty-`{}` results: **the MCP can serve non-empty but wrong content for files that arrived by repo sync and were never opened locally.** Field case (WV_2026-09-02_JC_02, confirmed DW S325): an operator's disk copy was byte-identical to source (no BOM, zero CR, clean fences) while the same file read through the MCP came back CRLF throughout - frontmatter unparseable, every `flag*` field invisible, on the same machine where other files' full flag clusters parsed cleanly. A stale or transformed serving-layer copy cannot be detected from inside the MCP path, and it targets precisely the highest-value flags (notes freshly synced from another operator, never yet opened by the recipient). So on a multi-operator project, any flag-load-bearing read - the sweep, a dashboard, a watch row - must use the filesystem path; the MCP fallback is only for surfaces with truly no filesystem access, and silence from it is never evidence of absence.

## Sub-check (b) -- stale-stub reconciliation [all projects, incl. solo]

Among the session-log stubs already listed at claim time (PI Step 3a), select those that are `status: in-progress`, owned by the CURRENT operator, older than `STALE_STUB_DAYS`, and NOT claimed today (live-sibling guard). For each, offer to **mark it abandoned with a one-line reason** -- offer only, never auto-author, and never touch another operator's stub.

v1 is detect + offer + mark-abandoned. Backfill-and-close (reconstructing the entry from the stub's git-commit window) is a later build gated on the git-reconstruction helper; a v1 that "closed" a stale stub without it would be a pattern-matched session close, which the lifecycle-skill rule forbids.

## Sub-check (c) -- intake what's-new [optional, cheap]

List the project's intake folders and surface items added since the last session. **Comparison anchor:** an item is "new" if its frontmatter `created` date is on or after the date of the most recent session-log entry (fall back to file mtime where `created` is absent). Anchoring on the last log entry's date -- not "since I last looked" -- makes two instances compute the same answer. Intake folders for DataWizard: `Feature Requests/`, `Bug Reports/`, `Skill Requests/`, `Intake Queue/` (the canonical intake registry; see the Conventions Registry).

## The compliance trace (always written)

Write ONE line into the claim stub every orientation, unconditionally, including the running PI version. Gated-off checks report their gate rather than being omitted -- a missing line is a broken sweep, and must stay distinguishable from "nothing was waiting."

```
flag sweep [PI v4.6]: 3 surfaced, 1 handled, 0 deferred | stubs: 1 stale, 0 reconciled | intake: 2 new
```

Solo-project example: `flag sweep [PI v4.6]: n/a (solo) | stubs: 1 stale, 0 reconciled | intake: 0 new`. The session-closer carries this line forward when it overwrites the stub at close, so even a session that never closes leaves the sweep record on disk.
