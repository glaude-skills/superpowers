#!/usr/bin/env bash
# Context budget gate for the skills themselves (using-superpowers
# references/context-budget.md, sections 1, 7 and 8):
#   1. using-superpowers/SKILL.md, which the SessionStart hook injects whole,
#      stays within 9,000 characters and 20 KB, so the hook output stays under
#      Claude Code's 10,000-character cap with room for the wrapper.
#   2. Every `references/<file>` a SKILL.md names exists (no dead reference).
#   3. Every file in a skill's references/ is named somewhere in that skill
#      folder or in a root entry file (no orphan detail nobody routes to).
#   4. Every SKILL.md stays within 40 KB; split detail into references/.
# Caps ratchet: lower them when a skill shrinks, never raise them to make room.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

BOOTSTRAP=skills/using-superpowers/SKILL.md
BOOTSTRAP_MAX_CHARS=9000
BOOTSTRAP_MAX_BYTES=20480
SKILL_MAX_BYTES=40960

FAILURES=0
pass() { echo "  [PASS] $1"; }
fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

# UTF-8 code points, independent of the locale.
chars() { LC_ALL=C tr -d '\200-\277' < "$1" | wc -c | tr -d '[:space:]'; }
bytes() { wc -c < "$1" | tr -d '[:space:]'; }

echo "skill context budget"

n=$(chars "$BOOTSTRAP"); b=$(bytes "$BOOTSTRAP")
if [[ $n -le $BOOTSTRAP_MAX_CHARS && $b -le $BOOTSTRAP_MAX_BYTES ]]; then
    pass "$BOOTSTRAP is $n characters, $b bytes (caps $BOOTSTRAP_MAX_CHARS, $BOOTSTRAP_MAX_BYTES)"
else
    fail "$BOOTSTRAP is $n characters, $b bytes, over $BOOTSTRAP_MAX_CHARS characters or $BOOTSTRAP_MAX_BYTES bytes — move a section verbatim to references/ and route to it (references/context-budget.md)"
fi

for skill in skills/*/; do
    skill=${skill%/}
    md="$skill/SKILL.md"
    [[ -f $md ]] || continue

    b=$(bytes "$md")
    if [[ $b -gt $SKILL_MAX_BYTES ]]; then
        fail "$md is $b bytes, over $SKILL_MAX_BYTES — move rarely needed sections verbatim to $skill/references/"
    fi

    # Dead references: a backticked or linked `references/<file>` (or
    # `../<skill>/references/<file>`) outside code fences, resolved from the
    # file that names it. Checked in every .md of the skill folder, because
    # moved sections point back and across skills too.
    while IFS= read -r -d '' doc; do
        dir=$(dirname "$doc")
        while IFS= read -r ref; do
            [[ -z $ref ]] && continue
            # From the naming file, or from the skill root (prompt templates
            # name skill-root paths).
            [[ -e "$dir/$ref" || -e "$skill/$ref" ]] || fail "$doc names $ref, which does not exist"
        done < <(tr -d '\r' < "$doc" | awk '/^```/{f=!f; next} !f' \
            | grep -oE '(`|\()(\.\./)*([a-z0-9-]+/)?references/[A-Za-z0-9._-]+\.md' \
            | sed -E 's/^[`(]//' | sort -u || true)
    done < <(find "$skill" -name '*.md' -print0)

    # Orphans: a references/ file nothing in the skill folder or root entry files names.
    if [[ -d "$skill/references" ]]; then
        for ref in "$skill"/references/*.md; do
            name=$(basename "$ref")
            if ! grep -rqF --exclude="$name" "$name" "$skill" GEMINI.md AGENTS.md 2>/dev/null; then
                fail "$ref is named nowhere in $skill or a root entry file — add a routing row or delete it"
            fi
        done
    fi
done
[[ $FAILURES -eq 0 ]] && pass "every SKILL.md within $SKILL_MAX_BYTES bytes, no dead or orphan references/"

echo
if [[ $FAILURES -eq 0 ]]; then echo "All skill context budget tests passed"; else echo "$FAILURES skill context budget test(s) failed"; exit 1; fi
