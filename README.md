# Superpowers

Superpowers is a complete software development methodology for your coding agents, built on top of a set of composable skills and some initial instructions that make sure your agent uses them.

---

## About this fork (glaude-skills/superpowers)

This is a customized fork of [obra/superpowers](https://github.com/obra/superpowers), synced to upstream **v6.4.2**. It keeps upstream's Claude-subagent methodology and layers a few standing policies on top:

- **Korean by default.** All user-facing answers, explanations, and summaries are written in Korean; code, commands, paths, and identifiers stay verbatim.
- **Project agents, their own models, human stop points.** A dispatch uses the project's agent for the role from `.claude/agents/` (reviewers read-only) and `general-purpose` only when there is none; no `model` argument is passed, so the agent definition decides unless your partner names one. A review fix loop runs two rounds at most, then open findings go to your partner; a step that still fails after one retry is reported, never skipped.
- **Reviews run on Claude subagents.** Code review and the brainstorming design review are dispatched to Claude subagents — no external review tool (e.g. Codex) in the loop. The brainstorming architectural path includes an adversarial design review (Claude subagent) before the user gate.
- **Commit/MR messages: Korean, no AI trailers.** Commit and PR/MR text is written in Korean, and AI attribution trailers (`Co-Authored-By: Claude`, `🤖 Generated with ...`) are never added.
- **`.ai/` project policy.** At the very start of work in any project, the agent ensures a `.ai/` folder exists at the repo root defining the project's policy (context, architecture, conventions, status), and keeps it current at every stopping point — especially each commit.
- **One work directory per feature.** Spec, plan, DoD, and understanding doc live together in `docs/work/<slug>/` (`<slug>` = branch slug). Brainstorming starts with a read-only re-entry check of that directory: initial run, follow-up, partial rerun, or new run.
- **`definition-of-done` skill (fork-only).** writing-plans drafts `dod.md` (criteria with verification tiers T1–T4 and named verification commands), commits design/plan/DoD as a draft, and freezes the DoD in its own commit when the plan is approved. Execution ends with a fixed-format DoD verdict (`VERIFIED` / `AWAITING_HUMAN` / `FAILED` / `BLOCKED`).
- **Claims about existing code are checked.** The spec reviewer and the plan self-review open the code behind every claim about existing behavior.
- **PR/MR by default, no menu.** `finishing-a-development-branch` does not present a merge/PR/keep menu or wait for a choice. With a green suite it pushes the branch and opens a PR/MR; your partner approves the work by merging that PR/MR. The agent never merges into the base on its own. Local merge, keep-as-is, and discard happen only when asked for in so many words; if the PR/MR cannot be opened, the branch is kept and the blocker reported. `executing-plans` and `subagent-driven-development` list opening the PR/MR as not a stop. Without `gh`/`glab` the agent opens the PR/MR itself through the forge REST API with the token git already stores; the compare URL is only the fallback when that fails.
- **One review per chunk, not per task.** `subagent-driven-development` groups consecutive tasks that build one piece together (same files or subsystem, a tool and its first use, small same-shape edits) into review chunks before Task 1 and records the table in the ledger. Each task still gets its own implementer, tests and commit; the review runs once when the chunk's last task is done, over the whole chunk. A task stands alone only when it is large or risky by itself, and the last chunk may fold into the final review.
- **Sync with the base before the PR.** `finishing-a-development-branch` merges `origin/<base>` (merge, not rebase) and re-runs the full suite before pushing, then checks mergeability. PR bodies carry measured numbers and keep unverified items unchecked.
- **One file per item.** Tech debt (`docs/tech-debt/<summary>.md`) and change history (`docs/changelog/YYYY-MM-DD-<slug>.md`) never go into a shared list file.
- **Two review seats when there is a contract.** With a frozen DoD or project rule documents, the whole-branch review runs a contract reviewer (`requesting-code-review/contract-reviewer.md`) in parallel with the bug reviewer; when they disagree about a frozen criterion the code meets, the contract wins and changing it is your partner's call.
- **Agent conventions.** Implementers tag `[ASSUMPTION]` / `[DECISION_NEEDED]`, read existing work first when re-dispatched, and change only what was flagged; reviewers mark `[POSSIBLE]` findings and list what they did not review.
- **Work records stay in the project.** Everything a resume needs lives in committed project `.md` files (and MEMORY for lasting preferences only): one `.ai/status/<slug>.md` per task with state, next action, done list and decisions, updated at every stopping point and pushed with the branch. A new session on any machine reads it and continues at `## Next`; a missing SDD ledger is rebuilt from it. Harness to-do lists, plugin trackers, scratch directories and chat are never the record.
- **Document ownership and caps.** Entry files and `.ai/` rules hold global rules and links only; feature detail goes to `docs/work/<slug>/`; no file every branch writes in the same place. A project that already wires its own entry keeps it. `using-superpowers/scripts/context-check` fails on missing `@` imports, entry line and always-loaded byte caps (ratchet: never raised to make room), and orphan `.ai/` rule documents.
- **Routing table.** The `.ai/` policy keeps rarely-needed rule documents out of always-loaded context: a trigger → document → must-not-forget line table, applied to the changed paths when dispatching subagents.
- **Needs Confirmation table and one-time feedback.** Specs end with a table of undecided questions and recommendations; after the PR, process feedback is asked for once and registered as follow-up work, never folded into the PR.
- **Structure analyses come with claude.ai diagrams.** When an answer explains how parts of an existing system work together, the agent publishes one HTML page with the Artifact tool holding a detailed 업무 흐름도 and 시스템 아키텍처 (inline SVG, real class, table and topic names, a `file:line` table), even when the partner asked only for their own understanding, in a hurry, or briefly.
- **Designs start as claude.ai mockups.** Before anything people look at is built or changed, the agent publishes a mockup with the Artifact tool, gives the link, and waits for an explicit approval; a change request is republished to the same URL. Brainstorming publishes design mockups without an offer message, and the local visual companion covers designs only when the Artifact tool is unavailable.
- **Traceable server logs (`writing-traceable-logs`, fork-only).** Server work carries one request id across requests, async hops and outside calls; every request and every SMS, 알림톡, email, push or external API call writes a log line; personal information is masked through one shared utility in logs, exception messages and error responses; operator or admin access to personal data writes an access record (개인정보 접속기록). The implementer prompt and the code reviewer check it.
- **`explain-pr` skill (fork-only).** Every PR/MR path writes a developer-facing understanding doc before pushing, wired in as Step 4.5 of `finishing-a-development-branch` and linked from the PR body by a commit-SHA permalink.

### Changelog (fork)

- **fork-v6.4.2.21** (plugin version 6.4.74): `using-superpowers` adds the long dash (em dash, en dash) row to the Korean style table: write commas, colons or parentheses, or split the sentence, and leave code, commands and quoted originals as they are. Opened as PR #6 on 6.4.63 and brought up to date with main.
- **fork-v6.4.2.20** (plugin version 6.4.73): `subagent-driven-development` adds a Token Budget section, because an agent re-reads its whole context on every call and a long-lived one costs roughly the square of its lifetime (measured: one implementer on three tasks made 329 calls and read about 107M cached tokens, half of its session's ten subagents). One fresh agent per task ends at its commit; a run of small tasks shares an implementer only when it is expected to take a few dozen calls and opens no images. Briefs carry the task section, files and acceptance criteria, never whole design documents. Long commands run in the foreground with a timeout instead of being polled in the background. Images are opened only as a verdict needs them, or handed to a short image-only agent or the human. Heavy jobs (full suite, build, GPU measurement, window capture) run one at a time across agents; the 6.4.71 suite beside a reading reviewer is one heavy job plus one light one. A plan with no risky chunk gets only the final review, and a fix round or final fix wave gets a scoped re-review only for an operational defect. Merges, status lines and short checks stay with the controller. The implementer, task-reviewer and re-review templates carry the waiting, image and heavy-job rules; `dispatching-parallel-agents` adds that parallel saves time, not tokens, and that heavy jobs run one at a time.
- **fork-v6.4.2.19** (plugin version 6.4.72): `using-superpowers` adds "사람에게 묻는 질문 쓰는 법" to the Korean style section. A question to the human partner must be answerable on its own: what it is about and the current state, each option as a visible outcome, the recommendation with one reason, and what happens if there is no answer. Labels made up during the work are spelled out. Added after a question written with internal labels drew "뭔 소리여 ?" (2026-11-14).
- **fork-v6.4.2.18** (plugin version 6.4.71): `subagent-driven-development` dispatches one implementer for a run of consecutive small tasks that edit the same files or subsystem (each task keeps its own tests, commit and ledger line; a large or risky task keeps its own implementer), and the controller runs the chunk's full suite in the background in the same turn it dispatches the chunk's reviewer instead of handing the suite to an implementer.
- **fork-v6.4.2.17** (plugin version 6.4.70): new `writing-traceable-logs` skill: request id from the first filter through async hops and outbound calls, one log line per request and per SMS, 알림톡, email, push or external API call, masking of personal information through one shared utility, and 개인정보 접속기록 for operator or admin access. `using-superpowers` makes it a required sub-skill for any server work; `subagent-driven-development/implementer-prompt.md` and `requesting-code-review/code-reviewer.md` carry it.
- **fork-v6.4.2.16** (plugin version 6.4.69): `using-superpowers` adds Analysis Diagrams on claude.ai: an answer that explains how two or more parts of an existing system work together ships one Artifact page with a 업무 흐름도 and a 시스템 아키텍처 drawn from real code names plus a `file:line` table, overriding the Artifact default of answering in the terminal when nobody else reads it; a rationalization table covers "only for my own understanding", "urgent" and "briefly". `brainstorming` sends diagrams of an analyzed existing structure there and keeps the visual companion for proposed designs.
- **fork-v6.4.2.15** (plugin version 6.4.68): `using-superpowers` adds Work Records Stay in the Project: work records live only in committed project `.md` files and MEMORY, one `.ai/status/<slug>.md` per task (state, `## Next`, done, decisions, open) updated at every stopping point and pushed, and a resume protocol that starts from it on any machine. The Project Policy adds document ownership (entry files hold rules and links only, no shared list files, no single `STATUS.md`), keeps a project's existing entry wiring, and ships `scripts/context-check` (missing imports, line and byte caps with a ratchet, orphan rule documents). `executing-plans` and `subagent-driven-development` mirror ledger completions and rulings into the status file and rebuild a missing ledger from it; `brainstorming` reads and creates it; `finishing-a-development-branch` records `pr-open`/`merged` in it. Subagents and Stop Points: project agents from `.claude/agents/` before `general-purpose` (reviewers read-only), no `model` argument (the agent definition decides), review fix loops cut from five rounds to two with escalation to your partner instead of self-adjudication, and one retry before a failing step is reported. `finishing` passes the PR/MR body as a file (`glab api ... -F description=@file`, no `$(cat ...)`) and adds post-merge cleanup after an ancestry proof; `using-git-worktrees` defaults to `.claude/worktrees/`, `<type>/<slug>` branches (renamed from `worktree-<name>`), branching from a fetched `origin/<base>`, with ownership recorded in the status file.
- **fork-v6.4.2.14** (plugin version 6.4.67): `using-superpowers` adds Design Mockups First: work that creates or changes a screen, layout, component, style, slide or page starts with a mockup published to claude.ai through the Artifact tool, and is implemented only after an explicit approval of that mockup. `brainstorming` publishes design mockups without an offer message in both the bounded and the architectural path; the local visual companion covers designs only when the Artifact tool is unavailable.
- **fork-v6.4.2.13** (plugin version 6.4.66): `using-superpowers` wires every project's entry so it loads each session: root `CLAUDE.md` is `@CONTEXT.md`, and `CONTEXT.md` lists the always-read documents with a one-line description and an `@` import (small documents only) and the on-demand documents as a table of plain paths. It also says that edits to this fork are copied to the active cache, committed, pushed and taken into `main` in the same turn, with the version bumped (a same version never refreshes the cache). `subagent-driven-development` and `executing-plans` keep reviews and test runs to the minimum: reviews only for chunks with risk the tests cannot see, low-risk chunks folded into a neighbor, no review for docs or tooling chunks, the full suite only at the end of a reviewed chunk and before finishing.
- **fork-v6.4.2.12** (plugin version 6.4.65): `subagent-driven-development` reviews once per chunk of related tasks instead of after every task; the controller sets the chunk boundaries before Task 1 and records them in the ledger. `requesting-code-review` and `writing-plans` describe the same cadence.
- **fork-v6.4.2.11** (plugin version 6.4.64): `finishing-a-development-branch` opens a PR/MR by default instead of presenting three options and waiting (6.4.63); the merge approval is the PR/MR merge. `executing-plans` and `subagent-driven-development` stop lists no longer treat opening the PR/MR as a reason to stop and ask. Without `gh`/`glab`, `finishing-a-development-branch` and `explain-pr` open the PR/MR through the forge REST API instead of handing the compare URL to the partner.
- **fork-v6.4.2.10** (plugin version 6.4.9): Korean prose rules ban fabricated naive reactions that make the author look foolish and verb-form table headers.
- **fork-v6.4.2.9** (plugin version 6.4.8): Korean prose rules ban vague situation phrases, subject-less contrast pairs, pre-emptive denials nobody raised, letter placeholders for named services, ambiguous verbs and coined word pairs.
- **fork-v6.4.2.8** (plugin version 6.4.7): Korean prose rules ban lecturing tone, arrogant phrasing, vague summary sentences, machine-eyed "who calls it" questions and trailing "~고요." fragments.
- **fork-v6.4.2.7** (plugin version 6.4.6): Korean prose rules ban report-style title subtitles ("서비스 세 곳 비교") and fix the good-title example.
- **fork-v6.4.2.6** (plugin version 6.4.5): Korean prose rules add AI-favored words ("핵심", "짚어 보다"), narrative or aphorism titles, and the owner's "○○명" naming style.
- **fork-v6.4.2.5** (plugin version 6.4.4): Korean prose rules allow explanatory analogies and conversational in-text questions; only decorative metaphors, aphorisms and question headings stay banned.
- **fork-v6.4.2.4** (plugin version 6.4.3): `using-superpowers` language block: Korean prose style rules (no question or metaphor headings, no repeated words, no reader-guiding filler, no aphorisms, no duplicated parenthetical dates), taken from review feedback on a tech blog.
- **fork-v6.4.2.3** — Jeju harness, second batch: contract reviewer seat with arbitration rules, implementer/reviewer report tags and re-dispatch rule, routing table in the `.ai/` policy, Needs Confirmation table in specs, one-time process feedback after the PR.
- **fork-v6.4.2.2** — Folded in the generic parts of the Jeju (aic-api) harness: `definition-of-done` skill with draft/freeze commits, `docs/work/<slug>/` as the single artifact location, the brainstorming re-entry check, the existing-code claims check (spec reviewer + plan self-review), base sync before the PR, PR-body rules, one-file-per-item tech debt and changelog, and SHA permalinks in `explain-pr`.
- **fork-v6.4.2.1** — Merged upstream v6.4.2 as a real merge commit (upstream as second parent), so future syncs get the correct merge-base. Dropped the dev-branch / no-worktree policy: workspace isolation now follows upstream `using-git-worktrees` again. Carried the `.ai/` policy into upstream's rewritten `executing-plans` Setup.
- **fork-v6.3.0.1** — Re-based on upstream v6.3.0. Re-applied every fork policy onto upstream's rewritten text: `using-superpowers` (condensed upstream — language block moved after `EXTREMELY-IMPORTANT`, `.ai/` policy after `The Rule`), `using-git-worktrees`, `subagent-driven-development` (+ implementer prompt; upstream's worktree-based Setup replaced by the dev-branch + `.ai/` policy), `finishing-a-development-branch` (upstream went 4 options → 3 + explicit discard), `brainstorming` (upstream split into Three Paths). Dropped upstream-deleted reference files.
- **fork-v6.0.3.1** — Re-based on upstream v6.0.3 (dropped the old v5.0.7-based Codex commits). Added the dev-branch + `.ai/` policies and the Claude-subagent adversarial design review.

### Staying in sync with upstream

```bash
git remote add upstream https://github.com/obra/superpowers.git   # once
git fetch upstream --tags
git switch -c sync-<version> main
git merge v<version>           # merge-base is the last synced upstream release
# resolve conflicts by keeping the policies above, then run tests/
```

Since fork-v6.4.2.1 the last synced upstream release is a real parent of `main`, so sync is an ordinary merge. Check the policy set with `git diff v<version> HEAD` — it should show only the fork's files.

### Versioning fork changes

Claude Code decides whether `/plugin update` has anything to install by the plugin `version`. A fork change that keeps the version leaves every machine that already has that version on the old copy ("already at the latest version").

- **Every fork change that should reach installed machines bumps the patch version** in `package.json`, `.claude-plugin/plugin.json`, and `.claude-plugin/marketplace.json` together (run `tests/version-bump/` checks if you touch the bump script).
- **Never use a pre-release suffix** such as `6.4.2-fork.1`: semver orders it *below* `6.4.2`, so machines on `6.4.2` would never update.
- **On an upstream sync**, set the version one patch above the larger of the fork's and upstream's — the number must only ever increase.
- Record which upstream release the fork is based on in the changelog entry below (`fork-v<upstream>.<n>` labels).

---


## Table of Contents

- [How it works](#how-it-works)
- [Commercial Services](#commercial-services)
- [Getting Started](#installation)
  - [Claude Code](#claude-code)
  - [Antigravity](#antigravity)
  - [Codex App](#codex-app)
  - [Codex CLI](#codex-cli)
  - [Cursor](#cursor)
  - [Devin CLI](#devin-cli)
  - [Factory Droid](#factory-droid)
  - [Gemini CLI](#gemini-cli)
  - [GitHub Copilot CLI](#github-copilot-cli)
  - [Grok Build CLI](#grok-build-cli)
  - [Kimi Code](#kimi-code)
  - [OpenCode](#opencode)
  - [Pi](#pi)
  - [Qwen Code](#qwen-code)
  - [Hermes Agent](#hermes-agent)
  - [Muse](#muse)
- [The Basic Workflow](#the-basic-workflow)
- [When Something Goes Wrong](#when-something-goes-wrong)
- [Community](#community)
- [What's Inside](#whats-inside)
- [Philosophy](#philosophy)
- [Contributing](#contributing)
- [Updating](#updating)
- [License](#license)
- [Visual companion telemetry](#visual-companion-telemetry)

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do. 

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest. 

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY. 

Next up, once you say "go", it launches a *subagent-driven-development* process, having agents work through each engineering task, inspecting and reviewing their work, and continuing forward. It's not uncommon for your agent to work autonomously for a couple hours at a time without deviating from the plan you put together.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Superpowers.

## Commercial Services

If you're using Superpowers in enterprise and could benefit from commercial support, additional tooling, or managed spending, please don't hesitate to drop us a line at sales@primeradiant.com.

## Installation

Installation differs by harness. If you use more than one, install Superpowers separately for each one.

### Claude Code

Superpowers is available via the [official Claude plugin marketplace](https://claude.com/plugins/superpowers)

#### Official Marketplace

- Install the plugin from Anthropic's official marketplace:

  ```bash
  /plugin install superpowers@claude-plugins-official
  ```

#### Superpowers Marketplace

The Superpowers marketplace provides Superpowers and some other related plugins for Claude Code.

- Register the marketplace:

  ```bash
  /plugin marketplace add obra/superpowers-marketplace
  ```

- Install the plugin from this marketplace:

  ```bash
  /plugin install superpowers@superpowers-marketplace
  ```

### Antigravity

Install Superpowers as a plugin from this repository:

```bash
agy plugin install https://github.com/obra/superpowers
```

Antigravity runs the plugin's session-start hook, so Superpowers is active from
the first message. Reinstall with the same command to update.

### Codex App

Superpowers is available via the [official Codex plugin marketplace](https://github.com/openai/plugins).

- In the Codex app, click on Plugins in the sidebar.
- You should see `Superpowers` in the Coding section.
- Click the `+` next to Superpowers and follow the prompts.

### Codex CLI

Superpowers is available via the [official Codex plugin marketplace](https://github.com/openai/plugins).

- Open the plugin search interface:

  ```bash
  /plugins
  ```

- Search for Superpowers:

  ```bash
  superpowers
  ```

- Select `Install Plugin`.

### Cursor

- In Cursor Agent chat, install from marketplace:

  ```text
  /add-plugin superpowers
  ```

- Or search for "superpowers" in the plugin marketplace.

### Devin CLI

- Install the plugin from this repository:

  ```bash
  devin plugins install obra/superpowers
  ```

- Update to the latest version with:

  ```bash
  devin plugins update superpowers
  ```

### Factory Droid

- Register the marketplace:

  ```bash
  droid plugin marketplace add https://github.com/obra/superpowers
  ```

- Install the plugin:

  ```bash
  droid plugin install superpowers@superpowers
  ```

### Gemini CLI

- Install the extension:

  ```bash
  gemini extensions install https://github.com/obra/superpowers
  ```

- Update later:

  ```bash
  gemini extensions update superpowers
  ```

### GitHub Copilot CLI

- Register the marketplace:

  ```bash
  copilot plugin marketplace add obra/superpowers-marketplace
  ```

- Install the plugin:

  ```bash
  copilot plugin install superpowers@superpowers-marketplace
  ```

### Grok Build CLI

Superpowers is available via the [official Grok plugin marketplace](https://github.com/xai-org/plugin-marketplace).

- Install the plugin from xAI's official marketplace:

  ```bash
  grok plugin install superpowers@xai-official --trust
  ```

- Or open the marketplace in the TUI, search for Superpowers, and install it:

  ```text
  /marketplace
  ```

### Kimi Code

Superpowers is available in Kimi Code's plugin marketplace.

- Open Kimi Code's plugin manager:

  ```text
  /plugins
  ```

- Go to `Marketplace` > `Superpowers` and install it.

- Or install directly from this repository:

  ```text
  /plugins install https://github.com/obra/superpowers
  ```

- Detailed docs: [docs/README.kimi.md](docs/README.kimi.md)

### OpenCode

OpenCode uses its own plugin install; install Superpowers separately even if you
already use it in another harness.

- Tell OpenCode:

  ```
  Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
  ```

- Detailed docs: [docs/README.opencode.md](docs/README.opencode.md)

### Pi

Install Superpowers as a Pi package from this repository:

```bash
pi install git:github.com/obra/superpowers
```

For local development, run Pi with this checkout loaded as a temporary package:

```bash
pi -e /path/to/superpowers
```

The Pi package loads the Superpowers skills and a small extension that injects the `using-superpowers` bootstrap at session startup and again after compaction. Pi has native skills, so no compatibility `Skill` tool is required. Subagent and task-list tools remain optional Pi companion packages.

### Qwen Code

Qwen Code installs plugins from Claude Code marketplaces directly.

- Install the plugin from this repository, and pick `superpowers` when prompted:

  ```bash
  qwen extensions install obra/superpowers
  ```

- Update later:

  ```bash
  qwen extensions update superpowers
  ```

### Hermes Agent

Install Superpowers as a Hermes plugin from this repository:

```bash
hermes plugins install obra/superpowers --enable
```

Restart any active Hermes sessions after installing. Note: Hermes has no
post-compaction hook, so a very long session that compacts over its first
turn loses the bootstrap — start a fresh session if skills stop triggering.

### Muse

Superpowers is available as a native Muse plugin — same repo, same skills, all harnesses. The `using-superpowers` bootstrap is injected via the native `SessionStart` hook alongside Claude Code, Codex, Cursor, Gemini, Pi, and the rest — no per-session opt-in.

- Install from a local checkout:

  ```bash
  muse plugins install ./
  muse plugins approve superpowers
  ```

  Or clone and install:

  ```bash
  git clone https://github.com/obra/superpowers.git
  muse plugins install ./superpowers
  muse plugins approve superpowers
  ```

- Update later:

  ```bash
  muse plugins update superpowers
  ```

Restart any active Muse sessions after installing so the `SessionStart` hook takes effect — skills are active immediately, hooks require approval on first install. To verify, start a fresh session and send `Let's make a react todo list` — a working install auto-triggers `brainstorming` before any code is written. Version is tracked in `.version-bump.json` so `scripts/bump-version.sh` keeps it in sync.

## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Either dispatches a fresh subagent per task with a review after each (most thorough), or implements every task inline in the current session with one fresh review of the whole branch at the end (cheapest).

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, pushes the branch and opens a PR/MR by default (local merge, keep, or discard only on explicit request), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## When Something Goes Wrong

Sometimes a session misbehaves: a skill fires when it shouldn't, stays silent when it should, or the agent ignores its plan, repeats work, or burns more tokens than you'd expect. Ask your coding agent to "figure out what went wrong with superpowers in this session" and it will invoke the **diagnosing-superpowers** skill. To examine an earlier session, name it: "figure out what went wrong with superpowers in session `<id>`".

The skill reads the session transcript, reports what happened with line-level evidence, and, if you want, packages a scrubbed bundle for a bug report.

## Community

Superpowers is built by [Jesse Vincent](https://blog.fsck.com) and the rest of the folks at [Prime Radiant](https://primeradiant.com).

- **Discord**: [Join us](https://discord.gg/35wsABTejz) for community support, questions, and sharing what you're building with Superpowers
- **Issues**: https://github.com/obra/superpowers/issues
- **Release announcements**: [Sign up](https://primeradiant.com/superpowers/) to get notified about new versions

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed
- **diagnosing-superpowers** - Work out what went wrong in a session, with evidence; export a scrubbed bundle or file an issue

**Collaboration** 
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Inline plan execution: one context, one final review
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-superpowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

Read [the original release announcement](https://blog.fsck.com/2025/10/09/superpowers/).

## Contributing

The general contribution process for Superpowers is below. Keep in mind that we don't generally accept contributions of new skills and that any updates to skills must work across all of the coding agents we support.

1. Fork the repository
2. Switch to the 'dev' branch
3. Create a branch for your work
4. Follow the `writing-skills` skill for creating and testing new and modified skills
5. Submit a PR, being sure to fill in the pull request template.

Skill-behavior tests use the drill eval harness from [superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/), cloned into `evals/` — see `evals/README.md` for setup. Plugin-infrastructure tests live at `tests/` and run via the relevant `run-*.sh` or `npm test`.

See `skills/writing-skills/SKILL.md` for the complete guide.

## Updating

Superpowers updates are somewhat coding-agent dependent, but are often automatic.

## License

MIT License - see LICENSE file for details

## Visual companion telemetry

Because skills and plugins don't provide any feedback to creators, we have no idea how many of you are using Superpowers. By default, the Prime Radiant logo on brainstorming's optional visual companion feature is loaded from our website. It includes the version of Superpowers in use. It does not include any details about your project, prompt, or coding agent. We don't see your clicks or anything about what you're building. This helps us have a rough idea of how many folks are using Superpowers and which version of Superpowers they're using. It's 100% optional. To disable this, set the environment variable `SUPERPOWERS_DISABLE_TELEMETRY` to any true value. Superpowers also honors Claude Code's `DISABLE_TELEMETRY` and `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` opt-outs.
