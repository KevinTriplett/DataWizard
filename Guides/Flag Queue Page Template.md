---
created: 2026-08-18
edit_log:
  - "DW-S279 2026-08-18 - created (Flag Surfacing Chain B2: depersonalized from
    a piloting project's live queue page; empty-due-last sort fix)"
maturity: working
operator: Andrew
seed_version: 1.2.0
title: Flag Queue Page Template
type: guide
updated: 2026-08-18
---
# Flag Queue Page Template

*The per-person render surface for the flag system: one page, one section per operator, each section listing every note in the project whose `flag_for` still carries that name. The page is a **render surface, not the mechanism** -- the vault data (`flag*` frontmatter, [[YAML Schema]] Team Coordination Fields) is the interface, and the orientation sweep reads the frontmatter directly. The page exists so operators can see their whole queue between sessions, and so a rollout has something to read at canary time ([[Team Attention Rollout]]).*

## How to use

1. Create `Flag Queue - ProjectName.md` in the project's infrastructure folder (`_Infrastructure - ProjectName/`).
2. Copy everything below the template line into it; keep the intro paragraphs.
3. Duplicate the per-operator section once per operator, replacing the placeholder names (`Alice`, `Ben`) with your operators' first names -- exactly as they appear in `flag_for`.
4. Requires the Dataview plugin. On a project with a pre-existing flag backlog, expect long first renders ([[Team Attention Rollout]], First-render expectations).

Two mechanics worth knowing, baked into the queries below:

- **Empty-due-last sort.** A plain `SORT flag_due ASC` puts dateless items *first* in Dataview -- the inverse of the design (due-first, undated by flag date at the end). The `default(flag_due, date(9999-12-31))` wrapper fixes this, and also handles a `flag_due: null` literal left by a properties editor.
- **Exact-name matching.** `contains()` is an exact element match when `flag_for` is a YAML *list*, but a substring match when it is a bare inline string (`Ben` would match `Bennett`). Write `flag_for` as a list (the YAML Schema's recommended form) to keep matching exact.

---

# Flag Queue - ProjectName

*One page per person below. Each section pulls every note anywhere in the project whose `flag_for` still carries that name. This is the render surface for the orientation sweep: at session start, your Claude reads YOUR section, tells you what is waiting, and removes your name from anything you deal with. Field definitions and conventions: [[YAML Schema]], Team Coordination Fields.*

*Acting on a flag takes your name off `flag_for` (your Claude does this for you). A conscious defer KEEPS your name -- the item re-surfaces next session, due-first, and ages toward its `flag_due` / `flag_default` (defer must stay distinguishable from done). A flag nobody dismisses is a flag nobody saw: if your section is long, that is the backlog talking, not this page failing.*

## Alice

```dataview
TABLE WITHOUT ID file.link AS Item, flag AS Flagged, flag_by AS By, flag_due AS Due, flag_note AS "What is needed"
WHERE flag_for AND contains(flag_for, "Alice") AND !contains(file.path, "xArchive")
SORT default(flag_due, date(9999-12-31)) ASC, flag ASC
```

## Ben

```dataview
TABLE WITHOUT ID file.link AS Item, flag AS Flagged, flag_by AS By, flag_due AS Due, flag_note AS "What is needed"
WHERE flag_for AND contains(flag_for, "Ben") AND !contains(file.path, "xArchive")
SORT default(flag_due, date(9999-12-31)) ASC, flag ASC
```

*(one section per operator)*
