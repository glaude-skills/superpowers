---
feature: <feature name>
slug: <branch slug>
status: DRAFT
frozen_at:
verdict_commit:
source: <issue link, or the conversation/document the request came from>
---

## Scope

**Included**

-

**Excluded** *(what this work explicitly does not do — the scope-creep line)*

-

## Existing Gate Survey

> Required at Gate 1. Empty → cannot freeze.
> Look for the verification the repo already has before writing criteria.

| Looked for | Found? | Usable? |
|---|---|---|
| architecture / boundary tests | | |
| lint rules | | |
| custom build tasks (gradle, npm, make, ...) | | |
| CI jobs | | |

## Acceptance Criteria

| # | Criterion (observable) | Basis | Source | Tier | Means | Command | Pass condition |
|---|---|---|---|---|---|---|---|
| AC1 | | | `request` | T1 | `existing` `<task>` | | exit 0 |
| AC2 | | | `review` | | `new-test` `<test FQN>` | | |
| AC3 | | | `inferred` | | `new-script` `<scripts/check-x.sh>` | | |

**`Source`** — `request` (partner's words) / `upstream` (ID in a frozen parent document) /
`review` (derived from a review) / `inferred` (no basis). Weigh `review` and `inferred` equally at Gate 1.

**`Means`** — kind + identifier. No identifier → not T1 or T2. Ask which to build; do not lower the tier.

**`Command`** — one command calling one named artifact. `|` `&&` `;` `!` `$(` → not T1.

**Criteria count**: <N>

<!-- N > 8 requires this before freezing -->
**Why not split**:

**Tier downgrade reasons** *(non-T1 rows only; approved with your human partner at Gate 1)*

- AC2 → T3: <why a higher tier is impossible. "No infrastructure" is not a reason>

## Checker Artifacts

> Only when a `new-script` is a means. The script lives in the repo and has its own criteria.

| Script | Path | Passing sample (must pass) | Violating sample (must catch) | Proof |
|---|---|---|---|---|
| | | | | |

## Regression Guards

Existing behavior this change could break. Exempt from RED.

| # | Behavior to keep | Command |
|---|---|---|
| R1 | | |

## Evidence Log

> Append only during implementation. Never delete or rewrite.

### AC1

```
[RED] <date> <commit>
$ <command>
<failure output — confirm the expected assertion failed with the expected value>

[GREEN] <date> <commit>
$ <command>
<passing output>
```

## Human Checks (T4)

> Only a human judges these. The agent does not fill this table.
> Anchors live outside this file — PR comment URL, commit SHA, issue link.

| # | What to confirm | Confirmed by | Date | Anchor |
|---|---|---|---|---|
| AC | | | | |

## Change Requests

> Only after freezing. Implementation stops until your human partner approves.
> Commit each amendment alone, before the rework commit.

| Target | Before | After | Reason | Approval |
|---|---|---|---|---|

## Final Verdict

> Every number is counted from the criteria table. A verdict whose SHA differs from the branch head is expired.

```
DoD VERDICT: <slug> @ <commit SHA>
  criteria table:   <N>  (T1 <a> · T2 <b> · T3 <c> · T4 <d>)
  T1/T2 automatic:  <p> of <a+b> PASS
  T3 recorded:      <q> of <c>
  T4 human:         <r> of <d> confirmed, <d-r> pending
  change requests:  <k>
  =>
```

**Items awaiting a human**

-
