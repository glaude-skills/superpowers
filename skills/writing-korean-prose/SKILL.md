---
name: writing-korean-prose
description: Use when writing Korean that a person will read - commit messages, PR/MR titles and descriptions, review comments, reports to your human partner, design docs, plans, code comments, mermaid labels, test names, blog posts - especially as a subagent that did not receive the session-start bootstrap
---

# 한국어 문장 쓰기

사람이 읽는 한국어는 사람이 쓴 기술 문서처럼 쓴다. 규칙 표는 한 곳에만 있다.

**정본:** 이 스킬의 Base directory 옆 `../using-superpowers/references/korean-style.md`. 파일 전체를 읽고 따른다.

세션 시작 때 들어오는 using-superpowers 에는 부류별 한 줄 요약만 있다(6.4.97 부터). 컨트롤러도 이 세션에서 그 파일을 아직 읽지 않았으면 사람이 읽는 한국어를 쓰기 전에 읽는다. 서브에이전트, 다른 세션에서 넘겨받은 작업도 같다.

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
- 경민님이 새로 지적한 표현은 `../using-superpowers/references/korean-style.md` 와 `ai-style.md` 두 곳에 함께 넣는다. 부류 요약이 바뀌면 using-superpowers SKILL.md 의 부류별 한 줄도 고친다. 이 스킬에는 표를 복사하지 않는다
