# ServiceLoader Pattern - Platform Abstraction

## The Problem

Different mod loaders have incompatible APIs:

```java
// Forge: Get current platform
FMLLoader.getDist() == Dist.CLIENT

// Fabric: Get current platform
FabricLoader.getInstance().getEnvironmentType() == EnvType.CLIENT
```

**You can't use Forge code in common/**, and **you can't use Fabric code in common/**!

## The Solution: ServiceLoader

Java's `ServiceLoader` provides dependency injection without external libraries. It's perfect for multi-loader mods.

### How It Works

1. **Common module** defines service **interface**
2. **Platform modules** provide **implementations**
3. **META-INF/services/** files register implementations
4. **Common code** loads implementation at runtime via ServiceLoader

## Step-by-Step Implementation

### Step 1: Define Interface in common/

```java
// common/src/main/java/com/mod/platform/PlatformHelper.java
package com.mod.platform;

import java.nio.file.Path;

public interface PlatformHelper {
    /**
     * Get the current mod loader platform
     */
    Platform getPlatform();

    /**
     * Check if running on physical client (not dedicated server)
     */
    boolean isPhysicalClient();

    /**
     * Get mod version string
     */
    String getModVersion();

    /**
     * Get config directory path
     */
    Path getConfigDirectory();

    /**
     * Check if mod is loaded
     */
    boolean isModLoaded(String modId);
}

public enum Platform {
    FORGE, NEOFORGE, FABRIC, QUILT
}
```

### Step 2: Implement in forge/

```java
// forge/src/main/java/com/mod/forge/platform/ForgePlatformHelper.java
package com.mod.forge.platform;

import com.mod.platform.Platform;
import com.mod.platform.PlatformHelper;
import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.fml.ModList;
import net.minecraftforge.fml.loading.FMLLoader;
import net.minecraftforge.fml.loading.FMLPaths;

import java.nio.file.Path;

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
        return ModList.get()
            .getModContainerById(MOD_ID)
            .map(c -> c.getModInfo().getVersion().toString())
            .orElse("UNKNOWN");
    }

    @Override
    public Path getConfigDirectory() {
        return FMLPaths.CONFIGDIR.get();
    }

    @Override
    public boolean isModLoaded(String modId) {
        return ModList.get().isLoaded(modId);
    }
}
```

**Register Service** (`forge/src/main/resources/META-INF/services/com.mod.platform.PlatformHelper`):

Create a text file with **fully qualified class name**:
```
com.mod.forge.platform.ForgePlatformHelper
```

### Step 3: Implement in fabric/

```java
// fabric/src/main/java/com/mod/fabric/platform/FabricPlatformHelper.java
package com.mod.fabric.platform;

import com.mod.platform.Platform;
import com.mod.platform.PlatformHelper;
import net.fabricmc.api.EnvType;
import net.fabricmc.loader.api.FabricLoader;

import java.nio.file.Path;

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
        return FabricLoader.getInstance()
            .getModContainer(MOD_ID)
            .map(c -> c.getMetadata().getVersion().getFriendlyString())
            .orElse("UNKNOWN");
    }

    @Override
    public Path getConfigDirectory() {
        return FabricLoader.getInstance().getConfigDir();
    }

    @Override
    public boolean isModLoaded(String modId) {
        return FabricLoader.getInstance().isModLoaded(modId);
    }
}
```

**Register Service** (`fabric/src/main/resources/META-INF/services/com.mod.platform.PlatformHelper`):

Create a text file with **fully qualified class name**:
```
com.mod.fabric.platform.FabricPlatformHelper
```

### Step 4: Use in common/

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
        LOGGER.info("Running on platform: {}", PLATFORM.getPlatform());

        if (PLATFORM.isPhysicalClient()) {
            // Client-specific initialization
            initClient();
        }

        if (PLATFORM.isModLoaded("jei")) {
            // Optional JEI integration
            setupJEI();
        }
    }

    public static PlatformHelper getPlatform() {
        return PLATFORM;
    }
}
```

## Common Service Patterns

### Network Helper

**Interface**:
```java
public interface NetworkHelper {
    void sendToServer(Packet packet);
    void sendToClient(ServerPlayer player, Packet packet);
    void sendToAll(Packet packet);
}
```

**Usage in common/**:
```java
NetworkHelper network = ServiceLoader.load(NetworkHelper.class).findFirst().orElseThrow();
network.sendToServer(new MyPacket(data));
```

### Registry Helper

**Interface**:
```java
public interface RegistryHelper {
    <T> Supplier<T> register(RegistryType<T> type, String name, Supplier<T> supplier);
}
```

**Usage**:
```java
RegistryHelper registry = ServiceLoader.load(RegistryHelper.class).findFirst().orElseThrow();
Supplier<Item> rubySword = registry.register(RegistryType.ITEM, "ruby_sword", () -> new RubySword(...));
```

### Config Helper

**Interface**:
```java
public interface ConfigHelper {
    int getMaxEnergy();
    boolean isFeatureEnabled(String feature);
    void save();
    void load();
}
```

**Usage**:
```java
ConfigHelper config = ServiceLoader.load(ConfigHelper.class).findFirst().orElseThrow();
if (config.isFeatureEnabled("super_mode")) {
    enableSuperMode();
}
```

## Best Practices

### ✅ Cache ServiceLoader Results

```java
// ✅ GOOD - Load once
public class MyMod {
    private static final PlatformHelper PLATFORM = ServiceLoader.load(PlatformHelper.class)
        .findFirst()
        .orElseThrow();

    public static PlatformHelper getPlatform() {
        return PLATFORM;
    }
}
```

```java
// ❌ BAD - Load every time (slow!)
public static boolean isClient() {
    return ServiceLoader.load(PlatformHelper.class)
        .findFirst()
        .orElseThrow()
        .isPhysicalClient();
}
```

### ✅ Provide Fallback for Missing Service

```java
// ✅ GOOD - Graceful fallback
private static PlatformHelper loadPlatformHelper() {
    return ServiceLoader.load(PlatformHelper.class)
        .findFirst()
        .orElseGet(() -> {
            LOGGER.warn("No platform helper found, using default");
            return new DefaultPlatformHelper();
        });
}
```

### ✅ Use Service Interfaces for Platform Operations

```java
// ✅ GOOD - Service abstraction
public interface MenuHelper {
    void openMenu(ServerPlayer player, MenuProvider provider);
}

// Forge implementation uses NetworkHooks.openScreen(...)
// Fabric implementation uses player.openHandledScreen(...)
```

```java
// ❌ BAD - Platform code in common
public void openMenu(ServerPlayer player) {
    // Can't use NetworkHooks in common!
    NetworkHooks.openScreen(player, menuProvider);
}
```

## Troubleshooting

### Service Not Found

**Error**: `NoSuchElementException: No value present`

**Causes**:
1. Missing META-INF/services file
2. Wrong file name (must match interface fully qualified name)
3. Wrong class name in service file
4. Service implementation not in classpath

**Fix**:
```
✅ Correct structure:
forge/src/main/resources/
└── META-INF/
    └── services/
        └── com.mod.platform.PlatformHelper  ← File name = interface FQN

Content of file:
com.mod.forge.platform.ForgePlatformHelper  ← Fully qualified class name
```

### Multiple Services Registered

**Error**: Multiple implementations loaded

**Cause**: Both forge and fabric JARs on classpath simultaneously

**Fix**: This is normal in dev environment. Use `.findFirst()` to pick one:
```java
ServiceLoader.load(PlatformHelper.class)
    .findFirst()  // Takes first available
    .orElseThrow();
```

### Service Class Not Found

**Error**: `ClassNotFoundException` when loading service

**Cause**: Implementation class not compiled or not in JAR

**Fix**: Ensure platform module's build includes service implementation

## Alternatives

### @ExpectPlatform (Architectury)

If using Architectury framework:
```java
// common/
public class PlatformHelper {
    @ExpectPlatform
    public static boolean isPhysicalClient() {
        throw new AssertionError();
    }
}

// forge/
public class PlatformHelperImpl {
    public static boolean isPhysicalClient() {
        return FMLLoader.getDist() == Dist.CLIENT;
    }
}
```

See [ExpectPlatform Pattern](./expectplatform-pattern.md) for details.

### Manual Factory Pattern

```java
// common/
public interface PlatformHelper { ... }

public class PlatformHelperFactory {
    private static PlatformHelper instance;

    public static void setInstance(PlatformHelper helper) {
        instance = helper;
    }

    public static PlatformHelper get() {
        return instance;
    }
}

// forge/
@Mod(MOD_ID)
public class MyModForge {
    public MyModForge() {
        PlatformHelperFactory.setInstance(new ForgePlatformHelper());
    }
}
```

---

**Related**:
- [@ExpectPlatform Pattern](./expectplatform-pattern.md) - Architectury alternative
- [Common Code Pattern](../architectures/common-code-pattern.md) - Service interfaces
- [Subproject Pattern](../architectures/subproject-pattern.md) - Service implementations
