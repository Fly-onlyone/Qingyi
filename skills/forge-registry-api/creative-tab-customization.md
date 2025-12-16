---
name: creative-tab-customization
description: Advanced CreativeModeTab configuration for Forge 1.20. Covers custom icons, item ordering, filtering, and multi-tab organization patterns.
---

# Creative Tab Customization

Creative tabs organize items in the creative inventory. Forge 1.20 provides powerful builder APIs.

## Basic Tab Creation

```java
public class ModCreativeTabs {
    public static final DeferredRegister<CreativeModeTab> TABS =
        DeferredRegister.create(Registries.CREATIVE_MODE_TAB, MODID);

    public static final RegistryObject<CreativeModeTab> MOD_TAB =
        TABS.register("mod_tab", () -> CreativeModeTab.builder()
            .title(Component.translatable("itemGroup." + MODID))
            .icon(() -> new ItemStack(ModItems.RUBY.get()))
            .displayItems((params, output) -> {
                output.accept(ModItems.RUBY.get());
                output.accept(ModItems.RUBY_SWORD.get());
            })
            .build());

    public static void register(IEventBus modEventBus) {
        TABS.register(modEventBus);
    }
}
```

## Tab Organization Patterns

### Pattern 1: Category-Based Organization

```java
public static final RegistryObject<CreativeModeTab> MATERIALS_TAB =
    TABS.register("materials", () -> CreativeModeTab.builder()
        .title(Component.translatable("itemGroup.mymod.materials"))
        .icon(() -> new ItemStack(ModItems.RUBY_ORE.get()))
        .displayItems((params, output) -> {
            // Raw Materials
            output.accept(ModItems.RUBY_ORE.get());
            output.accept(ModItems.EMERALD_ORE.get());
            
            // Processed Materials
            output.accept(ModItems.RUBY.get());
            output.accept(ModItems.EMERALD.get());
            
            // Ingots
            output.accept(ModItems.RUBY_INGOT.get());
        })
        .build());
```

### Pattern 2: Tool-Based Organization

```java
public static final RegistryObject<CreativeModeTab> TOOLS_TAB =
    TABS.register("tools", () -> CreativeModeTab.builder()
        .title(Component.translatable("itemGroup.mymod.tools"))
        .icon(() -> new ItemStack(ModItems.MYSTIC_PICKAXE.get()))
        .displayItems((params, output) -> {
            // Pickaxes
            output.accept(ModItems.COPPER_PICKAXE.get());
            output.accept(ModItems.DIAMOND_PICKAXE.get());
            output.accept(ModItems.MYSTIC_PICKAXE.get());
            
            // Axes
            output.accept(ModItems.COPPER_AXE.get());
            output.accept(ModItems.DIAMOND_AXE.get());
            
            // Swords
            output.accept(ModItems.COPPER_SWORD.get());
            output.accept(ModItems.MYSTIC_SWORD.get());
        })
        .build());
```

### Pattern 3: Conditional Display

```java
.displayItems((params, output) -> {
    // Always show
    output.accept(ModItems.RUBY.get());
    
    // Only if config enabled
    if (ModConfig.ENABLE_EXPERIMENTAL.get()) {
        output.accept(ModItems.EXPERIMENTAL_ITEM.get());
    }
    
    // Only if other mod loaded
    if (ModLoader.isModLoaded("other_mod")) {
        output.accept(ModItems.COMPAT_ITEM.get());
    }
})
```

## Multiple Tab Organization

```java
public class ModCreativeTabs {
    public static final DeferredRegister<CreativeModeTab> TABS =
        DeferredRegister.create(Registries.CREATIVE_MODE_TAB, MODID);

    // Materials Tab
    public static final RegistryObject<CreativeModeTab> MATERIALS =
        TABS.register("materials", () -> CreativeModeTab.builder()
            .title(Component.translatable("itemGroup.mymod.materials"))
            .icon(() -> new ItemStack(ModItems.RUBY.get()))
            .displayItems((params, output) -> {
                output.accept(ModItems.RUBY.get());
                output.accept(ModItems.EMERALD.get());
            })
            .build());

    // Equipment Tab
    public static final RegistryObject<CreativeModeTab> EQUIPMENT =
        TABS.register("equipment", () -> CreativeModeTab.builder()
            .title(Component.translatable("itemGroup.mymod.equipment"))
            .icon(() -> new ItemStack(ModItems.HELMET.get()))
            .displayItems((params, output) -> {
                output.accept(ModItems.HELMET.get());
                output.accept(ModItems.CHESTPLATE.get());
                output.accept(ModItems.LEGGINGS.get());
                output.accept(ModItems.BOOTS.get());
            })
            .build());

    public static void register(IEventBus modEventBus) {
        TABS.register(modEventBus);
    }
}
```

## Translations

File: src/main/resources/assets/mymod/lang/en_us.json

```json
{
    "itemGroup.mymod": "My Mod",
    "itemGroup.mymod.materials": "Materials",
    "itemGroup.mymod.equipment": "Equipment"
}
```

## Advanced Patterns

### Item Sorting

```java
.displayItems((params, output) -> {
    List<Item> items = new ArrayList<>();
    items.add(ModItems.EMERALD.get());
    items.add(ModItems.RUBY.get());
    items.add(ModItems.SAPPHIRE.get());
    
    items.sort((a, b) -> 
        a.getDescription().getString()
         .compareTo(b.getDescription().getString())
    );
    
    items.forEach(output::accept);
})
```

### Search Bar Support

```java
.withSearchBar()
.displayItems((params, output) -> {
    String search = params.getSearchTabInfo().getSearchTerm().toLowerCase();
    
    for (Item item : allItems) {
        String name = item.getDescription().getString().toLowerCase();
        if (search.isEmpty() || name.contains(search)) {
            output.accept(item);
        }
    }
})
```

### Enchanted Items

```java
.displayItems((params, output) -> {
    // Regular item
    output.accept(ModItems.RUBY.get());
    
    // Enchanted item
    ItemStack enchanted = new ItemStack(ModItems.SWORD.get());
    enchanted.enchant(Enchantments.BLOCK_EFFICIENCY, 5);
    output.accept(enchanted);
})
```

## Best Practices

1. Use translatable Component for titles
2. Organize by function or rarity
3. Use distinctive icons
4. Keep items under 50 per tab
5. Add language entries
6. Hide unavailable items

Complete CreativeModeTab patterns for Forge 1.20 mods.
