---
name: definition-of-done
description: Use when about to start implementing a planned feature, bugfix, or refactor, when asked "is this done?", or right before declaring work complete - when completion criteria exist only in conversation or prose
---

# Definition of Done

## Overview

Agents say "done" too easily. When the completion criteria live only in prose, they shift between
models and sessions, and verification becomes an impression.

**Core principle:** take the verdict away from the model. Only two things are model-independent:

1. **A frozen file** — a human can detect tampering with `git diff`.
2. **The exit code of a named artifact** — a test, task, or committed script with an identifier.

"Named" is the point. An exit code leaves nothing to interpret, but nothing guarantees *what it
measures*. A shell pipeline hand-written into the contract is itself an unverified program, and it
can exit 0 while measuring nothing.

**Violating the letter of these rules is violating the spirit of these rules.**

## The Iron Rules

1. No implementation code before the contract is FROZEN.
2. No completion claim without evidence. Evidence is the output of a command you just ran.
3. Never quietly edit a frozen criterion. To change one, stop and get re-approval.
4. While even one human check is pending, do not use the word "done".
5. Run each verification command at the moment you write it into the contract. A command you
   never ran is not a criterion.

## The Contract File

`docs/work/<slug>/dod.md`, created from [template.dod.md](template.dod.md). `<slug>` is the branch
slug — the same key as `design.md`, `plan.md`, and `understanding.md` in that directory. A project
instruction naming another location wins; use one path for drafting, freezing, and the verdict.

## Procedure

### Gate 1 — Draft and Freeze (before implementation)

1. Write `dod.md` from the template, `status: DRAFT`.
2. **Survey the existing gates** — architecture tests, lint rules, custom build tasks, CI jobs.
   Actually look. Fill the survey table. **An empty survey cannot be frozen.** Skip it and you will
   hand-write a shell pipeline that duplicates a gate the repo already has.
3. Extract acceptance criteria (rules below).
4. **Draft commit:** commit `design.md`, `plan.md`, and `dod.md` (still DRAFT) together.
5. Present the contract with the plan; ask your human partner to approve.
6. On approval, set `status: FROZEN` and `frozen_at`, and **commit only that change**:

   ```bash
   git add docs/work/<slug>/dod.md
   git commit -m "docs(<scope>): freeze DoD contract"
   ```

   The freeze commit's diff must be just those two lines. That is why step 4 exists: without the
   draft commit, the freeze commit carries the whole new file and history cannot show that the
   contract preceded the code. Never fold the freeze into the first implementation commit.

### During Implementation

- T1/T2 criteria: write the test first and watch it fail (RED). Paste the RED output into the
  evidence log, then the GREEN output after implementing.
- Discover a criterion is wrong? Stop implementing. Add a row under `## Change Requests`, get
  approval, and **commit the amendment alone, before the rework commit.** Reversed order reads as
  the amendment justifying the rework after the fact.

### Gate 2 — Verdict

Check that every criterion has evidence, then print the verdict in the fixed format below.

## Verification Means

The `Means` column holds a kind **plus an identifier**:

| Kind | Identifier | Example |
|---|---|---|
| `existing` | a task/job already in the repo | `npm run lint:arch` |
| `new-test` | fully qualified name of a test this change adds | `tests/api/orders.test.ts::rejects-empty-cart` |
| `new-script` | path of an executable committed to the repo | `scripts/check-legacy-names.sh` |

**No identifier → the criterion is not T1 or T2 yet.** Ask your human partner at Gate 1 which of
the three to build. You are deferring a decision, not lowering the tier.

**T1 command shape:** one command calling one named artifact. If the command contains `|`, `&&`,
`;`, `!`, or `$(`, it is not T1 — a pipeline's exit code is its last stage's, so it swallows
earlier failures.

**Alternation patterns:** when a check matches several alternatives (`grep -E 'a|b'`), confirm each
alternative matches on its own. A dead alternative hides behind a live one, even in RED.

**A `new-script` has its own acceptance criteria.** List a passing sample and a violating sample in
`## Checker Artifacts` and prove the script passes one and catches the other before using it.

## Writing Acceptance Criteria

**Shape:** `When [condition], [actor] produces [observable result].`

**Test:** could two people read this sentence alone and reach different verdicts? Then rewrite it.

**Banned words** (each observer reads them differently — a criterion containing one is void):
works correctly, handles properly, appropriately, without problems, stable, user-friendly, fast,
optimized, improved, robust.

**Count:** no minimum, no maximum. Never pad to a number — padded criteria are the empty
checkboxes this skill exists to stop.
- **Necessity:** "if this broke, would the feature be broken?" If not, delete it. "Existing tests
  pass" is a regression guard, not a criterion. "Follows conventions" is noise.
- **Coverage:** is any `Included` scope item verified by no criterion? Add one.
- Two criteria proven by the same means are one criterion. Merge them.
- **More than 8 criteria:** fill `Why not split`. Empty → cannot freeze. This shows the size to
  your human partner at Gate 1; it is not a ban.

**Traceability** — every criterion records `Basis` and `Source`:

| Source | Meaning | At Gate 1 |
|---|---|---|
| `request` | your partner's words, quoted | confirm as-is |
| `upstream` | an ID from a frozen parent document | check against it |
| `review` | derived from a review | **weigh like `inferred`** |
| `inferred` | no basis | focus here |

`review` and `inferred` rows are what nobody asked for — scanning just those rows catches scope
creep. Recording a review-derived criterion as `request` fabricates a basis.

## Verification Tiers

| Tier | Means | Who judges |
|---|---|---|
| T1 | single command calling a named artifact | exit code |
| T2 | reproducible command + expected output | a human re-runs it |
| T3 | recorded observation (screenshot, log file) | a human reviews later |
| T4 | human eyes only | only a human |

**Default is T1.** Lowering a tier needs a written reason that your human partner approves at
Gate 1 — never alone. **"There is no test infrastructure" is not a reason;** it means build a
`new-test` or `new-script`, and ask which.

**T4 anchors live outside the contract** — a PR comment URL, commit SHA, or issue link. A filled
cell in a file the agent writes is not human confirmation.

## RED First

T1/T2 criteria must fail before implementation, with the failure in the evidence log. A T1
criterion without a RED log counts as **unmet**.

RED must fail **for the expected reason** — the expected assertion with the expected wrong value.
An import error, syntax error, or missing file is not RED; the test never ran.

Regression guards are exempt: they are supposed to pass. Their first output is a baseline.

## Verdict Format (fixed)

**Every number below is counted from the criteria table. If they disagree, no verdict.**

```
DoD VERDICT: <slug> @ <commit SHA>
  criteria table:   8  (T1 5 · T2 1 · T3 1 · T4 1)
  T1/T2 automatic:  6 of 6 PASS
  T3 recorded:      1 of 1
  T4 human:         0 of 1 confirmed, 1 pending
  change requests:  2
  => AWAITING_HUMAN
```

- `VERIFIED` — zero pending human checks and every automatic check PASS. Only then.
- `AWAITING_HUMAN` — automatic checks pass, human checks remain. Do not write "done"; list them.
- `FAILED` — an automatic check failed.
- `BLOCKED` — verification itself cannot run (environment, dependency).

A commit after the verdict that changes a gate result requires updating the evidence and the
verdict. A verdict whose SHA differs from the branch head is expired.

## Common Rationalizations

| Excuse | Reality |
|---|---|
| "I'll implement first and write criteria after" | Gate 1 violation. Criteria written afterward bend to the code. |
| "No existing task, so T2" | Not a reason to lower a tier. Ask which artifact to build. |
| "A grep pipeline is a fine check" | It is an unverified program. No identifier, no T1. |
| "Chaining with `&&` is one command" | The chain's exit code is the last command's. |
| "I'll count the verdict numbers from memory" | Count from the table or the verdict is wrong. |
| "The reviewer asked for it, so it's `request`" | It is `review`. The scope-creep detector dies otherwise. |
| "I filled the T4 row, so it's confirmed" | You wrote that file. The anchor must live outside it. |
| "Blocked — I'll relax the criterion slightly" | Rule 3. Stop and get re-approval. |
| "Freezing in the first code commit is fine" | Then history cannot prove the contract came first. |
| "The tests passed" (not re-run) | Only output you just produced is evidence. |

## Red Flags — Stop

- A verification command contains `|`, `&&`, `;`, `!`, or `$(`
- `Means` holds a description instead of an identifier
- The gate survey is empty
- More than 8 criteria and `Why not split` is empty
- You are writing verdict numbers without counting the table
- Every `Source` is `request`
- Implementation code exists and `status` is still `DRAFT`

## Handoff

The contract file is the handoff point between sessions and models. Whoever picks the work up
reads `docs/work/<slug>/dod.md` and knows the criteria and the progress.
