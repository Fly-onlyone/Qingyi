# Code Guide

## Package Structure

```
{{project_root}}/
├── src/                    # Source code
│   ├── components/         # UI components
│   ├── services/           # Business logic
│   ├── utils/              # Utility functions
│   ├── types/              # Type definitions
│   └── config/             # Configuration
├── tests/                  # Test files
├── docs/                   # Documentation
└── scripts/                # Build/deploy scripts
```

---

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Classes | `PascalCase` | `UserService` |
| Functions | `camelCase` | `getUserById` |
| Constants | `UPPER_SNAKE` | `MAX_RETRIES` |
| Interfaces/Types | `PascalCase` | `UserProps` |
| Files (components) | `PascalCase` | `UserProfile.{{ext}}` |
| Files (utilities) | `camelCase` | `formatDate.{{ext}}` |
| Files (tests) | `*.test.*` | `UserProfile.test.{{ext}}` |
| Private fields | `_camelCase` | `_internalState` |

---

## Code Patterns

### Pattern 1: Service Singleton

**When to Apply**: Shared stateful service accessed across the application.

**Template**: See `src/services/[ServiceName]` for examples in your codebase.

**Anti-Patterns**:
- Creating multiple instances
- Storing request-specific data in singleton

---

### Pattern 2: Repository Pattern

**When to Apply**: Data access abstraction for testability.

**Template**: See `src/repositories/[RepositoryName]` for examples.

**Anti-Patterns**:
- Business logic in repository
- Returning raw database entities

---

### Pattern 3: Factory Pattern

**When to Apply**: Object creation with varying configurations.

**Template**: See `src/factories/[FactoryName]` for examples.

---

### Pattern 4: Error Handling

**When to Apply**: Consistent error handling across the application.

**Template**: See error handling in service layer files.

---

### Pattern 5: Configuration Object

**When to Apply**: Multiple optional parameters.

**Template**: See config objects in `src/config/` directory.

---

### When NOT to Use Patterns

- **YAGNI**: Don't add abstractions for hypothetical futures
- **Simple cases**: Direct implementation beats pattern overhead
- **Single use**: Patterns shine with repetition
- **Team unfamiliarity**: Unknown patterns reduce maintainability

---

## Code Style

### Imports Order

1. External libraries
2. Internal modules (absolute paths)
3. Relative imports
4. Type imports
5. Style imports

### File Organization

1. Imports
2. Types/Interfaces
3. Constants
4. Component/Class definition
5. Helper functions
6. Exports

---

## Best Practices

- **Single Responsibility**: One component/class = one purpose
- **DRY**: Extract repeated code (3+ occurrences)
- **Early Returns**: Reduce nesting with guard clauses
- **Explicit over Implicit**: Prefer clarity over brevity
- **Immutability**: Prefer const, avoid mutation
