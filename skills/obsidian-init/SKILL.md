---
name: obsidian-init
description: >-
  This skill should be used when the user wants to create an Obsidian vault that
  documents a codebase as a graph-linked, atomic-note knowledge base. Scope:
  greenfield initialization only — NOT for updating, refreshing, or re-syncing an
  already-populated vault.

  ACTION TRIGGERS:
  - "create obsidian vault", "init obsidian", "scaffold obsidian vault"
  - "document codebase in obsidian", "make obsidian knowledge base"
  - "obsidian vault for project", "set up obsidian", "build obsidian vault"
  - "obsidian knowledge vault", "vault for documentation", "obsidian-style docs"

  NATURAL LANGUAGE PATTERNS:
  - "obsidian vault" + codebase/project/docs context
  - "set up" / "build" / "create" / "init" + obsidian + vault
  - "document" + codebase + obsidian
  - "map my codebase" / "second brain for this repo" / "zettelkasten for this codebase"
  - "build a wiki for" + repo / project / codebase
  - "link notes about this project"

  PROACTIVE TRIGGERS (fire even without naming Obsidian):
  - User wants a navigable knowledge graph / wiki / MOC / Map of Content for a repo
  - User mentions Logseq, Zettelkasten, or atomic-note documentation for a codebase
  - User has created an empty `obsidian/` folder and wants it pre-populated

  DO NOT fire when:
  - User wants to update / refresh / re-sync an existing populated vault
  - User mentions only "knowledge base" or "knowledge vault" without Obsidian context
    (could be RAG / embeddings work)
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent, AskUserQuestion
---

# Obsidian Vault Initialization Workflow

Create a complete Obsidian vault that documents a codebase using **atomic concept notes**
with heavy wikilinking and Mermaid diagrams. The vault is plain markdown + a `.obsidian/`
config folder, checked into the repo so it travels with the code.

## Core Principles (read first)

1. **A vault is just a folder.** Markdown files + `.obsidian/` config. No CLI, no app, no
   server required to create one.
2. **Concept-driven, not file-driven.** One note per *meaningful unit* (a class, a flow,
   a pattern, an integration) — not one note per source file (noisy) and not one fat note
   per module (kills the graph).
3. **Atomic + linked.** Each note 50–200 words. Use `[[wikilinks]]` liberally; even
   forward references to not-yet-written notes are fine.
4. **MOC layering.** `_HOME.md` → zone `_index.md` → leaf-folder `_index.md` → concepts.
   Every leaf folder needs an `_index.md` Map of Content.
5. **Mermaid only.** No PNG/Excalidraw — keeps the vault grep-able, diff-able, version-
   controllable.
6. **Inventory before writing.** Derive concept names from real source files
   (`__init__.py`, route registrations, store directories) — don't invent.
7. **Canonicalize wikilink names BEFORE bulk content.** Emit the full `[[Wikilink]]`
   string list in Step 2b; pass it to every subagent. This prevents naming drift that no
   cleanup pass can fully repair.
8. **Templates first.** Write `_Templates/Concept Note.md` etc. before content so every
   contributor (human or LLM) follows the same shape.

See `references/vault-structure.md` for the canonical folder layout.

## Step 1: Decide Scope & Granularity (silent defaults first)

**Apply these defaults silently** unless the user's message explicitly conflicts:

| Decision | Default | When to override |
|---|---|---|
| Vault location | `./obsidian/` in project root | User names a different path; or repo already has an `obsidian/` folder used for something else |
| Granularity | **per concept** (80–150 notes for medium repo) | User explicitly asks for per-module (fewer notes) or per-file (more notes) |
| Depth | full content (Mermaid + cross-links) | User asks for "skeleton only" or "minimal" |

Only call `AskUserQuestion` if:
- The user's message contradicts a default (e.g., asks for per-file *and* "fewer notes")
- The repo has multiple plausible vault locations and the user didn't pick one
- A user instruction in CLAUDE.md or the conversation says to always confirm

Don't pause for confirmation when defaults are unambiguous — `obsidian-init` is meant to
run autonomously from a one-line request.

## Step 2: Survey the Codebase (Inventory Pass)

Before scaffolding, do one read pass to map what exists. Use direct `Glob` + `Read` for
known paths; for broader exploration, dispatch an `Agent` call with
`subagent_type: general-purpose`, `model: sonnet`, and instructions to return only a structural map (no
deep reads):

- **Project root manifests** — `package.json`, `pyproject.toml`, `Cargo.toml`, etc. to
  identify languages, frameworks, primary dependencies.
- **Backend (if Python/FastAPI):** `app/main.py` (startup order),
  `app/db/session.py` or equivalent (data model inventory), `app/api/__init__.py` (routes),
  each module's `__init__.py`.
- **Backend (other languages):** entry point + routing manifest + DB schema files.
- **Frontend (if React/Vue):** `src/main.*`, `src/store/`, `src/routes/`, `src/hooks/`,
  `src/components/` (Glob counts), animation/theme files.
- **Existing docs** — `CLAUDE.md`, `README.md`, `docs/`, `.claude/rules/`.

Goal: identify what concepts exist per planned zone. See `references/vault-structure.md`
"Typical concepts per zone" table for a starting list of expected concepts for a typical
full-stack project.

## Step 2b: Canonicalize Wikilink Names (CRITICAL)

**Before any scaffolding or subagent dispatch**, produce the complete flat list of
`[[Wikilink]]` strings the vault will use. This is the single most important step for
preventing name drift in Step 9.

For each concept identified in Step 2, write its exact final wikilink form to an
in-memory list grouped by zone:

```
Architecture:
  [[Main Domain Flow]]
  [[Auth Flow]]
  [[Job Scheduler Startup]]
  ...
Backend / agent:
  [[OrchestratorService]]
  [[Worker Pool]]
  ...
Backend / db:
  [[<Model> Model]]   (always suffix "Model" for db entities)
  ...
Patterns:
  [[<Pattern Name> Pattern]]   (always suffix "Pattern" for conventions)
  ...
```

**Rules to apply consistently:**

- DB models: always `<Entity> Model` (e.g., `User Model`, not `User`)
- Patterns: always `<Name> Pattern` or `<Name> Handling` or `<Name> Checklist`
- Endpoints: always `<Group> Endpoints` (e.g., `Auth Endpoints`)
- Subagents/services: bare class name (e.g., `TradingAgent`, `Notification Service`)
- Use Title Case for note names; lowercase only for module-folder paths
- Prefer existing TitleCase names from the source code over re-derivation

Save this list as a working buffer and pass it verbatim to every Step 9 subagent under a
"Required wikilink names" section. **Subagents will follow the list if given; they
invent variants if not.**

## Step 3: Compose & Scaffold Directory Tree

**Don't apply a fixed layout.** Compose the zone structure from what the codebase
actually contains, then scaffold those folders. The vault structure should mirror the
codebase's reality — a backend-only API doesn't need `02-Frontend/`, a CLI tool doesn't
need `02-Frontend/` *or* `03-Integrations/`, a monorepo might need `01-Services/<each>/`.

### Always create

- `.obsidian/` — config
- `_Templates/` — three template files
- `00-Architecture/` — cross-cutting flows (every codebase has 1+)
- At least one **primary code zone** (see decision table below)
- A **glossary zone** (rename `06-Glossary/` if numbering doesn't fit)

### Conditional zones — decide based on the codebase

| Zone | Create when… | Example projects |
|---|---|---|
| `01-Backend/` | Server-side code with multiple modules | API service, full-stack web |
| `02-Frontend/` | UI layer (web, mobile, desktop) | full-stack web, Tauri/Electron app |
| `01-Core/` (instead of Backend/Frontend) | Pure library / SDK / framework — no client/server split | npm package, Python lib, Rust crate |
| `01-Services/<service>/` | Monorepo with multiple deployable services | microservices repo |
| `02-Packages/<package>/` | Monorepo with shared library packages | turborepo, pnpm workspace |
| `01-Commands/` + `02-Internals/` | CLI tool | dev CLIs, build tools |
| `01-Pipeline/<stage>/` + `02-Models/` | ML / data pipeline / ETL | training repos, data lakes |
| `03-Integrations/` | Codebase uses 3+ external systems worth documenting | apps with DB + APIs + SaaS |
| `04-Patterns/` | Codebase has 3+ non-obvious conventions to codify | mature codebases |
| `05-Operations/` | Non-trivial build/deploy/debug workflows | anything with CI, releases, or runtime ops |
| `07-Protocols/` | Codebase implements a wire/network protocol | RPC servers, custom transports |
| `07-Data/` | Significant data modeling concerns (schemas, analytics) | ML + analytics |

### Inference rules

1. **Each top-level source directory** under `src/`, `app/`, `lib/`, etc. becomes a
   subfolder of the relevant code zone. Use the actual module names; don't rename.
2. **Don't create a zone for <5 expected concepts.** Fold small clusters into siblings
   (e.g., a 1-concept `middleware/` belongs inside `01-Backend/` as a subfolder, not as
   its own top-level zone).
3. **Multiple deployable components** (monorepo) → each gets its own top-level code
   zone, or live under a shared `01-Services/`.
4. **Numbered prefixes** keep zones in stable display order. `00-` for foundational,
   `01-`/`02-` for primary code, `03-` for external boundary, `04-`/`05-` for derivative
   content, `06-` (or last) for glossary. The numbering tells the reading order — adjust
   freely as long as that intent is preserved.

### Example layouts (pick the nearest match, then customize)

**Full-stack web app:**
```
obsidian/{.obsidian, _Templates, 00-Architecture, 01-Backend/<modules>, 02-Frontend/<modules>, 03-Integrations, 04-Patterns, 05-Operations, 06-Glossary}
```

**Backend-only API service:**
```
obsidian/{.obsidian, _Templates, 00-Architecture, 01-Backend/<modules>, 03-Integrations, 04-Patterns, 05-Operations, 05-Glossary}
```

**Pure library / SDK:**
```
obsidian/{.obsidian, _Templates, 00-Architecture, 01-Core/<modules>, 04-Patterns, 05-Glossary}
```

**Monorepo with multiple services:**
```
obsidian/{.obsidian, _Templates, 00-Architecture, 01-Services/<service-a>/<modules>, 01-Services/<service-b>/<modules>, 02-Packages/<shared-lib>, 03-Integrations, 04-Patterns, 05-Operations, 06-Glossary}
```

**ML / data pipeline:**
```
obsidian/{.obsidian, _Templates, 00-Architecture, 01-Pipeline/<stages>, 02-Models, 03-Integrations, 04-Patterns, 05-Operations, 06-Glossary, 07-Data}
```

**CLI tool:**
```
obsidian/{.obsidian, _Templates, 00-Architecture, 01-Commands, 02-Internals, 04-Patterns, 05-Operations, 06-Glossary}
```

See `references/vault-structure.md` for more layouts and the per-zone concept-list
starting prompts that match each shape.

### Folder creation by OS

- **Windows (PowerShell):** `New-Item -ItemType Directory -Path "obsidian/<subpath>" -Force` for each subpath, or one loop over a list. `mkdir -p` from bash will fail in PowerShell-default Claude Code shells.
- **POSIX (bash):** `mkdir -p` with the full path list.
- **Either OS:** Skip explicit folder creation and rely on `Write` auto-creating parent directories when you write the first file into each folder.

> ⚠️ **Pitfall 1 — Obsidian auto-init:** if Obsidian is running on the machine, it may
> auto-create empty placeholder JSON files inside `.obsidian/` as soon as you make the
> folder. Read those files first; if they exist with `{}` content, use `Edit` (not
> `Write`) to populate them.

> ⚠️ **Pitfall 2 — Locked files:** if Obsidian is open *with this vault*, `Write` will
> fail on `.obsidian/workspace.json` and may fail on `app.json` (Windows file lock). Tell
> the user to close Obsidian before running, or skip writing to `workspace.json`
> entirely (it's gitignored anyway).

## Step 4: Seed `.obsidian/` Config

Write the five core config files. **Copy exact contents from
`references/obsidian-config.md`** — don't re-derive:

| File | Purpose |
|---|---|
| `app.json` | Wikilink format, frontmatter display, tab size |
| `appearance.json` | Theme + accent color |
| `core-plugins.json` | Enable graph, backlinks, search, templates, etc. |
| `graph.json` | **Color groups by folder** (one color per zone) |
| `community-plugins.json` | `[]` (no third-party plugins) |

**Tune `graph.json` color groups to the actual zones chosen in Step 3.** The reference
file has a Trading-Agent example with `path:00-Architecture` through `path:06-Glossary` —
delete entries for zones you didn't create, add entries for zones you did create that
aren't in the example (e.g., `path:01-Services`, `path:07-Data`). The color groups make
Graph View instantly readable; only include the zones that exist.

## Step 5: Write Templates (Before Any Content)

Write three template files into `_Templates/`. Exact contents in
`references/note-templates.md`:

- `Concept Note.md` — for everything in Architecture/Backend/Frontend
- `Pattern Note.md` — for `04-Patterns/`
- `Integration Note.md` — for `03-Integrations/`

These set the structure all subsequent notes follow: frontmatter tags, `## Source` /
`## How it works` / `## Depends on` / `## Used by` / `## Gotchas` / `## See also`.

## Step 6: Write `README.md` + `_HOME.md`

- `README.md` (vault root) — one paragraph "open this folder as a vault" instructions +
  link to `_HOME.md`. Include Obsidian CLI smoke-test command for advanced users.
- `_HOME.md` — root MOC. Organize by zone with H2 headings. Each link gets a 1-line
  description. Add a **"Reading paths"** section (e.g., "New contributor:", "Frontend
  developer:", "DevOps:") with a curated chain of wikilinks.

Tag both with `tags: [moc, home]` in frontmatter.

## Step 7: Write Zone `_index.md` MOCs

Before writing any concept notes, write the `_index.md` MOC for every folder. Each MOC is
a wikilinked list of concepts in that folder + a 1-line description per concept. This
gives subsequent writers (yourself, subagents, or the user) a checklist of what concepts
the folder will contain.

Pattern per `_index.md`:

```markdown
---
tags: [moc, <zone>]
---

# <Zone Name> — Map of Content

> One-sentence purpose of this zone.

## <Subgroup heading>
- [[Concept Name]] — one-line description
- [[Another Concept]] — one-line description

## See also
- [[_HOME]]
- [[Related zone _index]]
```

## Step 8: Write Architecture Concepts (Cross-Cutting Flows)

Write the `00-Architecture/` notes yourself — these are the **mental scaffolding** every
other concept references. Typical concepts:

- Main domain flow(s) — e.g., "Trading Decision Flow", "Order Fulfillment Flow"
- RAG / search / knowledge pipeline (if applicable)
- Auth flow (JWT, OAuth, session)
- WebSocket / real-time architecture (if applicable)
- Background service / job scheduler startup order
- Logging / observability pipeline
- Any scheduled/cyclical workflow

Each gets a **Mermaid diagram** (`sequenceDiagram`, `flowchart`, `stateDiagram-v2`, or
`graph LR`). See `references/note-templates.md` for diagram examples.

## Step 9: Bulk Content via Parallel Subagents

For the remaining ~100+ concept notes, **dispatch parallel subagents** (one per
zone/subzone). This is the single biggest time-saver — 8 subagents in parallel can
produce ~300 atomic notes in ~6 minutes.

**How to dispatch in parallel:** issue multiple `Agent` tool calls inside a **single
response/tool-call block**. The Claude Code harness runs them concurrently. Do NOT
chain them sequentially across turns. Cap at 8 concurrent calls.

Use `Agent` with `subagent_type: general-purpose` and `model: sonnet`. Each brief must include:

1. **Exact output directory** (absolute path).
2. **Complete file list** (every note name to create, plus `_index.md`).
3. **Note format template** (frontmatter + section headings).
4. **Length constraint** — "60–180 words per note".
5. **Source file paths to read** — exact absolute paths; don't make the subagent guess.
6. **Canonical wikilink names** — the verbatim list from Step 2b. Phrase this in the
   subagent prompt as: *"Required wikilink names (use these EXACT strings; do not
   invent variants): [[Foo]], [[Bar Model]], [[Baz Pattern]], …"*
7. **Key facts to surface** — non-obvious behaviors, gotchas, version quirks.

> ⚠️ **Pitfall:** even with Step 2b's canonical list, subagents occasionally drift
> (`Persist Session Message Pattern` vs `persist_session_message Pattern`). Step 11's
> rename script catches these.

See `references/vault-structure.md` for an example 8-agent zone split for a full-stack
codebase of ~300 notes.

## Step 10: `.gitignore` Per-User State

Append to the project `.gitignore`:

```gitignore
# Obsidian per-user state (vault content + shared config IS tracked)
obsidian/.obsidian/workspace.json
obsidian/.obsidian/workspace-mobile.json
obsidian/.obsidian/workspaces.json
```

The rest of `.obsidian/` (config, graph, plugins) **stays tracked** — it's shared
configuration.

> ⚠️ **Pitfall — commit hygiene:** the vault adds ~100–300 new markdown files at once.
> Don't mix this with code changes. Tell the user (or do it yourself if the user
> authorized commits) to land the vault on a dedicated commit with a message like
> `chore(docs): scaffold obsidian vault` so it doesn't dominate unrelated PRs.

## Step 11: Cross-Link Verification + Cleanup

Run the **Layer 1 integrity script** from `references/verification.md`. It walks every
note, extracts wikilink targets, reports broken links, and excludes template
placeholders from the broken-link count.

Acceptable broken-link sources (the script filters these automatically):
- Template placeholders inside `_Templates/`
- Code examples like `` `[[wikilinks]]` `` in `README.md`
- Path-style folder references (rewrite as `[[Zone/Folder/_index|Alias]]`)

For the rest, use the **Layer 2 rename script** in `references/verification.md`. Add
your `(old, new)` regex pairs and run it. Common cases the script handles:
- Naming mismatches (`Foo Pattern` vs `foo Pattern`)
- Subagent-introduced variations
- References to concepts that exist under different names

Target: **≥99% of wikilink references resolve** (after filtering placeholders).

## Step 11b: Wire the Vault into Project Docs (Optional)

Offer to add a one-line pointer to the existing project README and/or CLAUDE.md so
contributors discover the vault:

> "Documentation lives in [`obsidian/`](./obsidian/_HOME.md) — open as an Obsidian vault, or browse the markdown directly."

This single line is the difference between a vault that gets used and one that gets
forgotten. Don't auto-edit those files — propose the line and let the user accept.

## Step 12: Verify with Obsidian CLI (Optional)

**Run this step ONLY if ALL conditions are met:**

- The user explicitly requested CLI verification, OR a deeper graph check is needed
- Obsidian 1.12+ is installed at the standard path (`%LOCALAPPDATA%\Programs\Obsidian\Obsidian.com` on Windows; `/Applications/Obsidian.app/Contents/MacOS/Obsidian` on macOS)
- Launching the Obsidian GUI as a side-effect is acceptable (the CLI requires the app running)
- The user has toggled "Enable Command line interface" in Obsidian Settings → General

Otherwise, **stop after Step 11** — the Layer 1 Python script covers structural
integrity. Don't launch the GUI unilaterally.

If the gate passes, see `references/verification.md` for the launch sequence and
graph-aware command set (`backlinks`, `orphans`, `deadends`, `search`, `properties`).

## Final Report

Report to the user:

- Total `.md` files written (per zone + total)
- Wikilink resolution rate (e.g., "99.5%")
- Number of orphans (should be `_HOME`, `README`, templates only)
- How to open the vault (GUI path + optional CLI smoke test)

Do **not** auto-launch Obsidian unless the user explicitly asks — launching a GUI app is
a visible side effect.

## Anti-Patterns to Avoid

The Core Principles cover positive guidance. Non-obvious negatives:

- **Don't** embed code snippets verbatim in notes — code rots, notes shouldn't. Link to
  the source file path instead.
- **Don't** install community plugins as part of init. Keep the vault portable.
- **Don't** create folders without `_index.md`. Every leaf folder needs a MOC (even a
  5-line stub).
- **Don't** rely on Obsidian CLI as a creation tool — it can only operate on existing
  vaults registered with a running Obsidian instance.
- **Don't** make the project root the vault root. Keep the vault in `./obsidian/` so its
  `README.md` doesn't collide with the project's.
- **Don't** auto-launch the Obsidian GUI. It's a visible side-effect; require explicit
  user consent (Step 12 gates).
