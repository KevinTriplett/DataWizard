---
title: Research Note Output Template
type: skill-reference
parent: tools-research
---

# Research Note Output Template

Reference template for the tools-research skill. Adapt sections to fit
the target -- not every section applies to every research target.

## Frontmatter

```yaml
---
title: "Research - [Name] - [Short Description]"
type: project-doc
status: complete | active | stub
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

Status values:
- `complete` -- research is thorough, no obvious gaps
- `active` -- partially researched, more to extract
- `stub` -- initial notes only, needs deeper investigation

## Note Structure

```markdown
# Research - [Name]: [Short Description]

[Opening paragraph: 1-3 sentences. What is it, who made it, why it
matters. End with a one-sentence relevance verdict for your project.]

**URL:** [primary link]
**Repo:** [GitHub/GitLab link if applicable]
**License:** [license]
**Maturity signals:** [stars, commits, contributors, last activity]

---

## What It Does

[Explain in your own words based on what you actually read. What
problem does it address? What's the core insight or approach?]

## How It Works

[Technical substance. Key components, data flow, design decisions.
Reference specific files, classes, or algorithms. Enough detail
that a future reader can understand without re-researching.]

### [Subsections as needed]

[Break into subsections for complex architectures.]

## Key Results or Capabilities

[What has it demonstrated? Benchmarks, concrete capabilities,
limitations. For papers: headline findings. For tools: what it
can actually do vs what it claims.]

## Key Details

[Standout phrases, formulations, failure modes, or specific insights
harvested during reading. These are the gems -- concrete and sharp
enough to be useful months later. Attribute them to their source.]

## Relevance Assessment

**Overall:** [One sentence verdict, then explain why.]

### Ideas Worth Tracking

[Numbered list. Each item names a specific idea AND connects it
to a specific pattern, decision, or document in your project.
Explain why the connection exists.]

### Not Applicable

[Bullet points. Specific about why each aspect doesn't apply.
Prevents future re-evaluation of the same questions.]

### Related Work

[How does this relate to other systems you're tracking?]

---

**Source coverage:** [What you actually read -- full repo, README
only, specific files, paper abstract vs full paper. Be honest.]
**Research status:** [Complete / More to extract / Stub only]
```

## Adapting the Template

- **Research paper:** Emphasize the problem, architecture, key results.
  May not need source file analysis.
- **Tool or framework:** Emphasize how it works, capabilities, compare
  to existing tools you're tracking.
- **Skill collection or methodology repo:** Emphasize patterns and
  specific files worth studying. May warrant multiple passes.
- **Reddit post or discussion thread:** May be lighter. The "Key Details"
  section becomes especially important -- capture the best formulations
  from comments, which are often sharper than the original post.
- **Small or simple project:** May need only 2-3 sections. A brief
  note is better than no note.

## Quality Signals

A good research note:
- Could be read by a fresh instance and give them working understanding
- Connects relevance to specific project patterns by name
- Notes what wasn't read so future passes know where to start
- Separates description from assessment (Phase 1 vs Phase 2)
- Preserves standout details, not just summaries
- Includes enough technical detail to be useful months later

A weak research note:
- Paraphrases the README without going deeper
- Says "interesting" or "relevant" without specifics
- Omits the "Not Applicable" section
- Doesn't note research coverage
- Flattens everything into generic assessment without preserving details
