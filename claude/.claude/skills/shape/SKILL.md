---
name: shape
description: A relentless interview that shapes a plan, decision, or idea into a shared understanding, building a personal, persistent .scratchpad/ knowledge base as it goes. Use when the user wants to stress-test their thinking, shape a change before building it, or uses any 'grill' or 'shape' trigger phrases.
---

# Shape

Shape a change before anyone builds it: interview relentlessly until you and the user share one understanding of what's being made, and write the vocabulary and the hard decisions down as you go.

This is the front door to the whole chain — `/shape → /to-spec → /to-tasks → /build → /review-changes`. It settles *what* and *why*; the spec handles *how*. Don't produce a plan here, and don't start building: shaping is finished when the understanding is shared, not when you can see the solution.

It is self-contained and portable: no other skill, no repo-wide setup, and no assumption that the repo has *any* existing docs infrastructure. Drop this one file into any project and it works the same everywhere.

Everything it writes goes under `.scratchpad/` in the current repo. `.scratchpad/` is understood to be gitignored and personal: your own local, cross-session knowledge base for a project, not a shared deliverable. This skill never writes to `CLAUDE.md`, `CONTEXT.md`, `CONTEXT-MAP.md`, or `docs/adr/` — if those exist, they're read-only inputs here, and if they don't exist, that's completely fine and changes nothing about how this skill works.

## First run in a repo

If `.scratchpad/` doesn't exist yet in this repo, check whether it's already gitignored. If it isn't (no `.gitignore`, or one that doesn't cover it), ask once whether to add a `.scratchpad/` line to `.gitignore`, then proceed either way — don't block the interview on this.

## Part 1 — The interview

Interview the user relentlessly until you reach a shared understanding of the plan, decision, or idea. Map it as a **design tree**: every decision branches into the decisions that hang off it.

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled — the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, existing code, existing docs), go find it yourself — read the files, search the codebase, dispatch a sub-agent if one is available. Don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.

## Part 2 — Reading existing context (optional, never edit these)

This step is opportunistic, not required. Many repos this skill runs in will have none of the following, and that's the normal case, not a missing prerequisite. If any of these happen to exist, treat them as ground truth to interview *against*, not a file to update:

- `CLAUDE.md` (or `AGENTS.md`) — project conventions and standing instructions.
- `CONTEXT.md` at the repo root — existing glossary, if this is a single-context repo.
- `CONTEXT-MAP.md` at the repo root — if present, the repo has multiple contexts; it points to each one's own `CONTEXT.md`. Infer which context the current topic belongs to; ask if unclear.
- `docs/adr/` — existing accepted decisions.

Use these purely as source material, when present:

- If the user uses a term that conflicts with an existing `CONTEXT.md`, call it out immediately: "Your glossary defines 'cancellation' as X, but you seem to mean Y. Which is it?"
- If the user states how something works, check whether the code or an existing ADR agrees, and surface any contradiction.

**Never write to `CLAUDE.md`, `CONTEXT.md`, `CONTEXT-MAP.md`, or `docs/adr/` from this skill**, whether or not they exist. Everything this skill produces goes to `.scratchpad/` instead (Part 3). If the user later wants any of it promoted into real project docs, that's a separate, explicit step they ask for — don't do it as part of shaping, and don't create any of these files as a side effect of shaping either.

## Part 3 — Capturing outcomes in `.scratchpad/`

As the interview resolves things, capture them immediately, inline — don't batch this up for the end.

### Where things live

```
.scratchpad/
├── INDEX.md
└── <topic-slug>/
    ├── glossary.md
    ├── notes.md
    ├── decisions/
    │   ├── 0001-slug.md
    │   └── 0002-slug.md
    ├── spec.md          ← written by /to-spec
    ├── tasks/                 ← written by /to-tasks
    ├── spikes/                ← written by /spike
    ├── research/              ← written by /research
    ├── map.md             ← written by /wayfinder
    ├── map-items/             ← written by /wayfinder
    └── reviews/               ← written by /review-changes
```

This is the shared layout for the whole skill set: every skill in the chain reads and writes the same `<topic-slug>` folder, so a shaping session's glossary is available to the spec, the spec is available to the tasks, and so on. This skill owns `glossary.md`, `notes.md`, and `decisions/`; it reads the rest but doesn't write them.

`INDEX.md` is a flat list of every topic shaped in this repo so far, one line each: the slug, a one-line description, and when it was last touched. This is what makes the scratchpad usable as a *persistent* personal knowledge base rather than disposable output — it's how you or a future session find what's already been worked through.

At the start of any session, resolve the topic:

1. **The user named it.** `/shape partial-refunds` → use that folder.
2. **Read `.scratchpad/INDEX.md`** and match what the user described against existing topics. If it matches or clearly extends one, say so and ask whether to resume that topic (reusing its slug, appending to its `glossary.md`/`notes.md`, continuing decision numbering) or start a fresh one alongside it.
3. **Check the git branch name** against known slugs — a branch `feat/partial-refunds` implies that topic.
4. **Nothing matches** → this is a new topic. Propose a short slug (e.g. `partial-refunds`, `event-bus`), confirm it with the user, and add it to `INDEX.md`.

State the resolved topic in your first line of output: "Working in `.scratchpad/partial-refunds/`." A wrong guess is cheap to correct before files are written and annoying afterwards.

`/shape` is an entry point, so creating a new topic here is normal — unlike the downstream skills, which should be suspicious of it.

Create files lazily — only when you have something to write. Update `INDEX.md` whenever a topic folder is created or touched.

### `INDEX.md`

Every other skill reads this to resolve which topic it's working in, so keep it accurate. One line per topic, most recently touched first:

```markdown
# Scratchpad index

- **partial-refunds** — partial refunds + credit notes on settled invoices. Last touched 2026-08-27. Stage: build (task 02 of 05).
- **adyen-migration** — move billing off Stripe onto Adyen. Last touched 2026-08-14. Stage: wayfinder (3 of 7 items closed).
- **webhook-retries** — dead-letter queue for failed webhook deliveries. Last touched 2026-07-30. Stage: done.
```

The **Stage** field is what makes a cold start cheap: it tells the next session where in the chain this topic stopped, so `/build` knows there are tasks and `/to-spec` knows one already exists. Update it whenever a skill moves the topic forward.

### Vocabulary → `glossary.md`

The moment a term is resolved, write it to `.scratchpad/<topic-slug>/glossary.md` right there in the conversation — don't wait.

Format:

```md
# <Topic> — Glossary

## Language

**Order**:
A one or two sentence description of the term.
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request
```

Rules:

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Only include terms specific to this topic.** General programming concepts don't belong even if the project uses them extensively.
- **Group under subheadings** when natural clusters emerge; a flat list is fine otherwise.
- Keep this file to terms and their definitions. It doesn't need to be as strictly guarded as a shared `CONTEXT.md` would — this is your own notes — but implementation details and running commentary belong in `notes.md` instead, so the glossary stays fast to scan.

### Hard decisions → `decisions/NNNN-slug.md`

Only offer to record a decision when **all three** are true:

1. **Hard to reverse**: the cost of changing your mind later is meaningful.
2. **Surprising without context**: a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off**: there were genuine alternatives and you picked one for specific reasons.

If any of the three is missing, skip it — most sessions produce zero of these, and that's normal.

When one qualifies, offer to write it, and if the user agrees, create `.scratchpad/<topic-slug>/decisions/NNNN-slug.md` (scan the folder for the highest existing number and increment):

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

That's it — an entry can be a single paragraph. Only add more if it genuinely earns its keep:

- **Status** (`proposed | accepted | deprecated | superseded by 0000-slug`): only if decisions here tend to get revisited.
- **Considered Options**: only when the rejected alternatives are worth remembering.
- **Consequences**: only when non-obvious downstream effects need calling out.

### Everything else → `notes.md`

Because this is a personal scratchpad rather than a shared, reviewed artifact, you don't have to throw away everything that isn't a clean glossary term or a gate-clearing decision. Anything worth remembering later — a resolved question that isn't quite a "term," an assumption the user confirmed, a piece of reasoning behind a softer call — can go in `.scratchpad/<topic-slug>/notes.md` as a running, timestamped or round-numbered log. This is the lower-bar catch-all; keep `glossary.md` and `decisions/` reserved for things that actually meet their respective bars.

## Closing the session

When the frontier is empty and the user confirms the shared understanding is reached:

1. Update `INDEX.md` with this topic's slug, one-line description, today's date, and Stage (`shape` if the next step is `/to-spec`).
2. Summarize what landed in `.scratchpad/<topic-slug>/` — which terms, which decisions (if any), and whether anything went to `notes.md`.
3. Mention plainly that nothing outside `.scratchpad/` was touched, and that promoting any of it into real project docs (`CONTEXT.md`, `docs/adr/`) — if this repo even has that infrastructure — is a separate, explicit step they can ask for next. Don't do it unprompted.
