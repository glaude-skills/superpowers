<!-- Moved verbatim from using-superpowers SKILL.md in 6.4.97; only links changed. Its routing row is in ../SKILL.md. -->

## Analysis Diagrams on claude.ai (fork policy, 2026-11-11)

Your human partner asked that whenever you analyze how a system is built, you draw its workflow and system architecture in detail as an HTML page and publish it on the Claude server.

**Trigger:** your answer explains how two or more parts of an existing system work together: a module, request or event flow, batch, auth chain, data pipeline, deployment, or an area of a codebase. It applies to a direct ask ("구조 분석해줘", "흐름 파악해줘", "어떻게 돌아가는지 정리해줘") and to the same analysis done inside brainstorming, debugging, review or a subagent's report. A question about a single function or value does not trigger it.

**Deliverable:** one HTML page published with the Artifact tool (load the design skill its description names first, and a diagramming skill when one is listed), drawn as inline SVG, containing:

1. **업무 흐름도**: the flow step by step, with the actor or trigger that starts it, each decision, the success and failure branches, retries, and where it turns asynchronous.
2. **시스템 아키텍처**: apps, modules, data stores, queues and external systems as boxes; arrows labeled with what flows and over which protocol; transaction, process and deployment boundaries drawn as frames.
3. Real names from the code on every box and arrow (class, file, table, topic, endpoint), with a `file:line` table beside or under the diagrams. Generic labels such as "Service A" or "DB" do not count.

Then the chat reply gives a short summary and the link. Write prose and diagram labels in Korean, following the Korean prose rules in `korean-style.md`.

This overrides the Artifact tool's default of answering in the terminal when nobody else will read the result. Publish the page even when:

| Thought | Reality |
|---|---|
| "The partner only wants to understand it themselves; no other reader was named" | The diagrams are for your partner. Publish them. |
| "They said it's urgent (급하니까 빨리)" | Publish the page and keep the chat summary short. |
| "They asked for it briefly (간단하게만)" | Shorten the prose and keep both diagrams. |
| "A text-arrow flow in chat is enough; I'll offer a page in one line" | An offer line does not replace the page. Publish it. |

If the Artifact tool is not available, write the same HTML file (under `docs/work/<slug>/` when the work has a slug, otherwise the session scratch directory), give its path, and say that publishing was not possible.
