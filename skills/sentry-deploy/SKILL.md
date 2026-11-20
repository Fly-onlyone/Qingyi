---
name: sentry-deploy
description: >-
  This skill should be used when the user asks to "deploy Sentry", "set up Sentry",
  "add Sentry to my project", "integrate Sentry error tracking", "create a Sentry project",
  "configure Sentry monitoring", "add Sentry error reporting", "set up Sentry profiling",
  "configure Sentry logging", "set up Sentry DSN", "set up Sentry session replay",
  or "keep PII out of Sentry". Creates the project via MCP and sets up the SDK for any
  stack with privacy-first defaults.
---

# Sentry Deployment Skill

Follow the three phases below in order. Skip Phase 1 if the Sentry project already exists and you have the DSN.

The [Privacy Defaults](#privacy-defaults) apply in every phase and override any snippet found in the docs. Sentry
events describe the app's end users, so send the minimum and let the user opt in to more.

---

## Phase 1 — Create the Sentry Project (via MCP)

Use `mcp__sentry__*` tools in this sequence:

1. **Verify identity** — `mcp__sentry__whoami` → confirms authenticated account. Do not repeat the account's email or
   name in chat.
2. **Find org slug** — `mcp__sentry__find_organizations` → note the `slug` and `regionUrl`.
   - Ask the user whether end-user data must stay in the EU. The data region is fixed per organization. If it must
     and `regionUrl` is not the EU region, tell the user they need an organization in the EU region, and stop
     before creating the project. Do not create an organization unasked.
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
2. **Check for an existing setup** — if the project already calls `init()`, list each setting that differs from the
   Privacy Defaults and ask the user before changing it.
3. **Look up SDK via Context7:**
   - `mcp__context7__resolve-library-id` → search "sentry \<framework\>" (e.g., "sentry fastapi", "sentry react", "sentry nextjs")
   - `mcp__context7__query-docs` → query install command, `init()` signature, and integration options
   - `mcp__context7__query-docs` → query the privacy options of the installed SDK version:
     - how it controls default PII: `send_default_pii` / `sendDefaultPii`, or the newer `data_collection` /
       `dataCollection`, and the exact category names;
     - its stack-frame local variables option and its request-body size option;
     - its `before_send`, `before_send_transaction` and `before_breadcrumb` hooks, and whether spans can bypass
       `before_send_transaction` (e.g. `beforeSendSpan`);
     - which integrations attach task or job arguments (e.g. Celery, RQ) and how to turn that off.
4. **Fallback** — if Context7 lacks coverage, use `brave-web-search` skill for official Sentry docs.

From the research, take the install command, import paths and option **names** — do **not** rely on memorised
snippets. Build `init()` from the Privacy Defaults. From doc snippets, add only `dsn`, `environment`, `release`, sample
rates and framework integrations. Drop every doc line that turns on an item the Privacy Defaults keep off, such as
`send_default_pii=True`, `sendDefaultPii: true`, `enableLogs: true`, `replayIntegration()`, `feedbackIntegration()` or
`consoleLoggingIntegration()`.

---

## Privacy Defaults

The option names below are examples. Confirm each one for the installed SDK version in Phase 2.

### Opt-in items

Every item is off unless the user turns it on in [Phase 3, step 1](#phase-3--install--configure).

| Item | Turning it on sends | Off setting |
|---|---|---|
| Default PII | IP address, cookies, request headers, the logged-in user's email/username from framework auth, AI prompts and responses (OpenAI, Anthropic, LangChain integrations), GraphQL request bodies, Redis/Mongo values | `send_default_pii=False` / `sendDefaultPii: false`, written explicitly. If the SDK uses `data_collection` / `dataCollection`, set **every** category explicitly: passing the option switches unset categories to more permissive defaults. |
| Stack-frame local variables | Values of the local variables in each stack frame | Python: `include_local_variables=False` (or `stack_frame_variables: False` under `data_collection`). Equivalent option elsewhere. |
| Request bodies | Form and JSON bodies of incoming requests | Python: `max_request_body_size="never"`. Equivalent option elsewhere. |
| URL query strings and fragments | Query parameters and `#` fragments, which often hold emails and tokens | Stripped by the scrub function below. |
| INFO breadcrumbs | The text of INFO log lines, which often holds user input | Logging integration breadcrumb level WARNING. Frontend: drop `console` breadcrumbs below `warning` in `beforeBreadcrumb`. |
| Sentry Logs | Log lines as separate log records | `enable_logs=False` / `enableLogs: false`. |
| Session Replay | A recording of the user's screen and clicks | No `replayIntegration()`. If on: keep `maskAllText`, `maskAllInputs` and `blockAllMedia` `true`, keep `networkDetailAllowUrls` empty, and ask for the sample rates (suggest `replaysSessionSampleRate: 0` with on-error capture only). |
| User Feedback widget | Name, email, message and a screenshot | No `feedbackIntegration()`. If on: `enableScreenshot: false`, `showName: false` and `showEmail: false` unless the user wants them, and no prefilled name or email. |

### Fixed safeguards

Apply these always. They are not opt-in items.

1. **Explicit off values** — write every off setting explicitly (`False` / `false`). Never leave it unset, so a
   later doc paste cannot silently turn it on. Put one comment above them saying they are privacy defaults, off on
   purpose. Beside each item the user turned on, add a one-line comment saying the user chose it.
2. **Shared scrub function** — write one function and use it as both `before_send` and `before_send_transaction`.
   For each item the user turned on, remove the matching part.
   - Delete `request.cookies`, `request.data` and `request.query_string`.
   - Delete the `Authorization`, `Cookie` and `Referer` request headers.
   - Strip the query and fragment from `request.url`.
   - Keep only `id` in `user`.
   - In each span's `data`: delete `http.query`, `http.fragment` and `url.query`, and strip the query and fragment
     from `url`, `http.url`, `url.full` and `http.target`. If spans can bypass `before_send_transaction`, apply the
     same span scrub in the span hook.
3. **Breadcrumb hook** — in `before_breadcrumb`, apply the span-data rule above to breadcrumb `data`, and also strip
   the query and fragment from `from` and `to` (browser navigation breadcrumbs).
4. **Python key scrubber** — set `event_scrubber=EventScrubber(denylist=DEFAULT_DENYLIST + ["email", "phone"],
   recursive=True)` (from `sentry_sdk.scrubber`). Recent versions add `DEFAULT_PII_DENYLIST` on their own while
   `send_default_pii` is off. If the installed version has no `pii_denylist` parameter, add `DEFAULT_PII_DENYLIST`
   to the list yourself.
5. **User identity** — call `set_user` / `setUser` with an opaque internal ID only. Never pass email, username, name
   or IP address.
6. **Tags, contexts, extra** — never put personal data in them. Search the code for existing `set_tag`,
   `set_context`, `set_extra` (`setTag`, `setContext`, `setExtra`) calls and report any that pass personal data.
7. **Every init call** — frameworks with several init files (Next.js client/server/edge, SvelteKit, Nuxt, Remix)
   get the same settings and the same scrub function in each one. The consent gate applies to the client init only.

---

## Phase 3 — Install & Configure

1. **Ask once.** Before writing `init()`, send one message that covers:
   - each opt-in item, in plain words, with what turning it on sends (not the setting names);
   - whether to enable profiling;
   - the consent-gate choice, only if the app has no consent mechanism (see below).

   No answer, or "use defaults", means every opt-in item stays off, profiling stays off, and the consent gate is a
   TODO comment.
2. **Configure.** Apply the patterns found in Phase 2 together with the Privacy Defaults:
   - **Error tracing** — framework auto-integration or manual SDK setup to capture unhandled exceptions.
   - **Performance tracing** — configure `traces_sample_rate` (backend) or browser tracing integration (frontend).
   - **Profiling** *(optional)* — only if the user said yes: configure `profiles_sample_rate` (backend) or browser
     profiling integration (frontend).
   - **Logging** *(backend)* — attach logging integration so log events at ERROR+ level become Sentry events and
     WARNING+ become breadcrumbs (INFO only if the user opted in). Frontend SDKs typically use `console` breadcrumbs
     instead.

**Conditional init** — always gate `sentry.init()` / `Sentry.init()` on the DSN env var being present. Never initialise unconditionally.

**Frontend consent gate** — in browser code, also gate `Sentry.init()` on the visitor's consent. Use the app's
existing consent mechanism (cookie banner or consent manager). If the app has none, the user chooses in step 1: add a
minimal consent check, or leave a TODO comment at the init call. A gate with no consent UI blocks every event, so
say so when asking. Do not give legal advice on whether consent is required.

---

## Environment Variables

Use these standard names. Frontend frameworks often require a prefix (e.g., `VITE_`, `NEXT_PUBLIC_`).

```
# Required
SENTRY_DSN=https://...@oXXXX.ingest.sentry.io/XXXX
SENTRY_ENVIRONMENT=development
SENTRY_RELEASE=my-app@0.1.0
SENTRY_TRACES_SAMPLE_RATE=0.1

# Optional (only if user wants profiling)
SENTRY_PROFILES_SAMPLE_RATE=0.1
```

Frontend (Vite example — adjust prefix for other bundlers):
```
VITE_SENTRY_DSN=...
VITE_SENTRY_ENVIRONMENT=development
VITE_SENTRY_TRACES_SAMPLE_RATE=0.1
```

---

## Server-Side Privacy Settings (manual)

The Sentry MCP tools cannot change these settings. Give the user these steps to do in the Sentry web UI for each
project this app sends events to:

1. Open **Project Settings → Security & Privacy**.
2. Turn on **Data Scrubber** and **Use Default Scrubbers**.
3. Turn on **Prevent Storing of IP Addresses**.
4. Under **Additional Sensitive Fields**, add app-specific keys such as `email`, `phone` and `address`.
5. Under **Advanced Data Scrubbing**, add rules that mask **Email addresses** and **IP addresses** (optionally
   **Credit card numbers**) from `$string`. This catches personal data inside free text such as exception messages,
   log messages and SQL. Confirm the rule syntax in the Sentry docs before giving it.

To apply the same settings to every project, use **Organization Settings → Security & Privacy** instead.

---

## Handling Sentry Data in This Session

Sentry events can hold end users' personal data, and the MCP tools return whole payloads. While setting up and
verifying:

- Open only events you triggered during verification. Filter by the `SENTRY_ENVIRONMENT` value and the test error
  message.
- Do not open production issues, replays, logs or user feedback through any tool unless the user asks.
- Report each check as present or absent. Never quote the value.
- Never paste event payloads, breadcrumbs, request data, user objects or replay content into chat.

---

## Verification Checklist

- [ ] **Bug trace** — Throw a test error; confirm it appears in Sentry Issues.
- [ ] **Performance trace** — Trigger a request/navigation; confirm transaction in Performance tab.
- [ ] **Profiling** *(optional)* — Generate load; confirm flame graphs in Profiling tab.
- [ ] **Logging** — Emit an ERROR-level log; confirm the event appears in Issues.
- [ ] **Backend PII check** — Add a temporary test route that calls `set_user` / `setUser` with a fake ID, makes an
  outgoing HTTP call to a URL with `?email=test@example.com`, then raises an error from a function that holds a
  local variable. Call the route with `?email=test@example.com`, a fake `Cookie`, `Authorization: Bearer test`, a
  `Referer` with a query string, and a JSON body. In the error event and its transaction, confirm each of these is
  absent: IP address, `request.query_string`, the query in `request.url`, cookies, the `Authorization`, `Cookie` and
  `Referer` headers, the request body, local variables, every `user` field except `id`, and `http.query`,
  `url.query` or a query in any URL in breadcrumb and span data. Remove the test route afterwards.
- [ ] **Frontend PII check** — If the app has a consent gate, trigger an error before consent and confirm no event
  arrives. After consent, load a page with `?email=test@example.com#token=test`, trigger a fetch and an error.
  Confirm the query and fragment are absent from `request.url`, `Referer`, navigation breadcrumbs (`from`, `to`)
  and fetch breadcrumbs.
- [ ] Report each PII item as present or absent, following
  [Handling Sentry Data in This Session](#handling-sentry-data-in-this-session).
