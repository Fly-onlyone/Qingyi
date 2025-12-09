# Supporting File Example

This file demonstrates how to create supporting documentation for skills.

## Purpose

Supporting files provide:
- Detailed reference information
- Extended examples
- Specialized topics
- Version-specific content

## Structure

Organize supporting files by:
- Topic area
- Complexity level
- Framework/version
- Use case

## Content Guidelines

### Be Comprehensive

Include all relevant details that would be too verbose for SKILL.md:

```java
// Detailed implementation with comments
public class DetailedExample {
    /**
     * Comprehensive documentation explaining
     * every parameter, return value, and edge case.
     */
    public void detailedMethod(String param) {
        // Step-by-step implementation
        // with explanations for each line
    }
}
```

### Use Examples

Show real-world usage:

```java
// Real example from actual mod
@EventBusSubscriber(modid = ExampleMod.MODID)
public class ModEvents {
    @SubscribeEvent
    public static void onItemCrafted(PlayerEvent.ItemCraftedEvent event) {
        // Actual event handling logic
    }
}
```

### Link Back to Main Skill

Reference the main skill when appropriate:

> For an overview of this topic, see [SKILL.md](SKILL.md#section)

## File Organization

Create subdirectories for complex topics:

```
example-skill/
├── SKILL.md
├── basics/
│   └── getting-started.md
├── advanced/
│   └── optimization.md
└── reference/
    └── api-docs.md
```

## Progressive Disclosure

Claude loads supporting files only when needed, so:
- Keep SKILL.md concise
- Put details in supporting files
- Link appropriately
- Organize by topic

This saves tokens while maintaining comprehensive coverage.

---

**See also**: [SKILL.md](SKILL.md) for the main skill overview
