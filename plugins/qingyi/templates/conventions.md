# Code Conventions

## Directory Structure

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

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files (components) | PascalCase | `UserProfile.{{ext}}` |
| Files (utilities) | camelCase | `formatDate.{{ext}}` |
| Files (tests) | *.test.* | `UserProfile.test.{{ext}}` |
| Classes | PascalCase | `UserService` |
| Functions | camelCase | `getUserById` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Interfaces/Types | PascalCase | `UserProps` |
| Enums | PascalCase | `UserRole` |
| Private fields | _camelCase | `_internalState` |

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

## Best Practices

- **Single Responsibility**: One component/class = one purpose
- **DRY**: Extract repeated code (3+ occurrences)
- **Early Returns**: Reduce nesting with guard clauses
- **Explicit over Implicit**: Prefer clarity over brevity
- **Immutability**: Prefer const, avoid mutation
