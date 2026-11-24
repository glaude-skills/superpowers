<!-- Moved verbatim from using-superpowers SKILL.md in 6.4.98; only links changed. Its routing row is in ../SKILL.md. -->

## Server Logging (fork policy, 2026-11-12)

Your human partner asked that every server leave traceable logs for every request and response, for every call to an outside service (SMS, KakaoTalk 알림톡, email, external APIs), and for every handling of personal information (masked).

Any server work (HTTP handlers, background jobs, calls to SMS, 알림톡, email, push or external APIs, code that touches personal information) follows **REQUIRED SUB-SKILL: superpowers:writing-traceable-logs**, in design, plan, implementation and review alike. Specs and plans name the request id, call logging, masking and access-record work their change needs. Implementer and reviewer briefs for server code name the skill, because subagents do not see this section.
