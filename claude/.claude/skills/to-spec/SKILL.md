---
name: to-spec
description: "Turn the current conversation into a spec in .scratchpad/: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
---

# To Spec

Take the current conversation context and codebase understanding and produce a **spec**. Do NOT interview the user; just synthesize what you already know. If the conversation is too thin to synthesize from, say so and suggest `/shape` first rather than inventing requirements.

Output goes to `.scratchpad/<topic-slug>/spec.md`. Nothing is published to an issue tracker and no repo docs are modified. `.scratchpad/` is personal and gitignored.

## Resolving the topic

Every skill in this set works inside `.scratchpad/<topic-slug>/`. Resolve `<topic-slug>` before doing anything else, in this order:

1. **The user named it.** `/to-spec partial-refunds` → use `partial-refunds`. If that folder doesn't exist, say so and confirm before creating it.
2. **The user described it in the invocation.** `/to-spec adyen migration` → read `.scratchpad/INDEX.md` and match against existing topics. On a confident match, state which one you picked and continue. On an ambiguous match, list the candidates and ask.
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
    ├── glossary.md        ← read this for vocabulary
    ├── notes.md
    ├── decisions/         ← respect these
    └── spec.md            ← this skill writes here
```

## Process

1. **Gather vocabulary and constraints.** Read `.scratchpad/<topic-slug>/glossary.md`, `notes.md`, and `decisions/` if they exist, and use that vocabulary throughout the document. Also read the repo's own `CLAUDE.md`/`AGENTS.md`, `CONTEXT.md`, and `docs/adr/` **if they happen to exist** — respect any decisions recorded there. None of these are required, and none of them get edited.

2. **Explore the repo** to understand the current state of the codebase, if you haven't already.

3. **Sketch the seams** at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better — the ideal number is one.

   Check with the user that these seams match their expectations before writing the document.

4. **Write the document** to `.scratchpad/<topic-slug>/spec.md` using the template below. If a spec already exists for this topic, ask whether to revise it in place or start a new version alongside it (`spec-v2.md`).

5. **Update `INDEX.md`** with the topic and date.

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a spike produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a spike. Trim to the decision-rich parts, not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this design.

## Further Notes

Any further notes about the feature.

</spec-template>

## Closing

Tell the user where the document landed and that the natural next step is `/to-tasks` against it. Don't start breaking it into tasks yourself.
