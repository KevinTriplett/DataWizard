---
title: Make Your Project Data Holonic
type: guide
created: 2026-10-08
updated: 2026-10-08
operator: Andrew
origin: 'DW-S391 2026-10-08 - written for the Holonic Records adoption (T19 Chunk 7); generic Seed guide, reader-facing'
status: active
maturity: working
edit_log:
  - 'DW-S391 2026-10-08 - created (T19 Chunk 7); Reader-Facing Prose Style verification pass run'
---

# Make Your Project Data Holonic

Three projects keep a note about the same organization. Project-A has it on a stack map, Project-B has a row for it in an allies register, and Project-C mentions it on a slide. Each project looked up the website, wrote a one-line description and noted who the organization works with, and six months later the three notes disagree and nobody can say which one is right.

A holonic record splits each of those notes in two. The facts every project shares (the website, what the thing is, when it was founded, what it belongs to) live once, in a core note in the vault's `_Entities/` folder. Each project keeps its own note, called a projection, with a generated copy of the shared facts plus everything only that project cares about, such as priority, fit, stage and why it matters. The core gives the thing a permanent id, `hid`, and every tool that reads the vault joins on that id.

This guide walks a project through adopting the contract. The rules live in the YAML Schema, section "Holonic Records", which holds the core fields, the kinds table, keys, lifecycle, the relation record, the predicate table, the person rules and the projection fields. The rest is in the Conventions Registry, in the entry "Holonic records" (the rule, the shared-facts block, identity, sync and delivery) and in the ID families rows for `hid`, `core_id` and relation ids. The guide points at those sections and does not repeat them.

## When a thing needs a core

Make a core when a second project points at the thing, or when the thing has a name of its own outside your vault and will outlive the project that first wrote about it. Organizations, networks, funds, tools, protocols, people, gatherings and films all qualify. Your project's opinion of them does not. That belongs in the projection.

Some notes look like things and are not. A category note that groups fifteen tools under one heading is editorial, so it stays a project note. A topic or an idea has no kind yet. A project's shortlist is a view.

Cores are made on touch. Nobody backfills a whole vault in one sitting. A core appears the first time a session researches or updates something that lacks one, and a note that already exists is joined to its new core, never moved, so every link into it keeps working.

Pick the kind from the kinds table. The field takes one value. If a network also runs a fund, choose the kind that describes what it mostly is and let a relation carry the rest.

Nothing is ever deleted. A thing that stops existing is retired, and two cores that turn out to describe the same thing are merged. Both are operator rulings. No script makes either call, and the Registry's lifecycle rules say where the ruling is recorded.

## What your project's note carries

Once a core exists, your note about the thing becomes a projection. Four frontmatter fields tie it to the core, and a `## Shared facts (from core)` block prints the shared facts. The YAML Schema gives the field shapes under "On every projection", and the Conventions Registry gives the block's exact shape under "Projection block".

A tool writes both, either the federating tool when a note is created or touched, or a sync run later. Never type them by hand. A hand-written block looks fine until the next sync rewrites it from the core and the edit is gone.

Everything outside the block is yours. Priority, stage, warmth, owner, fit and "why we care" never leave the projection, so two projects can hold different views of the same organization and never see each other's notes.

Don't fix a wrong fact inside the block. Send the correction to the operator who owns the core. The core changes, and the next sync carries the fix into every projection at once, because corrections travel up to the core and never sideways from one project to another.

A projection does not have to be a note. Register rows count, and so do lines in a long list. The core records each one in its `projections:` field with a state such as `registry row, not a note` or `list entry, not a note`, which is how the join exists before anyone writes a note. A register that wants the join on its own side adds a `hid` column.

Some projects live in a separate repository that collaborators clone on their own machines, where the owning vault does not exist. That is why `core_note` is a plain path rather than a link, and why the block reads correctly with nothing else around it. The Registry's "Delivery classes" say who writes a projection into a repository the federating session does not own. In short, the federating session hands the text over. The other project's own session puts it in place.

## Writing a relation

A relation is a small record in a core's or a projection's frontmatter. It names a predicate, a target, the target's name as a person would read it, and where the fact came from. The full field list and the predicate table are in the YAML Schema under "Relations". Three questions get you to the right record.

First, who is the subject? A relation is written on its subject's note and reads in one direction. "Example Org is a member of Example Coalition" goes on Example Org's core, and nobody writes the inverse because an index works it out.

Second, is there a predicate that says exactly this? Founding, leading, building, membership, funding and building on another thing each have one, and the table lists every predicate with its inverse and whether it may sit on a core.

Third, if nothing fits exactly, use a role word. A thing that belongs to a whole in a particular way becomes `part_of` with the word in `role`, as in `hub`, `show` or `team`. A verb the table does not know becomes `related_to` with the verb in `role`.

Where you write the record decides who sees it. On a core, a relation is a shared fact that every projection's block prints. On a projection it stays your project's view. Four predicates are view-only and never go on a core: `knows`, `affiliated_with`, `best_connection_to` and `represents`.

If the target has no core yet, set `target` to `null` and let `target_name` carry the name. Writing by hand, you may put a `core_id` in `target`, and the next federating write swaps it for the `hid`.

Five shapes cover most cases. The first is a partner from an old free-text list, with the original string kept in `raw` so anyone can check the conversion.

```yaml
relations:
  - pred: partner_of
    target: m4k7q2w3x3z6b5c5d2f4
    target_name: Example Network
    source: _Entities/Example Org.md#partners[0]
    raw: Example Network
```

The second carries a verb from a project's own vocabulary onto the core as a shared fact. Here Project-A's `member-of` becomes `member_of`.

```yaml
  - pred: member_of
    target: c3d5f7h2j4k6m2n4p6q3
    target_name: Example Coalition
    source: Project-A/Notes/Example Org.md#relations[1]
    raw: 'member-of: Example Coalition'
```

The third keeps a role word that has no finer predicate. Its source is a register row, written as `<project>:<row id>.<field>`.

```yaml
  - pred: part_of
    target: r5s7t2u4v6w3x5y7z2a4
    target_name: Example Hub Network
    role: hub
    source: project-b:example-org.part_of[0]
```

The fourth sits on a person core and cites a public page, which every relation on a person core must do.

```yaml
  - pred: founded
    target: k7m2p4q3r3t5w6x2y6z4
    target_name: Example Org
    since: 2019
    source: https://example.org/team
```

The fifth is a correction. Never edit a relation in place. Mark the old record retracted, say who retracted it and why, and write the new record below it. The old one stays, so a reader can see what was believed and when it changed.

```yaml
  - pred: funded_by
    target: b2c4d6e3f5g7h2i4j6k3
    target_name: Example Fund
    source: Project-A/Notes/Example Org.md#relations[2]
    raw: 'funds: Example Fund'
    retracted: 2026-10-20
    retracted_by: Operator-A
    retracted_reason: the grant came from the fund's programme, not the fund
  - pred: funded_by
    target: p6r2t5w4x7y4z7a3b6c2
    target_name: Example Programme
    source: https://example.org/funding
```

## Adding a kind, a predicate or an anchor scheme

The lists are closed on purpose. Every filter, lint check and block in the vault reads them, and a value one project invents is a value no other project can find.

A kind is added only after a real record of it has been touched (a note or a register row that two projects point at), never in advance. To add one, write a row in the kinds table with the extra shared facts the kind carries, and ship the change with a Seed release note. A recommended practice, not a rule, is a `to_confirm` line on the first core of the new kind saying why none of the existing kinds fit. Two candidates come up often and are not kinds yet. A topic or concept has no shared facts to hold, and a team is almost always a `project` or an `org` already.

A new predicate is a schema change, so try the existing ones first. `part_of` with a role word and `related_to` with the source verb absorb most new needs without touching the table. If neither says what you mean, the new row needs its inverse, whether it is symmetric, and whether it may sit on a core or only on a projection. It ships in a minor release.

An anchor scheme is the part of a key before the tilde, as in `github~example-org`, and it is the cheapest addition of the three. `profile:<host>` already covers any site without a row of its own. Add a row when one host keeps coming up.

## People

A person core can exist before the person knows about it, because consent governs what leaves the vault and not whether a record exists. That rule lets three projects that each met the same person point at one record without exposing anything about them.

Person cores are made on touch, like any other. A person core's fields are a short allow-list (YAML Schema, "Persons"), and any other field on it is an error.

The three states follow what you know. A new person core is `unclaimed`. It holds a name, perhaps a one-liner taken from the person's own public profile, and relations that each cite a public source. It becomes `anchored` when the operator adds the first key, usually a public profile such as `linkedin~in/person-a-example`. It becomes `claimed` only when the person claims it, through a flow defined outside the schema. Most person cores never get there, and nothing waits for them to.

Some things never enter a person core at any state. Notes such as "met at the spring gathering", "keen on revenue sharing" or "warm intro through Operator-B" come from a relationship, so they stay in the project's own note about the person. So does any contact detail that arrived in a private conversation.

Exposure defaults to `team`. The core lives in the vault and in the index, and nothing about the person reaches a public export or a block outside the vault's own projections. `public` exposure becomes possible only after a claim. A person's projection prints a shorter block than an organization's, defined beside the organization block in the Registry.

## What an index gives you

An index is a database built by reading every core. It answers questions that a folder of notes answers slowly. Which core has this website, or this name? Which cores point at this one, and how? Do two cores claim the same key? What changed since a consumer last looked?

It can be thrown away and rebuilt from the vault at any time. The vault cannot be rebuilt from the index, which is why the vault is the authority and the index is not.

Lookups run on more than the `hid`. The index derives extra keys from each core's `core_id`, its website host, and its names and aliases, then checks them against the keys the core asserts (derivation rules in the YAML Schema, "Identity"). When two cores claim one key, the index holds the key and reports the pair instead of guessing. Each relation also gets an id computed from the record's content, never from its place in the list, so reordering a list changes nothing.

Consumers read changes, not snapshots. The index keeps a change log with one line per field-level change, and each consumer (the block sync, an export, a coordination board) keeps its own cursor into it. The Registry's sync rules describe the diff.

The index writes exactly one thing back into the vault. When a core has no `hid`, the index mints one. Nothing else flows from the index to the notes.

The Seed does not ship an index yet. The reference implementation stays in the maintainer's workshop, with the reconcile and backfill scripts and the federating tool, until a second vault runs it with only configuration changes. Until then a vault can adopt the contract by hand. A core without a `hid` still works for people, who read `core_id`, and tools that join on `hid` wait for the first index run.

## Giving an existing vault its hids

A vault that already has cores needs a `hid` on each, and the order of the two routes matters.

Check first whether another tool has already issued ids for the same things, such as a canvas, a map or a database that exports records under its own keys. If one has, those ids already sit in other people's exports and links, and minting fresh ones would give every thing two identities. So reconcile first, copying the existing ids into the cores, and mint only for the cores still empty afterwards. If no tool has issued ids, skip straight to the mint.

A reconcile run matches each issued id to a core by `core_id` where the other tool recorded one, and otherwise by name or alias, normalised exactly the way that tool normalised them. A name whose bracketed part gets dropped can collide with another name, and that collision is a held case, never a match. The run obeys five rules.

- It writes a `hid` only where a core has none.
- A core that already carries a different `hid` is a conflict, reported and not written.
- One key matching two cores, or two keys matching one core, is held for a person to decide.
- Every value is checked against the `hid` format in ID families before it is written.
- It never mints and never touches any other field.

Run it dry first and read the report: matched and written, already present, unmatched keys, unmatched cores, conflicts and held. Then apply it, keeping a copy of every core it writes so the run can be undone. Run it dry once more. A clean apply leaves nothing to write.

Then let the index mint for the rest. From then on the other tool reads `hid` from the cores, and its own id map becomes a mirror of the vault rather than the authority.
