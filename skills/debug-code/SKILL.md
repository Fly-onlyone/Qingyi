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
  - "why does" / "why is" + unexpected result
  - "stack trace" / "regression" + debugging context
  - "help me debug" / "help me fix"
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

**If ambiguous:** Use `AskUserQuestion` to ask: "Is this error happening in your **local development** environment or in **production/deployed** code?"

Record the scope -- it determines how Steps 2 and 3 behave.

## Step 2: Check Error Monitoring

If error monitoring tools (e.g., Sentry MCP) are available, query for related issues. If no monitoring is configured, skip to Step 3.

**Production scope:** Prioritize monitoring -- this is your primary source of truth.

**Development scope:** Check briefly for related patterns, but don't block on it if no results are found.

**Sentry tools (if available):**
- `mcp__sentry__search_issues` -- search for the error message or affected component
- `mcp__sentry__get_issue_details` -- get full stack trace, breadcrumbs, and tags
- `mcp__sentry__search_events` -- find related events and frequency
- `mcp__sentry__get_trace_details` -- trace performance issues across services

Error monitoring provides richer context than local logs: stack traces with source maps, breadcrumbs, user context, and release correlation.

**DO NOT** guess the cause from UI behavior alone.

## Step 3: Check Logs (Scope-Dependent)

### Development Scope

Check local project logs:
- Read log files in `logs/` directory, terminal output, browser console
- Check the application's log UI if available (e.g., Admin > Logs)
- `Grep` for error patterns in project-relative log files
- `Bash` to tail recent log output from the local dev server

### Production Scope

Check installed/deployed location logs:
- Read source files in `node_modules/` or installed package paths to understand library behavior
- Check log files at the installed location (e.g., `node_modules/<package>/logs/`, package-level `debug.log`, `npm-debug.log`, `yarn-error.log`)
- Check deployed server logs (remote log files, cloud logging services)
- Examine package install paths for configuration issues
- Cross-reference with Sentry findings from Step 2

Local project logs may still be useful as supplementary context in production scope.

## Step 4: Reproduce the Issue

Before researching or changing code:

- Confirm you can trigger the exact error
- Identify the minimal reproduction path
- Understand the full failure chain (what calls what, where it breaks)
- Check if the issue is environment-specific (OS, Node version, Python version, etc.)

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

If the original error persists or a new error surfaces, return to Step 1 with updated information and repeat the process.
