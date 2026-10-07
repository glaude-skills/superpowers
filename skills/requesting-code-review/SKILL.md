---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or: git merge-base origin/main HEAD
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer subagent:**

Dispatch a `general-purpose` subagent, filling the template at [code-reviewer.md](code-reviewer.md)

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit

## Two Seats for the Whole-Branch Review

**When the branch has a contract to keep** — `docs/work/<slug>/dod.md` is FROZEN, or the project
keeps rule documents assigned to paths (an `.ai/` routing table) — the whole-branch review gets
two reviewers, dispatched **in parallel in one message**:

| Seat | Template | Axis |
|---|---|---|
| Bug reviewer | [code-reviewer.md](code-reviewer.md) | bugs, regressions, security, test gaps |
| Contract reviewer | [contract-reviewer.md](contract-reviewer.md) | frozen DoD, spec and plan, project rules |

Give both the same range. Give the contract reviewer the rule documents the routing table assigns
to `git diff --name-only <base>...HEAD`. Neither condition holds → one seat, code-reviewer.md only.
Per-task reviews stay single-seat.

**When the two seats disagree:**
- The code **meets** a frozen DoD criterion and the bug reviewer's fix would break that criterion
  → the contract reviewer wins for now. The open question is "should the contract change?", and
  that is your human partner's decision. Order: partner approves → commit the DoD amendment alone
  → rework. Never reverse it; fixing first erases the basis of this branch's verdict.
- The code **violates** a criterion → that is a code fix, not a contract debate. Leave the
  contract alone; raising an amendment here lowers the bar to fit the code.
- No frozen criterion involved → the bug reviewer's verdict stands.

Do not widen the first rule to "any finding a criterion touches". Most changed files have some
criterion nearby; widening turns every bug report into a contract debate.

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/work/deployment/plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "I'll just review the diff myself instead of dispatching a reviewer" | You're the coordinator — reviewing the diff inline burns the context window you need to keep driving the work. Dispatch a reviewer subagent: the diff and the evaluation live in its context, and only the findings come back to you. |
| "The reviewer needs my whole session history to understand the change" | Hand it precisely crafted context, never your session's history. That keeps the reviewer on the work product, not your thought process. |

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: [code-reviewer.md](code-reviewer.md)
