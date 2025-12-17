# Common Code Pattern - Multi-Loader Projects

## Purpose

The **common** module contains platform-agnostic code that works identically on all mod loaders (Forge, NeoForge, Fabric, Quilt).

## What Goes in common/

### ✅ Include in Common

**Item/Block/Entity Classes** (logic, not registration):
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

**Shared Game Mechanics**:
```java
// common/src/main/java/com/mod/mechanics/PowerSystem.java
public class PowerSystem {
    public static int calculatePower(int baseValue, int multiplier) {
        return Math.min(baseValue * multiplier, 1000);
    }

    public static boolean canUsePower(Player player, int required) {
        // Platform-agnostic logic
        return player.experienceLevel >= required;
    }
}
```

**Data Models** (NBT structures, save data):
```java
// common/src/main/java/com/mod/data/PlayerData.java
public class PlayerData {
    private int energy;
    private List<String> unlockedAbilities;

    public CompoundTag save(CompoundTag tag) {
        tag.putInt("energy", energy);
        ListTag abilities = new ListTag();
        unlockedAbilities.forEach(s -> abilities.add(StringTag.valueOf(s)));
        tag.put("abilities", abilities);
        return tag;
    }

    public void load(CompoundTag tag) {
        energy = tag.getInt("energy");
        // ... load list
    }
}
```

**Utility Classes**:
```java
// common/src/main/java/com/mod/util/MathHelper.java
public class MathHelper {
    public static double distance3D(Vec3 a, Vec3 b) {
        return a.distanceTo(b);
    }

    public static BlockPos findNearestBlock(Level level, BlockPos center, Block target, int radius) {
        // Platform-agnostic block search
        for (BlockPos pos : BlockPos.betweenClosed(
            center.offset(-radius, -radius, -radius),
            center.offset(radius, radius, radius)
        )) {
            if (level.getBlockState(pos).is(target)) {
                return pos.immutable();
            }
        }
        return null;
    }
}
```

**Service Interfaces** (platform abstraction):
```java
// common/src/main/java/com/mod/platform/PlatformHelper.java
public interface PlatformHelper {
    Platform getPlatform();
    boolean isPhysicalClient();
    String getModVersion();
    Path getConfigDirectory();
}

public enum Platform {
    FORGE, NEOFORGE, FABRIC, QUILT
}
```

### ❌ Exclude from Common

**Registry Code** (platform-specific):
```java
// ❌ DON'T put in common/
DeferredRegister<Item> ITEMS = ...         // Forge-only
Registry.register(Registries.ITEM, ...)    // Fabric-only
```

**Event Handlers** (different systems):
```java
// ❌ DON'T put in common/
@SubscribeEvent                             // Forge-only
public static void onPlayerTick(...) {}

PlayerTickEvents.END.register(...)          // Fabric-only
```

**Platform-Specific APIs**:
```java
// ❌ DON'T put in common/
FMLLoader.getDist()                         // Forge-only
FabricLoader.getInstance()                  // Fabric-only
ModList.get()                               // Forge-only
```

## Directory Structure

```
common/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/mod/
│       │       ├── items/           # Item classes (no registration)
│       │       ├── blocks/          # Block classes (no registration)
│       │       ├── entities/        # Entity classes (no registration)
│       │       ├── mechanics/       # Game logic
│       │       ├── data/            # NBT models, save data
│       │       ├── util/            # Utilities, helpers
│       │       └── platform/        # Service interfaces
│       └── resources/
│           ├── assets/              # Textures, models, sounds (shared)
│           └── data/                # Recipes, loot tables (shared)
└── build.gradle
```

## Common Pitfalls

### ❌ Accidentally Using Platform APIs

```java
// ❌ BAD - Forge API in common module
import net.minecraftforge.common.MinecraftForge;

public class MyItem extends Item {
    public void init() {
        MinecraftForge.EVENT_BUS.register(this);  // COMPILE ERROR!
    }
}
```

**Fix**: Use service interfaces for platform-specific operations.

### ❌ Mixing Registration with Logic

```java
// ❌ BAD - Registry in common
public class ModItems {
    public static final DeferredRegister<Item> ITEMS = ...;  // FORGE-ONLY!

    public static final RegistryObject<Item> RUBY = ITEMS.register(...);
}
```

**Fix**: Keep classes in common/, registration in platform modules.

### ❌ Client-Only Code Without Abstraction

```java
// ❌ BAD - Direct Minecraft.getInstance() in common
public void doSomething() {
    Player player = Minecraft.getInstance().player;  // CLIENT-ONLY API!
}
```

**Fix**: Use level.isClientSide checks or platform services.

## Best Practices

### ✅ Keep Classes Pure

```java
// ✅ GOOD - Pure item class in common/
public class CustomPickaxe extends PickaxeItem {
    public CustomPickaxe(Tier tier, int attackDamage, float attackSpeed, Properties properties) {
        super(tier, attackDamage, attackSpeed, properties);
    }

    // Only override vanilla methods
    @Override
    public float getDestroySpeed(ItemStack stack, BlockState state) {
        return super.getDestroySpeed(stack, state) * 1.5f;
    }
}

// Then in forge/fabric modules:
// Forge: ITEMS.register("custom_pickaxe", () -> new CustomPickaxe(...))
// Fabric: Registry.register(..., new CustomPickaxe(...))
```

### ✅ Use Service Interfaces for Platform Operations

```java
// ✅ GOOD - Service interface in common/
public interface NetworkHelper {
    void sendToServer(Packet packet);
    void sendToClient(Player player, Packet packet);
}

// Implementations live in forge/ and fabric/ modules
// Common code uses: ServiceLoader.load(NetworkHelper.class).findFirst()
```

### ✅ Organize by Feature, Not Type

```java
// ✅ GOOD structure
common/src/main/java/com/mod/
├── ruby/                    # Ruby feature
│   ├── RubySword.java
│   ├── RubyBlock.java
│   ├── RubyArmor.java
│   └── RubyRecipeHelper.java
└── magic/                   # Magic feature
    ├── MagicWand.java
    ├── SpellEffect.java
    └── ManaSystem.java

// ❌ BAD structure
common/src/main/java/com/mod/
├── items/
│   ├── RubySword.java
│   ├── MagicWand.java
│   └── ...
├── blocks/
│   ├── RubyBlock.java
│   └── ...
└── ...
```

## Testing Common Code

Since common code is platform-agnostic, test it on **both** loaders:

1. Run Forge/runClient → Test common classes work
2. Run Fabric/runClient → Test common classes work
3. Verify identical behavior on both platforms

If behavior differs, you likely have platform-specific code leaking into common/.

---

**Related**:
- [Subproject Pattern](./subproject-pattern.md) - Platform module organization
- [Platform Abstraction](../platform-abstraction/serviceloader-pattern.md) - Service interfaces
