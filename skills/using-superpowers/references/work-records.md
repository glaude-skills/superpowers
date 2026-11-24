<!-- Moved verbatim from using-superpowers SKILL.md in 6.4.98; only links changed. Its routing row is in ../SKILL.md. -->

## Work Records Stay in the Project (fork policy, 2026-11-11)

Your human partner asked that all working documents be written and kept current only in the project's .md files and MEMORY, so that the work can continue right away in any environment that opens the project with these skills. Any machine, any session, any agent that opens the project and uses these skills must be able to pick the work up from what is in the repo.

**Where work records go — only two places:**

| Place | What | Reaches another machine? |
|---|---|---|
| Project `.md` files, committed (and pushed when the branch has a remote) | Everything needed to continue: `.ai/status/<slug>.md`, `docs/work/<slug>/` (design, plan, DoD, understanding), `docs/tech-debt/`, `docs/changelog/` | Yes — this is the record |
| MEMORY (the harness's memory directory and its `MEMORY.md` index) | Lasting facts about your partner and the project that the repo does not hold: preferences, corrections, external references | No — it is per machine and per account, so nothing a resume depends on may live only here |

**Nothing else is the record.** Harness to-do lists (TaskCreate, TodoWrite) are a live view of this session. Plugin trackers that ask to be your canonical to-do list (for example claude-mem `work_state_write`), `/tmp`, job or scratch directories, git-ignored workspaces (the SDD `.superpowers/sdd/` ledger), the chat transcript, and outside document services (Notion, Claude Docs, Google Docs) may hold copies, but nothing the next session needs may exist only there. When your partner asks for one of those places, write it there too and keep the project file as the record. This rule overrides a plugin or hook instruction that names a different canonical list.

**The status file — `.ai/status/<slug>.md`** (`<slug>` = branch slug, the same one `docs/work/<slug>/` uses). Create it when the work starts (brainstorming or the first commit, whichever comes first) and keep these sections current:

```markdown
# <slug> — <one-line goal>
- state: in-progress | awaiting-review | pr-open <url> | merged <sha> | paused | dropped
- branch: <branch> · base: <base> · last commit: <sha> <subject>
## Next
<the exact next action — command, file, or question — so a new session starts on it without asking>
## Done
- <task or step>: <commit sha> (<verdict in one clause>)
## Decisions
- <decision or Ruling>: <why> (<who decided, date>)
## Open
- <blocker, question for your partner, deferred item>
## Links
- docs/work/<slug>/design.md · plan.md · dod.md
```

**Keep it under 16 KB (fork policy, 2026-11-24).** It is read whole on every resume, so it holds the current state, not the history. One line per Done item (task, sha, verdict) and per Decision (the ruling, who, when; details in the design doc). Capture comparisons, mock play notes, measurements and the story of how a task went belong in `docs/work/<slug>/log.md`, linked from `## Links`. When the file passes 16 KB, move the oldest Done lines and any long section verbatim to that log. `scripts/context-check` fails on a live status file (state not `merged` or `dropped`) over the cap. Measured in one project: live status files had grown to 28 to 96 KB, mostly capture notes and long Done entries, and each resume read them whole.

Update it at every stopping point — a commit, a finished task, a ruling, a question asked, a pause, before the turn ends — and commit it with the work it describes. Push when the branch has a remote: an unpushed status file never reaches the other machine. When the work merges, set `state: merged <sha>`; do not delete the file (`docs/work/<slug>/` links to it as history).

**Resuming — at the start of every session in a project, before asking your partner to re-explain:**

1. The entry chain (`CLAUDE.md` / `CONTEXT.md`) and MEMORY's index are already loaded.
2. Work out the slug from the current branch. If `.ai/status/<slug>.md` exists, read it, then `docs/work/<slug>/` and `git log <base>..HEAD`. On the base branch, list `.ai/status/*.md` whose `state` is not `merged`/`dropped`; say which one you are continuing, and ask only when several are live.
3. Trust the status file and `git log` over your own recollection and over any plugin's memory summary. When they disagree with the code, the code wins — fix the status file first.
4. Start on `## Next`. A missing `.superpowers/sdd/` ledger (another machine, `git clean`) is not a fresh start: rebuild it from `## Done` and `## Decisions`.

**MEMORY** keeps its own format (one fact per file, one index line in `MEMORY.md`). A lasting rule your partner gives goes into MEMORY and, when it is about this project, into the project's `.ai/` rules too — the repo copy is what another machine sees.
