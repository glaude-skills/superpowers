<!-- Moved verbatim from subagent-driven-development SKILL.md in 6.4.98; only links changed. Its pointer stays under the same heading in ../SKILL.md. -->

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Close enough on spec compliance" | Reviewer found spec gaps = not done. Fix, or hit the cap and escalate — those are the only exits. |
| "I'll fix it myself, dispatching is overhead" | Controller fixes pollute your context and skip review. Resume the implementer. |
| "One more round will converge" | Past the cap, rounds don't converge — the failure is structural. Escalate to your partner. |
| "The reviewer will just find something new anyway" | Scoped re-reviews verify fixes; they cannot wander. New findings on untouched code go to the ledger, not the loop. |
| "This finding is obviously wrong, I'll drop it" | At the cap your partner decides, and every decision is a ledger entry. Silent discards are forbidden. |
| "The fix was small, skip the re-review" | Size is not the test. A round that fixes an operational defect ends with a scoped re-review, however small the fix; a round of check defects only is checked by its covering tests. |
| "Re-review everything, to be safe" | A re-review re-reads the diff at full cost. If you cannot write in one line how the finding reaches users or operations, it is a check defect and its covering tests are the check. |
| "Reviews slow the loop down" | The loop without reviews is just unverified churn. Reviews are the loop's brakes and steering. |
| "Ledger bookkeeping is overhead" | The ledger is what survives compaction. Controllers without one have re-dispatched entire completed task sequences. |
| "The implementer spawned its own reviewer — free extra assurance" | It's a duplicate seat reviewing the same diff; the task review is the gate. A worker-spawned reviewer is a defect to flag, not rigor. |
| "Every task deserves its own fresh implementer" | A small task dispatched alone is mostly start-up reading. A short run of small tasks on the same files shares one implementer; each task keeps its own tests and commit. |
| "This implementer already knows the code, give it the next task too" | Its every later call re-reads everything it has seen. Past a few dozen calls, or once it has opened images, a fresh implementer is cheaper than its start-up. |
| "The chunk's last implementer can run the full suite" | That holds the loop for the suite's whole duration. Run it yourself while the reviewer reads. |
| "I'll start it in the background and check on it" | Every check re-reads the whole context; one verifier checked 108 times. Foreground with a timeout, or wait for the completion notification. |
| "Let me look at all the captures myself" | Each image stays in context for every later call. Open the few a verdict needs; give the rest to a short image-only agent or to your partner. |
| "Run the suite, the build and the captures in parallel to save time" | Heavy jobs run one at a time. Overlapped, they slow each other and the measurements fail falsely; parallel agents save time, never tokens. |
| "I'll update `.ai/` later, in one pass" | A commit touching routes, data model, conventions, or progress without its `.ai/` update is incomplete. Same commit, every time. |
