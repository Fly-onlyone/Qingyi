# Subproject Pattern - Platform Modules

## Purpose

Platform modules (**forge/**, **fabric/**, **neoforge/**) contain loader-specific implementation code, registration, and mod entrypoints.

## What Goes in Platform Modules

### forge/ Module

**Forge Registration**:
```java
// forge/src/main/java/com/mod/forge/ModItemsForge.java
public class ModItemsForge {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MOD_ID);

    // Create instance from common class
    public static final RegistryObject<Item> RUBY_SWORD =
        ITEMS.register("ruby_sword", () -> new RubySword(
            Tiers.IRON, 3, -2.4f, new Item.Properties()
        ));

    public static void register(IEventBus modEventBus) {
        ITEMS.register(modEventBus);
    }
}
```

**Forge Event Handlers**:
```java
// forge/src/main/java/com/mod/forge/ForgeEventHandler.java
@Mod.EventBusSubscriber(modid = MOD_ID, bus = Bus.FORGE)
public class ForgeEventHandler {
    @SubscribeEvent
    public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
        if (event.phase == TickEvent.Phase.END) {
            // Forge-specific event handling
        }
    }
}
```

**Mod Entrypoint**:
```java
// forge/src/main/java/com/mod/forge/MyModForge.java
@Mod(MOD_ID)
public class MyModForge {
    public MyModForge(IEventBus modEventBus) {
        // Register items, blocks, etc.
        ModItemsForge.register(modEventBus);

        // Common init (platform-agnostic)
        MyMod.init();
    }
}
```

### fabric/ Module

**Fabric Registration**:
```java
// fabric/src/main/java/com/mod/fabric/ModItemsFabric.java
public class ModItemsFabric {
    public static final Item RUBY_SWORD = Registry.register(
        Registries.ITEM,
        new Identifier(MOD_ID, "ruby_sword"),
        new RubySword(ToolMaterials.IRON, 3, -2.4f, new Item.Settings())
    );

    public static void register() {
        // Items registered inline above
    }
}
```

**Fabric Event Handlers**:
```java
// fabric/src/main/java/com/mod/fabric/FabricEventHandler.java
public class FabricEventHandler {
    public static void registerEvents() {
        PlayerTickEvents.END.register((player) -> {
            // Fabric-specific event handling
        });
    }
}
```

**Mod Entrypoint**:
```java
// fabric/src/main/java/com/mod/fabric/MyModFabric.java
public class MyModFabric implements ModInitializer {
    @Override
    public void onInitialize() {
        // Register items, blocks, etc.
        ModItemsFabric.register();
        FabricEventHandler.registerEvents();

        // Common init (platform-agnostic)
        MyMod.init();
    }
}
```

## Platform Service Implementations

### Forge Implementation

```java
// forge/src/main/java/com/mod/forge/platform/ForgePlatformHelper.java
public class ForgePlatformHelper implements PlatformHelper {
    @Override
    public Platform getPlatform() {
        return Platform.FORGE;
    }

    @Override
    public boolean isPhysicalClient() {
        return FMLLoader.getDist() == Dist.CLIENT;
    }

    @Override
    public String getModVersion() {
        return ModList.get().getModContainerById(MOD_ID)
            .map(c -> c.getModInfo().getVersion().toString())
            .orElse("UNKNOWN");
    }

    @Override
    public Path getConfigDirectory() {
        return FMLPaths.CONFIGDIR.get();
    }
}
```

**Service Registration** (`forge/src/main/resources/META-INF/services/com.mod.platform.PlatformHelper`):
```
com.mod.forge.platform.ForgePlatformHelper
```

### Fabric Implementation

```java
// fabric/src/main/java/com/mod/fabric/platform/FabricPlatformHelper.java
public class FabricPlatformHelper implements PlatformHelper {
    @Override
    public Platform getPlatform() {
        return Platform.FABRIC;
    }

    @Override
    public boolean isPhysicalClient() {
        return FabricLoader.getInstance().getEnvironmentType() == EnvType.CLIENT;
    }

    @Override
    public String getModVersion() {
        return FabricLoader.getInstance().getModContainer(MOD_ID)
            .map(c -> c.getMetadata().getVersion().getFriendlyString())
            .orElse("UNKNOWN");
    }

    @Override
    public Path getConfigDirectory() {
        return FabricLoader.getInstance().getConfigDir();
    }
}
```

**Service Registration** (`fabric/src/main/resources/META-INF/services/com.mod.platform.PlatformHelper`):
```
com.mod.fabric.platform.FabricPlatformHelper
```

## Directory Structure

### Forge Module
```
forge/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/mod/forge/
│       │       ├── MyModForge.java       # Entrypoint (@Mod)
│       │       ├── ModItemsForge.java    # Item registration
│       │       ├── ModBlocksForge.java   # Block registration
│       │       ├── ForgeEventHandler.java # Event handlers
│       │       └── platform/             # Service implementations
│       │           └── ForgePlatformHelper.java
│       └── resources/
│           ├── META-INF/
│           │   ├── mods.toml             # Forge mod metadata
│           │   └── services/             # ServiceLoader registration
│           │       └── com.mod.platform.PlatformHelper
│           └── pack.mcmeta
└── build.gradle
```

### Fabric Module
```
fabric/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/mod/fabric/
│       │       ├── MyModFabric.java      # Entrypoint (ModInitializer)
│       │       ├── ModItemsFabric.java   # Item registration
│       │       ├── ModBlocksFabric.java  # Block registration
│       │       ├── FabricEventHandler.java # Event handlers
│       │       └── platform/             # Service implementations
│       │           └── FabricPlatformHelper.java
│       └── resources/
│           ├── fabric.mod.json           # Fabric mod metadata
│           ├── META-INF/
│           │   └── services/             # ServiceLoader registration
│           │       └── com.mod.platform.PlatformHelper
│           └── pack.mcmeta
└── build.gradle
```

## Build Configuration

Each platform module depends on common:

**forge/build.gradle**:
```groovy
dependencies {
    // Common module
    implementation project(':common')

    // Forge dependencies
    minecraft "net.minecraftforge:forge:${minecraft_version}-${forge_version}"
}
```

**fabric/build.gradle**:
```groovy
dependencies {
    // Common module
    implementation project(':common')

    // Fabric dependencies
    modImplementation "net.fabricmc:fabric-loader:${loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:${fabric_version}"
}
```

## Common Patterns

### Pattern 1: Delegated Registration

**Common** defines class:
```java
// common/.../RubyBlock.java
public class RubyBlock extends Block {
    public RubyBlock(Properties properties) {
        super(properties);
    }
}
```

**Forge** registers:
```java
// forge/.../ModBlocksForge.java
public static final RegistryObject<Block> RUBY_BLOCK =
    BLOCKS.register("ruby_block", () -> new RubyBlock(
        BlockBehaviour.Properties.of()
            .strength(3.0f)
            .requiresCorrectToolForDrops()
    ));
```

**Fabric** registers:
```java
// fabric/.../ModBlocksFabric.java
public static final Block RUBY_BLOCK = Registry.register(
    Registries.BLOCK,
    new Identifier(MOD_ID, "ruby_block"),
    new RubyBlock(AbstractBlock.Settings.create()
        .strength(3.0f)
        .requiresTool()
    )
);
```

### Pattern 2: Config Access

**Common** defines interface:
```java
public interface ConfigHelper {
    int getMaxEnergy();
    boolean isFeatureEnabled();
}
```

**Forge** implements with ForgeConfigSpec:
```java
public class ForgeConfigHelper implements ConfigHelper {
    @Override
    public int getMaxEnergy() {
        return ServerConfig.MAX_ENERGY.get();
    }
}
```

**Fabric** implements with custom config:
```java
public class FabricConfigHelper implements ConfigHelper {
    @Override
    public int getMaxEnergy() {
        return FabricConfig.maxEnergy;
    }
}
```

## Best Practices

### ✅ Keep Platform Code Minimal

Platform modules should be **thin wrappers** around common code:
```java
// ✅ GOOD - Minimal platform code
@Mod(MOD_ID)
public class MyModForge {
    public MyModForge(IEventBus modEventBus) {
        ModItemsForge.register(modEventBus);
        MyMod.init();  // Delegate to common
    }
}
```

```java
// ❌ BAD - Duplicated logic in platform
@Mod(MOD_ID)
public class MyModForge {
    public MyModForge(IEventBus modEventBus) {
        // Don't duplicate game logic here!
        int powerLevel = calculatePower(...);  // Should be in common!
    }
}
```

### ✅ Mirror Structure Across Platforms

Keep forge/ and fabric/ organized identically:
```
forge/                          fabric/
├── MyModForge.java     →      ├── MyModFabric.java
├── ModItemsForge.java  →      ├── ModItemsFabric.java
├── ForgeEventHandler   →      ├── FabricEventHandler
└── platform/           →      └── platform/
```

### ✅ Use Common for Entrypoint Logic

```java
// ✅ GOOD - Logic in common/
// common/.../MyMod.java
public class MyMod {
    public static void init() {
        LOGGER.info("Mod initializing...");
        FeatureManager.setup();
        // All initialization logic here
    }
}

// forge/.../MyModForge.java
@Mod(MOD_ID)
public class MyModForge {
    public MyModForge(IEventBus modEventBus) {
        ModItemsForge.register(modEventBus);
        MyMod.init();  // Just call common init
    }
}

// fabric/.../MyModFabric.java
public class MyModFabric implements ModInitializer {
    @Override
    public void onInitialize() {
        ModItemsFabric.register();
        MyMod.init();  // Same common init
    }
}
```

---

**Related**:
- [Common Code Pattern](./common-code-pattern.md) - What goes in common/
- [ServiceLoader Pattern](../platform-abstraction/serviceloader-pattern.md) - Service implementation
- [Forge Specifics](../framework-specific/forge-specifics.md) - Forge registration details
- [Fabric Specifics](../framework-specific/fabric-specifics.md) - Fabric registration details
