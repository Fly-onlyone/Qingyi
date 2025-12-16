---
name: deferred-register-deep-dive
description: Complete lifecycle and mechanics of DeferredRegister in Forge 1.19-1.20. Essential reading for registry implementation and troubleshooting.
---

# DeferredRegister Deep Dive

## Overview

DeferredRegister is the core registration system in Forge 1.19-1.20. It provides type-safe, lazy-loaded registry entries with automatic lifecycle management. Understanding how it works is critical to successful Minecraft mod development.

**Key Promise**: DeferredRegister ensures items/blocks/entities are registered at the correct time with thread-safe access patterns.

---

## The Three Phases of DeferredRegister

### Phase 1: Creation (Static Initialization)

```java
// In your ModItems class
public class ModItems {
    // Step 1: Create the DeferredRegister instance
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    // Step 2: Register entries during class loading
    public static final RegistryObject<Item> RUBY =
        ITEMS.register("ruby", () -> new Item(new Item.Properties()));

    public static final RegistryObject<Item> EMERALD =
        ITEMS.register("emerald", () -> new Item(new Item.Properties()));
}
```

**What Happens**:
1. `DeferredRegister.create()` creates an empty holder that won't load the registry yet
2. Each `.register()` call adds an entry to an internal queue
3. No actual registration occurs - items are not created
4. RegistryObject acts as a lazy reference to the eventual item

**Why This Matters**: This separation of declaration from registration allows the mod system to control when registries load, preventing crashes from accessing items before the registry is ready.

---

## The Three Phase Lifecycle

### Phase 2: Wiring to Event Bus (Mod Constructor)

```java
@Mod("mymod")
public class MyMod {
    public static final String MODID = "mymod";

    public MyMod(IEventBus modEventBus) {
        // This line connects the DeferredRegister to the event system
        ModItems.register(modEventBus);
        ModBlocks.register(modEventBus);
    }
}
```

When `.register(modEventBus)` is called, DeferredRegister subscribes to the MOD bus and waits for RegistryEvent.

### Phase 3: Registration and Retrieval (During Gameplay)

```java
// During RegistryEvent, items are created and registered
// After that, safe to use:
Item myRuby = ModItems.RUBY.get();
```

---

## Complete Workflow Example

From Forge 1.20 mod with items, blocks, and entities:

```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    public static final RegistryObject<Item> RUBY =
        ITEMS.register("ruby", () -> new Item(
            new Item.Properties().stacksTo(64)
        ));

    public static final RegistryObject<SwordItem> RUBY_SWORD =
        ITEMS.register("ruby_sword", () -> new SwordItem(
            Tiers.IRON, 3, -2.4f,
            new Item.Properties().stacksTo(1)
        ));

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}

@Mod("mymod")
public class MyMod {
    public MyMod(IEventBus modEventBus) {
        ModItems.register(modEventBus);
        modEventBus.addListener(this::commonSetup);
    }

    private void commonSetup(FMLCommonSetupEvent event) {
        event.enqueueWork(() -> {
            Item ruby = ModItems.RUBY.get(); // Safe access
        });
    }
}
```

---

## Best Practices

1. Always use DeferredRegister for game content
2. Register on MOD bus in mod constructor
3. Access .get() only after FMLCommonSetupEvent
4. Use RegistryObject as class fields
5. Register block items separately in ITEMS registry
6. Thread-safe access via event.enqueueWork()

This is comprehensive coverage of DeferredRegister mechanics in Forge 1.19-1.20.
