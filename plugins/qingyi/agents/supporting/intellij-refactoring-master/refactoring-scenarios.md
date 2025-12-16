# Refactoring Scenarios - Common Rename Scenarios and Solutions

This guide provides detailed walkthroughs of the most common refactoring scenarios in Minecraft mod development, with complete workflows and code examples.

## Overview

Each scenario includes:
- **Context**: When this scenario applies
- **Initial State**: Code before refactoring
- **Goal**: Desired outcome
- **Workflow**: Step-by-step process
- **Final State**: Code after refactoring
- **Verification**: How to confirm success

---

## Scenario 1: Rename Java Field (Safe)

### Context

Rename a Java constant/field without changing registry name. **Most common and safest** refactoring.

###Initial State

```java
// src/main/java/com/mod/init/ModItems.java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    public static final RegistryObject<Item> RUBY_SWORD = ITEMS.register(
        "ruby_sword",  // Registry name (PERMANENT)
        () -> new SwordItem(ModItemTier.RUBY, 3, -2.4F, new Item.Properties())
    );
}
```

### Goal

Rename Java field `RUBY_SWORD` to `SAPPHIRE_SWORD`, but **keep registry name** as `"ruby_sword"`.

### Workflow

**Step 1: Execute IntelliJ rename**
```
rename_refactoring(
    pathInProject="src/main/java/com/mod/init/ModItems.java",
    symbolName="RUBY_SWORD",
    newName="SAPPHIRE_SWORD"
)

Result: "Renamed successfully, updated 8 occurrences"
```

### Verification

- ✅ All code references updated automatically
- ✅ Registry name unchanged
- ✅ Existing worlds still work

**Time**: ~30 seconds

---

Back to [intellij-refactoring-master.md](../../intellij-refactoring-master.md)
