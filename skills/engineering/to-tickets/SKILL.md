---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker — edges as text in one file per ticket locally, or native blocking links on a real tracker.
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets** — tracer-bullet vertical slices, each declaring the tickets that **block** it.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Build the coverage ledger

Read the source's implementation decisions, acceptance assertions, invariants, stateful boundaries, evidence contract, and testing decisions. Preserve their IDs when the source is a spec. When the source is only a plan or conversation, assign ticketing-local IDs to the already-settled behaviours and truths; do not invent missing semantics.

Build a coverage ledger before slicing:

- assign every acceptance assertion to at least one ticket;
- attach each invariant to every ticket that can affect it;
- attach every applicable stateful boundary to each ticket that can violate it, give at least one ticket ownership of the end-to-end proof, and preserve its expected outcome;
- carry each evidence class and authorization boundary unchanged into the owning acceptance criterion;
- carry the pre-agreed testing seam for every owned acceptance assertion, invariant, and stateful boundary;
- note shared namespace needs such as a migration or schema version, contract identifier, public CLI command, asset name, or artifact path. Preserve names that are product decisions; leave mechanical allocation to `/implement` against the current repository state.

If the source is internally contradictory, or an acceptance assertion lacks the meaning or evidence needed to make a ticket verifiable, stop and return the gap to specification. Ticket slicing must not settle shared semantics.

### 4. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

Give each ticket the part of the source contract it owns: source acceptance IDs, affected invariants, declared stateful boundaries, required evidence classes, and shared namespace needs. Map every owned acceptance assertion, invariant, and stateful boundary to its pre-agreed test, replay, inspection, or evidence seam, but leave exact commands, data paths, hashes, and mechanical namespace values to implementation-time binding.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket — green is promised only there.

### 5. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

Also show a concise coverage summary: unassigned acceptance assertions, invariants without every affected owner, stateful boundaries without an owner, and evidence requirements that were weakened or lost. Every category must be empty before publishing.

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.

### 6. Publish the tickets to the configured tracker

Publish the approved tickets. **How** depends on the tracker `/setup-matt-pocock-skills` configured — the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below — one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. Use the platform's native blocking / sub-issue relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. Apply the `ready-for-agent` triage label unless instructed otherwise — the tickets are agent-grabbable by construction.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<local-ticket-template>

# <NN> — <Ticket title>

## Source contract

- Acceptance assertions: <A1 — full observable outcome, ...>
- Must-preserve invariants: <I1 — full invariant, ... or None>

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not a layer-by-layer implementation list.

## Acceptance criteria

- [ ] [A1] Criterion mapped to its source assertion

## Evidence

- [A1] Pre-agreed seam and required evidence class, if any
- [I1] Pre-agreed protecting seam
- [S1] Pre-agreed boundary seam

## Stateful boundaries

- [S1] Expected external outcome, or "None"

## Shared namespace needs

- Namespace kind and any product-decided name, or "None"

## Blocked by

The numbers/titles of the tickets that gate this one, or "None — can start immediately".

**Status:** ready-for-agent

</local-ticket-template>

<issue-template>

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective — not layer-by-layer implementation.

## Source contract

- Acceptance assertions: A1 — full observable outcome, ...
- Must-preserve invariants: I1 — full invariant, ... or None

## Acceptance criteria

- [ ] [A1] Criterion mapped to its source assertion

## Evidence

- [A1] Pre-agreed seam and required evidence class, if any
- [I1] Pre-agreed protecting seam
- [S1] Pre-agreed boundary seam

## Stateful boundaries

- [S1] Expected external outcome, or "None"

## Shared namespace needs

- Namespace kind and any product-decided name, or "None"

## Blocked by

- A reference to each blocking ticket, or "None — can start immediately".

</issue-template>

In either form, avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.
