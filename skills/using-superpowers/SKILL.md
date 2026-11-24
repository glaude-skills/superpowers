---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring skill invocation before ANY response including clarifying questions
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, ignore this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## 언어 (Language)

**항상 한국어로 응답하세요.** 사용자가 명시적으로 다른 언어를 요청하지 않는 한, 사용자에게 보여지는 모든 답변, 설명, 요약은 한국어로 작성합니다. (코드, 명령어, 파일 경로, 식별자 등 원문 그대로여야 하는 것은 예외입니다.)

### 한국어 문체 (fork policy, 2026-11-24 분리)

사람이 읽는 한국어(답변, 문서, 커밋과 PR, 코드 주석, mermaid 라벨)를 쓰기 전에 `references/korean-style.md` 를 읽는다. 부류별로 피할 것과 대신 쓸 표현이 그 파일에 있고, 판단은 그 표로 한다. 아래는 읽기 전에도 지키는 부류별 한 줄이다.

1. 제목과 헤딩: 질문, 비유, 이야기형 제목 대신 내용이 보이는 명사구를 쓴다.
2. 도입과 맺음: 숫자 연출, 묻지 않은 해명, 다음 글 예고 없이 한 일부터 쓰고 사실로 맺는다.
3. 문장 구조: 주어와 동사를 살리고 조사를 생략하지 않는다. 동작 명사 나열과 압축 대구는 풀어 쓴다.
4. 동사와 낱말: "핵심", "짚어 보다", 입말 동사("골랐다", "꽂았다"), 코드에 붙이는 비유 동사("키우다", "굴리다")를 쓰지 않는다.
5. 도구와 코드: 말하다, 알다, 부르다, 죽다 같은 사람 동사 대신 "호출한다", "참조한다", "출력한다"를 쓴다.
6. 비유와 경구: 꾸밈 비유, 경구, 극적 표현 대신 무엇이 일어났는지 사실로 쓴다.
7. 독자를 대하는 태도: 안내 멘트, 가르치는 말투, 자기 평가, 한계를 선택처럼 포장하는 말을 쓰지 않는다.
8. 용어: 억지 번역("단언", "경합") 대신 업계 용어(assertion, race condition)를 쓰고, 약어는 첫 등장에 풀어 쓴다.
9. 말투와 부호: 합니다체로 통일하고, 문장 끝 `!` `?` 앞에 한 칸 띄우며, 가운뎃점과 긴 하이픈을 쓰지 않는다.

서브에이전트는 이 절을 받지 못한다. 서브에이전트에게 사람이 읽는 한국어를 쓰게 할 때는 브리프에 `superpowers:writing-korean-prose` 를 적는다.

## The Rule

**Invoke relevant or requested skills BEFORE any response or action** — including clarifying questions, exploring the codebase, or checking files. If it turns out wrong for the situation, you don't have to use it.

**Before entering plan mode:** if you haven't already brainstormed, invoke the brainstorming skill first.

Then announce "Using [skill] to [purpose]" and follow the skill exactly. If it has a checklist, create a todo per item.

## 상시 로딩 법칙 (fork policy, 2026-11-24)

이 파일은 세션 시작 hook 이 startup, clear, compact 때마다 통째로 넣는다. Claude Code 는 hook 출력이 10,000자를 넘으면 앞 2,000자 미리보기만 넘긴다. 그래서 이 파일에는 전역 규칙과 라우팅 표만 두고 상세는 `references/` 가 소유한다. 같은 법칙을 모든 프로젝트와 스킬에 적용한다.

- 상시 로딩 파일(이 파일, 스킬 SKILL.md, 프로젝트 `CLAUDE.md` 와 `CONTEXT.md` 와 그 import)에는 전역 규칙과 링크 한 줄만 둔다.
- 상한은 래칫이다. 상한을 올려 자리를 만들지 않고, 규칙을 넣으려면 같은 만큼 줄인다.
- 상세를 옮길 때는 문장 그대로 옮기고 링크만 고친다.
- 모든 브랜치가 같은 자리에 쓰는 목록 파일을 만들지 않는다. 상태, 기술 부채, 변경 이력은 항목당 파일로 둔다.
- 죽은 참조, 고아 문서, 상한 초과는 커밋 전에 게이트 스크립트로 검사한다.

상세와 근거, 상한 수치는 `references/context-budget.md` 에 있다.

## 라우팅 표

작업이 첫 칸의 트리거에 해당하면 요청이 없어도 일을 시작하기 전에 두 번째 칸의 파일을 Read 한다. 경로는 이 스킬 폴더 기준이다. 세 번째 칸은 요약이 아니라 잊었을 때 가장 비싼 실패를 막는 한 줄이고, 판단은 원문으로 한다. 서브에이전트는 이 표를 받지 못하므로, 일을 맡길 때 이 표를 그 일에 적용한 파일 목록을 브리프에 넣는다.

| 트리거 (사용자 말, 작업) | 먼저 읽을 파일 | 잊으면 안 되는 한 줄 |
|---|---|---|
| 사람이 읽는 한국어를 쓴다 | `references/korean-style.md` | 부류별 표 전체를 따른다. 서브에이전트 브리프에는 `superpowers:writing-korean-prose` 를 적는다 |
| 사람에게 결정을 묻는다 | `references/asking-questions.md` | 질문마다 대상과 현재 상태, 선택지별 결과, 권고와 까닭, 답이 없을 때 할 일을 넣고 한 번에 셋까지만 묻는다 |
| 프로젝트 첫 접촉, 진입 파일이나 `.ai/` 수정 | `references/project-policy.md` | `.ai/` 가 없으면 먼저 만든다. 진입 파일이나 `.ai/` 를 고친 커밋 전에 `scripts/context-check` 를 돌린다 |
| 작업 시작, 커밋, 멈춤, 세션 재개 | `references/work-records.md` | 진행 상태는 `.ai/status/<slug>.md` 에 쓰고 작업과 함께 커밋, push 한다. 재개할 때는 그 파일과 `git log` 를 먼저 읽고 `## Next` 부터 시작한다. 할 일 목록과 플러그인 메모리는 기록이 아니다 |
| 에이전트 디스패치, 실행 중인 에이전트 보고 | `references/subagents.md` | 디스패치마다 표에서 고른 `model` 과 `effort` 를 넘기고 사용자에게 "opus high" 처럼 알린다. 에이전트 하나에 계획 태스크 하나, 브리프에 셀 수 있는 정지 조건(약 200 호출)을 쓴다 |
| 리뷰 수정 루프, 재시도해도 실패한 단계 | `references/subagents.md` | 리뷰 수정은 두 라운드까지 하고 남은 지적은 사용자에게 넘긴다. 실패한 단계는 건너뛰지 않고 보고한다 |
| 정리, 마무리, clear, compact 신호 | `references/session-handoff.md` | 답하기 전에 재개 프롬프트 파일, 상태 파일 `## Next`, 메모리를 먼저 갱신한다. 방식을 말하지 않았으면 clear 와 compact 중 하나를 까닭과 함께 한 줄로 권한다 |
| 세션이 "방금 clear 했으니 이어서" 로 시작 | `references/session-handoff.md` | 이 프로젝트의 재개 프롬프트 파일을 먼저 읽고 그 첫 단계를 따른다 |
| 몇 시간 이어지는 작업 시작, 사용 한도 후 재개 | `references/usage-limit-wake.md` | 깨우기 목록 파일이 있는 머신이면 이 세션을 프로젝트 항목으로 등록하고 사용자에게 한 줄로 알린다 |
| superpowers 스킬 수정 | `references/editing-skills.md` | 포크 클론을 고치고 활성 캐시에 복사한 뒤, 버전 3곳과 README 이력을 올려 같은 턴에 push 하고 PR 로 `main` 에 넣는다 |
| 화면, 레이아웃, 스타일처럼 보이는 것을 만들거나 바꾼다 | `references/design-mockups.md` | 코드보다 먼저 claude.ai 목업을 게시하고 명시적 승인을 받는다 |
| 기존 시스템의 구조나 흐름 분석 | `references/analysis-diagrams.md` | 실제 이름을 단 업무 흐름도와 시스템 아키텍처 HTML 페이지를 게시한다. 짧게 해 달라는 요청에도 그림은 둔다 |
| 서버 코드(요청 처리, 배치, 외부 호출, 개인정보) | `references/server-logging.md` | `superpowers:writing-traceable-logs` 를 따르고 구현과 리뷰 브리프에도 적는다 |
| 작업 규모 판단, 무거운 파이프라인 시작 | `references/scale-process.md` | 설계가 필요 없는 수정은 에이전트 없이 직접 하고, 작은 작업은 시작할 때 가벼운 경로를 한 번만 묻는다 |
| 월, 수, 금의 첫 세션 | `references/scale-process.md` | 상시 로딩 문서를 규칙당 한 줄로 줄이고 상세는 필요할 때 읽는 파일로 문장 그대로 옮긴다 |
| 상시 로딩 파일이나 스킬 SKILL.md 추가, 수정 | `references/context-budget.md` | 전역 규칙과 링크 한 줄만 둔다. 상한은 래칫이고, 커밋 전에 게이트를 돌린다 |

## Skill Priority

When multiple skills apply, process skills come first — they set the approach, then implementation skills (frontend-design, etc.) carry it out. Brainstorming and systematic-debugging are Superpowers' most common process skills, but the rule holds for any of them.

- "Let's build X" → superpowers:brainstorming first, then implementation skills.
- "Fix this bug" → superpowers:systematic-debugging first, then domain skills.

## Red Flags

These thoughts mean STOP—you're rationalizing:

| Thought | Reality |
|---------|---------|
| "This is just a simple question" | Questions are tasks. Check for skills. |
| "I need more context first" | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first" | Skills tell you HOW to explore. Check first. |
| "I can check git/files quickly" | Files lack conversation context. Check for skills. |
| "Let me gather information first" | Skills tell you HOW to gather information. |
| "This doesn't need a formal skill" | If a skill exists, use it. |
| "I remember this skill" | Skills evolve. Read current version. |
| "This doesn't count as a task" | Action = task. Check for skills. |
| "The skill is overkill" | Simple things become complex. Use it. |
| "I'll just do this one thing first" | Check BEFORE doing anything. |
| "This feels productive" | Undisciplined action wastes time. Skills prevent this. |
| "I know what that means" | Knowing the concept ≠ using the skill. Invoke it. |

## Platform Adaptation

If your harness appears here, read its reference file for special instructions:

- Claude Code: `references/claude-code-tools.md`
- Codex: `references/codex-tools.md`
- Pi: `references/pi-tools.md`
- Antigravity: `references/antigravity-tools.md`
- Hermes Agent: `references/hermes-tools.md`
- Muse: `references/muse-tools.md`

## User Instructions

User instructions (CLAUDE.md, AGENTS.md, GEMINI.md, etc, direct requests) take precedence over skills, which in turn override default behavior. Only skip skill workflows or instructions when your human partner has explicitly told you to.
