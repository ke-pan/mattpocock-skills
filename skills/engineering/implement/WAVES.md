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
2. Require a clean integration worktree. Resolve the integration target and record its exact commit as the immutable `implementation_base_sha`. Initialize the first `wave_base_sha` to the same commit; later waves advance `wave_base_sha` without rewriting `implementation_base_sha`.
3. Establish the durable run ledger described below.
4. Compute the current **frontier**: open tickets whose blockers are all integrated. Put only frontier tickets in the next wave. A ticket blocked by active work belongs to a later wave.
5. Run a handoff gate on every frontier ticket. Verify that it carries its source acceptance assertions, every affected invariant, each declared stateful boundary and expected outcome, required evidence classes and authorization boundaries, pre-agreed seams, and genuine blocking edges. Verify that the upstream artifacts do not assign conflicting meanings. If anything semantic is missing or contradictory, return it to specification or ticketing; do not repair the design inside implementation.
6. Bind the inherited contract to the current repository: resolve exact focused commands for each acceptance and stateful seam; identify current data paths, schema versions, compatibility versions, and hashes required by retained-data evidence; and note any codebase drift that makes the upstream contract impossible. Do not weaken or replace an evidence class during binding.
7. Classify every frontier ticket's TDD applicability before dispatch. Use `required` for any executable behaviour, including migrations, contracts, bug fixes, and integration repairs. Use `not_applicable` only when no executable seam exists, such as pure documentation or inert metadata, and record the root-owned reason before spawning. Ticket agents cannot create or broaden their own exceptions.
8. Use this adversarial checklist to detect omissions in stateful work, not to invent expected behaviour. For every applicable item, confirm that the spec or ticket already declares the outcome, then bind it to an executable check:
   - crash between persistent writes;
   - concurrent publication of the same key or revision;
   - retry, recovery, and cleanup ownership;
   - identity-key stability;
   - actual versus counterfactual state isolation;
   - partial and total dependency failure;
   - semantic failure after transport success.
9. Reserve the mechanical values for declared shared namespace needs: migration and schema versions, contract identifiers, ports, CLI commands, asset names, and artifact paths. The root resolves mechanical collisions; when a resolution changes a public interface or product semantics, return it to the spec or user. Ticket agents do not claim unreserved shared identifiers independently.
10. Check whether the wave can be given clear ownership. When two tickets cannot run without negotiating the same semantics or files, pause for re-slicing or a real dependency decision; never invent a blocker just to make scheduling easier.
11. Classify reasoning effort by semantic risk, not ticket size:
    - `medium` for bounded local UI, API, or schema-neutral work without shared persistent semantics;
    - `high` for external integrations, solver behaviour, lifecycle state, retention, additive compatibility migrations, or cross-module behaviour;
    - `xhigh` for concurrency, crash consistency, destructive migration rehearsal, counterfactual replay, or several interacting invariants.
12. Classify root-scheduled implementation, repair, Spec-review, and Standards-review agents individually. A prose classification is not a runtime setting: every spawn must pass the selected `reasoning_effort` explicitly.
13. Plan harness capacity so the root remains available and Stable-tree review can use independent Spec and Standards reviewers. Only the root schedules those reviewers.

For access or compliance tickets, verify that the inherited contract keeps technical capability, price, terms or authorization, permitted credentials, bounded-validation limits, and production activation permission separate. Enforce those boundaries; do not reinterpret them during implementation.

If one concept still carries multiple meanings, or an invariant cannot be stated precisely, return to design/specification before spawning agents.

Present one page to the user before the first spawn:

```text
Integration target: <branch>
Implementation base: <full SHA>
Run ledger: <path>

Wave N:
- <ticket and delivery>

Dispatch:
- <ticket> — fork <none or bounded turns>; effort <medium|high|xhigh>; TDD <required at confirmed seams | not_applicable because no executable seam>

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

- the spec or ticket set, integration target, immutable `implementation_base_sha`, current `wave_base_sha`, latest verified `integrated_sha`, and latest accepted wave head;
- every dispatch's agent handle, role or ticket, `fork_turns`, model override or inherited-model marker, planned reasoning effort, and explicit spawned reasoning effort;
- every ticket's root-classified TDD applicability, any pre-dispatch exception reason, confirmed seams, and exact RED/GREEN evidence for each completed vertical slice;
- confirmed decisions as append-only entries with the full chosen meaning, affected scope, original user confirmation, and any decision they supersede;
- wave and ticket status with bases, commit SHAs, gates, and review verdicts;
- the inherited source-to-ticket coverage, runtime evidence bindings, declared stateful boundaries, and shared namespace reservations;
- unresolved blockers and the next safe action.

Expand terse replies such as an option number into the option's full meaning while retaining the original reply. Keep the ledger as a state and decision index, not a transcript or duplicate spec.

Update it immediately after a user decision, ticket handoff, integration, review verdict, fix, or expensive acceptance result. Keep a short resume capsule at the top with the current SHA, phase, last confirmed decision, blockers, and next action.

After context compaction or a resumed session, verify the ledger's SHA and phase against Git before relying on a conversation summary for run-specific facts. Re-read this file only when the execution phase or procedure is unclear, or when the ledger and repository disagree. If a semantic decision cannot be reconstructed faithfully, stop and ask the user rather than infer it.

## Implementation contracts

Create one isolated worktree and branch per ticket from the wave's exact base commit. Launch only contracts that can run independently, up to the harness's useful concurrency.

Before allowing a spawned agent to work, enforce this dispatch gate:

1. Use `fork_turns: "none"` by default and pass the complete narrow contract below. Use a small positive turn count only when the contract depends on an immediately preceding user decision. Never use `fork_turns: "all"`.
2. Omit the model override unless the user, repository, or task requires a different model; omission deliberately uses the current model resolution.
3. Pass `reasoning_effort` explicitly and require it to equal the effort classified for that agent. Never rely on inherited effort.
4. Require the contract to carry root-classified TDD applicability, confirmed seams, and any pre-dispatch exception. If executable behaviour is marked `not_applicable`, stop and repair the contract before spawning.
5. Record the exact spawn arguments and returned agent handle in the run ledger. If `fork_turns` is unbounded, effort is absent, effort mismatches the plan, or TDD applicability is missing, interrupt the invalid dispatch and relaunch it before accepting work.

A Wave ticket agent executes this contract directly. Do not pass it the original user `/implement` invocation or ask it to select an execution shape; it is not a nested Direct-mode run. When TDD is required, it must invoke `/tdd` before its first implementation edit. It may invoke other applicable model-invoked domain skills, but the root alone invokes `/code-review` after integration.

Give every agent this narrow contract:

```text
Execution shape: Wave ticket worker; do not invoke /implement or /code-review
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
TDD applicability: required | not_applicable
TDD exception reason: none | <root-owned pre-dispatch reason>
Confirmed test seams:
Focused test commands:
Changed-area static checks:
Reasoning effort: medium | high | xhigh

Required return:
- commit SHA and concise commit summary
- commands run and their results
- for every required TDD slice: seam, exact RED command and intended behavioural failure, then exact GREEN command and result
- result for every mapped acceptance criterion and stateful seam
- concise self-review
- `git status --porcelain` showing a clean worktree

Do not:
- invoke /implement or /code-review
- skip /tdd when required or declare a new TDD exception
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

1. If TDD is `required`, load `/tdd` before the first implementation edit, list the confirmed seams, and work in vertical slices. Load other applicable model-invoked domain skills as needed. Do not load the user-invoked `/implement` skill or launch `/code-review`.
2. For every required slice, run and retain an exact RED command whose failure demonstrates the intended missing behaviour, then the exact GREEN command and passing result. A syntax, setup, unrelated, or already-green failure is not valid RED evidence.
3. If TDD is `not_applicable`, cite the unchanged root-owned pre-dispatch exception and make no executable-behaviour change. Stop if implementation reveals an executable seam; only the root may reclassify and redispatch the contract.
4. Execute every mapped acceptance and declared stateful-seam check, or report why the contract cannot supply its required evidence.
5. Run changed-area lint, format, typecheck, and focused tests.
6. Self-review the acceptance criteria, invariants, scope, evidence strength, TDD evidence, and diff; make bounded cleanup while green.
7. Inspect tracked and untracked changes before staging. Do not commit or leave dependency links, lockfiles, generated reports, or build output unless the ticket requires them.
8. Commit with source provenance and return a clean worktree.

Do not run the repository-wide suite in every ticket worktree. Put it in a ticket contract only when that ticket changes a high-risk shared seam.

The root verifies the returned SHA, inherited coverage, runtime evidence bindings, TDD classification, per-slice RED/GREEN evidence, commit boundary, source provenance, unexpected files, and clean worktree instead of accepting the handoff on trust. Reject a required-TDD handoff with missing or invalid RED evidence, and reject a `not_applicable` handoff that changed executable behaviour. Fix commits must reference their known source ticket or spec even when they do not close it.

## Wave integration

Wait for every ticket in the wave to pass its ticket gate.

1. Verify each ticket commit descends from the wave base and contains only its intended boundary.
2. Confirm the integration target still points at the wave base. If it moved, recompute the wave instead of integrating stale work.
3. Recheck shared namespace reservations for collisions in the returned diffs.
4. Fast-forward when possible; otherwise cherry-pick the reviewed ticket commits into the integration target in a stable order. Resolve cross-ticket conflicts and integration seams once, under the root agent.
5. Run the full relevant backend/frontend gates once on the integrated tree.
6. Fix only integration failures here; keep new product behaviour in tickets. Treat a failing integration gate as RED evidence and follow `/tdd` before making an executable repair.
7. Commit any integration fix with source provenance and record the stable result as `integrated_sha`.

Update the run ledger with the integrated commits, gate evidence, and new `integrated_sha` before dispatching the next wave.

Keep tool output proportional to the decision being made. Retain verbose logs or structured reports as artifacts when needed, but return concise pass/fail summaries, counts, elapsed time, hashes, and artifact paths to the root instead of streaming unbounded records into context.

Do not start a dependent ticket until the integration target contains an accepted wave. After Stable-tree review accepts the wave, set its final head as the accepted wave head, advance `wave_base_sha` to it, and base every next-wave worktree on that commit.

Test and review evidence belongs to the exact commit that produced it. A code change invalidates later-stage evidence for the old tree; rerun the gate for the stage that changed. The final target must always carry fresh repository-wide gate evidence.

## Stable-tree review

After every implementation wave and ordinary gate is stable:

1. Pin `review_base_sha` to this wave's immutable `wave_base_sha` and `review_head_sha` to the final integrated commit. Do not use the original `implementation_base_sha` for every wave.
2. Run /code-review once, supplying those immutable SHAs, an explicit reasoning effort for each axis, and reviewers who did not author the implementation. Let /code-review launch the Spec and Standards reviewers concurrently under its fresh-context dispatch gate.
3. Supply any confirmed ledger decisions that affect the reviewed behaviour but are not yet reflected in the spec or tickets.
4. Require the reviewers to inspect the inherited source-to-ticket coverage, runtime evidence bindings, and declared stateful seams as well as the diff.
5. Keep the root review focused on integration seams, shared namespaces, commit provenance, and disagreement between reviewers.

When both axes accept, record `review_head_sha` as the accepted wave head and advance `wave_base_sha` to it for the next frontier. Keep `implementation_base_sha` unchanged for final cumulative review and provenance.

When a reviewer blocks:

1. Assign the smallest bounded fix. When it changes executable behaviour, require `/tdd` and exact RED/GREEN evidence under the same ticket gate.
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

1. Run one final cumulative /code-review from immutable `implementation_base_sha` to the final accepted wave head, with explicitly classified reasoning effort for both axes. If that exact range and tree already received both accepted verdicts, reuse them instead of duplicating the review.
2. Repair any blocker with the bounded-fix and targeted-re-review rules, rerunning ordinary or expensive evidence invalidated by the fix.
3. Advance the user-approved final target to the accepted commit.
4. Run one final repository-wide gate on the final target.
5. Confirm every acceptance criterion has the required evidence and every declared stateful boundary has a result.
6. Audit every commit after `implementation_base_sha` for known source provenance.
7. Confirm the target and every retained worktree are clean and contain no unexpected artifacts.
8. Mark the run ledger complete and retain or archive it according to the repository's scratch policy.
9. Report the implementation base, per-wave ranges and integrated commits, final cumulative review verdicts, acceptance evidence, final gate, and whether anything was pushed or changed on the tracker. Include `implicit_effort_spawn_count`, `full_history_fork_count`, `missing_red_evidence_count`, and every TDD exception; all three counts must be zero for a conforming run.

Never push or mutate tracker state without explicit user authorization.
