#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HOOK_UNDER_TEST="$REPO_ROOT/hooks/session-start"
WRAPPER_UNDER_TEST="$REPO_ROOT/hooks/run-hook.cmd"

FAILURES=0
TEST_ROOT="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() {
    echo "  [PASS] $1"
}

fail() {
    echo "  [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

make_home() {
    local name="$1"
    local home="$TEST_ROOT/$name/home"
    mkdir -p "$home"
    printf '%s\n' "$home"
}

assert_command_output() {
    local description="$1"
    local shape="$2"
    local contains="$3"
    local not_contains="$4"
    local home="$5"
    shift 5

    local output
    if ! output="$(env -i PATH="${PATH:-}" HOME="$home" "$@" 2>&1)"; then
        fail "$description"
        echo "    hook exited non-zero"
        echo "$output" | sed 's/^/      /'
        return
    fi

    if printf '%s' "$output" | \
        EXPECT_SHAPE="$shape" \
        EXPECT_CONTAINS="$contains" \
        EXPECT_NOT_CONTAINS="$not_contains" \
        EXPECT_MAX_CHARS="${EXPECT_MAX_CHARS:-}" \
        EXPECT_PREFIX="${EXPECT_PREFIX:-}" \
        node -e '
const fs = require("fs");

const input = fs.readFileSync(0, "utf8");
let payload;
try {
  payload = JSON.parse(input);
} catch (error) {
  console.error(`invalid JSON: ${error.message}`);
  process.exit(1);
}

function hasOwn(object, key) {
  return Object.prototype.hasOwnProperty.call(object, key);
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

const shape = process.env.EXPECT_SHAPE;
let context;

if (shape === "nested") {
  if (!hasOwn(payload, "hookSpecificOutput")) {
    fail("missing hookSpecificOutput");
  }
  if (hasOwn(payload, "additional_context") || hasOwn(payload, "additionalContext")) {
    fail("nested output also included a top-level context field");
  }
  const hookOutput = payload.hookSpecificOutput;
  if (!hookOutput || typeof hookOutput !== "object" || Array.isArray(hookOutput)) {
    fail("hookSpecificOutput is not an object");
  }
  if (hookOutput.hookEventName !== "SessionStart") {
    fail(`unexpected hookEventName: ${hookOutput.hookEventName}`);
  }
  context = hookOutput.additionalContext;
} else if (shape === "cursor") {
  if (hasOwn(payload, "hookSpecificOutput")) {
    fail("cursor output included hookSpecificOutput");
  }
  if (!hasOwn(payload, "additional_context")) {
    fail("cursor output missing additional_context");
  }
  if (hasOwn(payload, "additionalContext")) {
    fail("cursor output included additionalContext");
  }
  context = payload.additional_context;
} else if (shape === "sdk") {
  if (hasOwn(payload, "hookSpecificOutput")) {
    fail("sdk output included hookSpecificOutput");
  }
  if (!hasOwn(payload, "additionalContext")) {
    fail("sdk output missing additionalContext");
  }
  if (hasOwn(payload, "additional_context")) {
    fail("sdk output included additional_context");
  }
  context = payload.additionalContext;
} else {
  fail(`unknown expected shape: ${shape}`);
}

if (typeof context !== "string" || context.trim() === "") {
  fail("injected context was empty");
}

const expectedText = process.env.EXPECT_CONTAINS || "";
if (expectedText && !context.includes(expectedText)) {
  fail(`context did not contain expected text: ${expectedText}`);
}

const forbiddenTexts = (process.env.EXPECT_NOT_CONTAINS || "")
  .split("\u001f")
  .filter(Boolean);
for (const forbiddenText of forbiddenTexts) {
  if (context.includes(forbiddenText)) {
    fail(`context contained forbidden text: ${forbiddenText}`);
  }
}

const maxChars = Number(process.env.EXPECT_MAX_CHARS || 0);
if (maxChars && context.length > maxChars) {
  fail(`context is ${context.length} characters, over ${maxChars}`);
}

const expectedPrefix = process.env.EXPECT_PREFIX || "";
if (expectedPrefix && !context.startsWith(expectedPrefix)) {
  fail(`context did not start with: ${expectedPrefix}`);
}
'; then
        pass "$description"
    else
        fail "$description"
        echo "    output:"
        echo "$output" | sed 's/^/      /'
    fi
}

echo "SessionStart hook output tests"

# Registration shape: the hook must declare shell:"bash" so Claude Code on
# Windows dispatches via Git Bash (or fails with an actionable error) instead
# of PowerShell/cmd.exe, whose parsers break on the quoted command string
# (PowerShell ParserError; cmd.exe quote-stripping on paths with metacharacters).
if node -e '
const hooks = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
const entry = hooks.hooks.SessionStart[0].hooks[0];
if (entry.shell !== "bash") {
  console.error(`SessionStart hook shell is ${JSON.stringify(entry.shell)}, expected "bash"`);
  process.exit(1);
}
if (!/run-hook\.cmd" session-start$/.test(entry.command)) {
  console.error(`unexpected SessionStart command shape: ${entry.command}`);
  process.exit(1);
}
' "$REPO_ROOT/hooks/hooks.json"; then
    pass "hooks.json registers SessionStart with shell:bash dispatch"
else
    fail "hooks.json registers SessionStart with shell:bash dispatch"
fi

claude_home="$(make_home claude-code)"
assert_command_output \
    "Claude Code emits nested SessionStart additionalContext" \
    "nested" \
    "" \
    "" \
    "$claude_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$HOOK_UNDER_TEST"

wrapper_home="$(make_home run-hook-wrapper)"
assert_command_output \
    "run-hook.cmd wrapper dispatches to the named session-start script" \
    "nested" \
    "" \
    "" \
    "$wrapper_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$WRAPPER_UNDER_TEST" session-start

cursor_home="$(make_home cursor)"
assert_command_output \
    "Cursor emits top-level additional_context only" \
    "cursor" \
    "" \
    "" \
    "$cursor_home" \
    CURSOR_PLUGIN_ROOT="$REPO_ROOT" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$HOOK_UNDER_TEST"

copilot_home="$(make_home copilot-cli)"
assert_command_output \
    "Copilot CLI emits top-level additionalContext only" \
    "sdk" \
    "" \
    "" \
    "$copilot_home" \
    COPILOT_CLI=1 \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$HOOK_UNDER_TEST"

legacy_home="$(make_home legacy-warning-removed)"
mkdir -p "$legacy_home/.config/superpowers/skills"
assert_command_output \
    "SessionStart omits obsolete legacy custom-skill warning" \
    "nested" \
    "" \
    "Superpowers now uses"$'\037'"~/.config/superpowers/skills"$'\037'"~/.claude/skills"$'\037'"legacy" \
    "$legacy_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$HOOK_UNDER_TEST"

# Claude Code caps each hook context string at 10,000 characters and passes
# only a 2,000-character preview beyond it, so the real bootstrap must fit and
# carry no size warning.
size_home="$(make_home size-cap)"
EXPECT_MAX_CHARS=10000
assert_command_output \
    "Claude Code bootstrap fits the 10,000-character hook cap" \
    "nested" \
    "Skill directory for its relative paths" \
    "경고: superpowers using-superpowers" \
    "$size_home" \
    CLAUDE_PLUGIN_ROOT="$REPO_ROOT" \
    bash "$HOOK_UNDER_TEST"
EXPECT_MAX_CHARS=""

# An oversized SKILL.md is not cut silently: the warning comes first, inside
# the preview the model still sees.
big_root="$TEST_ROOT/oversized-plugin"
mkdir -p "$big_root/hooks" "$big_root/skills/using-superpowers"
cp "$HOOK_UNDER_TEST" "$big_root/hooks/session-start"
for _ in $(seq 1 300); do
    printf '%s\n' "Filler line that pushes the bootstrap over the hook cap of ten thousand characters." \
        >> "$big_root/skills/using-superpowers/SKILL.md"
done
big_home="$(make_home size-warning)"
EXPECT_PREFIX="경고: superpowers using-superpowers 부트스트랩이"
assert_command_output \
    "SessionStart warns first when the bootstrap exceeds the hook cap" \
    "nested" \
    "references/context-budget.md" \
    "" \
    "$big_home" \
    CLAUDE_PLUGIN_ROOT="$big_root" \
    bash "$big_root/hooks/session-start"
EXPECT_PREFIX=""

if [[ "$FAILURES" -gt 0 ]]; then
    echo "STATUS: FAILED ($FAILURES failure(s))"
    exit 1
fi

echo "STATUS: PASSED"
