---
title: Reader-Facing Prose Style
type: guide
created: 2026-09-08
updated: 2026-09-08
operator: Andrew
status: active
edit_log:
  - DW-S349 2026-09-08 - created; synthesis of 8 public style/humanizing skills (survey + meta-pattern extraction)
  - DW-S349 2026-09-08 - Exemplar section added; deep-layer pointer to the Reference companion
---

# Reader-Facing Prose Style

A synthesis of the strongest public rulesets for making AI-drafted prose read as human prose. This guide is the writing standard for any document a person will actually read - research resources, reports, onboarding docs, essays, anything read start to finish or aloud. It is the mandatory load for the writer role in the model-casting skill, and useful to any instance producing reader-facing text.

The problem it solves is real and specific. Model-drafted research documents can be accurate, well-organized, and still nearly unreadable aloud. The failure is not intelligence. It is a set of identifiable habits that current models overproduce, and that the model reviewing its own draft cannot see by feel - the model that wrote the draft is the model checking it. This guide names the habits and gives a countable verification pass that does not rely on feel.

Eight public rulesets were surveyed for this synthesis (full credits at the end). Where they converge, that convergence is the strongest evidence available that a pattern is a real tell. What follows is the convergent core, organized as: the stance, the seven diseases, the binding rules, and the verification pass.

## The stance

Three principles frame everything below.

**Sound like a specific person who has thought about the thing and has something to say.** The goal is not "don't sound like AI" - chasing a negative produces beige prose that is its own tell. Specificity and voice are the moat.

**Priority order when rules collide: accurate, then clear, then specific, then voiced, then stylish.** Never sacrifice accuracy for style. A boring true sentence beats an elegant vague one.

**Spirit beats letter.** If a rule below makes a sentence worse, break it. Do not compose against the blocklist - write the draft naturally first, then run the verification pass. Over-editing produces choppy, voiceless prose that reads just as machine-made; one survey source measured a draft getting objectively worse through two rounds of "refinement" after the big win came from cutting filler and adding specifics. Know when to stop.

## The seven diseases

Every surveyed ruleset converges on the same small set of root causes. Diagnose the disease and the fix is usually obvious. If you cannot name the disease, read the line aloud - it becomes audible.

**1. Announcing instead of saying.** The prose narrates its own discourse plan before executing it. A label appears before the payload: colon-hinged sentences where the left side names what the right side does, verbless fragments as paragraph openers, "the key insight is", "what I didn't expect was", "here's the thing", signposting ("let's dive in", "now let's look at"), pattern announcement ("the pattern is X"). The repair is always the same. Fold the label into the sentence that does the work. Start with the point.

**2. Manufactured antithesis.** The "not X but Y" family: "it's not just X, it's Y", "not only X but also Y", "the real question isn't X, it's Y", "X isn't new. Y is." Every surveyed source bans this family; it is the single most cited structural tell. The reframe usually hides the absence of a point. Fix: delete the rejected half and rewrite the positive half as a direct claim with specifics. One test rescues the honest cases: contrast is earned when the second half is concrete (a number, an instance, a mechanism) and the piece delivers it; it is banned when the second half is vague significance ("it's about mindset").

**3. Significance inflation and the promotional register.** Normal facts dressed as turning points: "stands as a testament", "marks a pivotal moment", "plays a vital role", "evolving landscape", "nestled in the heart of", "vibrant", "renowned". The fix is not a synonym. Delete the inflation and replace it with a specific fact. "Established in 1989, marking a pivotal moment in regional statistics" becomes "established in 1989 to publish regional statistics independently."

**4. Stacked compression.** Three moves that are each fine alone and damaging together: turning a concept into a metaphor, freezing a verb into a noun phrase, then packing the compressed units against each other. The reader must decode more than one packed phrase at once. This is the disease that makes dense synthesis unreadable aloud. Fix: keep verbs as verbs, at most one figure per sentence, never two compressed units side by side, and never leave the reader inside a metaphor - cash it out immediately. Related grammar-level tells from the survey: copula avoidance ("serves as" / "boasts" instead of "is" / "has"), trailing participle fake-depth ("..., highlighting its importance"), synonym cycling (protagonist / main character / central figure for one referent - pick the canonical noun and reuse it), and false ranges ("from the Big Bang to the dance of dark matter").

**5. Metronomic rhythm.** Every sentence 15 to 20 words, every paragraph three sentences, every list three items. Human writing is bursty. Fix by counting, not feel: vary sentence length aggressively (some under six words, some over twenty-five), vary paragraph length, break the rule-of-three reflex when the real count is two or four.

**6. Assistant voice.** The instruction-tuned register leaking into prose: hedge clusters ("it is important to note", "generally speaking"), false balance ("on one hand... on the other") where the piece actually has a position, teacher voice defining terms the audience knows, sycophantic or chat artifacts ("great question", "I hope this helps"), summary closers restating what was just said, vague attributions ("experts argue") in place of named sources. Fix: assert directly, pick a side, trust the reader, name the source or cut the claim, end when the content ends.

**7. Formula structure.** The same section shape repeated: setup paragraph, three bullets, takeaway bow; "Challenges and Future Prospects" sections; intro-body-body-conclusion with a restating conclusion. Fix: vary section lengths, let some sections end abruptly, merge the "what this means" into the text, replace formula sections with the specific facts they were padding over.

## The binding rules

The operative distillation. These are checked in the verification pass.

1. Start with the point. No sentence may announce what the next sentence will do.
2. No colon-hinged sentences. A colon introduces a literal list of three or more items, or follows a complete sentence to introduce an example. Nothing else.
3. No verbless fragments as sentences or paragraph openers (fine inside parentheses or after a dash).
4. No "not X but Y" and variants, unless the second half passes the earned-contrast test above.
5. Subject, verb, object. Convert nominalizations back into verbs. Prefer "is" and "has" over "serves as", "represents", "boasts". Prefer plain Anglo-Saxon words when nothing is lost.
6. One metaphor per sentence at most, cashed out immediately. Never two compressed units adjacent.
7. Every abstract claim gets a grounding anchor: a number, a name, a date, a concrete example. Never invent one - if the specific is missing, say so plainly or go get it.
8. Cut hedges unless the uncertainty is real; then name the actual exception ("this breaks down when X"), not "generally speaking".
9. Vocabulary: cut any word doing PR for an idea instead of describing it. High-frequency offenders: delve, leverage, utilize, robust, comprehensive, seamless, pivotal, crucial, tapestry, testament, landscape (figurative), realm, myriad, plethora, foster, streamline, harness, furthermore, moreover, "it is important to note". The principle outlives the list.
10. Transitions do logical work or do not appear. "But", "so", "because", "and" - or nothing. Not "furthermore".
11. Punctuation: em dashes rare (at most one per 300 words; this Seed's patch-safety rule already bans them in headings and anchor text). Semicolons almost never. Straight quotes. Bold only when genuinely additive.
12. Vary rhythm on purpose. In any passage over ~80 words, the longest sentence should beat the shortest by 20 or more words, and fewer than half the sentences should sit in the 10-to-20-word band.
13. Antecedents clear. The reader never investigates what "it", "this", or a noun phrase refers to.
14. End when the content ends. No summary paragraph, no uplifting closer, no engagement-bait question.
15. Never change substance while editing style. Every claim, number, quote, and conclusion survives intact.

## Exemplar

Before, exhibiting diseases 1 through 5 in four lines:

> Here's the key insight: Mondragon's model isn't just a business structure - it's a living tapestry of economic solidarity. By leveraging shared institutions - a bank, a university, a social-security mutual - the federation has navigated seven decades of challenges, underscoring the pivotal role of binding rules in fostering resilience and marking a turning point in cooperative economics.

Announcing opener, manufactured antithesis, significance inflation, banned vocabulary, two figures packed per sentence, every sentence the same weight. After:

> Mondragon is a federation of worker-owned cooperatives that has run for seventy years on shared institutions: a bank, a university, and a social-security mutual. The binding rules matter most. They govern how money, risk, and people move between otherwise independent enterprises, which is why the federation survived recessions that killed standalone cooperatives.

Nothing was lost but the decoration, and the after version carries more information.

## The verification pass

Run this on every finished reader-facing draft. The checks are counts and scans, not impressions - a mental read-through always sounds varied to the model that wrote it.

1. **Scan and count, writing the numbers down.** Em dashes (target: word count / 300 or fewer). Semicolons (target: 0 outside comma-containing lists). Colon-hinged sentences (target: 0). "Not X but Y" family hits (quote each, apply the earned-contrast test). Banned-vocabulary hits (quote each). A gate entry without an explicit count is a gate that was not run.
2. **Rhythm check from counts.** For a sample section, list every sentence's word count in order and check rule 12. Fix by splitting one mid-length sentence into a fragment plus remainder, or merging two mid-length neighbors.
3. **The read-aloud test.** Read a paragraph aloud, or imagine reading it to a colleague. Flag anything no human would say in conversation, anything that sounds like a press release, anything decodable rather than followable. This is the test the whole guide exists to pass.
4. **The byline test.** Could this passage have been written about any topic by swapping a few nouns? If yes, the specificity is missing - find it.
5. **One repair loop, then stop.** Fix what the scans flagged, re-scan only the sentences you rewrote (regenerated prose reintroduces tells at the same rate), and ship. Flagged residuals get removed, not justified - "this register needs it" is how the patterns survive. Past a second loop you are over-editing into voiceless prose.

## What to preserve

Style editing never touches substance. Keep technical accuracy, data points, proper nouns, attributions, and the argument. Do not pad a draft that got shorter - if the humanized version is much shorter than the input, the input was mostly puffery, and padding it back reintroduces the stripped patterns. And do not sand off genuine voice: opinions, asymmetric trade-offs, mixed feelings, and the occasional aside are what human writing has and formula writing lacks.

## Sources and credits

This guide synthesizes, with thanks:

| Source | License | Distinctive contribution |
|---|---|---|
| [andrewroxby/claude-style-patch](https://github.com/andrewroxby/claude-style-patch) | CC0 | The announcing diagnosis, the colon rule, stacked compression |
| [bharvey2026/humanise-skill](https://github.com/bharvey2026/humanise-skill) | MIT | Vocabulary swap tables, false-balance and teacher-voice fixes, "what good human writing sounds like" |
| [harshaneel/humanize](https://github.com/harshaneel/humanize) | MIT | Nine detection-literature levers, count-based gates, RLHF-voice stripping, rhetorical-scaffolding checklist |
| [jpeggdev/humanize-writing](https://github.com/jpeggdev/humanize-writing) | MIT | Eight-pass structure, significance inflation, grammar-level tells (from Wikipedia's "Signs of AI writing") |
| [artemnovitckii/content-skills](https://github.com/artemnovitckii/content-skills) (anti-ai-writing) | MIT | The five diseases framing, the specificity ladder, the earned-contrast test, rule priority, anti-overfitting |
| [haidrrrry/humanize-ai-writing](https://github.com/haidrrrry/humanize-ai-writing) | MIT | Compact 12-rule formulation, artifact stripping, don't-overcorrect note |
| [celestialdust/humanize-prose](https://github.com/celestialdust/humanize-prose) | MIT | Empirical drafts record: cut don't rephrase, evidence density wins, refinement regresses, know when to stop |
| [lguz/humanize-writing-skill](https://github.com/lguz/humanize-writing-skill) | MIT | Three-pass model, tiered banned-word dictionary |

Related Seed docs: the Conventions Registry (Model routing entry - which model should be writing in the first place), the model-casting skill (roles and execution), Filename Safety (character rules this guide's own text follows).

Deep layer: `Reader-Facing Prose Style - Reference.md` (same folder) holds the full survey - per-source profiles, complete merged catalogs, countable thresholds, domain calibrations, advanced techniques, and where the sources disagreed. Load it only when this guide's rules are not resolving a problem, or when revising this guide.
