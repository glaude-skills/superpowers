<!-- Moved verbatim from subagent-driven-development SKILL.md in 6.4.98; only links changed. Its pointer stays under the same heading in ../SKILL.md. -->

## Token Budget (fork policy, 2026-11-15)

Your human partner found that sessions spend too many tokens, above all
on subagents.
An agent re-reads its whole context on every tool call, so its cost is
roughly (number of calls) x (average context). A long-lived agent grows
both, so its cost grows with the square of its lifetime. Measured in one
real session: one implementer given three tasks made 329 tool calls and
read about 107M cached tokens, about 320k of context per call, because
every screenshot it opened stayed in its context; that one agent was
about half of what all ten of the session's subagents cost together. A
verifier waiting on a background test checked its status 108 times.
Three agents ran heavy jobs side by side (full suite, GPU frame timing,
window captures): six processes overlapped, the timing failed falsely,
and it had to be measured again.

These rules bind you and go into every dispatch (the templates carry the
ones a subagent keeps):

- **Lifetime.** One fresh agent per task is the default, and it ends at
  its commit: never hand a finished implementer its next task. Several
  small tasks share one implementer only under the caps in The Task Loop (`../SKILL.md`).
- **Narrow brief.** A dispatch carries the task brief, the files to
  change, and the acceptance criteria. Never make an agent read the whole
  plan or a whole design document: copy the section the task needs into
  the dispatch, or name it by heading.
- **Waiting on a command.** Run a long command (suite, build, export) in
  the foreground with a timeout long enough for it to finish, and take
  its result once. Never start it in the background and check its status
  in a loop: every check is a call that re-reads the whole context. When
  it must run in the background, wait for its completion notification
  and nothing else.
- **Images.** An image an agent opens stays in its context and is re-read
  on every later call. Open only the few a verdict needs. When many must
  be looked at, dispatch a short-lived agent that only looks at those
  images and returns one verdict line per image, or hand them to your
  partner.
- **Heavy jobs one at a time.** A full suite, a build, a GPU or frame-time
  measurement, and a capture that opens a window run one at a time across
  all agents, yours included: overlapping them slows each one and makes
  measurements fail falsely. What runs side by side is light: reading,
  writing code and docs, selected tests. The full suite beside a reading
  reviewer (Review Chunks, `../SKILL.md`) is one heavy job and one light one, which this
  allows. Running agents side by side saves time, never tokens.
- **Review by risk.** One review at the end of the plan is the default; a
  chunk gets its own review only for the risks Review Chunks (`../SKILL.md`) names. A
  re-review runs only for an operational defect (The fix loop, `../SKILL.md`).
- **The controller's share.** A merge, one status-file line, a check that
  takes a few calls: do it yourself instead of dispatching. A dispatched
  agent pays its start-up reading before its first useful call. Fixing
  review findings is not in this share (The fix loop, `../SKILL.md`).
