---
name: wayfinder
description: Plan a huge chunk of work (more than one agent session can hold) as a map of decision items in .scratchpad/, and resolve them one at a time until the way to the destination is clear.
disable-model-invocation: true
---

# Wayfinder

A loose idea has arrived, too big for one agent session, and wrapped in fog: the way from here to the **destination** isn't visible yet. Wayfinding is about finding that way, not charging at the destination. It charts the way as a **map** in `.scratchpad/`, then works its **decision items** (questions whose resolution is a decision, not slices of a build to execute) one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of charting: it shapes every item. It might be a spec to hand off and iterate on, a decision to lock before planning starts, or a change made in place like a data-structure migration.

No issue tracker is required. The map and its items are plain files.

## Resolving the topic

Every skill in this set works inside `.scratchpad/<topic-slug>/`. Resolve `<topic-slug>` before doing anything else, in this order:

1. **The user named it.** `/wayfinder partial-refunds` → use `partial-refunds`. If that folder doesn't exist, say so and confirm before creating it.
2. **The user described it in the invocation.** `/wayfinder adyen migration` → read `.scratchpad/INDEX.md` and match against existing topics. On a confident match, state which one you picked and continue. On an ambiguous match, list the candidates and ask.
3. **This conversation already established one.** If an earlier turn worked in a topic, stay in it. Don't re-derive or silently switch.
4. **Infer from the repo state.** Check the current git branch name against topic slugs in `INDEX.md` (a branch `feat/partial-refunds` implies the topic `partial-refunds`). For skills that read a diff, also check recent commit messages.
5. **Nothing matched.** Read `INDEX.md` and show the user the topics that exist, most recent first, and ask which one — or offer to start a new one. Never guess, and never write into a topic you picked without saying so.

State the resolved topic in your first line of output, so a wrong guess is caught immediately rather than after files are written: "Working in `.scratchpad/partial-refunds/`."

**Wayfinder is an entry point, so it usually creates the topic.** When charting a new map, derive the slug from the destination once you've named it (step 1 of charting), not from the user's opening words — the destination is sharper. Confirm the slug with the user before writing, and add it to `INDEX.md`. When *working* an existing map, resolve as above and never create.

## Plan, don't do

This is **planning** by default: each item resolves a decision, and the map is done when the way is clear, with nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off to `/to-spec` or `/to-tasks`. An effort can override this in its **Notes**, carrying execution into the map itself, but absent that, produce decisions, not deliverables.

## Refer by name

Every item has a **name**: its title. In everything the human reads (narration, the map's Decisions-so-far), refer to it by that name, never by a bare number or slug. A wall of `04, 05, 06` is illegible; names read at a glance.

## Layout

```
.scratchpad/
└── <topic-slug>/
    ├── map.md                 ← the map
    └── map-items/
        ├── 01-<slug>.md           ← open and closed items
        └── 02-<slug>.md
```

### The map body

`map.md` is the whole map at low resolution, loaded once per session. It is an **index**, not a store: it lists the decisions made and points at the items that hold their detail. A decision lives in exactly one place, its item file, so the map never restates it, only gists it and links.

Open items are **not** listed in the map: they're found by reading `map-items/` for files whose status is `open`.

```markdown
## Destination

<what reaching the end of this map looks like: the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing an item.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index: one line per closed item, enough to judge relevance, then open the file for the detail -->

- [<closed item title>](./map-items/01-slug.md): <one-line gist of the answer>

## Not yet specified

<!-- in-scope fog you can't turn into an item yet; graduates as the frontier advances -->

## Out of scope

<!-- work ruled beyond the destination; closed, never graduates -->
```

### Items

Each item file is a question sized to one agent session:

```markdown
# <NN>: <Item title>

**Type:** research | spike | shaping | task
**Status:** open | closed
**Blocked by:** <item numbers/titles, or "None">
**Claimed by:** <name/session, or unclaimed>

## Question

<the decision or investigation this item resolves>

## Answer

<empty until resolved>
```

An item is **unblocked** when every item blocking it is closed; the **frontier** is the open, unblocked, unclaimed items — the edge of the known. Claim an item by filling `Claimed by` **first**, before any work, so concurrent sessions skip it.

Assets created while resolving an item (spike files, research notes) are linked from the item, not pasted in.

## Item types

Every item is either **HITL** (human in the loop, worked _with_ a human who speaks for themselves) or **AFK**, driven by the agent alone. A HITL item only resolves through that live exchange; the agent never stands in for the human's side of it (an agent that answers its own questions has broken this).

- **Research** (AFK): reading documentation, third-party APIs, or local resources to surface a fact a decision waits on. Resolved via `/research`. Use when knowledge outside the current working directory is required.
- **Spike** (HITL): raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to, via `/spike`. Links the spike as an asset. Use when "how should it look" or "how should it behave" is the key question.
- **Shaping** (HITL): conversation. The default case. Resolved via `/shape`.
- **Task** (HITL or AFK): manual work that must happen before a _decision_ can be made: nothing to decide, spike, or research, but the discussion is blocked until it's done. Signing up for a service so its API can be judged, provisioning access, moving data so its shape can be seen. This is the one type that _does_ rather than decides, and it earns its place by unblocking a decision, not by delivering the destination. The agent drives it alone where it can (AFK); otherwise it hands the human a precise checklist (HITL). The answer records what was done and any resulting facts (credentials location, new URLs, row counts) later items depend on.

## Fog of war

The map is _deliberately_ incomplete: don't chart what you can't yet see. Beyond the live items lies the **fog of war**: the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open. Resolving an item clears the fog ahead of it, graduating whatever's now specifiable into fresh items, one at a time, until the way to the destination is clear and no items remain.

The map's **Not yet specified** section is where that dim view is written down: the suspected question, the area to revisit later. It's the undiscovered frontier _toward_ the destination: everything here is in scope, just not sharp enough to make an item.

**Fog or item?** The test is whether you can state the question precisely now, _not_ whether you can answer it now.

- **Item when** the question is already sharp, even if it's blocked and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply. Don't pre-slice the fog into item-sized pieces: it's coarser than an item, and one patch may graduate into several items, or none.

**Not yet specified** excludes what's already decided, what's already a live item, and what's out of scope.

## Out of scope

Fog only ever gathers _toward_ the destination. The destination fixes the scope, so work beyond it is **out of scope**: it isn't fog, and it doesn't belong in **Not yet specified**. It gets its own section on the map: work you've consciously ruled out of _this_ effort. Scope, not sharpness, lands it here.

Out-of-scope work never graduates, so it returns only if the destination is redrawn, and then as a fresh effort, not a resumption.

When an item that already exists turns out to sit past the destination, **close it** and leave one line in the **Out of scope** section: the gist plus why, linking the closed item. It stays out of **Decisions so far**, which records the route actually walked; a scope boundary isn't a step on it.

## Invocation

Two modes. Either way, **never resolve more than one item per session**, with the exception of research items.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Run `/shape` to pin down what this map is finding its way to: the spec, decision, or change. The destination fixes the scope, so it's settled first.
2. **Map the frontier.** Grill again, **breadth-first** this time: fan out across the whole space rather than deep on any one thread, surfacing the open decisions and the first steps takeable now. **If this surfaces no fog** (the way is already clear, the whole journey small enough for one session), you don't need a map. Stop and ask the user how they'd like to proceed — likely straight to `/to-spec`.
3. **Create `map.md`**: Destination and Notes filled in, Decisions-so-far empty, the fog sketched into **Not yet specified**.
4. **Create the items you can specify now** under `map-items/`, then wire the `Blocked by` edges in a **second pass** (items need numbers before they can reference each other). Everything you can't yet specify stays in the fog.
5. **Fire the research items.** For each `research` item you just created, run `/research` in parallel where you can, capturing findings under `.scratchpad/<topic-slug>/research/` with a pointer from the item.
6. Stop: charting is one session's work; it hand-resolves nothing.

### Work through the map

User invokes with a topic slug. An item is **optional**: without one, you pick the next decision, not the user.

1. Load `map.md`: the low-res view, not every item body.
2. Choose the item. If the user named one, use it. Otherwise take the first frontier item in order. **Claim it** before any work.
3. Resolve it. **Zoom as needed**: read the full body of any related or closed item on demand; run whichever skills the `## Notes` block names. If in doubt, run `/shape`.
4. Record the resolution: fill the item's `## Answer`, set status `closed`, and append a one-line gist plus link to the map's **Decisions so far**.
5. Add newly-surfaced items; graduate any fog the answer has made specifiable, clearing each graduated patch from **Not yet specified** so it lives only as its new item. If the answer reveals that an item sits beyond the destination, **rule it out of scope** rather than resolving it. If the decision invalidates other parts of the map, update or delete those items.

The user may run unblocked items in parallel, so expect other sessions to be editing these files concurrently.
