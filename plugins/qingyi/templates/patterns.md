# Code Patterns

This file documents recurring code patterns used in this project.

---

## Pattern 1: Service Singleton

**When to Apply**: Shared stateful service accessed across the application.

```{{language}}
{{singleton_example}}
```

**Anti-Patterns**:
- Creating multiple instances
- Storing request-specific data in singleton

---

## Pattern 2: Repository Pattern

**When to Apply**: Data access abstraction for testability.

```{{language}}
{{repository_example}}
```

**Anti-Patterns**:
- Business logic in repository
- Returning raw database entities

---

## Pattern 3: Factory Pattern

**When to Apply**: Object creation with varying configurations.

```{{language}}
{{factory_example}}
```

---

## Pattern 4: Error Handling

**When to Apply**: Consistent error handling across the application.

```{{language}}
{{error_example}}
```

---

## Pattern 5: Configuration Object

**When to Apply**: Multiple optional parameters.

```{{language}}
{{config_example}}
```

---

## When NOT to Use Patterns

- **YAGNI**: Don't add abstractions for hypothetical futures
- **Simple cases**: Direct implementation beats pattern overhead
- **Single use**: Patterns shine with repetition
- **Team unfamiliarity**: Unknown patterns reduce maintainability
