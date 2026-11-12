---
name: debug-code
description: >-
  Use when the user encounters bugs, errors, crashes, or unexpected behavior.

  ACTION TRIGGERS:
  - "debug", "fix bug", "fix error", "troubleshoot", "investigate error"
  - "not working", "broken", "crashed", "why is this failing"
  - "trace the error", "find the bug", "root cause"

  NATURAL LANGUAGE PATTERNS:
  - "I'm getting" + error/exception/traceback
  - "help me debug" / "help me fix"
  - "here's the error" / "here's the log"
  - "the log says" / "the output shows"

  PROACTIVE TRIGGERS (fire even without explicit debug request):
  - User pastes error messages, stack traces, tracebacks, or error logs
  - User pastes log lines with ERROR, FATAL, Exception, Traceback, panic
  - User reports HTTP errors, DB errors, test failures, or compile errors
  - User describes symptoms: "returns null", "blank page", "hangs", "freezes"
allowed-tools: Read, Grep, Glob, Bash, Edit, Write, AskUserQuestion
---

# Debugging Workflow

Enforce a disciplined, step-by-step debugging process. Do NOT skip steps or guess fixes.

## Step 1: Detect Error Scope

Before investigating, determine whether the error is in **development** or **production** context.

**Development signals:**

- Error references files in the current working directory (`src/`, `lib/`, project-relative paths)
- User says "my code", "local", "dev", "localhost"
- Error occurs during local dev server, build, or test runs
- Stack trace points to project source files

**Production signals:**

- Error references `node_modules/`, installed package paths, deployed URLs
- User says "production", "deployed", "live", "staging", "server"
- Error occurs on a remote host or deployed environment
- Stack trace points to bundled/minified code or installed dependencies

**If ambiguous:** Use `AskUserQuestion` to ask: "Is this error happening in your **local development** environment or in
**production/deployed** code?"

Record the scope -- it determines how Steps 2 and 3 behave.

## Step 2: Check Error Monitoring

If error monitoring tools (e.g., Sentry MCP) are available, query for related issues. If no monitoring is configured,
skip to Step 3.

**Production scope:** Prioritize monitoring -- this is your primary source of truth.

**Development scope:** Check briefly for related patterns, but don't block on it if no results are found.

**Sentry tools (if available):**

- `mcp__sentry__search_issues` -- search for the error message or affected component
- `mcp__sentry__get_issue_details` -- get full stack trace, breadcrumbs, and tags
- `mcp__sentry__search_events` -- find related events and frequency
- `mcp__sentry__get_trace_details` -- trace performance issues across services

Error monitoring provides richer context than local logs: stack traces with source maps, breadcrumbs, user context, and
release correlation.

**DO NOT** guess the cause from UI behavior alone.

## Step 3: Check Logs (Scope-Dependent)

### Development Scope

Check logs from the **project root** only:

- Read log files in `logs/` directory, terminal output, browser console
- Ask the user to check their application's admin/log UI if one exists
- `Grep` for error patterns in project-relative log files
- `Bash` to tail recent log output from the local dev server

**If no logs are found:** Use `AskUserQuestion` to ask the user for log output, error messages, or reproduction steps
before proceeding.

### Production Scope

**First, load configured log paths** from the plugin's `log_paths` option:

`log_paths` = `${user_config.log_paths}`

The value is a comma-separated list of directories or file paths pointing to the **production application's installed
location**. These are absolute paths or paths relative to project root. If the value is empty or still starts with `${`
(the option is not set), no log paths are configured.

Check logs in this order:

1. **Configured `log_paths`** (if set) — read/grep these first as the primary log source
2. Read source files in installed package paths to understand library behavior
3. Check ecosystem-specific log files:
    - **JS/TS:** `node_modules/<package>/logs/`, `npm-debug.log`, `yarn-error.log`
    - **Python:** `venv/`, `pip-log.txt`, `.tox/` output, `pytest` output
    - **Java/Kotlin:** `target/`, `build/` output, `hs_err_pid*.log`
    - **Go:** build output, `go test` output
4. Check deployed server logs (remote log files, cloud logging services)
5. Examine package install paths for configuration issues
6. Cross-reference with Sentry findings from Step 2

**If no logs are found in any location:** Use `AskUserQuestion` to ask the user for log output, error messages, or exact
reproduction steps rather than proceeding with insufficient information.

Local project logs may still be useful as supplementary context in production scope.

## Step 4: Reproduce the Issue

Before researching or changing code:

- Re-run the exact command, test, or request that triggered the error
- Identify the minimal reproduction path
- Understand the full failure chain (what calls what, where it breaks)
- Check if the issue is environment-specific (OS, Node version, Python version, etc.)

If the user has not provided exact reproduction steps, use `AskUserQuestion` to request them before proceeding.

Reproduction gives you concrete data for the next step.

## Step 5: Research Before Fixing

Before writing any fix:

- Search for the exact error message or code using web search and documentation tools
- Verify correct CLI commands, API signatures, and configuration syntax
- Check for known issues, breaking changes, or version-specific behavior
- Read official documentation for the relevant library/framework

**Tools to use:**

- Context7: `resolve-library-id` then `query-docs` for library-specific issues
- Web search for error messages, Stack Overflow, GitHub issues
- GitHub MCP: `search_code` for real-world usage patterns, `search_issues` for known bugs/fixes

**DO NOT** write a fix based on memory or assumption. Verify first.

## Step 6: Fix the Root Cause

When implementing the fix:

- Trace the error to its origin -- don't patch symptoms downstream
- Fix at the source, not at the caller
- If multiple things are broken, fix them in dependency order
- Keep the fix minimal -- don't refactor surrounding code

**Anti-patterns to avoid:**

- Adding try/catch to silence errors instead of fixing them
- Bypassing safety checks (e.g., `--no-verify`, `--force`)
- Guessing CLI flags without checking docs
- Copying fixes from unrelated Stack Overflow answers

## Step 7: Verify the Fix

After applying changes:

- Re-run the exact scenario that triggered the original error
- Confirm the error is gone
- Check that no new errors were introduced (run tests, check logs)
- If the fix involved configuration, verify in a clean state

If the original error persists or a new error surfaces, return to Step 1 with updated information and repeat the
process.
