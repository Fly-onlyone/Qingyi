# Commit Message Guidelines

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change that neither fixes nor adds |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `chore` | Build process, dependencies |

## Examples

```
feat(auth): add OAuth2 login flow

fix(api): handle null response from payment service

docs(readme): update installation instructions

refactor(utils): extract date formatting to helper
```

## Rules

1. Use imperative mood ("add" not "added")
2. Keep first line under 50 characters
3. Capitalize first letter after type
4. No period at end of subject line
5. Separate subject from body with blank line
6. Wrap body at 72 characters
7. Use body to explain *what* and *why*, not *how*

## Anti-Patterns

- `fixed stuff`
- `WIP`
- `update`
- `misc changes`
- `fix: Fix the fix that was fixed`
