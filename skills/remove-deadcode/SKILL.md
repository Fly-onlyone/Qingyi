---
name: remove-deadcode
description: >-
  This skill should be used when the user asks to "scan for dead code",
  "remove dead code", "find unused code", "clean up unused exports",
  "find unused dependencies", "remove unused imports", "prune dead files",
  "find orphaned files", "check for unused functions", or "clean up barrel exports".
  Also triggers on mentions of "dead code", "unused code", "orphaned code", or "stale code".
  Provides a language-agnostic phased workflow: parallel exploration with grep-verified
  evidence, false positive awareness for framework patterns, cascade detection, safe
  removal ordering, and post-removal verification. Works with any language or stack.
---

# Dead Code Removal Workflow

Systematically find and remove dead code across a codebase using grep-verified evidence.
Never remove code based on assumptions — every finding must be verified with a codebase-wide
search confirming zero external references.

## Step 0: Detect Project Stack

Before scanning, identify the languages, frameworks, package managers, and build tools in use.
Read manifest files (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`,
`Gemfile`, `*.csproj`, `build.gradle`, etc.) and entry points to understand:

- Which languages and frameworks are present
- How modules are imported/exported (barrel files, packages, modules, crates)
- How dependencies are managed and which tools to use for verification
- Which framework registration patterns to watch for (see `references/false-positives.md`)

## Core Principle: Evidence Before Deletion

For every candidate dead symbol, run a codebase-wide grep. A symbol is confirmed dead ONLY when
grep returns results exclusively in its own definition file and/or re-export files, with
zero consumer references anywhere else.

## Phase 1: Explore and Categorize

Launch parallel Explore agents (scale to codebase size) to scan different areas. Each agent
should check every file, function, class, and export in its assigned area.

### What to Scan

Check each category systematically (see `references/scan-categories.md` for detailed checklists):

1. **Dead files/modules** — Files where every export has zero external consumers
2. **Dead functions/classes/methods** — Exported symbols with zero references outside their own file
3. **Dead re-exports** — Barrel/index re-exports that nothing consumes
4. **Dead state management code** — Selectors, reducers, getters never used by consumers
5. **Dead API client methods** — Wrapper functions defined but never called
6. **Dead dependencies** — Packages in manifests but never imported (watch for lazy/transitive)
7. **Dead UI/style code** — Components, variants, helpers, CSS defined but never referenced
8. **Dead type definitions** — Types/interfaces/structs only used by other dead code

### Cascade Detection

When a file is confirmed dead, check what it uniquely imports. Those imports may now also be dead:
- Dead module imports a helper → check if that helper has other consumers
- Dead file imports a type → check if that type is used elsewhere
- Dead re-export references a util → check if the util has direct imports

## Phase 2: Verify with False Positive Awareness

Before marking anything as dead, consult `references/false-positives.md` for framework-specific
patterns that appear unused but are dynamically consumed.

### Quick False Positive Checklist

- Framework-registered items (ORM models, routers, middleware, DI bindings, plugins)
- Decorator/annotation/attribute-driven code (`@route`, `@Component`, `#[derive]`, `[ApiController]`)
- Lazy/conditional/dynamic imports and reflection-based usage
- Type stubs, ambient declarations, and `.d.ts` / `.pyi` files
- Entry points, CLI commands, and lifecycle hooks
- Build tool configs, scripts, and code generators
- Transitive runtime dependencies required by other packages
- Convention-based discovery (file-based routing, auto-scanning packages)

### Verification Command Pattern

For each suspect symbol, run:
```
Grep pattern="SymbolName" path="<project-root>" output_mode="files_with_matches"
```

Dead if: results contain ONLY the definition file and/or re-export files.
Alive if: results contain ANY consumer file outside definition + re-export.

## Phase 3: Plan Safe Removal Order

Order deletions to avoid cascading import/compilation errors:

1. **Delete dead files first** — removes the most code with least risk
2. **Remove dead symbols from live files** — edit, don't delete the file
3. **Clean re-exports** — remove re-export lines from barrel/index/package files
4. **Remove dead state/hook/handler definitions** — from source files
5. **Clean orphaned imports** — in files where removed exports leave unused imports
6. **Remove dead dependencies** — from manifests, then sync lockfile
7. **Run formatters** — ensure modified files conform to project style

## Phase 4: Execute Removal

### Removal Checklist

For each confirmed dead item:

1. Delete the file or remove the symbol using the Edit tool
2. Remove its re-export line from any barrel/index file
3. Clean up imports that are now unused in the modified file
4. If removing a dependency, update the manifest and run the package manager sync command
5. Run the project formatter on each modified file

Adapt commands to the project's toolchain (read CLAUDE.md or project docs for the correct
lint/format/build/test commands).

## Phase 5: Verify Nothing Broke

Run in sequence after all removals:

1. **Lint** — check for new import/reference errors
2. **Type check** — catch broken type references (if the project uses static typing)
3. **Build/compile** — verify all imports resolve and compilation succeeds
4. **Test** — run the test suite to catch runtime breakage
5. **IDE diagnostics** — if IDE MCP available, run `get_file_problems` on modified files

If ANY verification step reveals a new error in a file modified during removal, investigate
immediately — likely a false positive that was incorrectly removed.

## Phase 6: Optional — Install Detection Tools

Only suggest this step if the user asks about ongoing detection or automation.
For ongoing dead code prevention, install dedicated scanners:

| Language | Tool | Install | Run |
|----------|------|---------|-----|
| Python | vulture | `pip install vulture` | `vulture src/ --min-confidence 80` |
| TypeScript/JS | knip | `npm add -D knip` | `npx knip` |
| Go | deadcode | `go install golang.org/x/tools/cmd/deadcode@latest` | `deadcode ./...` |
| Rust | (built-in) | — | `cargo build` emits `dead_code` warnings |
| Java | ProGuard / Spotbugs | varies | detects unused classes/methods |
| C# | (built-in) | — | Roslyn analyzers emit `CS0219` / `IDE0051` warnings |
| Ruby | debride | `gem install debride` | `debride .` |

Configure whitelists or suppression files for framework false positives before triaging results.
