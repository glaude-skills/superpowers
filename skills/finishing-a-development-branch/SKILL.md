---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work - guides completion of development work by presenting structured options for merge, PR, or cleanup
---

# Finishing a Development Branch

## Overview

Guide completion of development work by presenting clear options and handling chosen workflow.

**Core principle:** Verify tests → Detect environment → Present options → Write understanding doc (PR paths) → Execute choice → Clean up.

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

## The Process

### Step 1: Verify Tests

**Before presenting options, verify tests pass:**

```bash
# Run project's test suite
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
```
Tests failing (<N> failures). Must fix before completing:

[Show failures]

Cannot proceed with merge/PR until tests pass.
```

Stop. Don't proceed to Step 2.

**If tests pass:** Continue to Step 2.

### Step 2: Detect Environment

**Determine workspace state before presenting options:**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

This determines which menu to show and how cleanup works:

| State | Menu | Cleanup |
|-------|------|---------|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 4 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 4 options | Provenance-based (see Step 6) |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 3 options (no merge) | No cleanup (externally managed) |

### Step 3: Determine Base Branch

```bash
# Try common base branches
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

Or ask: "This branch split from main - is that correct?"

### Step 4: Present Options

**Normal repo and named-branch worktree — present exactly these 4 options:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

**Detached HEAD — present exactly these 3 options:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)
3. Discard this work

Which option?
```

**Don't add explanation** - keep options concise.

### Step 4.5: Write the Understanding Doc

**Runs only on the PR/MR paths** — standard-menu Option 2, or detached-HEAD Option 1. Skip it for local merge, keep-as-is, and discard.

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
  → docs/work/<slug>/understanding.md
  ```

Do not push until the explain-pr exit checklist passes.

### Step 5: Execute Choice

#### Option 1: Merge Locally

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

# Only after merge succeeds: cleanup worktree (Step 6), then delete branch
```

Then: Cleanup worktree (Step 6), then delete branch:

```bash
git branch -d <feature-branch>
```

#### Option 2: Push and Create PR

**Step 4.5 must be complete first** — understanding doc committed, PR-body block in hand.

```bash
# Push branch (the understanding doc rides along in the commits)
git push -u origin <feature-branch>
```

Create the PR/MR with the understanding-doc block at the top of the body:

```bash
gh pr create --base <base-branch> --body-file <body.md>                        # GitHub
glab mr create --target-branch <base-branch> --description "$(cat <body.md>)"  # GitLab
```

**No gh/glab installed:** push, then print the compare URL together with the PR-body block for your human partner to paste.

**Do NOT clean up worktree** — user needs it alive to iterate on PR feedback.

#### Option 3: Keep As-Is

Report: "Keeping branch <name>. Worktree preserved at <path>."

**Don't cleanup worktree.**

#### Option 4: Discard

**Confirm first:**
```
This will permanently delete:
- Branch <name>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for exact confirmation.

If confirmed:
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
```

Then: Cleanup worktree (Step 6), then force-delete branch:
```bash
git branch -D <feature-branch>
```

### Step 6: Cleanup Workspace

**Only runs for Options 1 and 4.** Options 2 and 3 always preserve the worktree.

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
```

**If `GIT_DIR == GIT_COMMON`:** Normal repo, no worktree to clean up. Done.

**If worktree path is under `.worktrees/` or `worktrees/`:** Superpowers created this worktree — we own cleanup.

```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune  # Self-healing: clean up any stale registrations
```

**Otherwise:** The host environment (harness) owns this workspace. Do NOT remove it. If your platform provides a workspace-exit tool, use it. Otherwise, leave the workspace in place.

## Quick Reference

| Option | Understanding Doc | Merge | Push | Keep Worktree | Cleanup Branch |
|--------|-------------------|-------|------|---------------|----------------|
| 1. Merge locally | - | yes | - | - | yes |
| 2. Create PR | yes (Step 4.5) | - | yes | yes | - |
| 3. Keep as-is | - | - | - | yes | - |
| 4. Discard | - | - | - | - | yes (force) |

Detached-HEAD menu: its Option 1 (push + PR) maps to the Option 2 row — understanding doc required.

## Common Mistakes

**Skipping test verification**
- **Problem:** Merge broken code, create failing PR
- **Fix:** Always verify tests before offering options

**Open-ended questions**
- **Problem:** "What should I do next?" is ambiguous
- **Fix:** Present exactly 4 structured options (or 3 for detached HEAD)

**Pushing before the understanding doc**
- **Problem:** Doc lands in a follow-up commit or never — reviewer gets a PR with no why
- **Fix:** Step 4.5 commits the doc, then Step 5 pushes

**Writing the understanding doc from the diff**
- **Problem:** Restates what the reviewer can already read; the session-only context (abandoned alternatives, traps) is lost
- **Fix:** warm path — pull the why from this session, use the bundle only for the mechanical parts

**Cleaning up worktree for Option 2**
- **Problem:** Remove worktree user needs for PR iteration
- **Fix:** Only cleanup for Options 1 and 4

**Deleting branch before removing worktree**
- **Problem:** `git branch -d` fails because worktree still references the branch
- **Fix:** Merge first, remove worktree, then delete branch

**Running git worktree remove from inside the worktree**
- **Problem:** Command fails silently when CWD is inside the worktree being removed
- **Fix:** Always `cd` to main repo root before `git worktree remove`

**Cleaning up harness-owned worktrees**
- **Problem:** Removing a worktree the harness created causes phantom state
- **Fix:** Only clean up worktrees under `.worktrees/` or `worktrees/`

**No confirmation for discard**
- **Problem:** Accidentally delete work
- **Fix:** Require typed "discard" confirmation

## Red Flags

**Never:**
- Add `Co-Authored-By: Claude` / AI-attribution / "Generated with" trailers to commits or PRs (see Commit Message Policy)
- Write a commit message or PR/MR description in English (한국어 필수 — see Commit Message Policy)
- Proceed with failing tests
- Push or open a PR/MR without the understanding doc committed
- Defer the understanding doc to after the PR is up — the session context is gone by then
- Merge without verifying tests on result
- Delete work without confirmation
- Force-push without explicit request
- Remove a worktree before confirming merge success
- Clean up worktrees you didn't create (provenance check)
- Run `git worktree remove` from inside the worktree

**Always:**
- Verify tests before offering options
- Detect environment before presenting menu
- Present exactly 4 options (or 3 for detached HEAD)
- Run Step 4.5 (superpowers:explain-pr, warm) on every PR/MR path
- Get typed confirmation for Option 4
- Clean up worktree for Options 1 & 4 only
- `cd` to main repo root before worktree removal
- Run `git worktree prune` after removal
