---
name: writing-traceable-logs
description: Use when writing, changing or reviewing server code that handles HTTP requests or responses, runs a background job or scheduler, calls an outside service (SMS, KakaoTalk 알림톡, email, push, any external API), or reads, stores, shows or exports personal information
---

# Writing Traceable Logs

## Overview

Your human partner's standing rule for every server (2026-11-12): "서버에서는 모든 요청,응답에 대한 추적 가능한 로깅을 남기고, 외부 연계(SMS,알림톡,EMAIL,외부APICall) 등 그리고 개인정보(마스킹) 관련해서 추적 가능한 로그를 남기라고 명시해둬".

One request id links the request, every log line it causes, every outside call it makes and every personal-data access, and no log line holds personal information in the clear. A server change is done only when the four parts below hold for the code it touches.

## 1. Request id

- The first filter takes a well-formed incoming `X-Request-Id` (or the header the project already uses) or generates one, puts it in the logging context (MDC or the platform's equivalent) so every line carries it, and returns it in the response header. When the error body has a request id field, it holds the same value.
- The id crosses every boundary: outbound calls send it as a header, and queued jobs, async tasks and events store it and restore it when they run. A scheduled job with no originating request uses its own job or run id in the same field.

## 2. Requests and responses

Every request writes one line when it finishes, failures included:

| Field | Content |
|---|---|
| request id | from section 1 |
| method, route | HTTP method, route template and actual path |
| status, duration | response status, elapsed ms |
| user | internal user id when authenticated, never name, email or phone |
| client | client IP, user agent |
| bodies | request and response body after masking (section 4), cut to a size cap such as 4 KB |

- Never logged in any form: `Authorization` and cookie headers, passwords, tokens, API keys, one-time codes.
- File, binary and multipart bodies: log content type and size only.
- When the project's rules forbid some content in logs (user-written text, AI prompts), log that body's size and field names instead of its values.
- Health checks and static files may skip the line.

## 3. External calls (SMS, 알림톡, email, push, external APIs)

Each integration has one client or wrapper that logs every call, so no call site sends without a trace:

| Field | Content |
|---|---|
| request id | originating request or job id |
| integration, operation | `sms`, `alimtalk`, `email`, `push` or the API name; endpoint or template code |
| recipient | masked phone, email or token tail |
| attempt | retry number |
| result | HTTP status, provider result code, provider message id |
| duration | elapsed ms |
| error | exception class and provider error code, no payload |

- Message content is not logged; the template code and variable names are.
- Failures log at WARN or ERROR with the same fields, so a failed SMS can be found by request id or masked recipient and then looked up in the provider console by its message id.
- A provider response that echoes the recipient or the message is masked before it is logged.

## 4. Personal information

**Masking.** Every log line, exception message and error response masks personal information through one shared masking utility (or a log serializer that calls it), never by hand at each call site. The utility has its own tests.

| Item | Logged as |
|---|---|
| Name | 김*민 |
| Phone | 010-****-5678 |
| Email | ab***@example.com |
| Resident or foreigner registration number | 900101-1****** |
| Card or account number | last 4 digits |
| Address | up to 시/군/구 |
| Password, token, auth code | never logged |

Entities and DTOs that hold personal fields mask or omit them in `toString()`, because exception messages and debug lines print them.

**Access records (개인정보 접속기록).** When an operator or admin views, searches, changes, deletes or downloads someone's personal information, the server writes a record: operator account, time, source IP, data subject id, action, and for a download the reason. Keep the records at least 1 year, and 2 years when the system holds 50,000 or more people or handles unique identifiers or sensitive information (개인정보의 안전성 확보조치 기준). A user acting on their own data needs only the request line.

## Done Check for Server Changes

- [ ] New endpoint: covered by the request line, and a test reads the captured log output and finds no unmasked personal data
- [ ] New outside call: goes through its integration's logging wrapper
- [ ] New personal field: handled by the masking utility, with a test
- [ ] New operator or admin access to personal data: writes an access record
- [ ] New async hop (thread pool, scheduler, queue, event): the request id is restored on the other side

## Common Mistakes

| Mistake | Fix |
|---|---|
| Logging an entity or DTO whose `toString()` prints phone or email | Mask or omit personal fields in `toString()` |
| Exception message built from the request payload | Put ids in the message, not values |
| Request id lost in async tasks, thread pools or schedulers | Copy the logging context into the task (a Spring `TaskDecorator`, for example) and clear it afterwards |
| Masking applied in the web layer only | Mask in the shared utility so workers and integrations get it too |
| Logging the whole provider response | Log the result code and message id, and mask the rest |
