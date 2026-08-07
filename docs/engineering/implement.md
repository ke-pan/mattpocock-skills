## What it does

`implement` builds work that has already been decided. You point it at a [ticket](https://www.aihero.dev/ai-coding-dictionary/ticket), a [spec](https://www.aihero.dev/ai-coding-dictionary/spec), or the plan you just agreed in the conversation, and it writes the code, drives [tdd](https://aihero.dev/skills-tdd) at the seams, typechecks as it goes, commits to the current branch, and then runs [code-review](https://aihero.dev/skills-code-review) against the committed range.

It has two execution shapes. **Direct mode** builds one bounded change in the current session. **Wave mode** takes a whole ticket graph from [to-tickets](https://aihero.dev/skills-to-tickets): one root session validates the handoff, records decisions in a durable run ledger, and dispatches an isolated implementation agent per unblocked ticket, integrating and reviewing each stable wave before opening the next.

It never reopens the plan. There is no interview, no clarifying round, no proposal of a different approach. Whatever was settled upstream is the input, and the skill's whole job is to turn that into a commit. That is what separates it from typing "build this" at a fresh [agent](https://www.aihero.dev/ai-coding-dictionary/agent), which will happily redesign the work while it builds it.

## When to reach for it

You invoke this by typing `/implement` — the agent won't reach for it on its own. It ships with `disable-model-invocation: true`, so no other skill can call it either. Wherever [ask-matt](https://aihero.dev/skills-ask-matt) or [to-tickets](https://aihero.dev/skills-to-tickets) says "then `/implement`", that is an instruction to you, not something the agent will do unprompted.

Where the work currently lives decides whether this is the right skill:

| The work is… | Reach for |
| --- | --- |
| One ticket on the tracker | `/implement #42` in a fresh [session](https://www.aihero.dev/ai-coding-dictionary/session) — Direct mode |
| A set of tickets with blocking edges | `/implement` once with the ticket set — Wave mode coordinates them from one root session |
| A spec, not yet split up, and the build spans sessions | [to-tickets](https://aihero.dev/skills-to-tickets) first, then `/implement` with the ticket set |
| A spec, and the build is small | `/implement` directly against the spec |
| Only in the conversation you just had, and it's still small | `/implement` right there, in the same window |
| Not written down anywhere yet | [grill-with-docs](https://aihero.dev/skills-grill-with-docs), or [grill-me](https://aihero.dev/skills-grill-me) if there's no codebase |
| One concrete behaviour you want test-first, with no spec | [tdd](https://aihero.dev/skills-tdd) directly |
| Already built, and you want it checked | [code-review](https://aihero.dev/skills-code-review) directly |

The same-session case is worth naming because the skill's own first line doesn't cover it. `SKILL.md` says "the spec or tickets", which nudges the [model](https://www.aihero.dev/ai-coding-dictionary/model) to go hunting for a file that doesn't exist. If the plan lives only in the thread, say so when you invoke it.

## Prerequisites

`implement` commits to the branch you are on. It does not create one, and it does not ask. Check you are on the branch you want the work on before you start.

If the tickets came from [to-tickets](https://aihero.dev/skills-to-tickets), the tracker they live on was configured by [setup-matt-pocock-skills](https://aihero.dev/skills-setup-matt-pocock-skills). `code-review` reads the same configuration to find the originating spec at close-out.

## What one run does

A Direct-mode run, in order:

1. Resolve the base commit, read the ticket or spec, and validate its contract — acceptance assertions, invariants, stateful boundaries, evidence requirements. Semantic gaps go back upstream instead of being filled here.
2. Drive [tdd](https://aihero.dev/skills-tdd) at the pre-agreed seams, one red-green slice at a time, retaining the exact RED and GREEN evidence.
3. Typecheck often, run single test files as it goes.
4. Self-review against the acceptance criteria and make bounded cleanup while green, then run the full test suite once.
5. Commit to the current branch, then run [code-review](https://aihero.dev/skills-code-review) against the immutable committed range.

A Direct-mode run covers one ticket, sized by [to-tickets](https://aihero.dev/skills-to-tickets) to fit a single fresh [context window](https://www.aihero.dev/ai-coding-dictionary/context-window). A Wave-mode run covers the whole graph: the root gives each unblocked ticket its own isolated agent and worktree, integrates the wave, reviews the wave delta, and repeats until the graph is done — closing with one review of the final cumulative range.

## Pre-agreed seams

The idea the skill runs on is the **seam**: the public boundary you observe behaviour at, without reaching inside. Tests live at seams. Working at a seam agreed before any code is written is what keeps the tests durable, because the implementation underneath can be rewritten without the tests moving.

The word "pre-agreed" is doing real work. A seam recorded in the spec or an implementation contract counts as already agreed — `implement` uses it without re-asking. `tdd` is the skill that asks when no upstream seam exists, and it refuses to write a test at an unconfirmed seam. So the agreement happens either upstream in the spec, or in the first exchange of the run; if it happens nowhere, the run quietly becomes "just write the code". Naming the seams in the spec is what stops that.

## Common questions

**It finished, but my ticket is still open and the acceptance criteria are still unchecked.**

Partly expected. `implement` never changes tracker state directly — it does not close issues or tick the `- [ ]` boxes. What it does do is preserve provenance: each fully delivered ticket gets its tracker's closing reference (a `Closes #<n>` line on GitHub) in the commit body, so the issue closes when the commit reaches the default branch. Until that merge happens, or on a tracker with no closing convention, the ticket's state is yours to reconcile. This matters most on a dependency chain, because `to-tickets` defines the frontier as tickets whose blockers are all closed.

**Can I point it at all my tickets at once, or run several in parallel?**

Yes — that is what Wave mode is for. Invoke `/implement` once with the ticket set and one root session coordinates the graph: it dispatches an isolated agent per unblocked ticket, each in its own git worktree, then integrates and reviews the wave before opening the next. The ticket agents execute root-owned contracts rather than recursively invoking `/implement`, which is what keeps the fan-out bounded.

What remains unsupported is launching several *uncoordinated* `/implement` sessions side by side in one checkout. That is worse than unsupported: one field report describes a `git commit --amend` in one session landing on another session's commit, a stash vanishing from `refs/stash`, and commits landing on the wrong branch, all in a single afternoon across three issues. The sessions share one working directory, one index, and one HEAD. If the work is a graph, hand the whole graph to one Wave-mode root instead.

**Can it open a pull request instead of committing?**

Not built in. It commits straight to the current branch, which several people find too eager: the code lands before they have had a chance to verify it works. There is no configuration flag and no PR mode. People override it in the invocation ("commit to a branch and open a PR") or by editing their local copy of the skill.

**`code-review` says it cannot see my changes.**

`code-review` reviews committed trees — staged and working-tree changes are invisible to it. `implement` accounts for this: it commits first, then reviews the immutable range between the recorded base and the committed head. If you invoke `code-review` yourself with uncommitted work, commit first.

On reviewer independence: the implementing agent never reviews its own work as either axis. In Direct mode it schedules independent reviewers through `code-review`; in Wave mode only the root launches reviews, against each integrated wave delta and the final cumulative range.

**One ticket burned 150k tokens. Am I using it wrong?**

Probably the ticket is too big rather than the skill being misused. A run does codebase exploration, a red-green loop per seam, a full suite, and a review, so a non-trivial ticket exceeding 100k [tokens](https://www.aihero.dev/ai-coding-dictionary/token) is normal rather than a sign something broke. The lever is upstream: right-size the tickets in [to-tickets](https://aihero.dev/skills-to-tickets) so each fits one fresh window. If a single ticket keeps blowing out, split it rather than raising the [effort](https://www.aihero.dev/ai-coding-dictionary/effort) level.

**`/implement #2` in a fresh session worked on something completely unrelated.**

`#2` is resolved against whatever numbered list the agent can see, which in a fresh session may be a todo file, a checklist, or another work list rather than the configured tracker. The resolution is confident rather than fail-closed, so the mistake is not obvious until it has started. Pass the full reference, the issue URL or `owner/repo#2`, and ask it to confirm the title back before it begins.

## It's working if

- The session opens by reading the ticket or spec and restating what it will build, rather than asking you what to build.
- You can see an actual `/tdd` invocation in the trace, not just tests appearing in the diff.
- Typechecks and single test files run repeatedly during the run, and the full suite runs once near the end.
- The run reaches a commit on your current branch without you prompting it to carry on.
- The diff is one ticket's worth of change: a vertical slice through every layer, not several tickets swept together.

## Where it fits

`implement` is the build step of the main chain, second from the end:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

Its neighbours are [to-tickets](https://aihero.dev/skills-to-tickets), which produces the tickets it consumes and declares the blocking edges that decide their order; [tdd](https://aihero.dev/skills-tdd), which it drives internally at each seam; and [code-review](https://aihero.dev/skills-code-review), which it runs after committing, against the immutable range. It sits downstream of the planning skills: Wave mode validates the handoff's contract before dispatching, but it does not redesign the shape of what it was handed, so a horizontally-layered ticket still gets built as written.

That trust is why [wayfinder](https://aihero.dev/skills-wayfinder) merges onto the chain at [to-spec](https://aihero.dev/skills-to-spec) rather than looping its map straight into `implement`. Go straight to `implement` from a map only when the effort turned out genuinely small.

[ask-matt](https://aihero.dev/skills-ask-matt) is the router over the whole set when you are not sure which flow you are in.
