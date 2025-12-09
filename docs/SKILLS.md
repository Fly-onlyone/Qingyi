# Comprehensive Skill Creation Guide

Complete guide for creating skills in the Qingyi Minecraft Development Plugin.

## Overview

Skills are model-invoked knowledge modules that Claude loads automatically when relevant to the current task.

## Key Concepts

### Skills vs Agents

- **Skills**: Knowledge modules (passive, loaded when needed)
- **Agents**: Task executors (active, delegated for workflows)

Use skills for reference information, use agents for execution.

## File Structure

```
skills/
└── skill-name/
    ├── SKILL.md                 # Required main file
    ├── reference.md             # Optional supporting files
    ├── examples/
    │   └── example.java
    └── templates/
        └── template.java
```

## SKILL.md Format

```yaml
---
name: skill-name
description: What, when, why to use this skill. Include trigger keywords.
allowed-tools: Read, Grep, Glob  # Optional
---

# Skill Display Name

## What This Covers

Brief overview...

## When to Use

Specific scenarios...

## Core Knowledge

Main content...

## See Also

[Reference docs](reference.md)
[Examples](examples/)
```

## Writing Descriptions

Include:
- **Domain keywords** (minecraft, forge, registry, items)
- **Action verbs** (implement, create, configure)
- **Use cases** (when implementing X, when working with Y)

**Example**:
```yaml
description: Implement Minecraft items, blocks, and entities using registry systems. Use when creating custom content, registering game objects, or implementing item/block behavior. Covers Forge DeferredRegister, Fabric Registry, and Quilt registries.
```

## Progressive Disclosure

Keep SKILL.md concise, use supporting files for details:

**SKILL.md**:
```markdown
## Registry System

Minecraft uses registries to track all game content.

For detailed information:
- [Forge Registries](forge-registries.md)
- [Fabric Registries](fabric-registries.md)
- [Examples](examples/registry-example.java)
```

Claude loads supporting files only when needed.

## Best Practices

1. **Specific names**: `minecraft-api-reference` not `minecraft-help`
2. **Rich descriptions**: Include many relevant keywords
3. **Organized content**: Use headers and lists
4. **Real examples**: Show actual code, not pseudocode
5. **Version awareness**: Separate content by MC version if needed

## Testing

Test by asking questions that should load the skill:

```
"How do I create a custom item in Forge?"
→ Should load minecraft-api skill
```

## See Also

- [skills/README.md](../skills/README.md)
- [examples/example-skill/](../examples/example-skill/)
