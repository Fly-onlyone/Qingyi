# Vault Structure Reference

The canonical folder layout for a concept-driven Obsidian vault documenting a codebase.

## Zone numbering

Numbered prefixes (`00-`, `01-`, …) keep zones in a stable display order in the file
explorer and make `path:00-Architecture` queries reliable for graph color groups.

```
obsidian/
├── .obsidian/                  Obsidian config (tracked except workspace*.json)
│   ├── app.json
│   ├── appearance.json
│   ├── core-plugins.json
│   ├── graph.json              (color groups by folder)
│   └── community-plugins.json
├── _Templates/                 Note templates (Concept / Pattern / Integration)
├── README.md                   How to open the vault
├── _HOME.md                    Root MOC — entry point
│
├── 00-Architecture/            Cross-cutting flows (~8–12 concepts)
│   ├── _index.md
│   ├── <Main Domain> Flow.md
│   ├── Auth Flow.md
│   ├── Background Service Startup.md
│   ├── Request Logging Pipeline.md
│   └── …
│
├── 01-Backend/                 Backend code zones (one folder per top-level module)
│   ├── _index.md
│   ├── <module>/               (e.g., agent/, api/, db/, knowledge/, services/)
│   │   ├── _index.md
│   │   ├── <Concept Name>.md
│   │   └── …
│   └── …
│
├── 02-Frontend/                Frontend code zones (same shape as Backend)
│   ├── _index.md
│   ├── components/
│   ├── routes/
│   ├── store/
│   ├── hooks/
│   └── …
│
├── 03-Integrations/            External systems (one note each, ~15–25)
│   ├── _index.md
│   ├── <Service Name>.md       (MongoDB, Postgres, Stripe, Sentry, etc.)
│   └── …
│
├── 04-Patterns/                Codebase conventions (~10–15)
│   ├── _index.md
│   ├── <Pattern Name>.md
│   └── …
│
├── 05-Operations/              Build/release/debug (~10–15)
│   ├── _index.md
│   ├── Build Commands.md
│   ├── Dev Server Architecture.md
│   ├── Release Workflow.md
│   └── …
│
└── 06-Glossary/                Domain terms (~10–20)
    ├── _index.md
    ├── <Term>.md
    └── …
```

## What goes where

| Zone | Contents | Typical concept names |
|---|---|---|
| `00-Architecture/` | System-wide flows with Mermaid diagrams | `<Domain> Decision Flow`, `Auth Flow`, `Job Scheduler Startup`, `Search Pipeline` |
| `01-Backend/<module>/` | One subfolder per top-level module under `app/` or `src/` | `<Service>`, `<Endpoint Group>`, `<Model>`, `<Worker>` |
| `02-Frontend/<module>/` | One subfolder per top-level module under `src/` | `<Component>`, `<Hook>`, `<Store>`, `<Route>` |
| `03-Integrations/` | One flat note per external dependency or library | `MongoDB`, `Stripe`, `Sentry`, `Tauri` |
| `04-Patterns/` | One note per codebase convention | `<Foo> Pattern`, `<X> Handling`, `<Y> Checklist` |
| `05-Operations/` | One note per operational concern | `Build Commands`, `Dev Server Architecture`, `Release Workflow`, `Debug Checklist` |
| `06-Glossary/` | One short note per domain term/acronym | `RAG`, `JWT`, `MoC`, `<DomainAcronym>` |

## Concept granularity rules

- **One concept per note.** A class, a flow, a pattern, an integration — not a file.
- **50–200 words per note.** Atomic and link-heavy.
- **Every folder gets an `_index.md`** — even if it's a 5-line MOC.
- **Folders organize; wikilinks navigate.** Folder structure is for the file explorer;
  the graph is built from `[[wikilinks]]`.

## Zone decision rules

The folder structure is **composed from the codebase**, not prescribed. The default
full-stack layout above is one example — pick the layout that matches your project shape.

### Always create

- `.obsidian/` — config
- `_Templates/` — three template files
- `_HOME.md` — root MOC
- `00-Architecture/` — cross-cutting flows (every codebase has at least 1)
- At least one primary code zone
- A glossary zone (rename if numbering changes)

### Conditional zones

| Zone | Skip when… |
|---|---|
| `01-Backend/` | No server-side code |
| `02-Frontend/` | No UI layer |
| `03-Integrations/` | Fewer than 3 external systems |
| `04-Patterns/` | No codified codebase conventions |
| `05-Operations/` | Trivial build/deploy (no CI, no runtime ops, no release process) |
| Per-folder concept notes | Folder has <3 meaningful concepts — fold into the parent zone's `_index.md` as bullets |

### Project-shape templates

For non-full-stack codebases, swap the code zones:

**Backend-only API service**
```
obsidian/{_Templates, 00-Architecture, 01-Backend/<modules>, 03-Integrations, 04-Patterns, 05-Operations, 05-Glossary}
```

**Pure library / SDK / framework** (no client/server split)
```
obsidian/{_Templates, 00-Architecture, 01-Core/<modules>, 04-Patterns, 05-Glossary}
```

**Monorepo with multiple deployable services**
```
obsidian/{_Templates, 00-Architecture, 01-Services/<service-a>/<modules>, 01-Services/<service-b>/<modules>, 02-Packages/<shared-lib>, 03-Integrations, 04-Patterns, 05-Operations, 06-Glossary}
```

**ML / data pipeline**
```
obsidian/{_Templates, 00-Architecture, 01-Pipeline/<stages>, 02-Models, 03-Integrations, 04-Patterns, 05-Operations, 06-Glossary, 07-Data}
```

**CLI tool**
```
obsidian/{_Templates, 00-Architecture, 01-Commands, 02-Internals, 04-Patterns, 05-Operations, 06-Glossary}
```

**Pure documentation / spec / standard**
```
obsidian/{_Templates, 00-Architecture, 01-Sections, 02-Examples, 04-Patterns, 06-Glossary}
```

### Numbering

Numbered prefixes preserve display order. Use `00-` for foundational, `01-/02-` for
primary code, `03-` for external boundary, `04-/05-` for derivative content, last number
for glossary. Adjust as long as the numbering tells the reading story. Renumber freely
when you drop zones — don't leave gaps (`00, 02, 04` looks broken).

## Heuristic for concept count

| Codebase size | Concepts target |
|---|---|
| Small (~50 source files) | 40–60 notes |
| Medium (~150 source files) | 80–120 notes |
| Large (~300+ source files) | 150–250 notes |

Don't try to hit "one note per file" for large codebases — that produces noise, not
knowledge.

## Typical concepts per zone (full-stack Python+React starting list)

Use this as a **starting prompt** during Step 2 inventory — confirm each concept exists
in the actual codebase before adding it to the canonical wikilink list. Skip concepts
that don't apply.

### `00-Architecture/`

`<Main Domain Flow>`, `Auth Flow`, `Background Service Startup`,
`Request Logging Pipeline`, `WebSocket Connection Manager` (if applicable),
`<Search/RAG> Pipeline` (if applicable), `<Scheduled Job> Cycle`,
`Subagent Delegation Pattern` (if multi-agent), `Chat Session Lifecycle` (if chat UI),
`Knowledge Graph Edges` (if graph DB)

### `01-Backend/<module>/`

- **agent/** (AI orchestration): `<MainAgent>`, each subagent, tool registry, each tool category, session recorder, memory telemetry, task scheduler
- **api/**: Router registration order, each endpoint group, each WebSocket channel
- **db/**: One note per Document/Model + `<ORM> Document Pattern`, `<connection> Session`
- **services/**: One note per service class
- **knowledge/** / **rag/** (if applicable): Embeddings, Cache, Retriever, RRF/Fusion, Reranker, Chunker
- **security/**: Encryption, key store, key provider, resolver
- **middleware/**: Each middleware class
- **core/**: Rate Limiting, App Settings, Logging config, Platform Event Loop (if Windows-aware)

### `02-Frontend/<module>/`

- **components/**: Notable components (not every leaf); group by domain (auth, dashboard, table, layout, effects)
- **routes/**: Routing pattern + each route group
- **api/**: HTTP client interceptor, case conversion, query options factory
- **websocket/**: Each WebSocket hook
- **store/**: Each store + `<Library> Store Pattern`
- **hooks/**: Notable custom hooks
- **theme/**: Theme factory, palette, presets, MUI/component overrides
- **utils/**: Validators, transformers, env detection, logger, monitoring config
- **animations/**: Each variant from variants.ts, spring configs, reduced-motion

### `03-Integrations/`

Each external dependency: `<DB>`, `<DB driver>`, `<ORM>`, `<Auth provider>`,
`<Monitoring>`, `<Build tool>`, `<Test runner>`, `<Bundler>`, `<Animation lib>`,
`<UI framework>`, `<State lib>`, `<Router>`. One note each.

### `04-Patterns/`

Codebase conventions: `<X> Handling`, `<Component>Wrapper Pattern`,
`<Service> Auth Pattern`, `<Notification> Pipeline`, `<Configuration> Checklist`,
`<Persistence> Pattern`.

### `05-Operations/`

`Build Commands`, `Dev Server Architecture`, `<Build tool> Commands` (per platform),
`Release Workflow`, `Conventional Commits`, `<Monitoring> Setup`, `<Logging> Queries`,
`Production Debugging Checklist`, `<Linter> Rules`, `<Formatter> Rules`, `Pre-commit Hooks`

### `06-Glossary/`

Domain terms + acronyms used throughout: stack-specific (`JWT`, `RAG`, `RRF`), library
shortenings, internal abbreviations.

## Example 8-agent zone split (full-stack ~300-note vault)

Use this allocation when dispatching parallel subagents in Step 9 of the main workflow:

| Agent | Zone(s) | Approx. notes |
|---|---|---|
| 1 | Backend agent/AI orchestration | ~25 |
| 2 | Backend data layer: db + security + middleware + core | ~40 |
| 3 | Backend services + API endpoints | ~40 |
| 4 | Backend knowledge/RAG + exchange + news | ~25 |
| 5 | Frontend components + routes + tauri/desktop | ~45 |
| 6 | Frontend store + hooks + api + websocket | ~35 |
| 7 | Frontend theme + utils + animations | ~30 |
| 8 | Integrations + Patterns + Operations + Glossary | ~60 |

For backend-only or frontend-only repos, collapse agents accordingly (4 agents typical).
Max 8 concurrent — beyond that, parallel benefits saturate and rate-limit risk grows.
