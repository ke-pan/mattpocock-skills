---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Before writing code, check whether any model-invoked domain skill applies to this work — frontend/UI, database, a specific framework or platform — and load it first. The spec tells you what to build; those tell you the house rules for building it.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Before committing, preserve provenance for any source work already known:

- Do not make a ticket or spec a prerequisite. Never create or guess one just to populate the commit message.
- Mention each known source ticket and spec in the commit body, using its tracker reference, URL, or local path.
- Add the tracker's closing reference only for each item fully delivered by this commit. Do not close a broader parent spec merely because one child ticket is done.
- Follow the commit-provenance convention in `docs/agents/issue-tracker.md` when present. For an older GitHub or GitLab config that defines none, add a separate `Closes #<number>` line for each completed same-repository item, qualifying cross-repository references with the repository or project path. For any other tracker with no convention, keep the reference as plain text rather than guessing auto-close syntax.

If there is no durable source item, commit normally without a reference.

Commit your work to the current branch.
