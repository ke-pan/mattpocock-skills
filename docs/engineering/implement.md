Quickstart:

```bash
npx skills add mattpocock/skills --skill=implement
```

```bash
npx skills update implement
```

[Source](https://github.com/mattpocock/skills/tree/main/skills/engineering/implement)

## What it does

`implement` builds the work described in a spec or a set of tickets — driving it through test-driven development, typechecking, and the full test suite, then handing off to review and committing to the current branch with any known source work attached.

It does **not** decide what to build. The spec is already settled and the seams are already agreed; `implement` executes that plan rather than reopening it. It is the hands, not the head — the thinking happened upstream.

## When to reach for it

You invoke this by typing `/implement` — the agent won't reach for it on its own.

Reach for it once the work is written down as a spec or split into tickets and you're ready to turn that into code. If the spec doesn't exist yet, write it first — for that, use [to-spec](https://aihero.dev/skills-to-spec), or [to-tickets](https://aihero.dev/skills-to-tickets) to break a spec into tickets. If you just want to build something test-first without a full spec, drop to [tdd](https://aihero.dev/skills-tdd) directly.

## Pre-agreed seams

The idea `implement` runs on is the **seam** — the stable interface a feature is tested at, chosen before any code is written. It doesn't invent seams mid-build; it uses the ones already picked (during [to-spec](https://aihero.dev/skills-to-spec)) and writes tests against them via [tdd](https://aihero.dev/skills-tdd). Working at pre-agreed seams is what keeps the implementation honest: the tests target something durable, so the code underneath can move without the tests moving.

Around that core it keeps the loop tight — typecheck often, run single test files as it goes, run the whole suite once at the end — then closes out with a review pass and a commit to the current branch.

## Source work travels with the commit

A ticket is provenance, not an entry requirement. When the work came from a known ticket or spec, `implement` carries that reference into the commit message. A tracker item fully delivered by the commit gets the tracker's closing reference, so reaching the default branch can close it automatically; a broader parent spec is mentioned without being closed.

Work that starts from a local spec file records its path instead. Work that exists only in the current conversation still commits normally — `implement` never invents a ticket, guesses an identifier, or stops solely because there is nothing durable to reference.

## House rules first

A spec says what to build. It rarely says how your frontend is expected to look, which query patterns your database punishes, or what your framework considers idiomatic — those are **house rules**, and they usually live in some other skill you've installed.

So before writing any code, `implement` looks for a domain skill that covers the ground this work sits on and loads it. It doesn't carry a list of them; the point is to check rather than to remember, because the set of installed skills changes and a hardcoded list would rot. Expect it to reach past this repo — a UI ticket may well pull in whatever design or framework skill you have to hand.

What it can find this way is the **model-invoked** half of your installed set — the skills an agent is allowed to reach for on its own. User-invoked skills are hidden from it by design, so they stay yours to fire: if one of your own carries house rules for this work, type it before you type `/implement`.

## Where it fits

`implement` is the build step near the end of the main chain, just before the review:

```txt
grill-with-docs → to-spec → to-tickets → implement → code-review
```

Reach for it after the work has been specced and sequenced, not before. Its key neighbours are [to-tickets](https://aihero.dev/skills-to-tickets), which produces the tickets — each declaring its blocking edges — that it works through, and [tdd](https://aihero.dev/skills-tdd), which it drives internally to write the tests at each seam before running its own [code-review](https://aihero.dev/skills-code-review) pass and committing. When you're unsure which skill or flow fits, [ask-matt](https://aihero.dev/skills-ask-matt) routes you.
