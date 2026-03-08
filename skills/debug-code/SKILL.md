---
name: debug-code
description: >-
  This skill should be used when the user encounters bugs, errors, crashes, or unexpected behavior
  and needs to debug or troubleshoot.

  ACTION TRIGGERS:
  - "debug", "fix bug", "fix error", "troubleshoot", "investigate error"
  - "why is this failing", "not working", "broken", "crashed"
  - "trace the error", "find the bug", "root cause"
  - "getting an error", "throws exception", "unexpected behavior"

  NATURAL LANGUAGE PATTERNS:
  - "it's not working" + code/app context
  - "I'm getting" + error/exception/traceback
  - "why does" + unexpected result
  - "help me debug" / "help me fix"
---

# Debugging Workflow

Enforce a disciplined, step-by-step debugging process. Do NOT skip steps or guess fixes.

## Step 1: Check Sentry First

Before reading local logs, check Sentry for captured errors:

- `mcp__sentry__search_issues` -- search for the error message or affected component
- `mcp__sentry__get_issue_details` -- get full stack trace, breadcrumbs, and tags
- `mcp__sentry__search_events` -- find related events and frequency
- `mcp__sentry__get_trace_details` -- trace performance issues across services

Sentry provides richer context than local logs: stack traces with source maps, breadcrumbs, user context, and release correlation.

**DO NOT** guess the cause from UI behavior alone.

## Step 2: Check Local Logs

Supplement Sentry findings with local log data:

- Read log files (`logs/` directory, terminal output, browser console)
- Check the application's log UI if available (e.g., Admin > Logs)
- `Grep` for error patterns in logs
- `Bash` to tail recent log output

Local logs may contain details not captured by Sentry (debug-level messages, startup errors, configuration issues).

## Step 3: Research Before Fixing

Before writing any fix:

- Search for the exact error message or code using Brave/Context7
- Verify correct CLI commands, API signatures, and configuration syntax
- Check for known issues, breaking changes, or version-specific behavior
- Read official documentation for the relevant library/framework

**Tools to use:**
- Context7: `resolve-library-id` then `query-docs` for library-specific issues
- Brave Search: `brave-search-skills:web-search` for error messages, Stack Overflow, GitHub issues
- GitHub MCP: `search_code` for real-world usage patterns, `search_issues` for known bugs/fixes

**DO NOT** write a fix based on memory or assumption. Verify first.

## Step 4: Reproduce the Issue

Before changing code:

- Confirm you can trigger the exact error
- Identify the minimal reproduction path
- Understand the full failure chain (what calls what, where it breaks)
- Check if the issue is environment-specific (OS, Node version, Python version, etc.)

## Step 5: Fix the Root Cause

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

## Step 6: Verify the Fix

After applying changes:

- Re-run the exact scenario that triggered the original error
- Confirm the error is gone
- Check that no new errors were introduced (run tests, check logs)
- If the fix involved configuration, verify in a clean state
