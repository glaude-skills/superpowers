#!/usr/bin/env bash
# Tests for using-superpowers/scripts/context-check: the gate for the project
# document rules (missing imports, line and byte caps, orphan rule documents,
# shared status lists, exemptions and the entry-file settings comment).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHECK="$REPO_ROOT/skills/using-superpowers/scripts/context-check"

FAILURES=0
TEST_ROOT=""

pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
        rm -rf "$TEST_ROOT"
    fi
}
trap cleanup EXIT

# Fresh repo with a valid CONTEXT.md entry chain.
new_repo() {
    cleanup
    TEST_ROOT=$(mktemp -d)
    cd "$TEST_ROOT"
    git init -q
    mkdir -p .ai/architecture .ai/status
    printf '@CONTEXT.md\n' > CLAUDE.md
    printf '# demo\n@.ai/CLAUDE.md\n' > CONTEXT.md
    printf '# rules\n| when | `.ai/architecture/db.md` | one line |\n' > .ai/CLAUDE.md
    printf 'db rules\n' > .ai/architecture/db.md
    printf '# task\n' > .ai/status/feature-x.md
    git add -A
}

run() { set +e; OUT=$(bash "$CHECK" "$@" 2>&1); CODE=$?; set -e; }

echo "context-check"

new_repo; run
if [[ $CODE -eq 0 && $OUT == OK:* ]]; then pass "valid chain passes"; else fail "valid chain passes: $OUT"; fi

new_repo; printf '@.ai/missing.md\n' >> CONTEXT.md; run
if [[ $CODE -eq 1 && $OUT == *"imports @.ai/missing.md"* ]]; then pass "missing import fails"; else fail "missing import fails: $OUT"; fi

new_repo; printf 'x\n' > .ai/architecture/orphan.md; git add -A; run
if [[ $CODE -eq 1 && $OUT == *"orphan rule document .ai/architecture/orphan.md"* ]]; then pass "orphan fails"; else fail "orphan fails: $OUT"; fi

new_repo; printf 'x\n' > .ai/architecture/orphan.md; git add -A; run --exempt .ai/architecture/orphan.md
if [[ $CODE -eq 0 ]]; then pass "exempt skips orphan"; else fail "exempt skips orphan: $OUT"; fi

new_repo; printf 'x\n' > .ai/architecture/untracked.md; run
if [[ $CODE -eq 0 ]]; then pass "untracked doc is not an orphan"; else fail "untracked doc is not an orphan: $OUT"; fi

new_repo; for _ in $(seq 1 10); do printf 'line\n' >> CONTEXT.md; done; run --max-lines 5
if [[ $CODE -eq 1 && $OUT == *"CONTEXT.md has 12 lines, cap 5"* ]]; then pass "line cap fails"; else fail "line cap fails: $OUT"; fi

new_repo; printf '<!-- context-check: --max-lines 5 -->\n' >> CONTEXT.md; for _ in $(seq 1 10); do printf 'line\n' >> CONTEXT.md; done; run
if [[ $CODE -eq 1 && $OUT == *"cap 5"* ]]; then pass "settings comment applies"; else fail "settings comment applies: $OUT"; fi

new_repo; printf '<!-- context-check: --max-lines 5 -->\n' >> CONTEXT.md; run --max-lines 50
if [[ $CODE -eq 0 ]]; then pass "flag overrides settings comment"; else fail "flag overrides settings comment: $OUT"; fi

new_repo; head -c 3000 /dev/zero | tr '\0' 'a' > .ai/CLAUDE.md; printf '\n`.ai/architecture/db.md`\n' >> .ai/CLAUDE.md; git add -A; run --max-total-kb 2
if [[ $CODE -eq 1 && $OUT == *"cap 2 KB"* ]]; then pass "byte cap fails"; else fail "byte cap fails: $OUT"; fi

new_repo; printf '# demo\r\n@.ai/CLAUDE.md\r\n' > CONTEXT.md; run
if [[ $CODE -eq 0 ]]; then pass "CRLF entry resolves imports"; else fail "CRLF entry resolves imports: $OUT"; fi

new_repo; printf '```\n@.ai/fenced.md\n```\n' >> CONTEXT.md; run
if [[ $CODE -eq 0 ]]; then pass "fenced @ line is not an import"; else fail "fenced @ line is not an import: $OUT"; fi

new_repo; printf 's\n' > .ai/status/STATUS.md; git add -A; run
if [[ $CODE -eq 0 && $OUT == *"WARN: .ai/status/STATUS.md"* ]]; then pass "shared STATUS.md warns"; else fail "shared STATUS.md warns: $OUT"; fi

new_repo; rm CONTEXT.md; printf '# entry\n@.ai/CLAUDE.md\n' > CLAUDE.md; run
if [[ $CODE -eq 0 && $OUT == *"(CLAUDE.md,"* ]]; then pass "CLAUDE.md entry without CONTEXT.md"; else fail "CLAUDE.md entry without CONTEXT.md: $OUT"; fi

echo
if [[ $FAILURES -eq 0 ]]; then echo "All context-check tests passed"; else echo "$FAILURES context-check test(s) failed"; exit 1; fi
