---
title: Research Note Output Template
type: skill-reference
parent: repo-research
---

# Research Note Output Template

Reference template for the repo-research skill. Adapt sections to fit the target — not every section applies to every research target.

## Frontmatter

```yaml
---
title: "Research - [Name] - [Short Description]"
type: project-doc
status: complete | active | stub
created: YYYY-MM-DD
updated: YYYY-MM-DD
datawizard_protocol_version: "[current version]"
---
```

Status values:
- `complete` — research is thorough, no obvious gaps
- `active` — partially researched, more to extract
- `stub` — initial notes only, needs deeper investigation

## Note Structure

```markdown
# Research — [Name]: [Short Description]

[Opening paragraph: 1-3 sentences positioning the project. What is it,
who made it, why it matters in the landscape. End with a one-sentence
relevance verdict for the current project.]

**Repo:** [URL]
**Paper:** [arXiv or publication link, if applicable]
**License:** [license]
**Maturity signals:** [stars, commits, contributors, last activity, age]
**Local clone:** [path, if cloned locally]

---

## [What It Does / The Problem It Solves]

[Adapt section name to fit. Explain the project in your own words
based on what you actually read, not README marketing. What problem
does it address? What's the core insight or approach?]

## [Architecture / How It Works]

[The technical substance. Key components, data flow, design decisions.
Reference specific files, classes, or algorithms you read. Include
enough detail that a future reader can understand the system without
re-researching it.]

### [Subsections as needed]

[Break into subsections for complex architectures. Components, workflow
steps, data model — whatever structure fits the target.]

## [Key Results / Capabilities]

[What has it demonstrated? Benchmarks, concrete capabilities, known
limitations. For papers: headline findings and transfer results.
For tools: what it can actually do vs what it claims.]

## DW Relevance Assessment

**Overall:** [One sentence: directly relevant / worth tracking / tangentially
relevant / not applicable. Then explain why.]

### [Ideas Worth Tracking / Patterns to Adopt / Conceptual Resonances]

[Numbered list. Each item names a specific idea AND connects it to
a specific DW pattern, decision, or document. Explain why the connection
exists, don't just assert it.]

### [Not Applicable / Where It Diverges]

[Bullet points. Be specific about why each aspect doesn't apply.
This prevents future researchers from re-evaluating the same questions.]

### [Related Work in DW Context]

[How does this relate to other tracked systems? NAO, Weave, tools in
the AI Memory Landscape doc, etc.]

---

**Source:** [What you actually read — repo README, specific source files,
paper abstract vs full paper, blog posts, community discussion. Be honest
about coverage.]
**Status:** [Research complete / More to extract / Stub only]
```

## Adapting the Template

The sections above are guidelines, not requirements. Adapt based on what the target actually is:

- **Research paper:** emphasize The Problem, Architecture, Key Results. May not need detailed source file analysis.
- **Tool/framework:** emphasize How It Works, Capabilities, and compare to existing tools in the vault.
- **Skill collection or methodology repo:** emphasize patterns and specific files worth studying. May warrant a harvest-style extraction rather than a single summary.
- **Small/simple project:** may need only 2-3 sections. A brief note is better than no note.

## Quality Signals

A good research note:
- Could be read by a fresh instance and give them working understanding of the system
- Connects relevance to specific project patterns by name (not "this is interesting for us")
- Notes what wasn't read so future passes know where to start
- Separates description from assessment (Phases 1 and 2 of the workflow)
- Includes enough technical detail to be useful months later

A weak research note:
- Paraphrases the README without going deeper
- Says "interesting" or "relevant" without explaining specifically why
- Omits the "Not Applicable" section (this is where honest assessment lives)
- Doesn't note the research coverage or what remains unread
