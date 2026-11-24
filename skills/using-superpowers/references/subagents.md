<!-- Moved verbatim from using-superpowers SKILL.md in 6.4.97; only links changed. Its routing row is in ../SKILL.md. -->

## Subagents and Stop Points (fork policy, 2026-11-11)

Your human partner settled three conflicts with their project harness in its favor. They apply in every project, harness or not.

- **Project agents first.** Before dispatching a template written as `Subagent (general-purpose):`, look in `.claude/agents/` for an agent whose description covers that role (implementer, code or task reviewer, spec or contract reviewer, design or architecture reviewer, QA/verification, docs) and dispatch it with the template as its prompt. Use `general-purpose` only when the project has no agent for the role. Reviewer roles are read-only: dispatch an agent without Write/Edit tools; when only a writing agent fits, the prompt says it must not edit.
- **Name the model and effort on every dispatch (fork policy, 2026-11-18, effort and sonnet 2026-11-21).** An omitted `model` inherits the session's model, and the session may be running Fable. Your partner said Fable runs only when they ask for it (2026-11-03), with one standing exception: work where quality or staging matters may run its design alone on Fable (2026-11-18). On 2026-11-21 they approved this table with an effort per kind of work, so this table is the explicit instruction the Agent tool's `effort` field asks for. Pick the row and pass both values:

  | Work being dispatched | `model` | `effort` |
  |---|---|---|
  | Your partner named a model or effort for this piece of work | that, for this piece only | that |
  | Design of work whose value is how it looks, plays or reads (visual design, staging and cinematics, story or script drafts): brainstorming, design document, draft | `fable` | `high` |
  | Other design, plans | `opus` | `high` |
  | Hard implementation: math, IK, shaders, a bug with no known cause | `opus` | `high` |
  | Routine implementation that follows a written plan | `opus` | `medium` |
  | Review, adversarial check, done verdict | `opus` | `high` |
  | Capture comparison, judging images | `opus` | `medium` |
  | Mechanical work: take captures and copy them, export, only run tests, check a merge, move doc lines | `sonnet` | `medium` |
  | Finding code or files (Explore) | `sonnet` | `low` |

  When it is unclear whether implementation is hard or routine, take the `high` row. A fork ignores both fields and runs as the session.
  Tell your partner the model and effort of every agent you dispatch, in the reply that announces it ("opus high", "sonnet medium"), and when you list running agents. Your partner asked for it on 2026-11-21. An agent dispatched without an `effort` runs at the session's default; say so instead of guessing a level.
  A project agent definition (`.claude/agents/`) whose frontmatter sets `model:` keeps its own model. Where a skill says to pick a tier or a more capable model, this table decides.
- **Keep each agent's context small (fork policy, 2026-11-21).** Every call of an agent rereads its whole context, so cost is calls times context size. Measured in one session: a fresh agent starts near 71k and settles near 120k after reading its brief and docs; one agent ran 493 calls up to 625k and read 210 million tokens. Write these into every brief:
  - **Reading range.** Name the doc sections and line ranges the agent needs. Files over 15 KB are never read whole: grep for the heading or symbol, then read with offset and limit.
  - **Wait in the foreground.** A command that fits in 10 minutes runs in the foreground with a timeout. A longer one runs in the background once, and the agent waits for its single completion notice without peeking at its output. Each wake rereads the whole context.
  - **Few images.** The agent reads at most five images for its verdict. Other captures are copied to your partner's review folder unseen.
- **One task per agent, and a stop the agent can count (fork policy, 2026-11-22).** The handoff formula below runs in the coordinator, and an agent cannot see its own context size, so a brief line such as "stop when your context passes 450k" is never obeyed. Measured in one session: four agents briefed that way ended at 520k, 540k, 590k and 700k; the two at 520k and 700k had each been given two plan tasks in one dispatch, and the one at 520k read 163 million tokens over 486 calls. So:
  - Dispatch one plan task per agent. Do not bundle two tasks ("DC-16 then DC-17") into one brief; the second task drags the whole first task's context through every call. A small follow-up that touches the same files (a one-line fix the coordinator found) may ride along.
  - Write a countable stop into every brief: "When you have made about 200 tool calls, or when one PR is merged, commit, write Next in the status file, report, and stop." Calls and merges are things the agent can count; context is not.
  - On every notification, apply the formula below to the reported `subagent_tokens`; when it says hand off, send the agent a message to commit, write Next and stop, then dispatch a fresh agent on the same branch.
  Your partner asked for it on 2026-11-22.
- **Feedback and small fixes (fork policy, 2026-11-23).** Your partner noticed that their feedback and bug fixes took as long as whole features. Measured that day: a one or two line fix took 48 to 70 minutes, mostly in pre-PR impact tests and lock waits; a hand pose fix took 231 calls because each candidate capture was read into context. Tokens follow calls times context, not wall time: waiting in the foreground is cheap, waking repeatedly is not. So:
  - Small fixes test narrowly before the PR, and the coordinator runs the impact batch every two or three small merges (godot-work, "작은 처방은 PR 앞에 좁은 테스트만").
  - Bundle feedback items that touch the same files or the same screen into one agent, at most three. Each item still gets its own red test or before and after capture. Unrelated items stay in separate agents.
  - A visual feedback brief states the pass criterion in numbers or in one checkable sentence before any capture (for example "no finger penetrates the object, gap under 2 mm, thumb on the opposite face"), and names how many candidate rounds the agent may shoot (one grid, then one refinement). The five image limit above still holds.
  - Multi-step measurements (bisecting commits, repeated budget runs) are scripted into one run with one completion notice (godot-work, "되풀이 측정은 스크립트 하나로 묶는다").
  - An agent that stopped with background work of its own can wake again when that work finishes. Before you hand its branch or worktree to a new agent, stop the old one (TaskStop) and check that no Godot process of its own is left, or two agents will edit one worktree.
  Your partner asked for it on 2026-11-23.
- **Hand off by formula (fork policy, 2026-11-21).** C is the agent's current context: the `subagent_tokens` of its notification, equal to the input tokens of its last request (`message.usage` in its transcript). R is the calls it still needs, by its own estimate or the tasks left. S is a fresh agent's settled context, 120k. Hand off when R x (C - S) > 3C + 1M: the old agent spends about three calls at C to commit and write Next, and the new one about ten calls near 100k to settle. Raise the 1M to 2M when the work is mid-debugging and much of it is not written down. Worked out: below C = 150k never hand off; at 250k hand off when more than 14 calls remain, at 400k more than 8, at 600k more than 5. Check every notification, and read the transcript of a long-running agent when no notification comes. The same formula decides when to suggest a clear of the session itself, with S the context after reading the resume file.

- **Stop points.** A review fix loop runs at most two rounds per review. Findings still open after round 2 go to your partner — open findings, what was tried, options, your recommendation — instead of being adjudicated by you. A step or agent that still fails after one retry is reported, never skipped. A code conflict you cannot resolve from the code and the spec is asked about. Rulings on plan ambiguities and conflicts continue as before.
