---
name: implement
description: "Implement one bounded change directly or coordinate a dependent ticket graph in integration waves."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

## Choose the execution shape

- **Direct mode** — one bounded ticket or a small spec that fits one agent session. Follow the direct workflow below.
- **Wave mode** — multiple tickets with blocking edges, or an explicit request for a root agent to coordinate implementation agents. Before doing any implementation work, read and follow [WAVES.md](WAVES.md) in full.

## House rules and seams

Before writing code, check whether any model-invoked domain skill applies — frontend/UI, database, a specific framework or platform — and load it first. The spec tells you what to build; those skills tell you the house rules for building it.

Use /tdd where possible. A seam recorded in the spec or an implementation contract is already pre-agreed; do not ask the user to confirm it again.

Treat a known source spec and ticket as the semantic and evidence contract. Validate it, then bind it to current commands, data, and repository state; do not recreate missing acceptance meanings, invariants, stateful outcomes, or evidence requirements inside implementation.

If an implementation decision or invariant is unresolved, stop before coding and return it to design/specification. Do not let an implementation agent silently settle shared semantics.

When the user resolves one, record the exact choice, its affected scope, and what it supersedes before resuming. In Wave mode, keep that record in the durable run ledger defined in `WAVES.md`.

## Direct mode

1. Resolve and record the exact base commit before editing.
2. Validate any known source contract and bind its acceptance, invariant, stateful-boundary, and evidence requirements to exact focused checks. Return semantic gaps upstream instead of filling them here.
3. Drive the behaviour red → green at the pre-agreed seams. Run focused tests and changed-area static checks regularly.
4. Perform a concise self-review against the acceptance criteria, invariants, scope, evidence requirements, and final diff. Make bounded cleanup while the tests are green.
5. Run the full relevant test suite once.
6. Commit the work, then confirm the worktree is clean.
7. Run /code-review against the immutable base and committed head. If a reviewer blocks, make the smallest fix, commit it, rerun affected focused gates and the full relevant suite on the new head, and ask that reviewer to inspect the fix delta.

Review must happen after the implementation is committed because /code-review reviews committed trees.
Test and review evidence belongs to the exact commit that produced it. Every completed Direct-mode head must have full relevant suite evidence; a later code change invalidates that evidence.

## Commit provenance

Preserve provenance for any source work already known:

- Do not make a ticket or spec a prerequisite. Never create or guess one just to populate the commit message.
- Mention each known source ticket and spec in the commit body, using its tracker reference, URL, or local path.
- Add the tracker's closing reference only for each item fully delivered by this commit. Do not close a broader parent spec merely because one child ticket is done.
- Follow the commit-provenance convention in `docs/agents/issue-tracker.md` when present. For an older GitHub or GitLab config that defines none, add a separate `Closes #<number>` line for each completed same-repository item, qualifying cross-repository references with the repository or project path. For any other tracker with no convention, keep the reference as plain text rather than guessing auto-close syntax.

If there is no durable source item, commit normally without a reference.

Do not push or change tracker state unless the user explicitly asks. Finish by reporting the commits, gates, clean-tree status, and whether anything was pushed or changed on the tracker.
