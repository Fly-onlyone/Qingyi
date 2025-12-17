---
name: multi-loader-project-patterns
description: Multi-loader Minecraft mod architecture for supporting Forge, NeoForge, Fabric, and Quilt simultaneously. Covers common/platform module separation, ServiceLoader abstraction, code placement decisions, multi-loader detection. Use when setting up cross-platform mods, migrating single-loader projects, or determining where code belongs in multi-loader architecture.
allowed-tools: mcp__intellij__get_project_modules, Read
---

# Multi-Loader Project Patterns

## What This Is

Multi-loader architecture allows a **single mod codebase** to run on multiple mod loaders:
- **Forge** / **NeoForge** (ModLoader-based)
- **Fabric** / **Quilt** (Lightweight)

**Benefits**: 2x+ audience, shared codebase, write once deploy everywhere
**Trade-offs**: Platform abstraction required, more complex build, must test all platforms

## Quick Architecture

```
mymod/
├── common/      # Shared code (item classes, logic, utilities)
├── forge/       # Forge-specific (registration, events, entrypoint)
└── fabric/      # Fabric-specific (registration, events, entrypoint)
```

**Key Principle**: Logic in common/, platform APIs in forge/fabric/

---

## Code Placement Decision Tree

**Step 1**: Does this code use Forge/Fabric-specific APIs?
- **YES** → Goes in `forge/` or `fabric/` module
- **NO** → Continue...

**Step 2**: Is this registry/event code?
- **YES** → Goes in platform modules (`forge/`, `fabric/`)
- **NO** → Continue...

**Step 3**: Is this item/block/entity class or shared logic?
- **YES** → Goes in `common/` module
- **NO** → Probably platform-specific, goes in `forge/fabric/`

---

## Module Responsibility (Quick Reference)

| Component | Common | Forge | Fabric |
|-----------|:------:|:-----:|:------:|
| Item/Block/Entity classes | ✅ | ❌ | ❌ |
| Registry code (DeferredRegister, Registry.register) | ❌ | ✅ | ✅ |
| Event handlers (@SubscribeEvent, callbacks) | ❌ | ✅ | ✅ |
| Shared game logic | ✅ | ❌ | ❌ |
| Platform API calls | ❌ | ✅ | ✅ |
| Service **interfaces** | ✅ | ❌ | ❌ |
| Service **implementations** | ❌ | ✅ | ✅ |
| Mod entrypoint (@Mod, ModInitializer) | ❌ | ✅ | ✅ |

---

## Multi-Loader Detection

### Using IntelliJ MCP

```java
get_project_modules()

Returns:
[
  {name: "common", type: "JAVA_MODULE"},
  {name: "forge", type: "JAVA_MODULE"},
  {name: "fabric", type: "JAVA_MODULE"}
]

→ Multi-loader project detected! Supports: Forge + Fabric
```

**Common module patterns**:
- `["common", "forge", "fabric"]` → Forge + Fabric
- `["common", "neoforge", "fabric"]` → NeoForge + Fabric
- `["common", "forge", "fabric", "quilt"]` → Forge + Fabric + Quilt

---

## Quick Example

### Common Module (Item Class)

```java
// common/src/main/java/com/mod/items/RubySword.java
public class RubySword extends SwordItem {
    public RubySword(Tier tier, int attackDamage, float attackSpeed, Properties properties) {
        super(tier, attackDamage, attackSpeed, properties);
    }

    @Override
    public InteractionResultHolder<ItemStack> use(Level level, Player player, InteractionHand hand) {
        if (!level.isClientSide) {
            player.addEffect(new MobEffectInstance(MobEffects.LUCK, 200));
        }
        return super.use(level, player, hand);
    }
}
```

### Forge Module (Registration)

```java
// forge/src/main/java/com/mod/forge/ModItemsForge.java
public class ModItemsForge {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MOD_ID);

    public static final RegistryObject<Item> RUBY_SWORD =
        ITEMS.register("ruby_sword", () -> new RubySword(
            Tiers.IRON, 3, -2.4f, new Item.Properties()
        ));
}
```

### Fabric Module (Registration)

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

## Platform Abstraction (ServiceLoader)

**Problem**: Common code can't use Forge/Fabric APIs

**Solution**: Service interfaces

**Step 1** - Define in common/:
```java
public interface PlatformHelper {
    Platform getPlatform();
    boolean isPhysicalClient();
}
```

**Step 2** - Implement in forge/fabric/:
```java
// Forge: return FMLLoader.getDist() == Dist.CLIENT;
// Fabric: return FabricLoader.getInstance().getEnvironmentType() == EnvType.CLIENT;
```

**Step 3** - Use in common/:
```java
PlatformHelper platform = ServiceLoader.load(PlatformHelper.class).findFirst().orElseThrow();
if (platform.isPhysicalClient()) {
    // Client-specific logic
}
```

**For complete ServiceLoader guide**: See [ServiceLoader Pattern](./platform-abstraction/serviceloader-pattern.md)

---

## When Multi-Loader Is Worth It

### ✅ Use Multi-Loader If:
- Large/popular mod (maximize audience)
- Long-term project (investment pays off)
- Team can handle complexity

### ❌ Skip Multi-Loader If:
- Small personal mod
- Short-term project
- Single-loader user base

---

## Detailed Guides

### Architecture Patterns
- **[Common Code Pattern](./architectures/common-code-pattern.md)** - What goes in common/, directory structure, best practices
- **[Subproject Pattern](./architectures/subproject-pattern.md)** - Platform module organization, service implementations, entrypoints
- **[Single-Loader Migration](./architectures/single-loader-migration.md)** - Converting existing single-loader mod to multi-loader

### Platform Abstraction
- **[ServiceLoader Pattern](./platform-abstraction/serviceloader-pattern.md)** - Service interfaces, META-INF configuration, common patterns
- **[@ExpectPlatform Pattern](./platform-abstraction/expectplatform-pattern.md)** - Architectury framework alternative

### Framework-Specific Details
- **[Forge Specifics](./framework-specific/forge-specifics.md)** - DeferredRegister, @Mod entrypoint, Forge events
- **[Fabric Specifics](./framework-specific/fabric-specifics.md)** - Registry.register, ModInitializer, Fabric callbacks
- **[NeoForge Specifics](./framework-specific/neoforge-specifics.md)** - NeoForge differences from Forge

### Build Configuration
- **[Gradle Setup](./gradle-configuration.md)** - Multi-module build.gradle, dependencies, publishing

---

## Common Pitfalls

### ❌ Platform APIs in Common

```java
// ❌ BAD - Forge API in common module
import net.minecraftforge.common.MinecraftForge;

public class MyItem extends Item {
    public void init() {
        MinecraftForge.EVENT_BUS.register(this);  // COMPILE ERROR!
    }
}
```

**Fix**: Use service interfaces or move to platform modules

### ❌ Duplicated Logic Across Platforms

```java
// ❌ BAD - Same logic in forge/ and fabric/
// Forge:
public void calculatePower() { return base * multiplier; }

// Fabric:
public void calculatePower() { return base * multiplier; }
```

**Fix**: Move shared logic to common/, keep only registration in platforms

### ❌ Wrong Module Dependencies

```java
// ❌ BAD - forge/ depends on fabric/
// forge/build.gradle
dependencies {
    implementation project(':fabric')  // WRONG!
}
```

**Fix**: Only platform modules depend on common, never on each other

---

Use this skill when working with multi-loader projects to ensure correct code placement, proper platform abstraction, and maintainable cross-platform architecture.
