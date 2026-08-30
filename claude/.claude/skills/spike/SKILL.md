---
name: spike
description: Build a throwaway spike to answer a design question. Use when the user wants to sanity-check whether a state model or logic feels right, or explore what a UI should look like.
---

# Spike

A spike is **throwaway code that answers a question**. The question decides the shape.

## Resolving the topic

Every skill in this set works inside `.scratchpad/<topic-slug>/`. Resolve `<topic-slug>` before doing anything else, in this order:

1. **The user named it.** `/spike partial-refunds` → use `partial-refunds`. If that folder doesn't exist, say so and confirm before creating it.
2. **The user described it in the invocation.** `/spike adyen migration` → read `.scratchpad/INDEX.md` and match against existing topics. On a confident match, state which one you picked and continue. On an ambiguous match, list the candidates and ask.
3. **This conversation already established one.** If an earlier turn worked in a topic, stay in it. Don't re-derive or silently switch.
4. **Infer from the repo state.** Check the current git branch name against topic slugs in `INDEX.md` (a branch `feat/partial-refunds` implies the topic `partial-refunds`). For skills that read a diff, also check recent commit messages.
5. **Nothing matched.** Read `INDEX.md` and show the user the topics that exist, most recent first, and ask which one — or offer to start a new one. Never guess, and never write into a topic you picked without saying so.

State the resolved topic in your first line of output, so a wrong guess is caught immediately rather than after files are written: "Working in `.scratchpad/partial-refunds/`."

**Creating a new topic** is `/shape`'s and `/wayfinder`'s job by default — they're the entry points. Other skills can create one, but should confirm first, because a new topic folder appearing mid-chain usually means the slug was resolved wrong.

## Pick a branch

Identify which question is being answered, using the user's prompt, the surrounding code, or by asking if the user is around:

- **"Does this logic / state model feel right?"** → build a single shareable HTML file: free-play buttons plus tabbed guided walkthroughs that push the state machine through cases that are hard to reason about on paper, and that a non-developer can drive.
- **"What should this look like?"** → generate several radically different UI variations on a single route, switchable via a URL search param and a floating bottom bar.

The two branches produce very different artifacts, so getting this wrong wastes the whole spike. If the question is genuinely ambiguous and the user isn't reachable, default to whichever branch better matches the surrounding code (a backend module → logic; a page or component → UI) and state the assumption at the top of the spike.

### Logic spikes

One self-contained HTML file, no build step, opened by double-click.

- Render the current state in full after every action — the whole relevant state object, not a summary.
- Free-play controls: one button per event the state machine accepts, disabled when the event isn't legal in the current state.
- Guided walkthroughs as tabs: each tab is a named scenario (the edge cases that are hard to hold in your head) that fires a fixed sequence of events, with the state shown at each step.
- Include the illegal transitions deliberately, so it's visible what the machine refuses.

### UI spikes

Several radically different takes on one route, not several tweaks of one take.

- One route, variations switched by a URL search param (`?v=2`) so any variation is linkable.
- A floating bottom bar to switch between them, labelled with what each variation is trying (not "Option A/B/C").
- Make them genuinely different in approach — different information hierarchy, different interaction model — not different padding.
- Static or hardcoded data is fine and preferred.

## Rules that apply to both

1. **Throwaway from day one, and clearly marked as such.** Locate the spike code close to where it will actually be used (next to the module or page it's spiking for) so context is obvious, but name it so a casual reader can see it's a spike, not production. For throwaway UI routes, obey whatever routing convention the project already uses; don't invent a new top-level structure.
2. **Trivial to run.** A UI spike starts from one command in the project's task runner: `pnpm <name>`, `python <path>`, `bun <path>`, etc. A logic demo is a single HTML file the user double-clicks. Either way, no thinking required to start it.
3. **No persistence by default.** State lives in memory. Persistence is the thing the spike is _checking_, not something it should depend on. If the question explicitly involves a database, hit a scratch DB or a local file with a clear "SPIKE, wipe me" name.
4. **Skip the polish.** No tests, no error handling beyond what makes the spike _runnable_, no abstractions. The point is to learn something fast.
5. **Surface the state.** After every action (logic) or on every variant switch (UI), print or render the full relevant state so the user can see what changed.

## Capture the answer

When the spike has done its job, the **answer** matters more than the artifact:

1. Write the verdict to `.scratchpad/<topic-slug>/spikes/<NN>-<question-slug>.md`: the question it settled, the answer, and any snippet that encodes the decision more precisely than prose can (a state machine, reducer, schema, or type shape). Trim to the decision-rich parts, not the working demo.
2. If the answer is a hard-to-reverse, surprising, real trade-off, also record it under `.scratchpad/<topic-slug>/decisions/` per `/shape`.
3. Keep the spike code itself out of main: commit it to a throwaway branch and note the branch name in the spike file, or delete it once the verdict is captured. The main branch keeps only the validated decision.

The spike file is what `/to-spec` and `/to-tasks` will read later, so make it legible without the code next to it.
