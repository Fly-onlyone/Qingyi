---
name: minecraft-tutorial-patterns
description: Educational tutorial patterns for Minecraft modding. Covers difficulty levels (beginner to expert), tutorial structure templates, hands-on exercises, common mistakes, framework comparisons, progressive learning paths. Use when creating learning materials, onboarding content, or feature implementation guides.
---

# Minecraft Tutorial Patterns

## Difficulty Levels (Quick Reference)

| Level | Target Audience | Topics | Estimated Time |
|-------|----------------|--------|----------------|
| **Beginner** | New to modding, basic Java | First item/block, lang files, textures | 30-60 min |
| **Intermediate** | Understands registration | Events, NBT, GUIs, recipes, datagen | 45-90 min |
| **Advanced** | Comfortable with events/NBT | Entities, AI, packets, multiblocks, rendering | 2-4 hours |
| **Expert** | Experienced modders | Multi-loader, optimization, shaders, libraries | 4-6 hours |

**Detailed breakdowns**: See [Difficulty Level Guides](./guides/difficulty-levels.md)

---

## Tutorial Structure Template

```markdown
# Tutorial: [Topic Name]

## Prerequisites
- Required knowledge or setup

## Learning Objectives
- [ ] Objective 1
- [ ] Objective 2

## Estimated Time: [X minutes/hours]

## Concept Overview
[Brief explanation...]

## Real-World Use Case
[Examples from actual mods...]

## Implementation Steps
### Step 1: [First Step]
[Code and explanation...]

### Step 2: [Second Step]
[Building on Step 1...]

## Framework Comparison
**Forge**: [approach]
**Fabric**: [approach]

## Common Mistakes
❌ Mistake 1: [fix]
❌ Mistake 2: [fix]

## Testing Checklist
- [ ] Test case 1
- [ ] Test case 2

## Practice Exercise
[Extension challenge...]

## Next Steps
- Learn [related topic]
- Build [project idea]
```

---

## Common Mistakes (Essential)

### Registry Names (Beginner)
```java
// ❌ Wrong: Uppercase
ITEMS.register("CustomItem", ...)

// ✅ Correct: snake_case
ITEMS.register("custom_item", ...)
```
**Why**: Resource locations require lowercase

### Client Code on Server (All Levels)
```java
// ❌ Wrong: Crashes dedicated server
Minecraft.getInstance().player.sendMessage(...);

// ✅ Correct: Check side
if (level.isClientSide) {
    // Client-only code
}
```
**Why**: `Minecraft.getInstance()` doesn't exist on servers (#1 crash cause)

### Missing Resources (Beginner)
**Symptom**: Purple/black checkerboard texture

**Fix**: Create matching files:
- `assets/modid/models/item/name.json`
- `assets/modid/textures/item/name.png`
- `assets/modid/lang/en_us.json`

**Complete mistakes catalog**: [Common Mistakes Database](./guides/common-mistakes.md)

---

## Framework Comparison Pattern

**When features differ, show both side-by-side**:

### Example: Item Registration

**Forge/NeoForge**:
```java
public static final RegistryObject<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(new Item.Properties()));
```
**Pros**: Type-safe, automatic naming
**Cons**: More boilerplate, indirect access

**Fabric**:
```java
public static final Item RUBY = Registry.register(
    Registries.ITEM, new Identifier(MODID, "ruby"), new Item(new Item.Settings())
);
```
**Pros**: Simpler, direct access
**Cons**: Manual Identifier, order critical

**Detailed comparisons**: [Framework Comparison Guides](./guides/framework-comparisons.md)

---

## Hands-On Exercise Patterns

### Fill-in-the-Blank
```java
// Exercise: Complete registration
public static final RegistryObject<Item> ITEM =
    ITEMS.register("_____", () -> new Item(
        new Item.Properties().stacksTo(_____)
    ));
```

### Bug Hunt
Provide broken code, students identify and fix issues.

### Feature Extension
Build on tutorial to add new features.

**Complete exercise templates**: [Exercise Templates](./guides/exercise-templates.md)

---

## Tutorial Best Practices

1. **Prerequisites** - List required knowledge
2. **Clear Objectives** - Checkboxes for measurable outcomes
3. **Time Estimate** - Help students plan
4. **Incremental** - Each step builds on previous
5. **Framework Comparison** - Show both when different
6. **Common Mistakes** - Save frustration
7. **Testing Steps** - Verify it works
8. **Extensions** - Challenge exercises
9. **Real Code** - No placeholders or pseudocode
10. **Explain Why** - Design decisions, not just code

---

## Progressive Learning Path

```
Beginner Path:
1. First item → Simple block → Textures/models → Recipes

Intermediate Path:
2. Event handlers → NBT storage → Custom GUIs → Data generation

Advanced Path:
3. Custom entities → Client/server packets → Complex systems

Expert Path:
4. Multi-loader support → Performance optimization → External libraries
```

---

## Anti-Patterns to Avoid

- ❌ Jumping to advanced code without foundation
- ❌ Assuming framework-specific knowledge
- ❌ Outdated API examples
- ❌ Mixing Forge/Fabric without clear labels
- ❌ Omitting client/server separation warnings
- ❌ Forgetting resource file requirements
- ❌ No testing or verification steps

---

## Quick Example: First Item Tutorial

**Prerequisites**: Java 17, IDE, basic Java knowledge

**Objectives**:
- [ ] Register custom item
- [ ] Create model and texture
- [ ] Add translation
- [ ] Test in-game

**Time**: 30 minutes

**Registration** (Forge):
```java
public static final RegistryObject<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(new Item.Properties()));
```

**Registration** (Fabric):
```java
public static final Item RUBY = Registry.register(
    Registries.ITEM, new Identifier(MODID, "ruby"), new Item(new Item.Settings())
);
```

**Resources Required**:
- `assets/modid/models/item/ruby.json`
- `assets/modid/textures/item/ruby.png`
- `assets/modid/lang/en_us.json` → `"item.modid.ruby": "Ruby"`

**Test**: `/give @s modid:ruby`

**Complete example**: [First Item Tutorial](./examples/first-item-tutorial.md)

---

## Detailed Guides

### Core Guides
- **[Difficulty Level Guides](./guides/difficulty-levels.md)** - Detailed breakdown of each level with learning outcomes and topics
- **[Tutorial Structure Guide](./guides/tutorial-structure.md)** - Step-by-step guide for creating effective tutorials
- **[Exercise Templates](./guides/exercise-templates.md)** - Complete collection of hands-on exercise patterns

### Reference Materials
- **[Common Mistakes Database](./guides/common-mistakes.md)** - Comprehensive error catalog organized by difficulty level
- **[Framework Comparison Guides](./guides/framework-comparisons.md)** - Side-by-side Forge vs Fabric patterns for all major features
- **[Testing Strategies](./guides/testing-strategies.md)** - How to verify tutorials work correctly

### Complete Examples
- **[First Item Tutorial](./examples/first-item-tutorial.md)** - Complete beginner example
- **[Event Handler Tutorial](./examples/event-handler-tutorial.md)** - Intermediate example
- **[Custom Entity Tutorial](./examples/custom-entity-tutorial.md)** - Advanced example

---

Use this skill when creating educational content to ensure tutorials are structured, progressive, and effective for learners at all skill levels.
