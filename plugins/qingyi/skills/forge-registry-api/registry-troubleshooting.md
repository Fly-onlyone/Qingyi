---
name: registry-troubleshooting
description: Comprehensive troubleshooting guide for Forge 1.19-1.20 registry issues. Covers common errors, diagnosis, and solutions.
---

# Registry Troubleshooting Guide

## Error 1: "Registry not found during initialization"

Symptom:
```
[FATAL] Registry not found: mymod:ruby
Exception: Registry not found during initialization
```

Root Cause: DeferredRegister not registered on MOD bus

Solution:
```java
@Mod("mymod")
public class MyMod {
    public MyMod(IEventBus modEventBus) {
        // ADD THIS LINE
        ModItems.register(modEventBus);
        ModBlocks.register(modEventBus);
    }
}
```

## Error 2: NullPointerException on .get()

Symptom:
```
java.lang.NullPointerException: Registry entry not filled
  at ModItems.RUBY.get()
```

Root Cause: Accessing .get() before registration complete

Solution - WRONG:
```java
// CRASHES
public static final Item RUBY = ModItems.RUBY.get();
```

Solution - CORRECT:
```java
public static Item getRuby() {
    return ModItems.RUBY.get(); // Safe during gameplay
}

// Or in event:
modEventBus.addListener(event -> {
    event.enqueueWork(() -> {
        Item ruby = ModItems.RUBY.get();
    });
});
```

## Error 3: Item Shows as Purple/Black Texture

Root Cause: Missing JSON model or texture file

Check files exist:
```
src/main/resources/assets/mymod/
├── models/item/
│   └── ruby.json
└── textures/item/
    └── ruby.png
```

Create model file - ruby.json:
```json
{
  "parent": "item/generated",
  "textures": {
    "layer0": "mymod:item/ruby"
  }
}
```

Create texture: 16x16 PNG file

Register name must match:
```java
ITEMS.register("ruby", () -> new Item(...));
```

## Error 4: Item Not in Creative Tab

Root Cause: Item not added to displayItems

Solution:
```java
.displayItems((params, output) -> {
    // Add this line
    output.accept(ModItems.RUBY.get());
})
```

Verify:
- ModCreativeTabs.register() called in mod constructor
- Tab registered on MOD bus
- output.accept() called for each item

## Error 5: BlockItem Not Working

Root Cause: Block items must be registered separately

WRONG:
```java
ModBlocks.register(modEventBus);
// Block exists, but no block item!
```

CORRECT:
```java
// ModBlocks.java
public static final RegistryObject<Block> RUBY_BLOCK =
    BLOCKS.register("ruby_block", () -> new Block(...));

// ModItems.java
public static final RegistryObject<BlockItem> RUBY_BLOCK_ITEM =
    ITEMS.register("ruby_block", () ->
        new BlockItem(ModBlocks.RUBY_BLOCK.get(), 
            new Item.Properties()));

// MyMod.java
public MyMod(IEventBus modEventBus) {
    ModBlocks.register(modEventBus);
    ModItems.register(modEventBus);
}
```

Block model: src/main/resources/assets/mymod/models/block/ruby_block.json
Item model: src/main/resources/assets/mymod/models/item/ruby_block.json

Item model:
```json
{
  "parent": "block/ruby_block"
}
```

## Error 6: "cannot find symbol: ForgeRegistries"

Root Cause: Wrong imports for version

CORRECT for Forge 1.19-1.20:
```java
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraftforge.registries.DeferredRegister;
```

WRONG for NeoForge:
```java
import net.neoforged.neoforge.registries.ForgeRegistries;
```

## Error 7: Item Name Mismatch

Symptom:
```
Cannot find item: mymod:ruby_ore
```

Root Cause: Registration name doesn't match reference

Check consistency:
```java
// Registration
ITEMS.register("ruby", () -> ...); // Name: "ruby"

// JSON references
"item": "mymod:ruby" // MUST match

// NOT:
"item": "mymod:ruby_ore" // WRONG
```

Naming Rules:
- Use lowercase_snake_case
- Match everywhere: code, JSON, recipes
- Example: ruby_ore (not RubyOre or ruby ore)

## Debugging Techniques

### Print Registry Contents

```java
modEventBus.addListener(event -> {
    event.enqueueWork(() -> {
        System.out.println("=== REGISTERED ITEMS ===");
        for (Item item : ForgeRegistries.ITEMS) {
            System.out.println("  " + 
                ForgeRegistries.ITEMS.getKey(item));
        }
    });
});
```

### Verify RegistryObject State

```java
System.out.println("RUBY present: " + 
    ModItems.RUBY.isPresent());
System.out.println("RUBY value: " + 
    ModItems.RUBY.get());
System.out.println("RUBY name: " + 
    ModItems.RUBY.getRegistryName());
```

## Common Mistakes Checklist

- [ ] DeferredRegister.register(modEventBus) called
- [ ] No .get() in static initializers
- [ ] .get() only called after registration completes
- [ ] Model JSON files exist
- [ ] Texture PNG files exist
- [ ] Registration names use lowercase_snake_case
- [ ] JSON references match registration names
- [ ] BlockItems registered separately
- [ ] CreativeModeTab registered if used

## Quick Fixes

1. Registry not found → Add ModItems.register(modEventBus)
2. NPE on .get() → Use event.enqueueWork()
3. Missing texture → Create JSON and PNG files
4. Item not in tab → Add output.accept() call
5. Block item broken → Register in ITEMS registry
6. Can't find symbol → Update imports

Use this guide to quickly diagnose and fix registry issues.
