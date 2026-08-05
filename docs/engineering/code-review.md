Quickstart:

```bash
npx skills add mattpocock/skills --skill=code-review
```

```bash
npx skills update code-review
```

[Source](https://github.com/mattpocock/skills/tree/main/skills/engineering/code-review)

## What it does

`code-review` reviews one committed diff along two independent axes: **Standards** asks whether the change follows the repository's documented conventions; **Spec** asks whether it faithfully implements the originating issue or spec.

Both reviewers are independent of the implementation authors and receive the same immutable base and head commit SHAs in fresh contexts. Each dispatch carries an explicitly classified reasoning effort while retaining the current model unless an override is required. Their verdicts stay separate — a change can pass one axis and fail the other — and a bounded blocker fix goes back only to the reviewer that raised it.

## When to reach for it

Type `/code-review`, or the agent reaches for it automatically when you ask to review a branch, PR, integrated feature, or changes since a known point.

Reach for it when there is a committed tree to judge against a known-good point. For building the code test-first, use [tdd](https://aihero.dev/skills-tdd); for executing a whole spec or dependency graph, use [implement](https://aihero.dev/skills-implement), which calls for review only after the implementation tree is stable.

## Prerequisites

The Spec axis needs an originating issue or spec. An explicit source supplied by you or the calling workflow wins; otherwise the skill follows commit provenance and the issue-tracker wiring from [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills). Without a spec, that axis reports `NOT_RUN` rather than inventing requirements or claiming acceptance.

## Immutable range, independent axes

The skill resolves symbolic refs such as `main` or `HEAD` to full commit SHAs once, verifies that the supplied base is an ancestor of the head, and gives both reviewers the exact same range and tree SHA. It stops rather than silently replacing a non-ancestor base with a merge-base. Uncommitted changes are reported as excluded: review evidence belongs to committed code, not to a moving worktree.

The Standards reviewer applies repository instructions plus a Fowler smell baseline. Documented repository rules win; tooling-enforced style is skipped; a smell is a judgement call and cannot block by itself. The Spec reviewer checks missing, partial, incorrect, and materially unrequested behaviour against quoted source requirements.

Each reviewer returns `ACCEPT` or `BLOCKED`, with blockers separated from non-blocking findings. The root presents the axes side by side without blending or reranking them.

## Targeted re-review

When a small fix addresses one blocker, the same reviewer inspects the original finding and only the fix delta. The other axis remains accepted. A full review restarts only when the fix materially changes architecture, shared invariants, or spec semantics.

## It's working if

- The report names full base and head SHAs.
- Standards and Spec receive the same committed diff and return separate verdicts.
- Uncommitted work is explicitly excluded.
- A bounded fix triggers one targeted re-review instead of both full reviews.

## Where it fits

`code-review` is the independent review at the tail of the main build chain:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

[implement](https://aihero.dev/skills-implement) stabilises and commits the tree before invoking it; [to-spec](https://aihero.dev/skills-to-spec) supplies the requirements and invariants the Spec axis judges. When you're unsure which flow fits, [ask-matt](https://aihero.dev/skills-ask-matt) routes you.
