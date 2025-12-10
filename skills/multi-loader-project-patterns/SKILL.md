---
name: multi-loader-project-patterns
description: Multi-loader Minecraft mod architecture. Covers Common/Forge/Fabric patterns, module organization, platform services, ServiceLoader, @ExpectPlatform, gradle setup. Use when working with multi-loader projects or planning cross-platform mods.
allowed-tools: mcp__intellij__get_project_modules, Read
---

# Multi-Loader Project Patterns - Cross-Platform Mod Architecture

This skill provides comprehensive guidance on building Minecraft mods that support multiple mod loaders (Forge, NeoForge, Fabric, Quilt) from a single codebase.

## Overview

### What Are Multi-Loader Projects?

Multi-loader projects allow a single mod to run on multiple mod loaders:
- **Forge** (ModLoader, widely used)
- **NeoForge** (Forge fork for MC 1.20.2+)
- **Fabric** (Lightweight, fast development)
- **Quilt** (Fabric fork with enhanced features)

**Benefits**:
- ✅ Wider audience (support more players)
- ✅ Shared codebase (reduce code duplication)
- ✅ Faster development (write once, deploy everywhere)
- ✅ Consistent features (same mod on all loaders)

**Challenges**:
- ⚠️ Platform abstraction needed (different APIs)
- ⚠️ Build complexity (multiple modules)
- ⚠️ Testing required (on each platform)

### Common Architectures

**Pattern 1: Common + Platform Modules**
```
mymod/
├── common/      (Shared code, platform-agnostic)
├── forge/       (Forge-specific implementation)
└── fabric/      (Fabric-specific implementation)
```

**Pattern 2: Architectury Framework**
```
Uses Architectury API for abstraction
Same structure, but with Architectury helpers
```

**Pattern 3: MultiLoader Template**
```
Similar to Pattern 1, but with standardized build scripts
```

---

## Module Structure

### The Common Module

**Purpose**: Platform-agnostic code that works everywhere

**What goes in common/**:
- ✅ Item/Block/Entity **classes** (not registration!)
- ✅ Shared logic (crafting, mechanics, algorithms)
- ✅ Data models (NBT structures, save data)
- ✅ Utility classes (helpers, constants)
- ✅ Interfaces and abstract classes
- ✅ Common resources (models, textures, recipes shared by all)

**What DOESN'T go in common/**:
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

**What goes in forge/**:
- ✅ Forge registration (DeferredRegister)
- ✅ Forge events (@SubscribeEvent)
- ✅ Forge-specific features (Capabilities, ForgeHooks)
- ✅ Mod entrypoint (class with @Mod annotation)
- ✅ Platform implementation of services

**What goes in fabric/**:
- ✅ Fabric registration (Registry.register)
- ✅ Fabric events (event interface registration)
- ✅ Fabric-specific features (Fabric API exclusive)
- ✅ Mod entrypoint (implements ModInitializer)
- ✅ Platform implementation of services

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

### Directory Layout Example

**Complete multi-loader structure**:
```
mymod/
├── common/
│   ├── src/main/java/com/mod/
│   │   ├── items/
│   │   │   ├── RubySword.java       (Item class)
│   │   │   └── ModItems.java        (Item references)
│   │   ├── blocks/
│   │   ├── platform/
│   │   │   └── PlatformHelper.java  (Service interface)
│   │   └── MyMod.java               (Common init logic)
│   └── src/main/resources/
│       ├── assets/mymod/            (Shared textures, models)
│       └── data/mymod/              (Shared recipes, loot)
│
├── forge/
│   ├── src/main/java/com/mod/forge/
│   │   ├── MyModForge.java          (Mod entrypoint)
│   │   ├── ModItemsForge.java       (Forge registration)
│   │   ├── platform/
│   │   │   └── ForgePlatformHelper.java  (Service impl)
│   │   └── events/
│   └── src/main/resources/
│       └── META-INF/mods.toml       (Forge metadata)
│
├── fabric/
│   ├── src/main/java/com/mod/fabric/
│   │   ├── MyModFabric.java         (Mod entrypoint)
│   │   ├── ModItemsFabric.java      (Fabric registration)
│   │   └── platform/
│   │       └── FabricPlatformHelper.java  (Service impl)
│   └── src/main/resources/
│       └── fabric.mod.json          (Fabric metadata)
│
├── build.gradle                     (Root build file)
├── settings.gradle                  (Module includes)
└── gradle.properties                (Version properties)
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

### Solution 1: Service Interfaces + ServiceLoader

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

### Solution 2: @ExpectPlatform (Architectury)

**Uses dev.architectury.injectables.annotations.ExpectPlatform**:

```java
// common/src/main/java/com/mod/platform/PlatformHelper.java
public class PlatformHelper {
    @ExpectPlatform
    public static Platform getPlatform() {
        throw new AssertionError();  // Replaced at runtime
    }
}

// forge/src/main/java/com/mod/forge/platform/PlatformHelperImpl.java
public class PlatformHelperImpl {
    public static Platform getPlatform() {
        return Platform.FORGE;
    }
}
```

**At compile time**, Architectury generates code to call the platform impl.

---

## Detection with IntelliJ MCP

### Using get_project_modules()

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

Modules found: ["common", "forge", "fabric", "quilt"]
→ Supports: Forge + Fabric + Quilt

Modules found: ["common", "neoforge", "fabric"]
→ Supports: NeoForge + Fabric
```

### Analyzing Build Files

**Read settings.gradle**:
```groovy
include 'common'
include 'forge'
include 'fabric'

→ Confirms 3-module setup
```

**Read gradle.properties**:
```properties
# Minecraft version
minecraft_version=1.20.1

# Loader versions
forge_version=47.1.0
fabric_loader_version=0.15.0
fabric_api_version=0.92.0+1.20.1

→ Version information for each platform
```

---

## Progressive Skill Loading

This skill uses **progressive loading** to optimize token usage. The main file (this file) provides overview and core concepts. For detailed patterns and examples, see:

### Supporting Files

1. **[Module Structure](./module-structure.md)** (~250 lines)
   - Detailed directory layouts for each module
   - Source set organization (main/client/server)
   - Resource file organization (per-platform vs shared)
   - Build script structure (root vs module build.gradle)
   - Real examples from popular multi-loader mods

2. **[Platform Abstraction](./platform-abstraction.md)** (~300 lines)
   - ServiceLoader pattern implementation (detailed)
   - @ExpectPlatform pattern (Architectury)
   - Conditional code patterns (@OnlyIn, @Environment)
   - Mixing platform-specific APIs safely
   - Registry abstraction examples
   - Event system abstraction
   - Real code examples from multi-loader mods

3. **[Gradle Configuration](./gradle-configuration.md)** (~250 lines)
   - Multi-module gradle setup (settings.gradle, root build.gradle)
   - Dependency management across modules (common dependencies)
   - Shadow/relocate for platform-specific libraries
   - JAR merging strategies (single JAR vs multiple JARs)
   - Publishing multi-loader artifacts (CurseForge, Modrinth)
   - Version property management
   - Example build.gradle files for each module

### When to Load Supporting Files

**Load [Module Structure](./module-structure.md)** when:
- Creating new multi-loader project from scratch
- Organizing existing code into modules
- Need detailed directory layout guidance
- Questions about where code belongs

**Load [Platform Abstraction](./platform-abstraction.md)** when:
- Implementing platform services
- Need to call platform-specific APIs from common code
- Writing registry or event abstraction layers
- Real implementation examples needed

**Load [Gradle Configuration](./gradle-configuration.md)** when:
- Setting up multi-module gradle project
- Configuring dependencies
- Publishing mod
- Build script issues

---

## Quick Reference

### Code Placement Decision Tree

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

### Module Responsibility Summary

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
// common/src/main/java/com/mod/items/RubyS word.java
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

### Pattern 3: Client/Server Code Separation

**Common code** (both sides):
```java
// common/src/main/java/com/mod/MyMod.java
public class MyMod {
    public static void init() {
        // Common init (both client and server)
        registerItems();
        registerBlocks();
    }
}
```

**Platform modules** (proxy pattern):
```java
// forge/src/main/java/com/mod/forge/MyModForge.java
@Mod(MOD_ID)
public class MyModForge {
    public MyModForge() {
        MyMod.init();  // Common init

        // Register client-only code
        if (FMLLoader.getDist() == Dist.CLIENT) {
            ClientInit.init();
        }
    }
}
```

---

## Benefits and Trade-offs

### Benefits

**Wider Reach**:
- ✅ Mod works on Forge AND Fabric (2x audience)
- ✅ Players can choose their preferred loader

**Code Reuse**:
- ✅ Core logic written once (in common/)
- ✅ Less duplication, easier maintenance
- ✅ Bug fixes apply to all platforms

**Consistent Experience**:
- ✅ Same features on all loaders
- ✅ Same textures, models, recipes
- ✅ Unified player experience

### Trade-offs

**Complexity**:
- ⚠️ More modules = more files
- ⚠️ Platform abstraction adds boilerplate
- ⚠️ Steeper learning curve

**Build Time**:
- ⚠️ Must build for each platform
- ⚠️ Longer CI/CD pipelines
- ⚠️ More test coverage needed

**Testing Burden**:
- ⚠️ Must test on Forge AND Fabric
- ⚠️ Platform-specific bugs possible
- ⚠️ Compatibility issues to watch

**Worth It If**:
- ✅ Large audience (popular mod)
- ✅ Long-term project (multi-year)
- ✅ Team can handle complexity

**Not Worth It If**:
- ❌ Small personal mod
- ❌ Short-term project
- ❌ Single-loader user base

---

## Summary

Multi-loader projects enable Minecraft mods to run on multiple mod loaders (Forge, NeoForge, Fabric, Quilt) from a shared codebase.

**Architecture**:
- **common/**: Shared code (item classes, logic, utilities)
- **forge/**: Forge-specific (registration, events)
- **fabric/**: Fabric-specific (registration, events)

**Platform Abstraction**:
- ServiceLoader pattern for dependency injection
- @ExpectPlatform for Architectury users
- Service interfaces in common/, impls in platforms

**Detection**:
- Use `get_project_modules()` to detect multi-loader projects
- Module names (common, forge, fabric) indicate structure
- Analyze build files for confirmation

**Key Principle**: Keep shared logic in common/, platform-specific in forge/fabric/.

For detailed patterns and examples, see the supporting files linked above.
