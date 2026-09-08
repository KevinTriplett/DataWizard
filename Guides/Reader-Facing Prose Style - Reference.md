---
title: Reader-Facing Prose Style - Reference
type: guide
created: 2026-09-08
updated: 2026-09-08
operator: Andrew
status: active
edit_log:
  - "DW-S349 2026-09-08 - created; deep companion to Reader-Facing Prose Style (full survey record, merged catalogs, thresholds, calibrations, divergences)"
---

# Reader-Facing Prose Style - Reference

The deep layer behind `Reader-Facing Prose Style.md`. The guide is the operative document and the only one to load routinely. Load this file in two situations: an instance is struggling with a style problem the guide's rules do not resolve, or someone is revising the guide and needs the source record. Raw copies of every surveyed source file are archived in the maintaining vault at `Workshop - DataWizard/Research/Prose Style Survey Sources/` (DW-local, not shipped with the Seed).

## The eight sources, profiled

**1. andrewroxby/claude-style-patch** (CC0, ~1,600 words). A binding response-style contract, not a rewrite tool. Sharpest diagnostic in the survey: the announcing habits (colon-hinged sentences, verbless fragment openers, depth-signaling) are one underlying behavior, narrating a discourse plan before executing it, and the repair is always to fold the label into the sentence that does the work. Also the origin of the stacked-compression analysis: metaphor plus nominalization plus adjacency is what makes dense prose undecodable. Contributed the guide's diseases 1 and 4, the colon rule, the antecedent rule, proportion-and-endings, and Tractatus numbering for genuinely hierarchical documents.

**2. bharvey2026/humanise-skill** (MIT, ~1,800 words). A surface-level editor with a strict preservation contract: never change, add, or remove substance. Largest clean vocabulary-swap tables (verbs, adjectives, nouns, each with context-dependent replacements). Distinctive: kill false balance and performative empathy, allow imperfect grammar as a human signal, do NOT fix every instance (a human editor leaves minor flaws; over-editing creates its own uncanny valley), and the closing portrait "what good human writing sounds like". Contributed disease 6's false-balance and teacher-voice items and the preservation stance.

**3. harshaneel/humanize** (MIT, ~5,600 words plus a 4,000-word ai-check scoring twin). The most rigorous source, grounded in detection literature. Its frame: nine measured signals (perplexity, burstiness, hedge density, lexical repetition, structural markers, specificity, part-of-speech density, punctuation fingerprint, RLHF voice), each with a write-side lever. Three ideas the whole guide leans on: the model that wrote the draft cannot check it by feel, so every gate is a literal scan with written counts and explicit zeros; flagged residuals get removed, not justified ("borderline but I'm keeping it because..." means the pattern won); and current detectors mostly fire on the instruction-tuned assistant voice, making RLHF stripping the single most valuable lever. Also the master banned-vocabulary list and the rhetorical-scaffolding checklist reproduced below.

**4. jpeggdev/humanize-writing** (MIT, ~3,800 words plus an ai-tells reference; built on Wikipedia's "Signs of AI writing", maintained by WikiProject AI Cleanup). Eight editing passes ordered structure-first. Distinctive: significance inflation and promotional register as their own passes with delete-and-replace-with-a-fact as the fix; pattern stacking (multiple weak signals on one phrase is one strong tell, count it once); calibrated non-tells (a single "serves as" is normal, title case is standard in AP/Chicago, curly quotes are correct in publishing contexts, "as of [date]" is standard journalism); and Pass 8, "add human texture and soul", because sterile clean prose is also a tell. Contributed diseases 3 and 7 and much of the verification pass's count-before-claiming discipline.

**5. artemnovitckii/content-skills, anti-ai-writing** (MIT, ~1,900 words). The best philosophical frame: the goal is not "don't sound like AI" (chasing a negative gives a beige voice) but "sound like a specific person who has thought about the thing." Origin of the five-diseases diagnostic method, the four-level specificity ladder (vague, specific, concrete, lived; aim level 3 minimum), the rule-priority order (accurate > clear > specific > voiced > stylish), the earned-contrast test that rescues honest "not X but Y" uses, the five-part analogy test with banned metaphor families, the byline test (cover the byline; could ten other writers have produced this?), and the anti-overfitting section. Contributed the guide's stance section nearly whole.

**6. haidrrrry/humanize-ai-writing** (MIT, ~750 words). The most compact formulation: twelve rules, Wikipedia-derived. Distinctive: strip machine artifacts (contentReference, oaicite, turn0search markers, utm parameters in links, markdown leaking into plain text), and the don't-overcorrect note: a single flagged word is not proof of AI; avoid clusters, and never mangle a sentence or delete information to purge one banned word.

**7. celestialdust/humanize-prose** (MIT). The empirical source: eight drafts of one real essay, GPTZero-scored. Trajectory: v4 tighter phrasing 75%, v5 voice texture 68%, v6 cut ~500 words of abstraction and added a direct quote plus three dates, 21%; then two refinement passes regressed to 56% and 66% despite feeling like improvements. Lessons the guide encodes: cut, do not rephrase; evidence density beats stylistic tuning; diagnose paragraphs first and leave evidence-dense ones alone; refinement past the win regresses; detector variance is 10-20 points, so stop when three rewrites land close. Also flags a real bias: non-native speakers and technical writers get over-flagged because their prose reads low-perplexity.

**8. lguz/humanize-writing-skill** (MIT). Three-pass model (vocabulary, structures, texture) with a tiered dictionary: tier 1 words are strong signals alone, tier 2 suspicious in clusters of three or more, tier 3 transitions fine alone but AI clusters them. The tiering matters: it prevents the false positive of flagging one ordinary word.

## Merged catalogs

### Banned vocabulary, by category

Tier 1 (strong signal alone): delve, tapestry (figurative), testament (figurative), pivotal, leverage (verb), harness, realm, myriad, plethora, paradigm, synergy, multifaceted, groundbreaking (figurative), revolutionize, embark, nestled, boasts, landscape (abstract noun), ecosystem (non-biological), interplay, intricacies.

Tier 2 (suspicious in clusters of 3+): robust, comprehensive, seamless, cutting-edge, innovative, nuanced, crucial, compelling, transformative, bolster, underscore, showcase (verb), evolving, foster, facilitate, streamline, imperative, intricate, overarching, unprecedented, meticulous, holistic, vibrant, garner, enduring, elevate, unlock, unleash.

Hedge and softener clusters: it is important to note, it is worth mentioning, notably, generally speaking, in many cases, it can be argued, arguably.

Formula openers and closers: in today's fast-paced world, in the ever-evolving landscape of, in an era of, imagine a world where, have you ever wondered, in conclusion, in summary, at the end of the day, at its core, the future looks bright, only time will tell, exciting times lie ahead.

Transition fingerprint: furthermore, moreover, additionally (as opener), it is clear that, this highlights, this underscores, as previously mentioned, that said, with that in mind, moving forward, when it comes to.

Significance inflation: stands as a testament to, marks a pivotal moment, plays a vital role, indelible mark, setting the stage for, deeply rooted in, key turning point, represents a shift, reflects a broader.

Promotional register: nestled in the heart of, breathtaking, must-visit, stunning, boasts a rich heritage, renowned for, world-class, state-of-the-art, passionate about, we're excited to.

Signposting: let's dive in, let's explore, let's break this down, here's what you need to know, without further ado.

Chat artifacts: great question, you're absolutely right, of course!, certainly!, I hope this helps, let me know if you'd like me to elaborate, as of my training cutoff.

Machine artifacts: contentReference, oaicite, turn0search markers, utm_source in links, markdown syntax leaking into plain text.

### Filler-phrase substitutions

due to the fact that > because | in the event that > if | has the ability to > can | for the purpose of > to | with regard to > about | prior to / subsequent to > before / after | in light of the fact that > since | despite the fact that > although | in order to > to | at this point in time > now | make a decision > decide.

### Rhetorical scaffolding checklist (the patterns that survive vocabulary cleanup because they feel like good writing)

Mini-aphorism paragraph closers (a 4-to-10-word punchy "lesson"); thesis-first paragraph openers (frame before experience); parallel-subject mirrors ("The code is one thing. Maintaining it is another."); an aphoristic final sentence on the whole piece; pattern announcement; "turns out" reveal pivots; setup sentences ("What I didn't expect was X"); anaphora (same opener on consecutive sentences); either/or binaries flattening a spectrum; balanced parenthetical pairs (real trade-offs are asymmetric); tricolons with identical grammar and escalating weight; chiasmus (reversed-parallel constructions that sound like insight); false ranges ("from X to Y" with no real scale); rhetorical question plus immediate answer ("The result? A 30% increase."); trailing participle fake-depth; copula avoidance clusters; synonym cycling; the perfect paragraph-per-idea arc (let one paragraph do two jobs); local over-smoothness (every sentence connecting perfectly reads machine-made; one slightly misfiring thought per stretch is human).

Three or more hits in one piece compound into a clear signature; fix all of them, not the worst one.

### RLHF / assistant-voice tells

"Here's how I'd think about it" framing > just say the thing. Balanced trade-off offering where the piece has a position > pick the side. Unrequested option enumeration > answer, then caveat if needed. Defining terms the audience knows > cut, trust the reader. Caveats appended to every claim > caveat only the plausible edge case. Closing recap > cut. Polite refusal-shaped disagreement ("While I understand the appeal of X...") > "X doesn't work because Y." Symmetric framing of asymmetric trade-offs > state the asymmetry.

## Countable thresholds (the numbers behind the guide's verification pass)

Em dashes: at most one per 300 words; zero under 300 words (source budgets ranged from 1/300 words to 1/500 words to 1 per 3-4 paragraphs; the guide takes the strictest that survives real prose). Even one em dash is a tell when it injects a dramatic mid-sentence aside. Semicolons: zero outside comma-containing lists and explicitly academic registers. Sentence spread in passages over ~80 words: longest minus shortest at least 20 words; fewer than half the sentences in the 10-to-20-word band; no three consecutive sentences within 5 words of each other; at least one sentence of 6 words or fewer per 150 words. Negative parallelism: in a piece under 1,000 words, once is plenty. Hedges: one per article is normal, five is a signature. Analogies: zero by default under 800 words, then about one per 1,500 words, and only if literal explanation would be longer AND less clear.

## Domain calibrations

**Technical:** domain-native vocabulary ("the hot path", "this falls apart at scale"), short definitive sentences for definitive claims, real tool names and version numbers, direct trade-offs.

**Narrative and essay:** open with a scene or incident, not a thesis; let the argument emerge; deliberate fragments for rhythm; one genuine moment of uncertainty or changed mind per ~500 words.

**Creative and lyrical:** the register where every rule gets rationalized away ("this em dash is doing literary work"). The rules hold. Human lyrical prose gets texture from specificity and asymmetry - a named street, a wrong note, an image that does not resolve - not from punctuation drama or balanced imagery pairs.

**Business:** the ask in sentence one or two, numbers and deadlines, paragraphs of 2-3 sentences.

**Chat and async updates:** register collapse is the tell - a polished status report with full clauses reads machine-made. Real async writing has abbreviations, approximations (~3-4 days), fragments, self-corrections, and structure that actually breaks. But do not fake disfluency in formal writing; hesitations in a board memo are their own tell.

## Advanced techniques, when stakes are high

Writer-profile distillation: when writing samples exist, extract 5-10 concrete style hypotheses first (sentence-length variance, punctuation habits, opener style, verbal tics, transition style) and edit toward the sample's register, not toward this guide's default terseness - replacement, not just removal. Detector-scored best-of-N: generate 3-5 variants, score, ship the lowest. Iterative paraphrase: at most two passes, then meaning drift outweighs gains. Self-rewrite distance: ask a different model to rewrite it in different words; a near-identical rewrite means the text sits at a probability maximum and still reads machine-made. Dead ends per the literature: homoglyph tricks, single cross-model rewrites, watermark stripping.

The biggest practical trap in rewriting: editing your own recent output. It anchors to its phrasing and silently degrades into word swaps that keep the original's rhythm and pivots. Treat your own prior draft as foreign text: extract what it says, re-derive the prose from the content. An edit log that reads as a list of substitutions means it was light-edited; start over.

## Where the sources disagreed, and how the guide ruled

Curly quotes: one source bans them outright (a surviving single-character tell), another notes they are typographically correct in publishing contexts. The guide omits a hard rule and keeps the Seed's existing straight-quote convention. Colons: the strictest source bans all colon-hinged clauses; others allow "Here's the problem: nobody tests this." The guide takes the strict rule because the colon-hinge is the announcing disease in miniature. Change summaries after a rewrite: one source bans any trailing changelog (evidence of light editing), another mandates a compact changes table. The guide sides with reporting verification counts, not a change narrative. First-person insertion: two sources encourage adding "I" and opinions; two warn against inserting a self that was not there. The guide permits voice but never invented experience, consistent with never inventing specifics. Em-dash budgets varied threefold; the guide takes the strictest.

## Maintenance

When revising the guide: re-check this file's catalogs against the archived raw sources before trimming anything (a rule that looks redundant may be the only trace of a real tell), and remember the blocklists rot - the principles (any word doing PR for an idea; any label preceding its payload; any symmetry substituting for content) outlive every list. Survey date: 2026-09-08.
