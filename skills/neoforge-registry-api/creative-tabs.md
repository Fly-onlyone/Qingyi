---
name: creative-tabs
description: Creative tab configuration for NeoForge 1.20-1.21. Same API as Forge with examples.
---

# Creative Tabs in NeoForge

NeoForge 1.20+ uses the same CreativeModeTab API as Forge 1.20.

## Basic Tab Creation

```java
public class ModCreativeTabs {
    public static final DeferredRegister<CreativeModeTab> TABS =
        DeferredRegister.create(Registries.CREATIVE_MODE_TAB, MODID);

    public static final Supplier<CreativeModeTab> MOD_TAB =
        TABS.register("mod_tab", () -> CreativeModeTab.builder()
            .title(Component.literal("My Mod"))
            .icon(() -> new ItemStack(ModItems.RUBY.get()))
            .displayItems((params, output) -> {
                output.accept(ModItems.RUBY.get());
                output.accept(ModItems.SWORD.get());
            })
            .build());

    public static void register(IEventBus modEventBus) {
        TABS.register(modEventBus);
    }
}
```

## Supplier Return Type

NeoForge returns Supplier instead of RegistryObject:

```java
// NeoForge
public static final Supplier<CreativeModeTab> MOD_TAB = ...

// Access is the same
CreativeModeTab tab = ModCreativeTabs.MOD_TAB.get();
```

## Multiple Tabs

```java
public class ModCreativeTabs {
    public static final DeferredRegister<CreativeModeTab> TABS =
        DeferredRegister.create(Registries.CREATIVE_MODE_TAB, MODID);

    // Materials Tab
    public static final Supplier<CreativeModeTab> MATERIALS =
        TABS.register("materials", () -> CreativeModeTab.builder()
            .title(Component.literal("Materials"))
            .icon(() -> new ItemStack(ModItems.RUBY.get()))
            .displayItems((params, output) -> {
                output.accept(ModItems.RUBY.get());
                output.accept(ModItems.EMERALD.get());
            })
            .build());

    // Tools Tab
    public static final Supplier<CreativeModeTab> TOOLS =
        TABS.register("tools", () -> CreativeModeTab.builder()
            .title(Component.literal("Tools"))
            .icon(() -> new ItemStack(ModItems.PICKAXE.get()))
            .displayItems((params, output) -> {
                output.accept(ModItems.PICKAXE.get());
                output.accept(ModItems.AXE.get());
                output.accept(ModItems.SWORD.get());
            })
            .build());

    public static void register(IEventBus modEventBus) {
        TABS.register(modEventBus);
    }
}
```

## Translatable Tabs

```java
.title(Component.translatable("itemGroup." + MODID + ".materials"))
```

Add to language file:
```json
{
    "itemGroup.mymod.materials": "Materials"
}
```

## Icon Customization

```java
// Simple item
.icon(() -> new ItemStack(ModItems.RUBY.get()))

// Enchanted
.icon(() -> {
    ItemStack icon = new ItemStack(ModItems.RUBY.get());
    icon.addTagElement(ItemStack.TAG_ENCHANTMENTS, new CompoundTag());
    return icon;
})

// Block
.icon(() -> new ItemStack(ModBlocks.RUBY_BLOCK.get()))
```

## Conditional Display

```java
.displayItems((params, output) -> {
    output.accept(ModItems.RUBY.get());
    
    // Only if enabled
    if (ModConfig.SHOW_SPECIAL.get()) {
        output.accept(ModItems.SPECIAL_ITEM.get());
    }
})
```

## Differences from Forge

| Feature | Forge 1.20 | NeoForge 1.20+ |
|---------|-----------|----------------|
| API | CreativeModeTab.Builder | CreativeModeTab.Builder |
| Return type | RegistryObject | Supplier |
| Access | .get() | .get() |
| Registry | Registries.CREATIVE_MODE_TAB | Registries.CREATIVE_MODE_TAB |

The builder API is identical. Only return type differs.

## Complete Example

```java
@Mod(MODID)
public class MyMod {
    public static final String MODID = "mymod";

    public MyMod(IEventBus modEventBus) {
        ModItems.register(modEventBus);
        ModCreativeTabs.register(modEventBus);
        modEventBus.addListener(this::commonSetup);
    }

    private void commonSetup(FMLCommonSetupEvent event) {
        event.enqueueWork(() -> {
            // Register recipes, etc.
        });
    }
}

public class ModCreativeTabs {
    public static final DeferredRegister<CreativeModeTab> TABS =
        DeferredRegister.create(Registries.CREATIVE_MODE_TAB, MyMod.MODID);

    public static final Supplier<CreativeModeTab> MAIN_TAB =
        TABS.register("main", () -> CreativeModeTab.builder()
            .title(Component.translatable("itemGroup.mymod"))
            .icon(() -> new ItemStack(ModItems.MAIN_ICON.get()))
            .displayItems((params, output) -> {
                output.accept(ModItems.RUBY.get());
                output.accept(ModItems.EMERALD.get());
                output.accept(ModItems.SWORD.get());
                output.accept(ModItems.HELMET.get());
            })
            .build());

    public static void register(IEventBus modEventBus) {
        TABS.register(modEventBus);
    }
}
```

Creative tabs in NeoForge use the same builder pattern as Forge.
