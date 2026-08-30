---
name: to-tasks
description: Break a spec, plan, or the current conversation into a set of tracer-bullet tasks, each declaring its blocking edges, written as one file per task under .scratchpad/.
disable-model-invocation: true
---

# To Tasks

Break a spec, plan, or conversation into a set of **tasks**: tracer-bullet vertical slices, each declaring the tasks that **block** it.

Tasks are written as local files under `.scratchpad/<topic-slug>/tasks/`. There is no issue tracker involved and none is required — blocking edges are plain text referencing task numbers.

## Resolving the topic

Every skill in this set works inside `.scratchpad/<topic-slug>/`. Resolve `<topic-slug>` before doing anything else, in this order:

1. **The user named it.** `/to-tasks partial-refunds` → use `partial-refunds`. If that folder doesn't exist, say so and confirm before creating it.
2. **The user described it in the invocation.** `/to-tasks adyen migration` → read `.scratchpad/INDEX.md` and match against existing topics. On a confident match, state which one you picked and continue. On an ambiguous match, list the candidates and ask.
3. **This conversation already established one.** If an earlier turn worked in a topic, stay in it. Don't re-derive or silently switch.
4. **Infer from the repo state.** Check the current git branch name against topic slugs in `INDEX.md` (a branch `feat/partial-refunds` implies the topic `partial-refunds`). For skills that read a diff, also check recent commit messages.
5. **Nothing matched.** Read `INDEX.md` and show the user the topics that exist, most recent first, and ask which one — or offer to start a new one. Never guess, and never write into a topic you picked without saying so.

State the resolved topic in your first line of output, so a wrong guess is caught immediately rather than after files are written: "Working in `.scratchpad/partial-refunds/`."

**Creating a new topic** is `/shape`'s and `/wayfinder`'s job by default — they're the entry points. Other skills can create one, but should confirm first, because a new topic folder appearing mid-chain usually means the slug was resolved wrong.

## Scratchpad layout

```
.scratchpad/
├── INDEX.md
└── <topic-slug>/
    ├── glossary.md        ← read for vocabulary
    ├── decisions/         ← respect these
    ├── spec.md      ← usual input
    └── tasks/
        ├── 01-slug.md
        └── 02-slug.md
```

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a path, a topic slug) as an argument, read it. By default, look for `.scratchpad/<topic-slug>/spec.md` and use it as the source.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Task titles and descriptions should use the vocabulary in `.scratchpad/<topic-slug>/glossary.md`, and respect anything in `decisions/` — plus the repo's own `CLAUDE.md`/`AGENTS.md`, `CONTEXT.md`, and `docs/adr/` if those exist. Don't require them to exist.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tasks.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each task its **blocking edges**: the other tasks that must complete before it can start. A task with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own task blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a task blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify task; green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each task, show:

- **Title**: short descriptive name
- **Blocked by**: which other tasks (if any) must complete first
- **What it delivers**: the end-to-end behaviour this task makes work

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct: does each task only depend on tasks that genuinely gate it?
- Should any tasks be merged or split further?

Iterate until the user approves the breakdown.

### 5. Write the tasks

Write one file per task under `.scratchpad/<topic-slug>/tasks/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). One task per file, never a single combined file. Update `INDEX.md`.

<task-template>

# <NN>: <Task title>

**What to build:** the end-to-end behaviour this task makes work, from the user's perspective, not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tasks that gate this one, or "None (can start immediately)".

**Status:** todo

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</task-template>

Work the **frontier**: any task whose blockers are all done. For a purely linear chain that means top to bottom.

Avoid specific file paths or code snippets: they go stale fast. Exception: if a spike produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a spike. Trim to the decision-rich parts, not a working demo, just the important bits.

## Closing

List the tasks that are on the frontier right now (blockers all satisfied) so the user knows what `/build` can pick up immediately.
