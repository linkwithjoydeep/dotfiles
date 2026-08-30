---
name: build
description: "Build a piece of work from a spec or a set of tasks in .scratchpad/."
disable-model-invocation: true
---

# Build

Implement the work described by the user, by a spec, or by a set of tasks.

## Resolving the topic

Every skill in this set works inside `.scratchpad/<topic-slug>/`. Resolve `<topic-slug>` before doing anything else, in this order:

1. **The user named it.** `/build partial-refunds` → use `partial-refunds`. If that folder doesn't exist, say so and confirm before creating it.
2. **The user described it in the invocation.** `/build adyen migration` → read `.scratchpad/INDEX.md` and match against existing topics. On a confident match, state which one you picked and continue. On an ambiguous match, list the candidates and ask.
3. **This conversation already established one.** If an earlier turn worked in a topic, stay in it. Don't re-derive or silently switch.
4. **Infer from the repo state.** Check the current git branch name against topic slugs in `INDEX.md` (a branch `feat/partial-refunds` implies the topic `partial-refunds`). For skills that read a diff, also check recent commit messages.
5. **Nothing matched.** Read `INDEX.md` and show the user the topics that exist, most recent first, and ask which one — or offer to start a new one. Never guess, and never write into a topic you picked without saying so.

State the resolved topic in your first line of output, so a wrong guess is caught immediately rather than after files are written: "Working in `.scratchpad/partial-refunds/`."

**Creating a new topic** is `/shape`'s and `/wayfinder`'s job by default — they're the entry points. Other skills can create one, but should confirm first, because a new topic folder appearing mid-chain usually means the slug was resolved wrong.

## Pick up the work

If the user names a task or spec, use it. Otherwise look in `.scratchpad/<topic-slug>/`:

- `tasks/` → take the first task on the **frontier**: the lowest-numbered task whose `Blocked by` entries are all `done` and whose own status is `todo`.
- No `tasks/`, but a `spec.md` → build from the spec directly.
- Neither → ask the user what to build; don't guess.

**One task per session.** A task is sized for a single fresh context window; running two in a row degrades both. When a task is finished, say so and stop rather than rolling into the next.

Before touching any code, record the current `HEAD` (`git rev-parse HEAD`) as the starting point — Finishing needs it to know what "the point you started from" means.

## Before writing code

Read for context, and don't require any of it to exist:

- `.scratchpad/<topic-slug>/glossary.md` — use this vocabulary in names, types, and commit messages.
- `.scratchpad/<topic-slug>/decisions/` — respect these; if the task contradicts one, stop and raise it rather than silently picking a side.
- The repo's `CLAUDE.md`/`AGENTS.md`, `CONTEXT.md`, `docs/adr/` if present.

## Implementing

Use `/tdd` where possible, at the seams agreed in the spec. `/tdd`'s "Seams: where tests go" section reads `spec.md`'s Testing Decisions directly, so it won't re-litigate them. If no seams were agreed and the change is non-trivial, agree them with the user before writing tests against them.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

## Finishing

1. Mark the task file's status `done` and tick its acceptance criteria. If the work revealed something the task didn't anticipate, append a line to `.scratchpad/<topic-slug>/notes.md` rather than quietly widening the task.
2. Run `/review-changes` against the point you started from.
3. Commit to the current branch.

Never edit files outside `.scratchpad/` other than the actual source changes the task calls for — no updating project docs as a side effect.
