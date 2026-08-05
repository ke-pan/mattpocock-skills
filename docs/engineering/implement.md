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

Before each wave, the root validates the upstream handoff: source acceptance assertions have ticket owners, affected invariants and stateful boundaries travel with them, and evidence requirements retain their original strength. It binds that contract to concrete commands and current data, but does not recreate missing design. If a shared meaning is absent or contradictory, implementation returns it to specification or ticketing. Parallel agents never get to settle lifecycle, compatibility, or state semantics independently.

## Direct mode

Direct mode keeps one bounded change tight. When a source spec or ticket exists, it validates and binds that contract before focused red-green cycles; it does not fill semantic gaps during coding. Every executable change loads TDD before editing and retains exact RED and GREEN evidence; only work with no executable seam can receive an exception recorded in advance. Changed-area static checks, a concise self-review, one full relevant suite, and a clean commit lead into independent Standards and Spec review against the committed tree, never an invisible working-copy diff.

## Wave mode

Wave mode is for an existing dependency graph. It records an immutable integration base, computes the currently unblocked **frontier**, and shows you a one-page wave map and invariant checklist before spawning implementation agents.

The root also keeps a compact, durable run ledger for facts that conversation compaction can blur: confirmed choices and their full meaning, the integrated commit, wave status, blockers, and the next safe action. It checks that ledger against Git when resuming instead of treating a generated conversation summary as authoritative. The ledger is not a transcript, and Wave mode does not install repository-wide agent instructions to make it discoverable.

Evidence strength arrives from the spec through the tickets. A synthetic fixture cannot silently stand in for retained production data or a bounded live sample. For stateful work, implementation uses an adversarial checklist to catch a missing crash, concurrency, retry, identity, replay-isolation, or dependency-failure case; it returns missing expected behaviour upstream instead of inventing it.

Before parallel work begins, the root allocates mechanical values for declared namespace needs such as migration versions, contract identifiers, CLI commands, and artifact paths. Product-facing names remain upstream decisions. Reasoning effort follows semantic risk rather than ticket size, with the highest effort reserved for concurrency, crash consistency, destructive migration rehearsals, and counterfactual replay. Every implementation and review dispatch carries that effort explicitly while keeping the current model unless an override is required; a full-history fork or inherited effort is an invalid dispatch.

Every ticket gets its own fresh context, worktree, ownership boundary, acceptance criteria, focused gates, reasoning effort, and clean-commit requirement. A ticket agent is a Wave worker, not a nested `/implement` Direct-mode run: for executable behaviour it must load TDD before editing and return valid per-slice RED and GREEN evidence, but it does not launch independent review. TDD exceptions are root-owned, fixed before dispatch, and limited to work with no executable seam. The root integrates one complete wave, runs the full relevant gates once, and bases the next wave on the accepted integrated commit.

Once the tree is stable, one independent Standards reviewer and one independent Spec reviewer inspect that wave's immutable delta from the previous accepted head. The original implementation base remains fixed for provenance and one final cumulative review, instead of being reread after every wave. Expensive benchmarks and migration rehearsals wait until the applicable reviews accept.

## Source work travels with the commit

A ticket is provenance, not an entry requirement. Known tickets and specs travel in the commit body; fully delivered tracker items get the configured closing reference, while broader parent specs are mentioned without being closed.

Work that exists only in the conversation still commits normally. `implement` never invents a tracker item, pushes, or mutates tracker state without explicit authorization.

## Where it fits

`implement` is the build-and-integration step near the end of the main chain:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

Its closest neighbours are [to-tickets](https://aihero.dev/skills-to-tickets), which supplies tracer-bullet tickets and blocking edges; [tdd](https://aihero.dev/skills-tdd), which drives each behaviour red-green; and [code-review](https://aihero.dev/skills-code-review), which independently judges the final committed range. When you're unsure which flow fits, [ask-matt](https://aihero.dev/skills-ask-matt) routes you.
