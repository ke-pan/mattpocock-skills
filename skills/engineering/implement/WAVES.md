# Implementation Waves

Use waves to execute a dependency graph without letting concurrency outrun integration.

## Contents

- [Preflight](#preflight)
- [Implementation contracts](#implementation-contracts)
- [Ticket gate](#ticket-gate)
- [Wave integration](#wave-integration)
- [Stable-tree review](#stable-tree-review)
- [Expensive acceptance](#expensive-acceptance)
- [Final integration](#final-integration)

## Preflight

Keep integration under the root agent's ownership.

1. Load the full spec, current ticket state, blocking edges, relevant ADRs, and repository instructions.
2. Require a clean integration worktree. Resolve the integration target and record its exact commit as `implementation_base_sha`.
3. Compute the current **frontier**: open tickets whose blockers are all integrated. Put only frontier tickets in the next wave. A ticket blocked by active work belongs to a later wave.
4. Extract a short invariant ledger from the spec, ADRs, and existing behaviour. Include the assertion or focused check that protects each invariant where one exists.
5. Check whether the wave can be given clear ownership. When two tickets cannot run without negotiating the same semantics or files, pause for re-slicing or a real dependency decision; never invent a blocker just to make scheduling easier.
6. Classify each ticket's reasoning effort:
   - `medium` for bounded UI, API, and migration work;
   - `high` for solver behaviour, lifecycle state, concurrency, retention, or cross-module invariants.

If one concept still carries multiple meanings, or an invariant cannot be stated precisely, return to design/specification before spawning agents.

Present one page to the user before the first spawn:

```text
Integration target: <branch>
Implementation base: <full SHA>

Wave N:
- <ticket and delivery>

Blocked for later:
- <ticket> by <blocker>

Invariants:
- <truth that must remain stable> — <protecting evidence>
```

Wait for confirmation. If tracker or integration state changes before dispatch, recompute the frontier and confirm the changed map.

## Implementation contracts

Create one isolated worktree and branch per ticket from the wave's exact base commit. Launch only contracts that can run independently, up to the harness's useful concurrency.

Give every agent this narrow contract:

```text
Ticket:
Base commit:
Worktree:
Owned files/domain:
Acceptance criteria:
Must-preserve invariants:
Pre-agreed test seams:
Focused test commands:
Changed-area static checks:
Reasoning effort: medium | high

Required return:
- commit SHA and concise commit summary
- commands run and their results
- concise self-review
- `git status --porcelain` showing a clean worktree

Do not:
- edit outside the owned area; stop and report if the contract cannot be completed inside it
- integrate another ticket
- push
- change tracker state
```

Pass only the invariants relevant to that ticket, but never omit a cross-ticket invariant it can affect. An agent owns its ticket, not the shared integration plan.

## Ticket gate

Each implementation agent must:

1. Load applicable model-invoked domain skills.
2. Drive focused tests red → green at the contract's seams.
3. Run changed-area lint, format, typecheck, and focused tests.
4. Self-review the acceptance criteria, invariants, scope, and diff; make bounded cleanup while green.
5. Commit with source provenance and return a clean worktree.

Do not run the repository-wide suite in every ticket worktree. Put it in a ticket contract only when that ticket changes a high-risk shared seam.

The root verifies the returned SHA, test evidence, commit boundary, and clean worktree instead of accepting the handoff on trust.

## Wave integration

Wait for every ticket in the wave to pass its ticket gate.

1. Verify each ticket commit descends from the wave base and contains only its intended boundary.
2. Confirm the integration target still points at the wave base. If it moved, recompute the wave instead of integrating stale work.
3. Fast-forward when possible; otherwise cherry-pick the reviewed ticket commits into the integration target in a stable order. Resolve cross-ticket conflicts and integration seams once, under the root agent.
4. Run the full relevant backend/frontend gates once on the integrated tree.
5. Fix only integration failures here; keep new product behaviour in tickets.
6. Commit any integration fix and record the stable result as `integrated_sha`.

Do not start a dependent ticket until the integration target contains the stable wave. Base every next-wave worktree on the new `integrated_sha`.

Test and review evidence belongs to the exact commit that produced it. A code change invalidates later-stage evidence for the old tree; rerun the gate for the stage that changed. The final target must always carry fresh repository-wide gate evidence.

## Stable-tree review

After every implementation wave and ordinary gate is stable:

1. Pin `review_base_sha` to the original implementation base and `review_head_sha` to the final integrated commit.
2. Run /code-review once, supplying those immutable SHAs and requiring reviewers who did not author the implementation. Let /code-review launch the Spec and Standards reviewers concurrently.
3. Keep the root review focused on integration seams, commit provenance, and disagreement between reviewers.

When a reviewer blocks:

1. Assign the smallest bounded fix.
2. Commit it and rerun affected ordinary gates.
3. Ask the same reviewer to inspect the blocked finding and only the resulting delta.

Keep the other accepted axis accepted. Restart a full axis, or both axes, only when the fix materially changes architecture, shared invariants, or the spec.

## Expensive acceptance

Identify long benchmarks and destructive migration rehearsals during preflight, but run them only after:

- a focused smoke test is green;
- semantics and invariants are frozen;
- both independent review axes accept;
- instrumentation can distinguish progress from a hang;
- the spec supplies exact acceptance assertions.

Use short representative runs while developing. Keep wall-clock cutoffs as safety limits, not correctness assertions. Bind the final result to the exact commit tested.

## Final integration

After review and expensive acceptance:

1. Advance the user-approved final target to the accepted commit.
2. Run one final repository-wide gate on the final target.
3. Confirm the target and every retained worktree are clean.
4. Report the implementation base, integrated commits, review verdicts, acceptance evidence, final gate, and whether anything was pushed or changed on the tracker.

Never push or mutate tracker state without explicit user authorization.
