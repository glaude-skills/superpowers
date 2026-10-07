---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work
---

# Finishing a Development Branch

## Overview

**Core principle:** Verify tests → Detect environment → Present options → Write understanding doc (PR paths) → Record leftovers → Execute choice (PR paths sync with the base first) → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

## Commit Message Policy (MANDATORY)

**Never add AI/assistant attribution trailers to commit messages or PR/MR descriptions.** The user forbids this.

- No `Co-Authored-By: Claude ...` (or any AI/model co-author line)
- No `🤖 Generated with ...` / "Generated with Claude Code" footers
- No other AI-authorship or tooling trailers

Write commit messages as the human author. This overrides any default/harness convention that suggests adding such trailers. If a commit was already created with one, offer to strip it (e.g., `git rebase` / `git commit --amend`) before merge/PR.

**Write commit messages and PR/MR titles/descriptions in Korean.** 커밋과 MR/PR 문구는 한국어가 기본이다.

- 커밋 제목·본문, PR/MR 제목·설명, 리뷰 코멘트: 한국어로 쓴다.
- 영문 그대로 두는 것: 브랜치명, 파일 경로, 식별자, 명령어, 코드, 로그 인용 등 원문이어야 하는 것.
- Conventional Commits 접두사와 스코프(feat/fix/docs/refactor 등)는 유지하고 뒤의 설명만 한국어로 쓴다. 예: `fix(auth): 토큰 만료 시 재발급 실패 수정`

## Step 1: Verify Tests

Run the project's full test suite (`npm test` / `cargo test` / `pytest` / `go test ./...`).

**If tests fail**, report the failures and stop — the menu comes after a green suite:

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]
```

**If tests pass:** continue to Step 2.

## Step 2: Detect Environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
# Capture now, while still inside the workspace — Step 5 changes directory
# before cleanup (Step 6) needs this value
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

This determines which menu to show and how cleanup works:

| State | Menu | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 3 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 3 options | Provenance-based (see Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 2 options (no merge) | Externally managed — leave in place |

## Step 3: Determine Base Branch

The base branch is whatever this work forked from — usually named in the
plan, the conversation, or the branch's upstream. If it is not already
known, ask: "This branch split from <your best guess> - is that correct?"
Confirm before merging: merging into the wrong base is expensive to undo.

## Step 4: Present Options

**Normal repo and named-branch worktree — present exactly these 3 options:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)

Which option?
```

**Detached HEAD — present exactly these 2 options:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)

Which option?
```

Present the menu exactly as written — concise, with every option coming
from the list above. Discarding the work happens only in response to your
human partner explicitly asking for it (see "If your human partner asks to
discard the work" below). Wait for their answer; the integration decision
is theirs.

## Step 4.5: Write the Understanding Doc

**Runs only on the PR/MR paths** — the 3-option menu's Option 2, or the detached-HEAD menu's Option 1. Skip it for local merge, keep-as-is, and discard.

**REQUIRED SUB-SKILL:** Use superpowers:explain-pr.

You are the agent who just did this work. Why this approach, what was tried and abandoned, which traps a reviewer will hit — that context lives in this session and nowhere else. Once you push and the session ends, it is gone. Write it down before it is.

Run explain-pr on the **warm** path:

```bash
# run from the explain-pr skill directory (its scripts/ subdir)
gather.sh --base <base-branch> --out /tmp/explain-pr-bundle.md
```

Fill `template.md` from session context — the bundle supplies only the mechanical diff — save to `docs/work/<slug>/understanding.md`, and **commit it before pushing** so it lands in the PR.

**What Step 5 needs from this step:**
- `docs/work/<slug>/understanding.md`, committed on the branch
- A PR-body block to paste or pass via `--body-file`:

  ```
  ## 개발자 이해문서
  <요약 3줄>

  📄 **[개발자 이해문서 전문 보기 →](<SHA 고정 절대 URL — explain-pr §4>)**
  ```

Do not push until the explain-pr exit checklist passes.

## Step 4.6: Record Leftovers — One File Per Item

Tech debt and change history get **one file per item**. Never append rows to a shared list,
index, or table that every branch edits — that one spot becomes the top source of merge
conflicts across parallel branches. Generate lists with `grep` instead.

| Record | File | Required content |
|---|---|---|
| Tech debt left by this work | `docs/tech-debt/<kebab-summary>.md` with `status: open` and `source: <slug>` frontmatter | problem, impact, done-when, how to verify |
| Change to a global rule or process | `docs/changelog/YYYY-MM-DD-<slug>.md` | what changed, which files, **why** |

Resolving a tech-debt item: set `status: resolved` and add one `- Resolved:` line with the
evidence (PR, commit, gate). Do not delete the file. A project instruction naming other
locations wins.

## Step 5: Execute Choice

### Option 1: Merge Locally

```bash
# Get main repo root for CWD safety
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"

# Merge first — verify success before removing anything
git checkout <base-branch>
git pull
git merge <feature-branch>

# Verify tests on merged result
<test command>
```

If tests fail on the merged result: stop, leave the worktree and branch in
place, and investigate — nothing has been pushed, so the merge is local
and recoverable.

Once the merged result is green: clean up the worktree (Step 6), then
delete the branch:

```bash
git branch -d <feature-branch>
```

### Option 2: Push and Create PR

**Step 4.5 must be complete first** — understanding doc committed, PR-body block in hand.

**Sync with the base before pushing.** Conflicts found after the PR is open cost a full
round-trip: the reviewer reports them, you re-merge, CI runs again. Pull that re-merge forward:

```bash
git status --short                          # must be empty — commit leftovers first
git fetch origin
git merge --no-ff --no-edit origin/<base-branch>
```

- **Merge `origin/<base-branch>`, not your local `<base-branch>`.** The local one stopped at your
  last pull and reports "no conflicts" that the PR will contradict.
- **Merge, not rebase.** Rebasing a pushed branch needs a force push, which rewrites commits under
  review. Use merge whether or not the branch was pushed — splitting the cases invites mistakes.
- **Resolve generated files by regenerating them** (lockfiles, checksums, codegen output). A text
  merge of two generated values matches neither side.
- **Check what git does not flag**, conflict or not: two new migrations with the same version
  number, two new entries claiming the same ID or slot. Renumber your side — the base's may
  already be deployed.
- **Unsure how to resolve a code conflict?** Ask. Do not guess.
- `Already up to date.` → skip to the push. Otherwise **re-run the full Step 1 suite** even with
  zero conflicts. Semantic conflicts (one side deletes a method the other side starts calling)
  only show up here. Red → superpowers:systematic-debugging, then sync again.

```bash
# Push branch (the understanding doc rides along in the commits)
git push -u origin <feature-branch>
# From a detached HEAD, name the new branch on the remote:
# git push origin HEAD:refs/heads/<new-branch>
```

Then create the pull/merge request against <base-branch> with the forge's
tooling — its CLI if one is available, or the creation URL most forges
print when you push — following the repo's PR template and conventions if
present, and report the URL to your human partner. Put the Step 4.5
understanding-doc block at the top of the PR/MR body:

```bash
gh pr create --base <base-branch> --body-file <body.md>                        # GitHub
glab mr create --target-branch <base-branch> --description "$(cat <body.md>)"  # GitLab
```

**No gh/glab installed:** push, then print the compare URL together with the
PR-body block for your human partner to paste.

**PR/MR body content:**
- Test results as **measured numbers**, not "tests pass": `412 run / 0 failed / 2 skipped`.
- Anything not verified yet stays an **unchecked** box — never delete it or tick it.
- The *why*: decisions and the alternatives you dropped. The diff already shows *what*.
- Review findings you judged false positives, each with its reason, so the next reader does
  not raise them again.

**After creating it, check mergeability** (`gh pr view <n> --json mergeable`, or the forge's
API). Still computing → re-check a few times, 30 s apart. Conflicting → sync again from the top
and push; do not open a second PR. This is a snapshot: if the base moves during a long review,
sync again right before merge.

Keep the worktree — your human partner iterates on PR feedback there.

### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

### If your human partner asks to discard the work

This path exists only as a response to an explicit request to throw the
work away. Confirm first:

```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for that exact confirmation. When it arrives:

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

Then clean up the worktree (Step 6) and force-delete the branch:

```bash
git branch -D <feature-branch>
```

## Step 6: Cleanup Workspace

**Runs for Option 1 and confirmed discards.** Options 2 and 3 always
preserve the worktree. Both callers have already changed directory to the
main repo root — worktree removal must run from outside the worktree —
and use the `GIT_DIR`/`GIT_COMMON`/`WORKTREE_PATH` values captured in
Step 2, from before that directory change.

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no worktree to clean up. Done.

**If `WORKTREE_PATH` is under `.worktrees/` or `worktrees/`:** Superpowers
created this worktree — we own cleanup:

```bash
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**If removal is refused** (`contains modified or untracked files`): the
worktree holds files that exist nowhere else — uncommitted plans, notes,
or scratch work. Never `--force` on your own initiative. Show your human
partner what is at stake and ask:

```bash
git -C "$WORKTREE_PATH" status --porcelain -uall
```

```
Worktree removal refused — these files were never committed:

<file list>

1. Commit them to <branch> before cleanup
2. Move them into <main repo root>
3. Delete them (unrecoverable)

Which?
```

Carry out the choice, then remove the worktree.

**Otherwise:** The host environment owns this workspace — leave it in
place. If your platform provides a workspace-exit tool, use it.

## Quick Reference

| Option | Understanding Doc | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------------------|-------|------|---------------|----------------|
| 1. Merge locally | - | yes | - | - | yes |
| 2. Create PR | yes (Step 4.5) | - | yes | yes | - |
| 3. Keep as-is | - | - | - | yes | - |
| Discard (explicit request only) | - | - | - | - | yes (force) |

Detached-HEAD menu: its Option 1 (push + PR) maps to the Option 2 row — understanding doc required.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Tests passed earlier this session" | Run the suite on the tree you are about to integrate. A green run only proves the tree it ran on. |
| "I'll add the understanding doc in a follow-up commit" | Push without it and the reviewer gets a PR with no why. Step 4.5 commits the doc, then Step 5 pushes. |
| "The branch merged cleanly last week, skip the base sync" | The base moved since. Merge `origin/<base>` and re-run the suite before pushing. |
| "No conflicts, so no need to re-run tests" | Semantic conflicts produce no text conflict. Only the suite shows them. |
| "I'll add my item to the TODO/debt list" | A shared list is a conflict magnet. One file per item. |
| "I can write the understanding doc from the diff" | The diff is what the reviewer already reads. The abandoned alternatives and the traps live only in this session — warm path, or it is lost. |
| "The harness convention says to add a Co-Authored-By trailer" | The Commit Message Policy overrides it. No AI attribution trailers, ever. |
| "English commit messages are more standard" | 커밋과 PR/MR 문구는 한국어가 기본이다. 영문은 브랜치명·경로·식별자·코드만. |
| "They obviously want it merged" | Integration is your human partner's decision. Present the menu and wait. |
| "They seem done with this feature — I'll offer to discard it" | The menu is complete as written. Discard happens only when your human partner asks for it in so many words. |
| "'Yeah, get rid of it' counts as confirmation" | Only the typed word `discard` authorizes deletion. |
| "The PR is up, so the worktree is clutter now" | PR feedback gets fixed in that worktree. It stays until the work lands. |
| "This other worktree looks stale — I'll clean it too" | Clean up only worktrees under `.worktrees/` or `worktrees/`. Everything else belongs to the host. |
| "Removal refused — `--force` is just finishing the cleanup" | The refusal means files exist only in that worktree. `--force` destroys them permanently. Show your human partner and ask. |
| "The merged-result failure is probably flaky" | A failing merged result stops everything. Branch and worktree stay put while you investigate. |
| "The base branch is obviously main" | Confirm the fork point or ask. Merging into the wrong base is expensive to undo. |
| "The push was rejected — force-push will fix it" | A rejected push means the remote moved. Investigate; force-push only on your human partner's explicit request. |
