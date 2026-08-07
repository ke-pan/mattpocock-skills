---
name: to-spec
description: Turn the current conversation into a spec and publish it to the project issue tracker — no interview, just synthesis of what you've already discussed.
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec. Do NOT interview the user — just synthesize what you already know.

The issue tracker and triage label vocabulary should have been provided to you — run `/setup-matt-pocock-skills` if not.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the spec, and respect any ADRs in the area you're touching.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

3. Extract the implementation contract before writing:

- Compare settled conversation decisions with relevant ADRs, existing behaviour, and compatibility promises. Do not silently choose between contradictory meanings. If a real conflict remains, report the exact conflict and stop instead of publishing the spec as ready.
- Give acceptance assertions, invariants, and stateful boundaries stable IDs so tickets can preserve their provenance.
- For calibration, research, or compatibility claims, state the required evidence class: `synthetic fixture`, `retained production data`, `bounded live sample`, or `production observation`. These classes are not automatically interchangeable.
- For access or compliance work, keep technical capability, price, terms or authorization, credentials that may be used, and production activation permission as separate decisions. Lack of production authorization does not by itself prohibit bounded validation; record the agreed boundary.

4. Write the spec using the template below, then perform a consistency pass: every acceptance assertion is compatible with the implementation decisions and invariants; every relevant stateful boundary has an expected external outcome; and every non-ordinary evidence claim has a declared class. Do not invent missing semantics during this pass.

5. Publish the consistent spec to the project issue tracker. Apply the `ready-for-agent` triage label - no need for additional triage.

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

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Acceptance Assertions

A numbered list using stable IDs (`A1`, `A2`, ...). State observable outcomes, not implementation tasks. Together they define what the finished spec must prove; each assertion must later be owned by at least one ticket.

## Invariants

A list using stable IDs (`I1`, `I2`, ...`) of truths every implementation slice must preserve. State cross-ticket behaviour, compatibility guarantees, lifecycle distinctions, ordering constraints, and meanings that must not be conflated. Phrase each invariant so an implementation agent can tell whether it changed, and name the protecting acceptance assertion where one is already known.

## Stateful Boundaries

List applicable high-risk boundaries using stable IDs (`S1`, `S2`, ...`) and the expected external outcome: crash between persistent writes; concurrent publication of the same identity or revision; retry, recovery, and cleanup ownership; identity-key stability; actual versus counterfactual state isolation; partial and total dependency failure; and semantic failure after transport success. State "None" when none apply.

## Evidence Contract

Map each acceptance assertion that needs evidence beyond ordinary automated tests to its required class: `synthetic fixture`, `retained production data`, `bounded live sample`, or `production observation`. For retained-data claims, specify the required dataset identity, schema compatibility, and freshness without pinning an implementation-time file path. For destructive migrations, distinguish the expected transformation from mutation-safety evidence. State "Ordinary automated tests only" when no additional evidence class applies.

For access or compliance work, record technical capability, price, terms or authorization, permitted credentials, bounded-validation limits, and production activation permission separately.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)
- The test, replay, inspection, or other seam expected to protect each acceptance assertion, invariant, and stateful boundary

## Out of Scope

A description of the things that are out of scope for this spec.

## Further Notes

Any further notes about the feature.

</spec-template>
