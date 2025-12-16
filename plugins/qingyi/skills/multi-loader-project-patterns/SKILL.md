---
name: multi-loader-project-patterns
description: Multi-loader Minecraft mod architecture. Covers Common/Forge/Fabric patterns, module organization, platform services, ServiceLoader, @ExpectPlatform, gradle setup. Use when working with multi-loader projects or planning cross-platform mods.
allowed-tools: mcp__intellij__get_project_modules, Read
---

# Multi-Loader Project Patterns

## What This Covers

- Multi-loader architecture (Common/Forge/Fabric modules)
- Module organization and code placement
- Platform abstraction (ServiceLoader, @ExpectPlatform)
- Multi-loader project detection
- Module responsibility patterns

## When to Use

- Building mods that support multiple loaders (Forge, NeoForge, Fabric, Quilt)
- Converting single-loader mod to multi-loader
- Analyzing multi-loader project structure
- Determining where code belongs in multi-loader projects
- Implementing platform abstraction layers

---

## Multi-Loader Architecture Overview

### What Is Multi-Loader?

Multi-loader projects allow a single mod to run on multiple mod loaders from a shared codebase:
- **Forge** / **NeoForge** (ModLoader, widely used)
- **Fabric** / **Quilt** (Lightweight, fast development)

**Benefits**:
- ✅ Wider audience (2x or more players)
- ✅ Shared codebase (less duplication)
- ✅ Write once, deploy everywhere

**Challenges**:
- ⚠️ Platform abstraction required
- ⚠️ More complex build setup
- ⚠️ Must test on each platform

### Common Architecture Pattern

```
mymod/
├── common/      (Shared code, platform-agnostic)
├── forge/       (Forge-specific implementation)
└── fabric/      (Fabric-specific implementation)
```

**Alternative**: Use Architectury framework for additional abstraction helpers

---

## Module Organization

### The Common Module

**Purpose**: Platform-agnostic code that works everywhere

**What Goes in common/**:
- ✅ Item/Block/Entity **classes** (logic, not registration)
- ✅ Shared game mechanics and algorithms
- ✅ Data models (NBT structures, save data)
- ✅ Utility classes (helpers, constants)
- ✅ Service **interfaces** (platform abstraction)

**What DOESN'T Go in common/**:
- ❌ Registry code (DeferredRegister, Registry.register)
- ❌ Event handlers (@SubscribeEvent, event registration)
- ❌ Platform-specific APIs (Forge/Fabric exclusive features)

**Example**:
```java
// common/src/main/java/com/mod/items/RubySword.java
public class RubySword extends SwordItem {
    public RubySword(Tier tier, int attackDamage, float attackSpeed, Properties properties) {
        super(tier, attackDamage, attackSpeed, properties);
    }

    @Override
    public InteractionResultHolder<ItemStack> use(Level level, Player player, InteractionHand hand) {
        // Shared logic works on all platforms
        if (!level.isClientSide) {
            player.addEffect(new MobEffectInstance(MobEffects.LUCK, 200));
        }
        return super.use(level, player, hand);
    }
}
```

### Platform Modules (Forge/Fabric)

**Purpose**: Platform-specific code and registration

**What Goes in forge/**:
- ✅ Forge registration (DeferredRegister)
- ✅ Forge events (@SubscribeEvent)
- ✅ Mod entrypoint (class with @Mod annotation)
- ✅ Platform **implementation** of services

**What Goes in fabric/**:
- ✅ Fabric registration (Registry.register)
- ✅ Fabric events (event callback registration)
- ✅ Mod entrypoint (implements ModInitializer)
- ✅ Platform **implementation** of services

**Example (Forge)**:
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
}
```

**Example (Fabric)**:
```java
// fabric/src/main/java/com/mod/fabric/ModItemsFabric.java
public class ModItemsFabric {
    public static final Item RUBY_SWORD = Registry.register(
        Registries.ITEM,
        new Identifier(MOD_ID, "ruby_sword"),
        new RubySword(ToolMaterials.IRON, 3, -2.4f, new Item.Settings())
    );
}
```

---

## Platform Abstraction

### The Problem

Different mod loaders have different APIs:

```java
// Forge: Get current platform
FMLLoader.getDist() == Dist.CLIENT

// Fabric: Get current platform
FabricLoader.getInstance().getEnvironmentType() == EnvType.CLIENT
```

**Can't use Forge code in common/**, and **can't use Fabric code in common/**!

### Solution: Service Interfaces + ServiceLoader

**Step 1: Define interface in common/**:
```java
// common/src/main/java/com/mod/platform/PlatformHelper.java
public interface PlatformHelper {
    Platform getPlatform();
    boolean isPhysicalClient();
    String getModVersion();
}

public enum Platform {
    FORGE, NEOFORGE, FABRIC, QUILT
}
```

**Step 2: Implement in forge/**:
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
}
```

**Step 3: Implement in fabric/**:
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
}
```

**Step 4: Register services** (in META-INF/services/):

**Forge**:
```
forge/src/main/resources/META-INF/services/com.mod.platform.PlatformHelper

Content:
com.mod.forge.platform.ForgePlatformHelper
```

**Fabric**:
```
fabric/src/main/resources/META-INF/services/com.mod.platform.PlatformHelper

Content:
com.mod.fabric.platform.FabricPlatformHelper
```

**Step 5: Use in common/**:
```java
// common/src/main/java/com/mod/MyMod.java
public class MyMod {
    private static final PlatformHelper PLATFORM = loadPlatformHelper();

    private static PlatformHelper loadPlatformHelper() {
        return ServiceLoader.load(PlatformHelper.class)
            .findFirst()
            .orElseThrow(() -> new RuntimeException("No platform helper found!"));
    }

    public static void init() {
        LOGGER.info("Running on platform: {}", PLATFORM.getPlatform());

        if (PLATFORM.isPhysicalClient()) {
            // Client-specific init
        }
    }
}
```

**For @ExpectPlatform pattern (Architectury)**: See [platform-abstraction.md](./platform-abstraction.md)

---

## Multi-Loader Project Detection

### Using IntelliJ MCP

**Detect multi-loader project**:
```
get_project_modules()

Returns:
[
  {name: "common", type: "JAVA_MODULE"},
  {name: "forge", type: "JAVA_MODULE"},
  {name: "fabric", type: "JAVA_MODULE"}
]

Analysis:
- Module names: "common", "forge", "fabric"
→ Multi-loader project detected!
```

**Determine supported loaders**:
```
Modules found: ["common", "forge", "fabric"]
→ Supports: Forge + Fabric

Modules found: ["common", "neoforge", "fabric"]
→ Supports: NeoForge + Fabric

Modules found: ["common", "forge", "fabric", "quilt"]
→ Supports: Forge + Fabric + Quilt
```

---

## Code Placement Decision Tree

**Question 1**: Does this code use Forge/Fabric-specific APIs?
- **Yes** → Goes in forge/ or fabric/ module
- **No** → Continue to Question 2

**Question 2**: Is this registry/event code?
- **Yes** → Goes in platform modules (forge/, fabric/)
- **No** → Continue to Question 3

**Question 3**: Is this item/block/entity class logic?
- **Yes** → Goes in common/ module
- **No** → Continue to Question 4

**Question 4**: Is this shared utility/helper?
- **Yes** → Goes in common/ module
- **No** → Probably platform-specific, goes in forge/fabric/

---

## Module Responsibility (Quick Reference)

| Component | Common | Forge | Fabric |
|-----------|--------|-------|--------|
| Item classes | ✅ | ❌ | ❌ |
| Block classes | ✅ | ❌ | ❌ |
| Entity classes | ✅ | ❌ | ❌ |
| Registry code | ❌ | ✅ | ✅ |
| Event handlers | ❌ | ✅ | ✅ |
| Shared logic | ✅ | ❌ | ❌ |
| Platform API calls | ❌ | ✅ | ✅ |
| Service interfaces | ✅ | ❌ | ❌ |
| Service impls | ❌ | ✅ | ✅ |
| Mod entrypoint | ❌ | ✅ | ✅ |

---

## Common Patterns

### Pattern 1: Item Registration Abstraction

**Common** (item class):
```java
// common/src/main/java/com/mod/items/RubySword.java
public class RubySword extends SwordItem { ... }
```

**Forge** (registration):
```java
// forge/src/main/java/com/mod/forge/ModItemsForge.java
public static final RegistryObject<Item> RUBY_SWORD =
    ITEMS.register("ruby_sword", () -> new RubySword(...));
```

**Fabric** (registration):
```java
// fabric/src/main/java/com/mod/fabric/ModItemsFabric.java
public static final Item RUBY_SWORD = Registry.register(..., new RubySword(...));
```

### Pattern 2: Config File Access

**Common** (interface):
```java
public interface ConfigHelper {
    int getMaxEnergy();
    boolean isFeatureEnabled();
}
```

**Forge** (impl):
```java
public class ForgeConfigHelper implements ConfigHelper {
    @Override
    public int getMaxEnergy() {
        return ModConfig.MAX_ENERGY.get();  // ForgeConfigSpec
    }
}
```

**Fabric** (impl):
```java
public class FabricConfigHelper implements ConfigHelper {
    @Override
    public int getMaxEnergy() {
        return ModConfig.MAX_ENERGY;  // Fabric config library
    }
}
```

---

## Benefits and Trade-offs

### Benefits
- ✅ Wider reach (2x audience)
- ✅ Code reuse (write once)
- ✅ Consistent features across loaders

### Trade-offs
- ⚠️ More complex build setup
- ⚠️ Platform abstraction boilerplate
- ⚠️ Must test on all platforms
- ⚠️ Longer build times

**Worth It If**:
- ✅ Large audience (popular mod)
- ✅ Long-term project
- ✅ Team can handle complexity

**Not Worth It If**:
- ❌ Small personal mod
- ❌ Short-term project
- ❌ Single-loader user base

---

## Supporting Documentation

### Detailed Guides
- [Module Structure](./module-structure.md) - Detailed directory layouts, source sets, resource organization
- [Platform Abstraction](./platform-abstraction.md) - ServiceLoader, @ExpectPlatform, registry/event abstraction
- [Gradle Configuration](./gradle-configuration.md) - Multi-module setup, dependencies, publishing

---

## Quick Summary

**Architecture**:
- **common/**: Shared code (item classes, logic, utilities)
- **forge/**: Forge-specific (registration, events)
- **fabric/**: Fabric-specific (registration, events)

**Platform Abstraction**:
- ServiceLoader pattern for dependency injection
- @ExpectPlatform for Architectury users
- Service interfaces in common/, impls in platforms

**Key Principle**: Keep shared logic in common/, platform-specific in forge/fabric/.

---

Use this skill when working with multi-loader projects to ensure correct code placement, proper platform abstraction, and maintainable architecture.
