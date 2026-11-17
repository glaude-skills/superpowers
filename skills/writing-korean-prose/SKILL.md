---
name: writing-korean-prose
description: Use when writing Korean that a person will read - commit messages, PR/MR titles and descriptions, review comments, reports to your human partner, design docs, plans, code comments, mermaid labels, test names, blog posts - especially as a subagent that did not receive the session-start bootstrap
---

# 한국어 문장 쓰기

사람이 읽는 한국어는 사람이 쓴 기술 문서처럼 쓴다. 규칙 표는 한 곳에만 있다.

**정본:** 이 스킬의 Base directory 옆 `../using-superpowers/SKILL.md` 의 `### 한국어 문체: AI 같은 버릇 금지` 절. 그 제목부터 다음 제목 `### 사람에게 묻는 질문 쓰는 법` 바로 앞까지 읽고 따른다. 그 파일 맨 위의 SUBAGENT-STOP 은 부트스트랩 전체에 대한 말이고, 이 절을 읽는 데는 해당하지 않는다.

세션 시작 때 using-superpowers 를 이미 받은 컨트롤러는 그 절이 컨텍스트에 있으니 다시 읽지 않는다. 서브에이전트, 다른 세션에서 넘겨받은 작업처럼 그 절이 컨텍스트에 없을 때 읽는다.

## 쓰기 전에 기억할 것

절을 읽기 전이라도 아래는 항상 지킨다.

- 문장 끝은 합니다체로 통일한다. 커밋과 PR 제목처럼 명사로 끝나는 짧은 문구는 예외
- 긴 하이픈(—, –)과 가운뎃점(·)을 쓰지 않는다
- 문장 끝 `!` `?` 앞에 띄어쓰기를 하나 넣는다
- 질문이나 비유 헤딩, 경구, "볼 것은 두 가지다" 같은 안내 멘트, "핵심", "짚어 보다" 를 쓰지 않는다
- 도구와 코드에 사람 동사(말하다, 알다, 부르다, 죽다)를 붙이지 않는다
- 커밋과 PR 문구에 AI 작성 트레일러를 넣지 않는다

## 다른 문서와의 관계

- 블로그 원고용 상세본은 tech-blog 저장소 `docs/writing/ai-style.md` 다. 그 저장소 안에서 글을 쓸 때는 그 파일을 먼저 읽는다
- 경민님이 새로 지적한 표현은 using-superpowers 의 절과 `ai-style.md` 두 곳에 함께 넣는다. 이 스킬에는 표를 복사하지 않는다
