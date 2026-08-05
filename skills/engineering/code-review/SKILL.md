---
name: code-review
description: Review committed changes between fixed points along two independent axes — Standards and Spec — with immutable review ranges, explicit verdicts, and targeted re-review of blocker fixes. Use when the user wants to review a branch, PR, integrated feature, or changes since a known point.
---

Review one committed diff along two independent axes:

- **Standards** — does the code conform to this repo's documented coding standards?
- **Spec** — does the code faithfully implement the originating issue, PRD, or spec?

Run both axes as independent parallel reviewers so they do not pollute each other's context. This skill is read-only: reviewers report; they do not edit.

The issue tracker should have been provided to you. If tracker access is required and `docs/agents/issue-tracker.md` is missing, ask the user to run `/setup-matt-pocock-skills`.

## Process

### 1. Pin an immutable range

Accept the base and head from the user or calling workflow. If only a base is supplied, use the current committed `HEAD` as the head. If no base is available, ask for it.

Resolve both refs once to full commit SHAs:

```text
input_base_sha = git rev-parse <base>^{commit}
review_head_sha = git rev-parse <head>^{commit}
merge_base_sha = git merge-base <input_base_sha> <review_head_sha>
review_head_tree_sha = git rev-parse <review_head_sha>^{tree}
```

Require `merge_base_sha` to equal `input_base_sha`. If it differs, report that the supplied base is not an ancestor and stop for an explicit range decision; never silently substitute the merge-base. Once confirmed, set `review_base_sha = input_base_sha`.

Capture the exact commands:

```text
git diff <review_base_sha>..<review_head_sha>
git log <review_base_sha>..<review_head_sha> --oneline
```

Confirm the diff is non-empty. Check `git status --porcelain` and report any worktree changes as excluded from review; never silently treat them as part of the committed range.

### 2. Identify the spec source

Look for the originating spec in this order:

1. A spec path, issue, or fetched contents supplied by the user or calling workflow.
2. Issue references in the reviewed commit messages — fetch them via `docs/agents/issue-tracker.md`.
3. A PRD/spec file under `docs/`, `specs/`, or `.scratch/` matching the branch or feature.
4. If nothing is found, ask the user where the spec is.

If no spec exists, skip the Spec reviewer and report `NOT_RUN — no spec available`. Do not treat a missing Spec review as acceptance.

### 3. Identify the standards sources

Find every repository document that says how code should be written, such as `AGENTS.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, and scoped instruction files.

On top of the repository's standards, the Standards axis always carries this Fowler smell baseline:

- **Mysterious Name** — a name does not reveal what it does or holds. → rename it; if no honest name comes, the design is murky.
- **Duplicated Code** — the same logic shape appears in more than one changed place. → extract the shared shape.
- **Feature Envy** — a method reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps** — the same fields or parameters keep travelling together. → bundle them into one type.
- **Primitive Obsession** — a primitive stands in for a domain concept. → give the concept its own type.
- **Repeated Switches** — the same conditional cascade recurs across the change. → centralise the dispatch.
- **Shotgun Surgery** — one logical change forces scattered edits. → gather what changes together.
- **Divergent Change** — one module changes for unrelated reasons. → split those responsibilities.
- **Speculative Generality** — abstraction exists for needs outside the spec. → delete or inline it.
- **Message Chains** — callers navigate a long object chain. → hide the walk behind the first object.
- **Middle Man** — a module mostly delegates onward. → call the real target directly.
- **Refused Bequest** — an implementer ignores most of what it inherits. → prefer composition.

Repository standards override the baseline. Tool-enforced style is outside reviewer scope. A smell is always a judgement call and is non-blocking by itself; block only for a documented standards violation or a concrete defect/risk.

### 4. Launch independent reviewers

Launch Standards and Spec reviewers who did not author the reviewed implementation, concurrently using the harness's available sub-agent mechanism. Give both the same `review_base_sha`, `review_head_sha`, `review_head_tree_sha`, diff command, and commit list. Record each reviewer identity or session handle for possible follow-up.

Classify each axis's reasoning effort before dispatch. Use an effort supplied by the calling workflow when present; otherwise use `medium` for a bounded local diff, `high` for lifecycle, retention, additive migrations, external integration, or cross-module behaviour, and `xhigh` only for concurrency, crash consistency, destructive migration rehearsal, counterfactual replay, or several interacting invariants.

Dispatch each reviewer with `fork_turns: "none"` and the complete review brief, and pass its classified `reasoning_effort` explicitly. Omit the model override unless the user, repository, or calling workflow requires one. Never use a full-history fork or inherited effort. Record the exact spawn arguments with the reviewer handle; if the effort is absent or mismatched, interrupt and relaunch before accepting a verdict.

Give the **Standards reviewer**:

- every standards-source path and applicable rule;
- the full smell baseline above;
- this brief: "Return `Verdict: ACCEPT` or `Verdict: BLOCKED`. Separate blockers from non-blocking findings. For each finding cite the file/hunk and the documented rule or named smell. Treat baseline smells as judgement calls and non-blocking by themselves. Skip tool-enforced style. Stay under 400 words."

Give the **Spec reviewer**:

- the exact spec source;
- this brief: "Return `Verdict: ACCEPT` or `Verdict: BLOCKED`. Block on missing, partial, incorrect, or materially unrequested behaviour. Separate blockers from non-blocking findings. Quote the governing spec text and cite the implementation hunk when one exists; for a missing requirement, say that no implementing hunk exists. Stay under 400 words."

### 5. Aggregate without reranking

Present the immutable review range and reviewed tree SHA, then the two reports under `## Standards` and `## Spec`. Preserve each verdict and finding severity. Do not merge or rerank the axes.

End with the verdict and finding count for each axis. There is no single blended winner: a change can pass one axis and fail the other.

## Targeted re-review

When a bounded fix addresses a blocker:

1. Record the previous reviewed head and resolve the new committed head.
2. Reuse the same reviewer session when the harness supports it. Otherwise state that reviewer continuity was unavailable and give the replacement the original finding and exact immutable ranges.
3. Ask that reviewer to inspect the original blocker and `git diff <previous_head_sha>..<new_head_sha>`.
4. Return whether the blocker is resolved and whether the fix delta introduces a new blocker.

Keep the other axis's accepted verdict. Run a full axis again only when the fix materially changes that axis; rerun both only when architecture, shared invariants, or spec semantics changed.
