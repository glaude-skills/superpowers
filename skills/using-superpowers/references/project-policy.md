<!-- Moved verbatim from using-superpowers SKILL.md in 6.4.98; only links changed. Its routing row is in ../SKILL.md. -->

## Project Policy (`.ai/`) — Standing Rule

**At the very start of work in any project, before any other skill, ensure the project root has a `.ai/` folder that defines the project's policy.**

1. **Bootstrap on first contact.** If `.ai/` does not exist at the repo root, create it and organize it into subfolders before doing other work. A typical layout:
   - `.ai/CLAUDE.md` — one-page project context loaded each session: global rules, links, the routing table
   - `.ai/architecture/` — IA, data model, routes
   - `.ai/convention/` — code, design, naming rules
   - `.ai/domain/` — domain rules and definitions
   - `.ai/status/<slug>.md` — one file per task (see `work-records.md`). Never one shared `STATUS.md`/`TASKS.md`: every branch writes it, so every merge conflicts there.

   Scale the structure to the project — a tiny project may need only `.ai/CLAUDE.md` and one status file. The point is that the project's policy lives in `.ai/`, not in your head.

2. **Wire the entry so it loads every session (fork policy, 2026-11-10).** A `.ai/CLAUDE.md` that nothing imports is never read. Your human partner asked for a CONTEXT.md that briefly says which docs to read and links them with @. On first contact, check and create:
   - Root `CLAUDE.md` whose only line is `@CONTEXT.md`.
   - Root `CONTEXT.md`: one line on what the project is, then an "always read" section where each document needed every session gets a one-line description and its own `@path` import line (at least `@.ai/CLAUDE.md`), then an "on demand" table (when to open it | document | what it holds) for the rest, written as backticked paths without `@`.
   - An `@` import loads the whole file into every session and every subagent, so only small documents get one (status logs, design docs, and scripts of tens of KB stay on demand). A path inside backticks is not imported.
   - If the project sits in a workspace whose own context file lists its projects (a parent `CONTEXT.md` with a service table), make sure the project has a row there that points at its `CONTEXT.md`.
   - **A project that already wires its entry another way keeps it.** If root `CLAUDE.md` (or `AGENTS.md`) already imports its rule documents and carries a routing table, do not add `CONTEXT.md` or rewrite `CLAUDE.md` into one line: that adds an import hop and breaks the project's own caps and gates. Apply items 3–6 to the entry the project has.

3. **Who owns what (fork policy, 2026-11-11).** Entry files (`CLAUDE.md`, `CONTEXT.md`, `.ai/CLAUDE.md`) and `.ai/` rule documents hold global rules and one-line links only — they load in every session and every subagent, so every line is a standing cost.
   - Feature behavior, paths, numbers, decisions and history belong in `docs/work/<slug>/` (design, plan, DoD, understanding), never in an entry file.
   - Task progress belongs in `.ai/status/<slug>.md`; tech debt in `docs/tech-debt/<summary>.md`; change history in `docs/changelog/YYYY-MM-DD-<slug>.md` — one file per item.
   - No file that every branch writes in the same place: no shared status list, no work index (`ls docs/work` is the index), no history table at the bottom of `CLAUDE.md`. Those were the repeat cause of merge conflicts.

4. **Keep it current at every stopping point — especially at each commit.** Whenever a unit of work ends (a commit, a finished task, a merged branch), update the relevant `.ai/` files and the task's status file in the same change so the policy and status never drift from the code. A commit that changes routes, data model, conventions, or progress without updating them is incomplete.

5. **Route, don't load everything.** Keep always-loaded context small. Rule documents that are not needed every session go in a routing table in the entry file (`.ai/CLAUDE.md`, imported from `CONTEXT.md` as in item 2, or the project's own entry), one row each: **trigger** (a task or path pattern) | **document to read first** | **the one line you must not forget**. When the current work matches a trigger, read that document before writing code or docs, even if nobody asked. When dispatching an implementer or reviewer subagent, apply the table to the paths involved and pass it the resulting document list — subagents do not see the table.

6. **Caps and the gate (fork policy, 2026-11-11).** Run `scripts/context-check` (next to this skill: `bash <this skill's dir>/scripts/context-check` from the repo root) before every commit that touches an entry file or `.ai/`, and wire it into the project's lint or pre-push step when there is one. It fails on a missing `@` import, an entry file over its line cap, always-loaded bytes over the cap, and an orphan `.ai/` rule document (neither imported nor named in the entry chain); it warns on a shared `STATUS.md`/`TASKS.md`. Defaults are 120 lines and 48 KB. A project records its own caps and exemptions in one entry-file comment, `<!-- context-check: --max-lines N --max-total-kb K --exempt PATH -->`, and each exemption gets a `docs/tech-debt/` item. **Caps ratchet:** never raise one to make room — a new rule goes in only when as much comes out, or a document moves to the on-demand table. A project with its own gate (for example a `harnessCheck` task) keeps it and runs this one only for what its gate does not check.

This rule is a standing project convention. A project's own `.ai/` (or CLAUDE.md/AGENTS.md) may extend or override the layout, but never skip having one.
