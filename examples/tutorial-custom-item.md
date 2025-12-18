# Example: minecraft-tutorial-engineer Output

This is an example tutorial created by the `minecraft-tutorial-engineer` agent.

---

# Tutorial: Creating Your First Custom Item

## Overview
- **Difficulty**: Beginner
- **Framework**: Forge 1.20.1
- **Time Estimate**: 30 minutes
- **Prerequisites**: Basic Java knowledge, mod development environment set up

## Learning Objectives
By the end of this tutorial, you will:
- [ ] Understand how item registration works in Forge
- [ ] Create a custom item with properties
- [ ] Add textures and models for your item
- [ ] Add language translations
- [ ] Test your item in-game

---

## Concepts Explained

### What is Item Registration?
In Minecraft, every item, block, and entity must be **registered** with the game before it can be used. Registration tells Minecraft:
- What your item is called (registry name)
- How to create instances of it
- When to initialize it

### Why DeferredRegister?
Forge uses `DeferredRegister` to ensure items are registered at the correct time. Without it:
- Items might be registered before Minecraft is ready
- Items might not be registered at all
- Crashes can occur

Think of `DeferredRegister` as a "to-do list" that Forge processes at the right moment.

---

## Step-by-Step Implementation

### Step 1: Create the Items Registry Class

Create a new class to hold all your item registrations.

```java
// src/main/java/com/yourmod/init/ModItems.java
package com.yourmod.init;

import com.yourmod.YourMod;
import net.minecraft.world.item.Item;
import net.minecraftforge.eventbus.api.IEventBus;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.RegistryObject;

public class ModItems {
    // Create a DeferredRegister for items
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, YourMod.MODID);

    // Register your first item!
    public static final RegistryObject<Item> RUBY =
        ITEMS.register("ruby", () -> new Item(new Item.Properties()));

    // Method to register with the event bus
    public static void register(IEventBus eventBus) {
        ITEMS.register(eventBus);
    }
}
```

**What this does**:
- `DeferredRegister.create()` - Creates a registration queue for items
- `ITEMS.register()` - Adds an item to the queue with name "ruby"
- `new Item(new Item.Properties())` - Creates a simple item with default properties

### Step 2: Register Items in Main Mod Class

Update your main mod class to call the registration.

```java
// src/main/java/com/yourmod/YourMod.java
package com.yourmod;

import com.yourmod.init.ModItems;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;

@Mod(YourMod.MODID)
public class YourMod {
    public static final String MODID = "yourmod";

    public YourMod() {
        // Get the mod event bus
        var modEventBus = FMLJavaModLoadingContext.get().getModEventBus();

        // Register items
        ModItems.register(modEventBus);
    }
}
```

**What this does**:
- Gets the mod event bus (Forge's event system)
- Calls `ModItems.register()` to queue item registrations
- Forge processes the queue during mod loading

### Step 3: Create Item Model

Create a model JSON file for your item.

```json
// src/main/resources/assets/yourmod/models/item/ruby.json
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "yourmod:item/ruby"
  }
}
```

**What this does**:
- `parent`: Uses Minecraft's standard item rendering
- `textures.layer0`: Points to your texture file

### Step 4: Add Texture

Place your texture image at:
```
src/main/resources/assets/yourmod/textures/item/ruby.png
```

**Requirements**:
- PNG format
- 16x16 pixels (or 32x32 for higher resolution)
- Transparent background (optional)

### Step 5: Add Language Translation

Create or update your language file:

```json
// src/main/resources/assets/yourmod/lang/en_us.json
{
  "item.yourmod.ruby": "Ruby"
}
```

**Format**: `item.<modid>.<item_name>`

### Step 6: Add to Creative Tab (Optional)

To make your item appear in the creative menu:

```java
// In ModItems.java, modify the registration:
public static final RegistryObject<Item> RUBY =
    ITEMS.register("ruby", () -> new Item(
        new Item.Properties()
            // Add to ingredients tab
    ));
```

Or create a custom creative tab (see advanced section).

---

## Common Mistakes

### Mistake 1: Forgetting to Call register()

```java
// WRONG - Items never registered!
public class YourMod {
    public YourMod() {
        // Missing: ModItems.register(modEventBus);
    }
}
```

**Symptom**: Item doesn't exist in-game, no errors in console.

```java
// CORRECT
public class YourMod {
    public YourMod() {
        var modEventBus = FMLJavaModLoadingContext.get().getModEventBus();
        ModItems.register(modEventBus); // Don't forget this!
    }
}
```

### Mistake 2: Wrong Registry Name Format

```java
// WRONG - Capital letters not allowed!
ITEMS.register("Ruby", () -> ...);

// WRONG - Spaces not allowed!
ITEMS.register("red ruby", () -> ...);

// CORRECT - lowercase with underscores
ITEMS.register("ruby", () -> ...);
ITEMS.register("red_ruby", () -> ...);
```

**Registry names must be**:
- Lowercase only
- No spaces (use underscores)
- No special characters

### Mistake 3: Wrong Model File Location

```
WRONG: assets/yourmod/model/item/ruby.json
                       ^^^^^ (missing 's')

CORRECT: assets/yourmod/models/item/ruby.json
                        ^^^^^^
```

**Remember**: It's `models` (plural), not `model`.

---

## Hands-On Exercise

### Challenge: Create a Custom Gem Set

**Task**: Create three gem items with different rarities:
1. `amethyst_shard` - Common (white name)
2. `sapphire` - Uncommon (yellow name)
3. `emerald_crystal` - Rare (aqua name)

**Hints**:
1. Use `Item.Properties().rarity(Rarity.UNCOMMON)` for rarity
2. Each item needs its own texture and model
3. Add all three to the language file

**Starter Code**:
```java
public static final RegistryObject<Item> AMETHYST_SHARD =
    ITEMS.register("amethyst_shard", () -> new Item(
        new Item.Properties()
        // TODO: Set rarity
    ));

// TODO: Add SAPPHIRE and EMERALD_CRYSTAL
```

**Checklist**:
- [ ] Three items registered
- [ ] Correct rarities applied
- [ ] Three textures created (16x16 PNG)
- [ ] Three model files created
- [ ] Language translations added

<details>
<summary>Click for Solution</summary>

```java
public static final RegistryObject<Item> AMETHYST_SHARD =
    ITEMS.register("amethyst_shard", () -> new Item(
        new Item.Properties() // Common by default
    ));

public static final RegistryObject<Item> SAPPHIRE =
    ITEMS.register("sapphire", () -> new Item(
        new Item.Properties().rarity(Rarity.UNCOMMON)
    ));

public static final RegistryObject<Item> EMERALD_CRYSTAL =
    ITEMS.register("emerald_crystal", () -> new Item(
        new Item.Properties().rarity(Rarity.RARE)
    ));
```

Language file:
```json
{
  "item.yourmod.amethyst_shard": "Amethyst Shard",
  "item.yourmod.sapphire": "Sapphire",
  "item.yourmod.emerald_crystal": "Emerald Crystal"
}
```
</details>

---

## Summary

You've learned how to:
- Create a `DeferredRegister` for items
- Register items with the mod event bus
- Create item models and textures
- Add language translations
- Avoid common registration mistakes

## Next Steps

- **Tutorial: Custom Item Properties** - Add durability, food, tools
- **Tutorial: Creative Tabs** - Organize your items
- **Tutorial: Custom Item Classes** - Items with special behavior

---

*Generated by minecraft-tutorial-engineer agent*
