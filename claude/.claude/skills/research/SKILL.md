---
name: research
description: Research a question against high-trust primary sources and capture the findings in .scratchpad/. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

# Research

Spin up a **background agent** to do the reading, so you keep working while it goes.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it to `.scratchpad/<topic-slug>/research/<question-slug>.md`.

## Resolving the topic

Every skill in this set works inside `.scratchpad/<topic-slug>/`. Resolve `<topic-slug>` before doing anything else, in this order:

1. **The user named it.** `/research partial-refunds` → use `partial-refunds`. If that folder doesn't exist, say so and confirm before creating it.
2. **The user described it in the invocation.** `/research adyen migration` → read `.scratchpad/INDEX.md` and match against existing topics. On a confident match, state which one you picked and continue. On an ambiguous match, list the candidates and ask.
3. **This conversation already established one.** If an earlier turn worked in a topic, stay in it. Don't re-derive or silently switch.
4. **Infer from the repo state.** Check the current git branch name against topic slugs in `INDEX.md` (a branch `feat/partial-refunds` implies the topic `partial-refunds`). For skills that read a diff, also check recent commit messages.
5. **Nothing matched.** Read `INDEX.md` and show the user the topics that exist, most recent first, and ask which one — or offer to start a new one. Never guess, and never write into a topic you picked without saying so.

State the resolved topic in your first line of output, so a wrong guess is caught immediately rather than after files are written: "Working in `.scratchpad/partial-refunds/`."

**Creating a new topic** is `/shape`'s and `/wayfinder`'s job by default — they're the entry points. Other skills can create one, but should confirm first, because a new topic folder appearing mid-chain usually means the slug was resolved wrong.

## The findings file

```markdown
# <The question, as a question>

**Answered:** <date> · **Confidence:** high | mixed | low

## Answer

<the short version: two or three sentences that actually answer the question>

## Findings

- <claim> — [source](url or path)
- <claim> — [source](url or path)

## Open / unresolved

<anything the primary sources didn't settle, and what would settle it>
```

Rules for the file:

- **Every claim carries its source.** A claim with no source is a guess and should be labelled as one, or cut.
- **Say when sources disagree**, and which one is more authoritative and why — don't silently pick.
- **Note the version.** Library and API facts go stale; record the version or the date the source was published, so a later session knows whether to re-check.
- **Answer first, evidence after.** The person reading this in three weeks wants the answer, not the reading journey.

## Scope

This skill gathers facts; it doesn't make decisions. If the investigation surfaces a choice to be made, say so and stop — that's a `/shape` item, not something to resolve here. If the answer settles a hard-to-reverse decision, record it under `.scratchpad/<topic-slug>/decisions/`, and add any new terms to `.scratchpad/<topic-slug>/glossary.md`.

When called as a research item from `/wayfinder`, link the findings file from the item and fill in its `## Answer` with the short version.
