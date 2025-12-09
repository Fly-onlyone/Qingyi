# Skills

Skills are reusable knowledge modules that Claude can automatically invoke when needed during conversations.

## What are Skills?

Skills are **model-invoked capabilities** that provide:

- Specialized knowledge or expertise
- Reference information and examples
- Procedural guidance
- Domain-specific patterns

Claude autonomously decides when to use skills based on their descriptions and the current task.

## Skills vs Agents

| Aspect | Skills | Agents |
|--------|--------|--------|
| **Invocation** | Automatic by Claude | User/system delegates |
| **Context** | Loaded into main conversation | Separate context window |
| **Purpose** | Knowledge/reference | Task execution |
| **Size** | Can be large (progressive loading) | Usually concise |
| **Example** | "How to use Minecraft registries" | "Design this mod's architecture" |

**Rule of thumb**: Skills are **what you know**, agents are **what you do**.

## When to Use Skills

Create skills for:
- **Reference documentation** (API guides, framework patterns)
- **Procedural knowledge** (how to set up environments, configure tools)
- **Examples and templates** (common code patterns, configurations)
- **Domain expertise** (Minecraft modding conventions, best practices)

Don't create skills for:
- Task execution workflows (use agents)
- Conversational flows
- One-off instructions

## Creating a Skill

### Directory Structure

Each skill is a **directory containing SKILL.md**:

```
skills/
└── your-skill-name/
    ├── SKILL.md              # Required main file
    ├── reference.md          # Optional supporting files
    ├── examples.md
    └── templates/
        └── template.java
```

### SKILL.md Format

```yaml
---
name: skill-name
description: What this skill does and when to use it. Include key terms that trigger usage.
allowed-tools: Read, Grep, Glob  # Optional
---

# Skill Display Name

## What This Skill Covers

Brief overview of the skill's domain.

## When to Use

Specific scenarios when Claude should invoke this skill.

## Core Knowledge

Main content goes here...

## Supporting Files

[See examples.md](examples.md) for detailed examples.
[See reference.md](reference.md) for API reference.
```

### Required Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique skill identifier (kebab-case) |
| `description` | Yes | When/why/how to use (include trigger keywords) |

### Optional Fields

| Field | Default | Description |
|-------|---------|-------------|
| `allowed-tools` | All tools | Restrict tool access when skill is loaded |

## Best Practices

### 1. Write Descriptive Names

Use specific, searchable names:

**Bad**: `minecraft-stuff`, `helper`, `utils`

**Good**: `minecraft-api-reference`, `forge-event-system`, `gradle-mod-setup`

### 2. Include Trigger Keywords in Description

```yaml
# Bad
description: Helps with Minecraft

# Good
description: Implement Minecraft items, blocks, and entities using registry systems. Use when creating custom content, working with registries, or implementing game logic for Forge, Fabric, and Quilt.
```

### 3. Use Progressive Disclosure

Keep SKILL.md concise, link to supporting files:

```markdown
# Minecraft Event System

## Overview
Brief explanation...

## For Detailed Information
- [Forge Events](forge-events.md)
- [Fabric Events](fabric-events.md)
- [Event Examples](examples/events/)
```

Claude loads supporting files only when needed, saving tokens.

### 4. Organize Supporting Files

```
minecraft-api/
├── SKILL.md                  # Main entry point
├── registries/
│   ├── items.md
│   ├── blocks.md
│   └── entities.md
├── events/
│   ├── forge-events.md
│   └── fabric-hooks.md
└── examples/
    ├── custom-item.java
    └── custom-block.java
```

### 5. Include Real Examples

Show actual code, not pseudocode:

```java
// In your ModItems class
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

public static final RegistryObject<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(new Item.Properties()));
```

### 6. Version-Specific Information

Separate content by framework/version when needed:

```
minecraft-api/
├── SKILL.md
└── versions/
    ├── forge-1.20.md
    ├── forge-1.21.md
    ├── fabric-1.20.md
    └── neoforge-1.21.md
```

## Example Skills

See [examples/example-skill/](../examples/example-skill/) for a complete template.

### Suggested Skills for Minecraft Development

1. **minecraft-api**
   - Core Minecraft API knowledge
   - Registry systems
   - Item/block/entity creation

2. **forge-setup**
   - Forge environment setup
   - build.gradle configuration
   - mods.toml setup

3. **gradle-configuration**
   - Gradle for mod development
   - Dependency management
   - Build tasks

4. **mixin-development**
   - Mixin basics and syntax
   - Injection points
   - Common patterns

5. **event-systems**
   - Forge events
   - Fabric hooks
   - Event handling patterns

6. **data-generation**
   - Recipe generation
   - Loot table generation
   - Model/texture generation

7. **networking**
   - Client-server communication
   - Packet creation
   - Data synchronization

8. **performance-optimization**
   - Profiling tools
   - Common bottlenecks
   - Optimization patterns

## How Skills Are Invoked

Claude automatically loads skills when:

1. **Task description matches** skill description keywords
2. **Agent specifies** skills in its configuration
3. **Context suggests** the skill would be helpful

You don't need to explicitly call skills - Claude decides based on relevance.

## Testing Your Skill

1. Create the skill directory and SKILL.md
2. Add comprehensive description with keywords
3. Test by asking Claude tasks that should trigger the skill
4. Verify Claude loads and uses the skill appropriately
5. Check if supporting files are loaded when needed

Example test:
```
"I need to create a custom item in my Forge mod"
→ Should load minecraft-api and forge-setup skills
```

## Skill Size Considerations

- **SKILL.md**: Keep under 2000 lines (for token efficiency)
- **Supporting files**: No strict limit (loaded progressively)
- **Total skill**: Can be very large if well-organized

Claude loads only what it needs from your skill's supporting files.

## Common Mistakes

### ❌ Too Vague
```yaml
description: Minecraft modding knowledge
```

### ✅ Specific and Keyword-Rich
```yaml
description: Create custom items, blocks, and entities in Minecraft mods using registry systems. Covers Forge DeferredRegister, Fabric Registry, and Quilt registries. Use when implementing game content.
```

### ❌ Everything in SKILL.md
A 5000-line SKILL.md with all information.

### ✅ Progressive Disclosure
A concise SKILL.md linking to organized supporting files.

## Next Steps

- Review [examples/example-skill/](../examples/example-skill/)
- Read comprehensive guide in [docs/SKILLS.md](../docs/SKILLS.md)
- Create your first skill for Minecraft APIs

---

**Current Status**: This directory is empty and ready for your custom skills.
