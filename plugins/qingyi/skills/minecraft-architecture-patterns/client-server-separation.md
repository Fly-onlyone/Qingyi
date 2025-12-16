# Client-Server Separation Guide

Comprehensive guide to properly separating client and server code in Minecraft mods.

## Why Separation Matters

Minecraft runs in three environments:
1. **Integrated Server** (Singleplayer): Client + Server in same JVM
2. **Dedicated Server**: Server only, no client classes
3. **Client**: Multiplayer client connecting to dedicated server

**Problem**: Client classes (e.g., `Minecraft.getInstance()`) don't exist on dedicated servers → **CRASH**

## Critical Rule

**NEVER use client classes in common/server code**

Client classes include:
- `net.minecraft.client.*` - All client packages
- `Minecraft.getInstance()` - Client singleton
- `LocalPlayer` - Client-side player
- Rendering classes - Entity renderers, GUI screens
- Key bindings, mouse input, etc.

## Forge/NeoForge Separation Techniques

### Technique 1: @OnlyIn Annotation

**Usage**: Mark classes/methods that should only load on client

```java
@OnlyIn(Dist.CLIENT)
public class ClientRenderHelper {
    public static void renderCustomOverlay() {
        Minecraft mc = Minecraft.getInstance();  // ← Safe, only loads on client
        // Rendering code
    }
}
```

**When to Use**:
- Client-only classes (renderers, GUI screens)
- Client-only methods (rendering utilities)

**Warning**: Can't access @OnlyIn methods from common code!

---

### Technique 2: @Mod.EventBusSubscriber with Dist

**Usage**: Separate client and common event handlers

```java
// Common events (runs on both sides)
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class CommonEvents {
    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        // Runs on server when player joins
    }
}

// Client-only events
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE, value = Dist.CLIENT)
public class ClientEvents {
    @SubscribeEvent
    public static void onRenderLevel(RenderLevelStageEvent event) {
        // Only runs on client
    }
}
```

---

### Technique 3: DistExecutor (Conditional Execution)

**Usage**: Run different code on client vs server

```java
public class MyClass {
    public static void doSomething() {
        DistExecutor.unsafeRunWhenOn(Dist.CLIENT, () -> () -> {
            // This only runs on client
            Minecraft.getInstance().setScreen(new CustomScreen());
        });
    }
}
```

**Warning**: Use sparingly - better to separate classes

---

### Technique 4: isClientSide Check

**Usage**: Runtime check for client vs server

```java
@SubscribeEvent
public static void onBlockPlace(BlockEvent.EntityPlaceEvent event) {
    Level level = (Level) event.getLevel();

    if (level.isClientSide) {
        // Client-side logic (visual feedback, particles)
    } else {
        // Server-side logic (game state changes, data saving)
    }
}
```

**When to Use**:
- Events that fire on both sides
- Methods that need different behavior per side

**Rule**: Most game logic should be **server-only**

---

## Fabric Separation Techniques

### Technique 1: Separate Entrypoints

**Usage**: Different initialization classes for client and common

```java
// Common entrypoint (src/main/java/)
public class MyMod implements ModInitializer {
    @Override
    public void onInitialize() {
        // Common setup (runs on both sides)
        ModItems.register();
        ModEvents.register();
    }
}

// Client entrypoint (src/client/java/)
@Environment(EnvType.CLIENT)
public class MyModClient implements ClientModInitializer {
    @Override
    public void onInitializeClient() {
        // Client-only setup
        EntityRendererRegistry.register(...);
        KeyBindingHelper.registerKeyBinding(...);
    }
}
```

**fabric.mod.json**:
```json
{
  "entrypoints": {
    "main": [
      "com.example.mymod.MyMod"
    ],
    "client": [
      "com.example.mymod.MyModClient"
    ]
  }
}
```

---

### Technique 2: @Environment Annotation

**Usage**: Mark client-only classes

```java
@Environment(EnvType.CLIENT)
public class ClientHelper {
    public static void doClientThing() {
        MinecraftClient.getInstance().setScreen(...);
    }
}
```

---

### Technique 3: Separate Source Sets

**Structure**:
```
src/
├── main/java/          # Common code (both sides)
└── client/java/        # Client-only code
```

**build.gradle (Fabric Loom)**:
```gradle
loom {
    runs {
        client {
            // Client run config
        }
        server {
            // Server run config
        }
    }
}
```

---

## Common Patterns

### Pattern: Logical Side Check

**Bad**:
```java
// ❌ Crashes on dedicated server
public void updateData(Player player) {
    Minecraft.getInstance().player.sendMessage(...);
}
```

**Good**:
```java
// ✅ Server-safe
public void updateData(Player player) {
    if (!player.level().isClientSide) {
        player.sendSystemMessage(Component.literal("Data updated"));
    }
}
```

---

### Pattern: Client/Server Message Sending

**Client → Server** (Command):
```java
// Client wants to request something from server
if (level.isClientSide) {
    // Send packet to server
    ModNetwork.sendToServer(new RequestPacket());
}
```

**Server → Client** (Update):
```java
// Server wants to inform client of change
if (!level.isClientSide) {
    // Send packet to client
    ModNetwork.sendToClient(player, new UpdatePacket(data));
}
```

---

### Pattern: Particles (Client-Only)

**Bad**:
```java
// ❌ Spawns particles on both sides (duplication!)
public void spawnParticles(Level level, Vec3 pos) {
    level.addParticle(ParticleTypes.FLAME, pos.x, pos.y, pos.z, 0, 0, 0);
}
```

**Good**:
```java
// ✅ Spawns only on client
public void spawnParticles(Level level, Vec3 pos) {
    if (level.isClientSide) {
        level.addParticle(ParticleTypes.FLAME, pos.x, pos.y, pos.z, 0, 0, 0);
    }
}
```

---

### Pattern: Entity Spawning (Server-Only)

**Bad**:
```java
// ❌ Spawns on both sides (duplicate entities!)
public void spawnEntity(Level level, EntityType<?> type, BlockPos pos) {
    Entity entity = type.create(level);
    entity.setPos(Vec3.atCenterOf(pos));
    level.addFreshEntity(entity);
}
```

**Good**:
```java
// ✅ Spawns only on server
public void spawnEntity(Level level, EntityType<?> type, BlockPos pos) {
    if (!level.isClientSide) {
        Entity entity = type.create(level);
        entity.setPos(Vec3.atCenterOf(pos));
        level.addFreshEntity(entity);
    }
}
```

---

## Testing for Proper Separation

### Test 1: Dedicated Server Test

**Method**: Run on dedicated server (no client classes loaded)

```bash
# Forge
./gradlew runServer

# Fabric
./gradlew runServer
```

**Expected**: No `ClassNotFoundException` or `NoClassDefFoundError`

---

### Test 2: Code Review Checklist

- [ ] No `net.minecraft.client.*` imports in common packages
- [ ] No `Minecraft.getInstance()` outside @OnlyIn(Dist.CLIENT) code
- [ ] All rendering code in client package or @OnlyIn
- [ ] Event handlers properly annotated with Dist.CLIENT if needed
- [ ] isClientSide checked before spawning particles
- [ ] isClientSide checked before entity/block modifications (server-only)

---

### Test 3: Static Analysis

**IntelliJ Inspection**: Create custom inspection for client imports in common code

---

## Common Mistakes

### ❌ Mistake 1: Client Import in Common Code

**Wrong**:
```java
// In common package
import net.minecraft.client.Minecraft;  // ← CRASH!

public class CommonClass {
    // Even if you don't use it, the import crashes servers!
}
```

### ❌ Mistake 2: Minecraft.getInstance() in Events

**Wrong**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Minecraft.getInstance().player.sendMessage(...);  // ← CRASH on dedicated server!
}
```

**Correct**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Player player = event.getEntity();
    if (!player.level().isClientSide) {
        player.sendSystemMessage(...);  // ← Server-safe
    }
}
```

### ❌ Mistake 3: Forgetting @OnlyIn on Client Classes

**Wrong**:
```java
// No @OnlyIn annotation!
public class ClientRenderHelper {
    public static void render() {
        Minecraft mc = Minecraft.getInstance();  // ← CRASH!
    }
}
```

**Correct**:
```java
@OnlyIn(Dist.CLIENT)
public class ClientRenderHelper {
    public static void render() {
        Minecraft mc = Minecraft.getInstance();  // ← Safe
    }
}
```

---

## Decision Tree: Where Should This Code Go?

```
Does it use client classes (Minecraft, rendering, input)?
├─ YES → client/ package with @OnlyIn(Dist.CLIENT)
└─ NO → Does it modify game state (blocks, entities, data)?
    ├─ YES → common package with if(!isClientSide) check
    └─ NO → Does it display information to user?
        ├─ YES (client-side display) → client/ package
        └─ NO (pure logic) → common package
```

---

## See Also

- [Main Architecture Patterns](./SKILL.md)
- [Package Structure Examples](./package-structures.md)
