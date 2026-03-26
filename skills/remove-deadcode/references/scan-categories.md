# Dead Code Scan Categories

Detailed checklists for systematically scanning each category of dead code.
Examples span multiple languages — adapt patterns to the project's stack.

## 1. Dead Files / Modules

Entire files where no export is consumed externally.

### Where to Look

- **Test files** importing non-existent modules (leftover from refactors)
- **Feature modules** removed from routing/registration but file remains
- **Utility files** created speculatively but never imported
- **State files** not exported from barrel and not directly imported
- **Hook/helper files** whose only consumer was another dead file
- **Component/view files** not rendered or referenced anywhere
- **Migration files** for tables that no longer exist (check before removing — rollback risk)

### How to Verify

For each exported symbol in the file, grep the project. If ALL exports only appear in
the file itself and its barrel re-export, the entire file is dead.

```
Grep pattern="ExportedName" path="<project>" output_mode="files_with_matches"
# Dead if: only returns the file itself + optional barrel/index
```

### Cascade Check

When deleting a dead file, check its imports — they may now be dead too:
- Dead module imports a helper → does that helper have other consumers?
- Dead file imports a type → is that type used elsewhere?

---

## 2. Dead Functions, Classes, and Methods

Symbols exported or publicly visible but never referenced elsewhere.

### Where to Look

- **Service/repository methods** — written but never called from controllers/routes
- **Utility functions** — speculative helpers (sleep, clamp, debounce, retry, etc.)
- **Factory classes** — created for features that were later removed
- **Calculator/processor functions** — business logic superseded by newer implementations
- **Deprecated symbols** — marked deprecated but callers were removed without cleanup
- **Public methods on structs/classes** — accessible but never called outside the type

### Language-Specific Export/Visibility Patterns

| Language | Exported If | Check For |
|----------|------------|-----------|
| Python | No `_` prefix or in `__all__` | `from module import name` |
| TypeScript/JS | `export` keyword | `import { name }` |
| Go | Capitalized name | `package.Name` |
| Rust | `pub` keyword | `use crate::module::name` |
| Java/Kotlin | `public` / default | `import package.ClassName` |
| C# | `public` / `internal` | `using Namespace; ... ClassName` |
| Ruby | All methods are public by default | `require` + method call |

### How to Verify

```
Grep pattern="functionName" path="<project>" output_mode="files_with_matches"
# Dead if: only the definition file appears
```

### Special Case: Class/Struct Methods

For methods on a class or struct, check both external and internal calls:

```
# External calls
Grep pattern="instance\.methodName|ClassName\.methodName" path="<project>"

# Internal calls (language-dependent)
# Python: self.methodName
# JS/TS: this.methodName
# Go: receiver.methodName (within same package)
# Rust: self.method_name
```

A method is dead only if BOTH external and internal checks return zero results
outside the definition.

---

## 3. Dead Re-Exports (Barrel / Index / Package Init)

Re-exports in aggregation files that nothing consumes through that path.

### Language-Specific Barrel Patterns

| Language | Barrel File | Re-export Syntax |
|----------|------------|-----------------|
| TypeScript/JS | `index.ts` | `export { X } from "./module"` |
| Python | `__init__.py` | `from .module import X` |
| Rust | `mod.rs` / `lib.rs` | `pub use submodule::X;` |
| Go | — (no barrels) | Package-level visibility only |
| Java | — (no barrels) | Package-level, but check facade classes |
| C# | — (no barrels) | Check `GlobalUsings.cs` or facade classes |

### How to Verify

Check if anyone imports the symbol through the barrel:
```
Grep pattern="from.*barrel-path.*import.*X" path="<project>"
# Also check direct imports bypassing the barrel
Grep pattern="from.*direct-path.*import.*X" path="<project>"
# Dead barrel export if: zero consumers via either path
```

### Common Pattern: Wildcard Re-Exports

`export * from './helpers'` or `pub use submodule::*` re-exports everything.
Check each individual symbol to find which are actually consumed.

---

## 4. Dead State Management Code

Selectors, reducers, computed properties, and getters never used by consumers.

### Where to Look

| Pattern | Frameworks |
|---------|-----------|
| Selectors | Zustand, Redux, Recoil, NgRx, Pinia, Vuex |
| Computed getters | MobX, Vue Composition API |
| Reducers/actions | Redux Toolkit, Flux |
| State slices | Any store with modular slices |
| Queries/mutations | TanStack Query, SWR, Apollo Client, RTK Query |

### How to Verify

```
Grep pattern="selectSomething" path="<project>/src" output_mode="files_with_matches"
# Dead if: only store definition + barrel, no component/route/hook files
```

---

## 5. Dead API Client Methods

Client-side API wrapper methods never called by any consumer.

### Where to Look

- Methods on API client objects/classes
- Query option factories never referenced
- Mutation hooks never used
- gRPC client stubs with unused methods
- GraphQL query/mutation definitions never imported

### How to Verify

```
# For object methods
Grep pattern="apiClient\.methodName" path="<project>/src"
# For standalone functions
Grep pattern="functionName" path="<project>/src" output_mode="files_with_matches"
# Dead if: only the definition file
```

### Bonus: Prefetch / Cache Mismatches

Check prefetch or cache-warming code — it may call API methods with a different data
shape than the consumer expects. This causes runtime bugs, not dead code, but is a
valuable finding during the same scan.

---

## 6. Dead Dependencies

Packages listed in manifests but never imported in source code.

### Manifest Files by Ecosystem

| Ecosystem | Manifest | Lockfile |
|-----------|----------|----------|
| Node.js | `package.json` | `package-lock.json` / `bun.lockb` / `yarn.lock` / `pnpm-lock.yaml` |
| Python | `pyproject.toml` / `requirements.txt` / `setup.py` | `uv.lock` / `poetry.lock` |
| Go | `go.mod` | `go.sum` |
| Rust | `Cargo.toml` | `Cargo.lock` |
| Java (Maven) | `pom.xml` | — |
| Java (Gradle) | `build.gradle` / `build.gradle.kts` | `gradle.lockfile` |
| Ruby | `Gemfile` | `Gemfile.lock` |
| C# | `*.csproj` | `packages.lock.json` |
| PHP | `composer.json` | `composer.lock` |

### How to Verify

For each dependency, determine its import name (often different from package name):

| Package Name | Import Name |
|-------------|------------|
| `beautifulsoup4` | `bs4` |
| `python-jose` | `jose` |
| `pymupdf` | `fitz` |
| `golang.org/x/text` | `text` (last segment) |
| `serde_json` (Rust) | `serde_json` |

Then grep for any form of import:
```
Grep pattern="import.*importName|from importName|require.*importName|use importName" path="<project>"
```

### Watch Out: Lazy, Conditional, and Dynamic Imports

Imports inside function bodies, behind conditions, or via reflection:
```python
def process():
    import fitz  # lazy — NOT dead
```
```typescript
const mod = await import("package");  // dynamic — NOT dead
```
```java
Class.forName("com.example.Driver");  // reflection — NOT dead
```
```go
import _ "github.com/lib/pq"  // blank import for side effects — NOT dead
```

### Watch Out: Type Stubs, Transitive, and Peer Dependencies

- Type stub packages (`pandas-stubs`, `@types/node`) — used by type checker, never imported
- Transitive runtime deps required by other packages without direct import
- Peer dependencies required by framework packages
- Build tool plugins referenced only in config files

---

## 7. Dead UI / Style Code

Components, variants, keyframes, helpers, and styles defined but never used.

### Where to Look

- **Components** — rendered nowhere (check routes, layouts, other components)
- **Animation variants/hooks** — defined in shared files but never referenced
- **CSS classes** — defined but never applied (check HTML templates and JSX)
- **Theme tokens/helpers** — exported but never consumed
- **Icons/assets** — imported nowhere

### How to Verify

```
Grep pattern="symbolName" path="<project>/src" output_mode="content"
```

### Watch Out: Name Collisions Across Systems

A name may exist in both code and style contexts:
- JS animation variant `glowPulse` (Framer Motion) vs CSS `@keyframes glowPulse`
- Component name `Card` vs CSS class `.Card`
- Theme token `cardHover` (JS object) vs shadow value `cardHover` (CSS string)

Verify which system the grep hit references before marking the code-level export as dead.

---

## 8. Dead Type Definitions

Types, interfaces, structs, enums, or typedefs only used by other dead code.

### Where to Look

- Type imports in dead files — those types may now be orphaned
- Exported types in a `types/` or `models/` directory never imported
- Interfaces used only as parameter types for dead functions
- Protobuf/GraphQL type definitions with no consumer

### How to Verify

After removing dead code, re-grep for types that were used by the removed code:
```
Grep pattern="TypeName" path="<project>" output_mode="files_with_matches"
# Dead if: only the type definition file remains
```

### Caution

Only remove types AFTER the code that used them is removed. A type that appears
dead during initial scan may be alive — its consumer just hasn't been checked yet.
