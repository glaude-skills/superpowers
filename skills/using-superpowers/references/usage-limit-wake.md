<!-- Moved verbatim from using-superpowers SKILL.md in 6.4.97; only links changed. Its routing row is in ../SKILL.md. -->

## Waking After Usage Limits (fork policy, 2026-11-18)

Your human partner runs a scheduled task that wakes sessions stopped by a usage limit. Since 2026-11-19 it checks every hour, reads the reset time from the limit message, and when the reset is still ahead it schedules a one-shot retry (`claude-resume-retry`) three minutes after it: a 6-hourly run at 03:01 woke a session whose limit reset at 03:40, the wake itself hit the limit, and the session stayed stopped for five hours. It wakes only the sessions listed in its list file, so a session that is not listed stays stopped.

The scheduler exists on a machine that has `~/.claude/resume-sessions.json` and `~/.claude/resume-sessions.ps1` (Windows task `claude-resume-sessions`). On such a machine, when you start or take over work that keeps running across hours (an orchestrating session with background subagents, a multi-task plan), make the current session the project's entry:

1. Your session id is the `sessionId` of your row in `claude agents --json` (match `cwd` and `name`).
2. Back up `resume-sessions.json`, then set the project's entry (add one if missing; replace one whose session is no longer running) as UTF-8 JSON:
   - `sessionId`: your session id
   - `configDir`: the token folder of the account this session runs on (for example `~/.claude-saycore`)
   - `cwd`: the project root
   - `prompt`: what to check on waking: stopped subagents (continue them with SendMessage), orphan processes and leftover locks, and the status files whose `## Next` holds the live work
   - `freshPromptFile`: a prompt file for a new session when resuming fails, kept current with the live work and the decisions your partner closed
3. Run `powershell -NoProfile -ExecutionPolicy Bypass -File ~/.claude/resume-sessions.ps1 -DryRun` and read the last line of `~/.claude/resume-logs/resume.log`: your entry shows `state=working`.
4. Tell your partner in one line that this session is on the wake list.

The scheduler itself ships with this skill: `scripts/resume-sessions.ps1` is the script and `scripts/install-resume-scheduler.ps1` installs it (copies the script into `~/.claude`, keeps an existing list file, registers the hourly task). On a Windows machine without those files, run `powershell -NoProfile -ExecutionPolicy Bypass -File <this skill's dir>/scripts/install-resume-scheduler.ps1`, then follow the steps above. After a skill update that changes `scripts/resume-sessions.ps1`, run the installer again so the copy in `~/.claude` matches. On a machine that is not Windows, say in one line that no wake schedule exists there.
