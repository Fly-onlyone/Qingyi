# Documentation Style Guide

## Core Principles

1. **Document WHY, not WHAT** - Code shows what, comments explain why
2. **Keep it current** - Outdated docs are worse than none
3. **Be concise** - Every word should add value
4. **Use examples** - Show, don't just tell
5. **Write for future you** - You won't remember in 6 months

## Documentation by Element

### Functions/Methods

```{{language}}
{{comment_start}}
Brief description of what it does.

@param paramName - Description of parameter
@returns Description of return value
@throws ErrorType - When this error occurs
@example
const result = functionName(arg);
{{comment_end}}
```

### Classes/Components

```{{language}}
{{comment_start}}
Brief description of the class purpose.

Handles [responsibility]. Used by [consumers].

@example
const instance = new ClassName();
{{comment_end}}
```

### Complex Logic

```{{language}}
// WHY: Explain business rule or non-obvious decision
// Example: Skip validation for admin users per security policy
```

## Skip Documentation For

- Getters/setters with obvious purpose
- Standard constructors
- Self-documenting code (`getUserById(userId)`)
- Test files (test names are documentation)

## Section Comments

Use for logical groupings:

```{{language}}
// ============================================================
// Section Name
// ============================================================
```

## Words to Avoid

| Avoid | Use Instead |
|-------|-------------|
| "This function..." | Start with verb |
| "Basically" | Remove |
| "Simply" | Remove |
| "Obviously" | Remove |
| "etc." | Be specific |

## README Checklist

- [ ] Project purpose (1-2 sentences)
- [ ] Installation steps
- [ ] Usage example
- [ ] Configuration options
- [ ] Contributing guidelines
- [ ] License
