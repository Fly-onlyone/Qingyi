---
name: sentry-deploy
description: >-
  This skill should be used when the user asks to "deploy Sentry", "set up Sentry",
  "add Sentry to my project", "integrate Sentry error tracking", "create a Sentry project",
  "configure Sentry monitoring", "add Sentry error reporting", "set up Sentry profiling",
  "configure Sentry logging", or "set up Sentry DSN".
  Covers end-to-end Sentry deployment: project creation via MCP tools, SDK installation,
  and configuration of error tracing, performance tracing, profiling, and logging
  for any language or framework.
---

# Sentry Deployment Skill

Follow the three phases below in order. Skip Phase 1 if the Sentry project already exists and you have the DSN.

---

## Phase 1 — Create the Sentry Project (via MCP)

Use `mcp__sentry__*` tools in this sequence:

1. **Verify identity** — `mcp__sentry__whoami` → confirms authenticated account.
2. **Find org slug** — `mcp__sentry__find_organizations` → note the `slug`.
3. **Find or create team** — `mcp__sentry__find_teams` (filter by org slug).
   - None suitable → `mcp__sentry__create_team` (org_slug, name).
4. **Check for existing project** — `mcp__sentry__find_projects` (org_slug, optional query) before creating a duplicate.
5. **Create project** — `mcp__sentry__create_project` (org_slug, team_slug, name, platform).

   **Common platform slugs:**

   | Stack | Slug |
   |---|---|
   | Python (generic) | `python` |
   | FastAPI | `python-fastapi` |
   | Django | `python-django` |
   | Flask | `python-flask` |
   | React / Vite | `javascript-react` |
   | Next.js | `javascript-nextjs` |
   | Vue | `javascript-vue` |
   | Node / Express | `node-express` |
   | Go | `go` |
   | Rust | `rust` |

6. **Get DSN** — `mcp__sentry__find_dsns` (org_slug, project_slug) → use the `dsn` field from the first result.
   - No DSNs → `mcp__sentry__create_dsn` (org_slug, project_slug, name: "Default").

**Multi-platform projects:** Create two separate projects (e.g., backend + frontend) so issues stay separated. Both can share the same team. Store each DSN in its respective `.env`.

---

## Phase 2 — Detect Stack & Research SDK

Before writing any code, identify the project's language and framework, then look up the correct SDK:

1. **Detect stack** — check `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, etc.
2. **Look up SDK via Context7:**
   - `mcp__context7__resolve-library-id` → search "sentry \<framework\>" (e.g., "sentry fastapi", "sentry react", "sentry nextjs")
   - `mcp__context7__query-docs` → query install command, `init()` signature, and integration options
3. **Fallback** — if Context7 lacks coverage, use `brave-search-skills:web-search` for official Sentry docs.

Use the exact install command, import paths, and `init()` parameters from the research output — do **not** rely on memorised snippets.

---

## Phase 3 — Install & Configure

Apply the patterns found in Phase 2. Enable all four features or pick selectively:

- **Error tracing** — framework auto-integration or manual SDK setup to capture unhandled exceptions.
- **Performance tracing** — configure `traces_sample_rate` (backend) or browser tracing integration (frontend).
- **Profiling** — configure `profiles_sample_rate` (backend) or browser profiling integration (frontend).
- **Logging** — attach logging integration so log events at ERROR+ level become Sentry events; INFO+ become breadcrumbs.

**Conditional init** — always gate `sentry.init()` / `Sentry.init()` on the DSN env var being present. Never initialise unconditionally.

---

## Environment Variables

Use these standard names. Frontend frameworks often require a prefix (e.g., `VITE_`, `NEXT_PUBLIC_`).

```
SENTRY_DSN=https://...@oXXXX.ingest.sentry.io/XXXX
SENTRY_ENVIRONMENT=development
SENTRY_RELEASE=my-app@0.1.0
SENTRY_TRACES_SAMPLE_RATE=0.1
SENTRY_PROFILES_SAMPLE_RATE=0.1
```

Frontend (Vite example — adjust prefix for other bundlers):
```
VITE_SENTRY_DSN=...
VITE_SENTRY_ENVIRONMENT=development
VITE_SENTRY_TRACES_SAMPLE_RATE=0.1
```

---

## Verification Checklist

- [ ] **Bug trace** — Throw a test error; confirm it appears in Sentry Issues.
- [ ] **Performance trace** — Trigger a request/navigation; confirm transaction in Performance tab.
- [ ] **Profiling** — Generate load; confirm flame graphs in Profiling tab.
- [ ] **Logging** — Emit an ERROR-level log; confirm the event appears in Issues.
