<!-- Moved verbatim from subagent-driven-development SKILL.md in 6.4.98; only links changed. Its pointer stays under the same heading in ../SKILL.md. -->

## Model Selection

**Do not pass a `model` argument** (`../../using-superpowers/references/subagents.md`): the dispatched agent's definition decides. The guidance below is for
writing those definitions, and for the dispatches where your partner asks
you to choose.

Use the least powerful model that can handle each role to conserve cost and increase speed.

**Mechanical implementation tasks** (isolated functions, clear specs, 1-2 files): use a fast, cheap model. Most implementation tasks are mechanical when the plan is well-specified.

**Integration and judgment tasks** (multi-file coordination, pattern matching, debugging): use a standard model.

**Architecture and design tasks**: use the most capable available model.
The final whole-branch review is one of these — dispatch it on the most
capable available model, not the session default.

**Review tasks**: choose the model with the same judgment, scaled to the
diff's size, complexity, and risk. A small mechanical diff does not need the
most capable model; a subtle concurrency change does. Scoped re-reviews of
small fix diffs take a cheap-to-mid tier.

**Fix-loop round 2**: a fresh implementer; one tier above the one that got
stuck only when a project agent definition offers it or your partner names it.

**An omitted model follows the agent definition.** A `general-purpose`
dispatch inherits your session's model; when that cost matters, the fix is an
agent definition with its own `model:`, not a per-call override.

**Turn count beats token price.** Wall-clock and context cost scale with how
many turns a subagent takes, and the cheapest models routinely take 2-3× the
turns on multi-step work — costing more overall. Use a mid-tier model as the
floor for reviewers and for implementers working from prose descriptions.
When the task's plan text contains the complete code to write, the
implementation is transcription plus testing: use the cheapest tier for
that implementer. Single-file mechanical fixes also take the cheapest tier.

**Task complexity signals (implementation tasks):**
- Touches 1-2 files with a complete spec → cheap model
- Touches multiple files with integration concerns → standard model
- Requires design judgment or broad codebase understanding → most capable model
