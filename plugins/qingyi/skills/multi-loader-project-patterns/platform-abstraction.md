# Platform Abstraction - Calling Platform-Specific APIs from Common Code

This guide covers patterns for accessing platform-specific APIs from common code in multi-loader projects, enabling code reuse while maintaining platform compatibility.

## The Core Problem

**Different mod loaders have different APIs**:

```java
// Forge API
FMLLoader.getDist() == Dist.CLIENT

// Fabric API
FabricLoader.getInstance().getEnvironmentType() == EnvType.CLIENT

// Can't use either in common/ module! Both would fail to compile.
```

**Solution**: Platform abstraction patterns

## Pattern 1: ServiceLoader (Recommended)

### Overview

**ServiceLoader** is a Java standard library mechanism for dependency injection. No external dependencies needed.

**Workflow**:
1. Define service interface in common/
2. Implement service in forge/ and fabric/
3. Register implementations via META-INF/services/
4. Load service at runtime in common/

### Step-by-Step Implementation

#### Step 1: Define Service Interface (Common)

```java
// common/src/main/java/com/mod/platform/PlatformHelper.java
package com.mod.platform;

public interface PlatformHelper {
    /**
     * Get the current mod loader platform
     */
    Platform getPlatform();

    /**
     * Check if we're on the physical client
     */
    boolean isPhysicalClient();

    /**
     * Check if we're on the dedicated server
     */
    boolean isDedicatedServer();

    /**
     * Get the mod version
     */
    String getModVersion();

    /**
     * Check if a mod is loaded
     */
    boolean isModLoaded(String modId);
}

public enum Platform {
    FORGE, NEOFORGE, FABRIC, QUILT
}
```

#### Step 2: Implement for Forge

```java
// forge/src/main/java/com/mod/forge/platform/ForgePlatformHelper.java
package com.mod.forge.platform;

import com.mod.platform.Platform;
import com.mod.platform.PlatformHelper;
import net.minecraftforge.fml.ModList;
import net.minecraftforge.fml.loading.FMLLoader;
import net.minecraftforge.api.distmarker.Dist;

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
    public boolean isDedicatedServer() {
        return FMLLoader.getDist() == Dist.DEDICATED_SERVER;
    }

    @Override
    public String getModVersion() {
        return ModList.get().getModContainerById(MyMod.MOD_ID)
            .map(c -> c.getModInfo().getVersion().toString())
            .orElse("UNKNOWN");
    }

    @Override
    public boolean isModLoaded(String modId) {
        return ModList.get().isLoaded(modId);
    }
}
```

#### Step 3: Implement for Fabric

```java
// fabric/src/main/java/com/mod/fabric/platform/FabricPlatformHelper.java
package com.mod.fabric.platform;

import com.mod.platform.Platform;
import com.mod.platform.PlatformHelper;
import net.fabricmc.api.EnvType;
import net.fabricmc.loader.api.FabricLoader;

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
    public boolean isDedicatedServer() {
        return FabricLoader.getInstance().getEnvironmentType() == EnvType.SERVER;
    }

    @Override
    public String getModVersion() {
        return FabricLoader.getInstance().getModContainer(MyMod.MOD_ID)
            .map(c -> c.getMetadata().getVersion().getFriendlyString())
            .orElse("UNKNOWN");
    }

    @Override
    public boolean isModLoaded(String modId) {
        return FabricLoader.getInstance().isModLoaded(modId);
    }
}
```

#### Step 4: Register Services

**Forge**:
```
File: forge/src/main/resources/META-INF/services/com.mod.platform.PlatformHelper

Content:
com.mod.forge.platform.ForgePlatformHelper
```

**Fabric**:
```
File: fabric/src/main/resources/META-INF/services/com.mod.platform.PlatformHelper

Content:
com.mod.fabric.platform.FabricPlatformHelper
```

**Important**: File name MUST be the fully qualified interface name!

#### Step 5: Load Service in Common Code

```java
// common/src/main/java/com/mod/MyMod.java
package com.mod;

import com.mod.platform.PlatformHelper;
import java.util.ServiceLoader;

public class MyMod {
    public static final String MOD_ID = "mymod";
    private static final PlatformHelper PLATFORM = loadPlatformHelper();

    private static PlatformHelper loadPlatformHelper() {
        return ServiceLoader.load(PlatformHelper.class)
            .findFirst()
            .orElseThrow(() -> new RuntimeException("No platform helper found!"));
    }

    public static void init() {
        System.out.println("Running on platform: " + PLATFORM.getPlatform());

        if (PLATFORM.isPhysicalClient()) {
            // Client-specific initialization
            initClient();
        }
    }

    public static PlatformHelper getPlatform() {
        return PLATFORM;
    }
}
```

#### Step 6: Use Anywhere in Common Code

```java
// common/src/main/java/com/mod/items/CustomItem.java
package com.mod.items;

import com.mod.MyMod;

public class CustomItem extends Item {
    @Override
    public InteractionResultHolder<ItemStack> use(Level level, Player player, InteractionHand hand) {
        // Use platform abstraction
        if (MyMod.getPlatform().isModLoaded("jei")) {
            // Do JEI integration
        }

        return super.use(level, player, hand);
    }
}
```

## Pattern 2: @ExpectPlatform (Architectury)

### Overview

**Architectury** provides `@ExpectPlatform` annotation for compile-time platform method injection.

**Dependencies**: Requires Architectury API

### Implementation

#### Step 1: Define Expected Methods (Common)

```java
// common/src/main/java/com/mod/platform/PlatformMethods.java
package com.mod.platform;

import dev.architectury.injectables.annotations.ExpectPlatform;

public class PlatformMethods {
    @ExpectPlatform
    public static Platform getPlatform() {
        throw new AssertionError();  // Replaced at compile time
    }

    @ExpectPlatform
    public static boolean isPhysicalClient() {
        throw new AssertionError();
    }

    @ExpectPlatform
    public static String getModVersion(String modId) {
        throw new AssertionError();
    }
}
```

#### Step 2: Implement for Forge

```java
// forge/src/main/java/com/mod/forge/platform/PlatformMethodsImpl.java
package com.mod.forge.platform;

import com.mod.platform.Platform;
import net.minecraftforge.fml.loading.FMLLoader;
import net.minecraftforge.fml.ModList;

public class PlatformMethodsImpl {
    public static Platform getPlatform() {
        return Platform.FORGE;
    }

    public static boolean isPhysicalClient() {
        return FMLLoader.getDist() == Dist.CLIENT;
    }

    public static String getModVersion(String modId) {
        return ModList.get().getModContainerById(modId)
            .map(c -> c.getModInfo().getVersion().toString())
            .orElse("UNKNOWN");
    }
}
```

**Note**: Implementation class MUST be in same package structure with "Impl" suffix!

#### Step 3: Use in Common Code

```java
// common/src/main/java/com/mod/MyMod.java
import com.mod.platform.PlatformMethods;

public class MyMod {
    public static void init() {
        Platform platform = PlatformMethods.getPlatform();
        System.out.println("Running on: " + platform);
    }
}
```

**Advantages**:
- ✅ Clean syntax (static methods)
- ✅ Compile-time checking
- ✅ No ServiceLoader boilerplate

**Disadvantages**:
- ❌ Requires Architectury dependency
- ❌ Strict naming conventions (PlatformMethodsImpl)
- ❌ Package structure must match

## Advanced Patterns

### Registry Abstraction

**Problem**: Different registry APIs

```java
// Forge
ITEMS.register("ruby_sword", () -> new RubySword(...));

// Fabric
Registry.register(Registries.ITEM, new Identifier("modid", "ruby_sword"), new RubySword(...));
```

**Solution**: Registry service

```java
// common/src/main/java/com/mod/platform/RegistryHelper.java
public interface RegistryHelper {
    <T> void registerItem(String name, Supplier<T> item);
    <T> void registerBlock(String name, Supplier<T> block);
}

// forge/src/main/java/com/mod/forge/platform/ForgeRegistryHelper.java
public class ForgeRegistryHelper implements RegistryHelper {
    private final DeferredRegister<Item> items = DeferredRegister.create(ForgeRegistries.ITEMS, MOD_ID);

    @Override
    public <T> void registerItem(String name, Supplier<T> item) {
        items.register(name, (Supplier<Item>) item);
    }

    public void registerAll(IEventBus bus) {
        items.register(bus);
    }
}

// fabric/src/main/java/com/mod/fabric/platform/FabricRegistryHelper.java
public class FabricRegistryHelper implements RegistryHelper {
    @Override
    public <T> void registerItem(String name, Supplier<T> item) {
        Registry.register(Registries.ITEM,
            new Identifier(MOD_ID, name),
            (Item) item.get());
    }
}
```

**Usage**:
```java
// common/src/main/java/com/mod/items/ModItems.java
public class ModItems {
    public static void register(RegistryHelper registry) {
        registry.registerItem("ruby_sword", () -> new RubySword(...));
        registry.registerItem("ruby_pickaxe", () -> new RubyPickaxe(...));
    }
}

// Platform modules call ModItems.register(registryHelper)
```

### Event System Abstraction

**Problem**: Different event systems

```java
// Forge
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) { ... }

// Fabric
ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> { ... });
```

**Solution**: Event wrapper service

```java
// common/src/main/java/com/mod/platform/EventHelper.java
public interface EventHelper {
    void onPlayerJoin(Consumer<Player> callback);
    void onPlayerLeave(Consumer<Player> callback);
    void onServerTick(Runnable callback);
}

// forge/src/main/java/com/mod/forge/platform/ForgeEventHelper.java
@EventBusSubscriber(modid = MOD_ID)
public class ForgeEventHelper implements EventHelper {
    private static final List<Consumer<Player>> JOIN_CALLBACKS = new ArrayList<>();

    @Override
    public void onPlayerJoin(Consumer<Player> callback) {
        JOIN_CALLBACKS.add(callback);
    }

    @SubscribeEvent
    public static void onPlayerLoggedIn(PlayerEvent.PlayerLoggedInEvent event) {
        JOIN_CALLBACKS.forEach(cb -> cb.accept(event.getEntity()));
    }
}

// fabric/src/main/java/com/mod/fabric/platform/FabricEventHelper.java
public class FabricEventHelper implements EventHelper {
    @Override
    public void onPlayerJoin(Consumer<Player> callback) {
        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
            callback.accept(handler.getPlayer());
        });
    }
}
```

**Usage**:
```java
// common/src/main/java/com/mod/MyMod.java
public class MyMod {
    public static void init() {
        EventHelper events = getPlatform().getEventHelper();
        events.onPlayerJoin(player -> {
            player.sendSystemMessage(Component.literal("Welcome!"));
        });
    }
}
```

### Config Abstraction

**Problem**: Different config libraries

```java
// Forge: ForgeConfigSpec
// Fabric: Various (AutoConfig, Cloth Config, etc.)
```

**Solution**: Config service

```java
// common/src/main/java/com/mod/platform/ConfigHelper.java
public interface ConfigHelper {
    int getMaxEnergy();
    boolean isFeatureEnabled(String feature);
    void reload();
}

// forge/src/main/java/com/mod/forge/platform/ForgeConfigHelper.java
public class ForgeConfigHelper implements ConfigHelper {
    public static final ForgeConfigSpec SPEC;
    private static final ForgeConfigSpec.IntValue MAX_ENERGY;

    static {
        ForgeConfigSpec.Builder builder = new ForgeConfigSpec.Builder();
        MAX_ENERGY = builder.defineInRange("maxEnergy", 1000, 0, 10000);
        SPEC = builder.build();
    }

    @Override
    public int getMaxEnergy() {
        return MAX_ENERGY.get();
    }
}
```

## Conditional Compilation

### @OnlyIn / @Environment (Not Recommended)

**Old pattern** (deprecated on modern versions):

```java
// Don't use this
@OnlyIn(Dist.CLIENT)
public void clientMethod() { ... }
```

**Problem**: Code still compiled, just not executed. Can cause class loading issues.

### Better: Separate Client Code

**Recommended pattern**:

```java
// common/src/main/java/com/mod/MyMod.java
public class MyMod {
    public static void init() {
        // Common init
    }

    public static void initClient() {
        // Called only on client
        ClientInit.register();
    }
}

// common/src/main/java/com/mod/ClientInit.java
public class ClientInit {
    public static void register() {
        // Client-only registration
        // This class only loaded on client
    }
}

// forge/src/main/java/com/mod/forge/MyModForge.java
@Mod(MOD_ID)
public class MyModForge {
    public MyModForge() {
        MyMod.init();

        if (FMLLoader.getDist() == Dist.CLIENT) {
            MyMod.initClient();  // Only called on client
        }
    }
}
```

## Testing Platform Abstraction

### Unit Testing

```java
// common/src/test/java/com/mod/PlatformTest.java
public class PlatformTest {
    private PlatformHelper platform;

    @BeforeEach
    public void setup() {
        // Create mock implementation for testing
        platform = new MockPlatformHelper();
    }

    @Test
    public void testPlatformDetection() {
        assertEquals(Platform.FORGE, platform.getPlatform());
    }
}

class MockPlatformHelper implements PlatformHelper {
    @Override
    public Platform getPlatform() {
        return Platform.FORGE;  // Mock response
    }
    // ... implement other methods
}
```

### Integration Testing

Test on **both Forge and Fabric**:

```bash
# Test on Forge
./gradlew :forge:runClient

# Test on Fabric
./gradlew :fabric:runClient

# Verify behavior identical on both
```

## Common Pitfalls

### Pitfall 1: Forgetting to Register Service

**Symptom**: `RuntimeException: No platform helper found!`

**Fix**: Check META-INF/services/ file exists with correct content

### Pitfall 2: Wrong Package Structure (@ExpectPlatform)

**Symptom**: Compile error "Cannot find implementation"

**Fix**: Implementation MUST be in `com.mod.forge.platform.PlatformMethodsImpl` if interface is `com.mod.platform.PlatformMethods`

### Pitfall 3: Using Platform APIs Directly in Common

**Symptom**: Compile errors in common module

**Fix**: All platform API calls MUST go through abstraction interface

### Pitfall 4: Not Testing on All Platforms

**Symptom**: Works on Forge, crashes on Fabric (or vice versa)

**Fix**: Test on ALL supported platforms before release

## Best Practices

### DO

- ✅ Use ServiceLoader for maximum compatibility
- ✅ Define clear service interfaces
- ✅ Keep platform impls simple (thin wrappers)
- ✅ Test on all platforms
- ✅ Document which methods require which platform features

### DON'T

- ❌ Call Forge/Fabric APIs directly from common
- ❌ Use `@OnlyIn` / `@Environment` (deprecated)
- ❌ Skip testing on one platform
- ❌ Create overly complex abstractions
- ❌ Forget to register services in META-INF/

## Summary

**Platform abstraction** enables common code to call platform-specific APIs safely.

**Patterns**:
1. **ServiceLoader** (Recommended): Standard Java, no dependencies
2. **@ExpectPlatform** (Architectury): Requires Architectury, cleaner syntax

**Common Abstractions**:
- Platform info (client/server, mod version)
- Registry (items, blocks, entities)
- Events (player join, tick, etc.)
- Config (mod configuration)

**Key Principle**: Keep abstractions **simple and focused**. Don't over-engineer.

For module organization, see [Module Structure](./module-structure.md).

For build configuration, see [Gradle Configuration](./gradle-configuration.md).
