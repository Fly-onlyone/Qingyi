# Architecture

## System Design

<!-- TODO: Describe your application's high-level architecture -->

### Layer Diagram

```
┌─────────────────────────────────────────┐
│              Presentation               │
│         (UI / API Controllers)          │
├─────────────────────────────────────────┤
│              Application                │
│         (Services / Use Cases)          │
├─────────────────────────────────────────┤
│               Domain                    │
│        (Business Logic / Models)        │
├─────────────────────────────────────────┤
│            Infrastructure               │
│      (Database / External APIs)         │
└─────────────────────────────────────────┘
```

## Data Flow

<!-- TODO: Describe how data moves through your system -->

1. **Request Entry**: ...
2. **Processing**: ...
3. **Response**: ...

## Key Components

| Component | Purpose | Location |
|-----------|---------|----------|
| <!-- TODO --> | <!-- TODO --> | `<!-- TODO -->` |

## State Management

<!-- TODO: How state is managed in your application -->

## External Integrations

| Service | Purpose | Configuration |
|---------|---------|---------------|
| <!-- TODO --> | <!-- TODO --> | `<!-- TODO -->` |

## Module Dependencies

```
<!-- TODO: Module dependency diagram -->
```

## Testing Strategy

| Test Type | Location | Run Command |
|-----------|----------|-------------|
| Unit | `tests/unit/` | `{{test_command}}` |
| Integration | `tests/integration/` | `{{integration_test_command}}` |
| E2E | `tests/e2e/` | `{{e2e_test_command}}` |
