<!-- Moved verbatim from using-superpowers SKILL.md in 6.4.98; only links changed. Its routing row is in ../SKILL.md. -->

## Scale the Process to the Task

Using a skill does not mean running every stage at full weight. Before you start a heavyweight pipeline (a project orchestrator, subagent-driven-development, the architectural brainstorming path), judge the task's size and pick the path that matches it.

| Size | Signals | Default path |
|---|---|---|
| Trivial | No design needed, the change is settled once it is stated (a number, a string, one condition, a small doc or config fix, a few lines in known files) | Do it yourself in the session: no subagent, no plan or task list, no brainstorming. Edit, run the relevant tests, commit, and open and merge the PR the project way |
| Small | One endpoint, column, or flag added to a flow that already exists; roughly ≤600 changed lines; one module family | Bounded: short design in chat → approval → one or two implementer dispatches → one final review |
| Medium / large | New domain, several apps, security, concurrency, data migration of existing records | Full pipeline |

- **Trivial work stays inline (fork policy, 2026-11-21).** Your human partner asked that simple work which needs no design, and which could skip the task step and be implemented right after it is settled, be done by you directly instead of handed to an agent. A dispatched agent pays a fixed cost that a small fix does not: it rereads the project context, makes a worktree, runs the test harness and opens the PR, so a one-line change takes 10 to 20 minutes and tens of thousands of tokens. Several trivial fixes still go inline, one after another. Work that changes how something looks or plays is not trivial even when the edit is small, because it needs captures and a verdict; it follows its normal path.
- **Trim the always-loaded docs every Monday, Wednesday and Friday (fork policy, 2026-11-21).** On those days the first session trims the project files every session and subagent loads at start (CLAUDE.md, CONTEXT.md and what they @-import, such as `.ai/CLAUDE.md`): one line per rule and routing row, details moved verbatim to a file read on demand (grep the row) or to the design doc. Skip it when the git log already shows a trim commit that day. Your human partner asked for it after a fresh session reached about 100k tokens before any work, a third of it one routing file.
- For a small task, recommend the light path in **one** question at the start. Cite the project pipeline's own skip rules if it has them. Do not run the full pipeline without asking.
- Keep a review on the risky parts only: migrations, auth, transaction boundaries.
- Merge the base branch before you start, so number collisions (Flyway versions, ids) show up now instead of mid-review.
- Real cost seen: one read endpoint plus one column (+594 lines) took about 20 subagent dispatches through the full pipeline. The partner said it should not have taken that long.
