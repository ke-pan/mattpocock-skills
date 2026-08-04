# Implementation Waves

Use waves to execute a dependency graph without letting concurrency outrun integration.

## Contents

- [Preflight](#preflight)
- [Run ledger](#run-ledger)
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
3. Establish the durable run ledger described below.
4. Compute the current **frontier**: open tickets whose blockers are all integrated. Put only frontier tickets in the next wave. A ticket blocked by active work belongs to a later wave.
5. Run a handoff gate on every frontier ticket. Verify that it carries its source acceptance assertions, every affected invariant, each declared stateful boundary and expected outcome, required evidence classes and authorization boundaries, pre-agreed seams, and genuine blocking edges. Verify that the upstream artifacts do not assign conflicting meanings. If anything semantic is missing or contradictory, return it to specification or ticketing; do not repair the design inside implementation.
6. Bind the inherited contract to the current repository: resolve exact focused commands for each acceptance and stateful seam; identify current data paths, schema versions, compatibility versions, and hashes required by retained-data evidence; and note any codebase drift that makes the upstream contract impossible. Do not weaken or replace an evidence class during binding.
7. Use this adversarial checklist to detect omissions in stateful work, not to invent expected behaviour. For every applicable item, confirm that the spec or ticket already declares the outcome, then bind it to an executable check:
   - crash between persistent writes;
   - concurrent publication of the same key or revision;
   - retry, recovery, and cleanup ownership;
   - identity-key stability;
   - actual versus counterfactual state isolation;
   - partial and total dependency failure;
   - semantic failure after transport success.
8. Reserve the mechanical values for declared shared namespace needs: migration and schema versions, contract identifiers, ports, CLI commands, asset names, and artifact paths. The root resolves mechanical collisions; when a resolution changes a public interface or product semantics, return it to the spec or user. Ticket agents do not claim unreserved shared identifiers independently.
9. Check whether the wave can be given clear ownership. When two tickets cannot run without negotiating the same semantics or files, pause for re-slicing or a real dependency decision; never invent a blocker just to make scheduling easier.
10. Classify reasoning effort by semantic risk, not ticket size:
    - `medium` for bounded local UI, API, or schema-neutral work without shared persistent semantics;
    - `high` for external integrations, solver behaviour, lifecycle state, retention, additive compatibility migrations, or cross-module behaviour;
    - `xhigh` for concurrency, crash consistency, destructive migration rehearsal, counterfactual replay, or several interacting invariants.
11. Plan harness capacity so the root remains available and Stable-tree review can use independent Spec and Standards reviewers. Only the root schedules those reviewers.

For access or compliance tickets, verify that the inherited contract keeps technical capability, price, terms or authorization, permitted credentials, bounded-validation limits, and production activation permission separate. Enforce those boundaries; do not reinterpret them during implementation.

If one concept still carries multiple meanings, or an invariant cannot be stated precisely, return to design/specification before spawning agents.

Present one page to the user before the first spawn:

```text
Integration target: <branch>
Implementation base: <full SHA>
Run ledger: <path>

Wave N:
- <ticket and delivery>

Blocked for later:
- <ticket> by <blocker>

Invariants:
- <truth that must remain stable> — <protecting evidence>

Handoff gaps:
- <missing or contradictory upstream contract, or none>

Evidence exceptions:
- <AC without its required evidence, or none>

Runtime reservations:
- <namespace and owner>
```

Do not ask for confirmation while a handoff gap or evidence exception remains. User confirmation approves the wave map; it does not silently waive an upstream contract.

Wait for confirmation. If tracker or integration state changes before dispatch, recompute the frontier and confirm the changed map.

## Run ledger

Keep run-specific truth outside the conversation history. Before the first spawn, create one concise, durable ledger in a repository-approved ignored scratch or state location. If the repository has no such location, use a durable path outside the implementation worktrees and report it. Do not modify `AGENTS.md`, `CLAUDE.md`, or tracker state merely to host or discover the ledger.

The root agent is the sole writer. Record:

- the spec or ticket set, integration target, `implementation_base_sha`, and latest verified `integrated_sha`;
- confirmed decisions as append-only entries with the full chosen meaning, affected scope, original user confirmation, and any decision they supersede;
- wave and ticket status with bases, commit SHAs, gates, and review verdicts;
- the inherited source-to-ticket coverage, runtime evidence bindings, declared stateful boundaries, and shared namespace reservations;
- unresolved blockers and the next safe action.

Expand terse replies such as an option number into the option's full meaning while retaining the original reply. Keep the ledger as a state and decision index, not a transcript or duplicate spec.

Update it immediately after a user decision, ticket handoff, integration, review verdict, fix, or expensive acceptance result. Keep a short resume capsule at the top with the current SHA, phase, last confirmed decision, blockers, and next action.

After context compaction or a resumed session, verify the ledger's SHA and phase against Git before relying on a conversation summary for run-specific facts. Re-read this file only when the execution phase or procedure is unclear, or when the ledger and repository disagree. If a semantic decision cannot be reconstructed faithfully, stop and ask the user rather than infer it.

## Implementation contracts

Create one isolated worktree and branch per ticket from the wave's exact base commit. Launch only contracts that can run independently, up to the harness's useful concurrency.

Give every agent this narrow contract:

```text
Ticket:
Base commit:
Worktree:
Owned files/domain:
Acceptance criteria:
Source acceptance assertions:
Must-preserve invariants:
Confirmed run decisions:
Declared stateful boundaries:
Inherited evidence contract:
Runtime test/evidence bindings:
Runtime namespace reservations:
Focused test commands:
Changed-area static checks:
Reasoning effort: medium | high | xhigh

Required return:
- commit SHA and concise commit summary
- commands run and their results
- result for every mapped acceptance criterion and stateful seam
- concise self-review
- `git status --porcelain` showing a clean worktree

Do not:
- edit outside the owned area; stop and report if the contract cannot be completed inside it
- weaken the required evidence class or claim an unreserved shared identifier
- integrate another ticket
- launch the independent Spec or Standards review
- push
- change tracker state
```

Pass only the invariants relevant to that ticket, but never omit a cross-ticket invariant it can affect. An agent owns its ticket, not the shared integration plan.

## Ticket gate

Each implementation agent must:

1. Load applicable model-invoked domain skills.
2. Drive focused tests red → green at the contract's seams.
3. Execute every mapped acceptance and declared stateful-seam check, or report why the contract cannot supply its required evidence.
4. Run changed-area lint, format, typecheck, and focused tests.
5. Self-review the acceptance criteria, invariants, scope, evidence strength, and diff; make bounded cleanup while green.
6. Inspect tracked and untracked changes before staging. Do not commit or leave dependency links, lockfiles, generated reports, or build output unless the ticket requires them.
7. Commit with source provenance and return a clean worktree.

Do not run the repository-wide suite in every ticket worktree. Put it in a ticket contract only when that ticket changes a high-risk shared seam.

The root verifies the returned SHA, inherited coverage, runtime evidence bindings, test evidence, commit boundary, source provenance, unexpected files, and clean worktree instead of accepting the handoff on trust. Fix commits must reference their known source ticket or spec even when they do not close it.

## Wave integration

Wait for every ticket in the wave to pass its ticket gate.

1. Verify each ticket commit descends from the wave base and contains only its intended boundary.
2. Confirm the integration target still points at the wave base. If it moved, recompute the wave instead of integrating stale work.
3. Recheck shared namespace reservations for collisions in the returned diffs.
4. Fast-forward when possible; otherwise cherry-pick the reviewed ticket commits into the integration target in a stable order. Resolve cross-ticket conflicts and integration seams once, under the root agent.
5. Run the full relevant backend/frontend gates once on the integrated tree.
6. Fix only integration failures here; keep new product behaviour in tickets.
7. Commit any integration fix with source provenance and record the stable result as `integrated_sha`.

Update the run ledger with the integrated commits, gate evidence, and new `integrated_sha` before dispatching the next wave.

Keep tool output proportional to the decision being made. Retain verbose logs or structured reports as artifacts when needed, but return concise pass/fail summaries, counts, elapsed time, hashes, and artifact paths to the root instead of streaming unbounded records into context.

Do not start a dependent ticket until the integration target contains the stable wave. Base every next-wave worktree on the new `integrated_sha`.

Test and review evidence belongs to the exact commit that produced it. A code change invalidates later-stage evidence for the old tree; rerun the gate for the stage that changed. The final target must always carry fresh repository-wide gate evidence.

## Stable-tree review

After every implementation wave and ordinary gate is stable:

1. Pin `review_base_sha` to the original implementation base and `review_head_sha` to the final integrated commit.
2. Run /code-review once, supplying those immutable SHAs and requiring reviewers who did not author the implementation. Let /code-review launch the Spec and Standards reviewers concurrently.
3. Supply any confirmed ledger decisions that affect the reviewed behaviour but are not yet reflected in the spec or tickets.
4. Require the reviewers to inspect the inherited source-to-ticket coverage, runtime evidence bindings, and declared stateful seams as well as the diff.
5. Keep the root review focused on integration seams, shared namespaces, commit provenance, and disagreement between reviewers.

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

When the inherited evidence contract requires retained production data, use the exact schema and data resolved during preflight for the final read-only check. Record the data identity and before/after hashes; a migrated fixture is not a substitute. Rehearse destructive migrations only on a verified copy and record the specified transformation separately from mutation safety.

## Final integration

After review and expensive acceptance:

1. Advance the user-approved final target to the accepted commit.
2. Run one final repository-wide gate on the final target.
3. Confirm every acceptance criterion has the required evidence and every declared stateful boundary has a result.
4. Audit every commit after `implementation_base_sha` for known source provenance.
5. Confirm the target and every retained worktree are clean and contain no unexpected artifacts.
6. Mark the run ledger complete and retain or archive it according to the repository's scratch policy.
7. Report the implementation base, integrated commits, review verdicts, acceptance evidence, final gate, and whether anything was pushed or changed on the tracker.

Never push or mutate tracker state without explicit user authorization.
