Quickstart:

```bash
npx skills add mattpocock/skills --skill=implement
```

```bash
npx skills update implement
```

[Source](https://github.com/mattpocock/skills/tree/main/skills/engineering/implement)

## What it does

`implement` turns a settled spec or ticket set into committed, reviewed code. It drives test-first implementation at pre-agreed seams, preserves source provenance in commits, and keeps test and review evidence attached to the exact commit that produced it.

It has two execution shapes. **Direct mode** builds one bounded change in one session. **Wave mode** coordinates multiple dependent tickets through isolated implementation agents, integrating only the current dependency frontier before moving downstream.

## When to reach for it

You invoke this by typing `/implement` — the agent won't reach for it on its own.

Reach for it once the work is settled and ready to build. Give it one bounded ticket for Direct mode, or an approved ticket graph for Wave mode. If the work is not yet specified, use [to-spec](https://aihero.dev/skills-to-spec); if a large spec still needs slicing and blocking edges, use [to-tickets](https://aihero.dev/skills-to-tickets).

## Pre-agreed seams and invariants

The spec says what can change and what must remain true. Testing **seams** recorded upstream are already agreed, so implementation agents use them without reopening the design. Cross-ticket **invariants** travel into the implementation contracts of every agent that can affect them.

If a shared meaning is still ambiguous, implementation pauses and returns it to design. Parallel agents never get to settle lifecycle, compatibility, or state semantics independently.

## Direct mode

Direct mode keeps one bounded change tight: focused red-green cycles, changed-area static checks, a concise self-review, one full relevant suite, and a clean commit. Independent Standards and Spec review happens against that committed tree, never against an invisible working-copy diff.

## Wave mode

Wave mode is for an existing dependency graph. It records an immutable integration base, computes the currently unblocked **frontier**, and shows you a one-page wave map and invariant checklist before spawning implementation agents.

Every ticket gets its own worktree, ownership boundary, acceptance criteria, focused gates, reasoning effort, and clean-commit requirement. Ticket agents do not each run the repository-wide suite or independent review. The root integrates one complete wave, runs the full relevant gates once, and bases the next wave on the newly integrated commit.

Once the tree is stable, one independent Standards reviewer and one independent Spec reviewer inspect the same immutable range. Expensive benchmarks and migration rehearsals wait until those reviews accept.

## Source work travels with the commit

A ticket is provenance, not an entry requirement. Known tickets and specs travel in the commit body; fully delivered tracker items get the configured closing reference, while broader parent specs are mentioned without being closed.

Work that exists only in the conversation still commits normally. `implement` never invents a tracker item, pushes, or mutates tracker state without explicit authorization.

## Where it fits

`implement` is the build-and-integration step near the end of the main chain:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

Its closest neighbours are [to-tickets](https://aihero.dev/skills-to-tickets), which supplies tracer-bullet tickets and blocking edges; [tdd](https://aihero.dev/skills-tdd), which drives each behaviour red-green; and [code-review](https://aihero.dev/skills-code-review), which independently judges the final committed range. When you're unsure which flow fits, [ask-matt](https://aihero.dev/skills-ask-matt) routes you.
