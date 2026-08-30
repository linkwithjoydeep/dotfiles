# Personal skill set

A portable, scratchpad-based fork of the [mattpocock/skills](https://github.com/mattpocock/skills) flow and shaping skills, inspired by that project's shape → spec → tasks → build → review chain. Everything here writes to `.scratchpad/` instead of an issue tracker: gitignored, personal, and requiring no project setup — drop any of these files into `.claude/skills/` in any repo and it works the same way.

## The chain

```
/wayfinder ─────► for efforts too big for one session
    │
    └──► /shape ──► /to-spec ──► /to-tasks ──► /build ──► /review-changes
             ▲
             │  supporting skills, pulled in as needed:
             ├── /spike          answer a design question with throwaway code
             ├── /research       gather facts from primary sources
             ├── /module-design  vocabulary for interfaces, seams, depth
             └── /tdd            red-green loop, used by /build
```

Start at `/shape` for a normal change. Start at `/wayfinder` when the effort spans multiple sessions and the route to a destination isn't visible yet. Everything downstream lives in one shared folder per piece of work: `.scratchpad/<topic-slug>/` — see [Scratchpad layout](#scratchpad-layout).

## The skills

### `/shape`

Interviews you, relentlessly, until you and the model share one understanding of what's being built and why. Works the request as a **design tree**: it asks every question it can answer right now (the **frontier**), waits for your answers, then asks the next round — never guessing at something you haven't told it, and never asking you something it could have looked up itself. This is the front door to the whole chain: it settles *what* and *why*; it deliberately does not produce a plan or start building.

As terms and hard decisions get settled, they're written immediately to `.scratchpad/<topic-slug>/glossary.md`, `decisions/`, and `notes.md` — not batched up for the end.

**Use it** to shape a change before anyone builds it, or to stress-test a plan you already have in mind. Trigger phrases: "shape this," "grill me on this," or just `/shape <what you're thinking about>`.

### `/to-spec`

Turns the current conversation into a written spec — no interview, pure synthesis of what's already been discussed. If you invoke it cold, without enough context in the conversation to synthesize from, it says so and points you back to `/shape` rather than inventing requirements.

Writes `.scratchpad/<topic-slug>/spec.md`: problem statement, solution, user stories, implementation decisions, testing decisions (including the seams to test at), and out-of-scope notes.

**Use it** right after a `/shape` session, once the shared understanding is in your head and just needs writing down.

### `/to-tasks`

Breaks a spec (or the conversation) into **tracer-bullet tasks**: vertical slices through every layer, each sized for one fresh context window, each declaring which other tasks **block** it. Proposes the breakdown, asks whether the granularity and blocking edges feel right, and iterates until you approve. The one exception to vertical slicing is a **wide refactor** (a mechanical change with huge blast radius) — that gets sequenced as expand → migrate-in-batches → contract instead of tracer bullets.

Writes one file per task under `.scratchpad/<topic-slug>/tasks/<NN>-<slug>.md`.

**Use it** after `/to-spec`, to turn the spec into an ordered, buildable backlog.

### `/build`

Implements one task (or a spec directly, if there's no task breakdown). Picks up the **frontier** task — the lowest-numbered one whose blockers are all done — reads the glossary and decisions first so its output uses the right vocabulary, and uses `/tdd` at the seams the spec already agreed on. Records the starting commit before touching code, so it has a fixed point to hand `/review-changes` afterward. Builds exactly one task per session and stops rather than rolling into the next.

**Use it** to execute a task from `.scratchpad/<topic-slug>/tasks/`, or a spec directly for simpler work that never needed a task breakdown.

### `/review-changes`

Reviews the diff between `HEAD` and a fixed point you supply (a commit, branch, tag, or merge-base) along **two separate axes**, each run by its own sub-agent so neither pollutes the other's judgment:

- **Standards** — does the diff follow this repo's documented conventions (`CLAUDE.md`/`AGENTS.md`, `CONTRIBUTING.md`, etc.), plus a fixed baseline of Fowler code smells that applies even when the repo documents nothing?
- **Spec** — does the diff actually deliver what the originating spec or task asked for, with nothing missing and nothing extra?

The two reports are never merged or reranked against each other — code can cleanly pass one axis and fail the other, and collapsing them into one verdict would hide that.

Writes `.scratchpad/<topic-slug>/reviews/<date>-<fixed-point>.md`.

**Use it** after finishing a task or a change, to check it before committing — `/build` calls this automatically at the end of each task.

### `/spike`

Builds throwaway code to answer one design question, fast. Picks one of two shapes depending on the question:

- **"Does this logic/state model feel right?"** → a single self-contained HTML file with free-play buttons and guided walkthroughs through the hard-to-reason-about cases, driveable by a non-developer.
- **"What should this look like?"** → several radically different UI takes on one route, switched by a URL param.

Either way it's throwaway from day one, trivial to run, has no persistence and no polish — the point is to learn something fast, not to ship it.

Writes the verdict (not the disposable code) to `.scratchpad/<topic-slug>/spikes/<NN>-<question-slug>.md`.

**Use it** when a question is cheaper to answer by building a rough, concrete thing than by discussing it in the abstract.

### `/research`

Spins up a background agent to read so you don't have to stop and do it yourself. It chases every claim back to a **primary source** (official docs, source code, specs, first-party APIs) rather than a secondary write-up, and it gathers facts only — if the investigation surfaces a real choice to make, it stops and hands that back as a `/shape` item rather than deciding it.

Writes `.scratchpad/<topic-slug>/research/<question-slug>.md`: a short answer up front, then the findings with sources, then what's still unresolved.

**Use it** whenever a decision is blocked on a fact you'd otherwise have to go dig up yourself.

### `/module-design`

Not a session you run so much as shared vocabulary the other skills lean on: **module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**. The core idea is the **deep module** — a lot of behavior behind a small interface, sitting at a clean seam, testable through that interface alone — and a few sharp tests for it (the deletion test, "one adapter is hypothetical, two is real").

It has no topic-resolution step of its own: it writes into whatever topic the calling skill already resolved, and only records a decision or glossary term if one gets settled and is worth keeping.

**Use it** when designing or reshaping an interface, deciding where a seam belongs, or when another skill (`/tdd`, `/to-spec`) needs this vocabulary underneath it.

### `/tdd`

The red → green loop, plus everything that makes the tests it produces worth keeping: test at pre-agreed seams only (never invent one mid-loop), one slice per cycle, no horizontal "write all the tests, then all the code." Documents the anti-patterns to catch in review — implementation-coupled tests, tautological assertions, mocking anything you don't control — with worked good/bad examples.

If `.scratchpad/<topic-slug>/spec.md` exists, its Testing Decisions section already names the agreed seams, so this skill reads those instead of re-litigating them.

**Use it** test-first for any non-trivial feature or bugfix; `/build` reaches for it automatically at the seams the spec agreed on.

### `/wayfinder`

For an idea too big for one session and too foggy to plan yet. Charts a **map** — a destination, plus **decision items** sized one-per-session — and works the map's **frontier** one item at a time rather than trying to see the whole route up front. Deliberately doesn't chart what it can't yet see: the unresolved-but-visible stuff goes in **Not yet specified**, sharpening into real items only as earlier items resolve. Never resolves more than one item per session (except research items, which can run in parallel).

Writes `.scratchpad/<topic-slug>/map.md` and one file per item under `map-items/`.

**Use it** to plan work that's too large or unclear for `/shape` to tackle directly — `/wayfinder` itself calls `/shape` to pin down the destination, and hands off to `/to-spec` or `/to-tasks` once the map is clear.

## Scratchpad layout

Every skill above works inside one shared topic folder, so a `/shape` session's glossary is available to `/to-spec`, the spec is available to `/to-tasks`, and so on:

```
.scratchpad/
├── INDEX.md                   ← every topic worked on in this repo
└── <topic-slug>/
    ├── glossary.md            ← /shape
    ├── notes.md                ← /shape, /build
    ├── decisions/              ← /shape, /spike, /module-design, /research
    ├── spec.md                ← /to-spec
    ├── tasks/                 ← /to-tasks
    ├── spikes/                ← /spike
    ├── research/               ← /research
    ├── map.md                 ← /wayfinder
    ├── map-items/              ← /wayfinder
    └── reviews/                ← /review-changes
```

`INDEX.md` is a flat, most-recent-first list of every topic — slug, one-line description, and a **Stage** (which skill it last touched). This is what makes `.scratchpad/` a persistent knowledge base rather than disposable output: any skill can resolve `<topic-slug>` by reading this file, matching it against what you typed or the current git branch name, and picking up exactly where a previous session left off.

## What these never touch

`CLAUDE.md`, `AGENTS.md`, `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`. If they exist, skills read them as ground truth to interview and review against. If they don't, nothing changes. Promoting anything out of `.scratchpad/` into real project docs is always a separate, explicit request — never a side effect of running one of these skills.
