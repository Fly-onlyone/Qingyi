# Common Mistakes Database for Minecraft Modding

This comprehensive database catalogs the most common mistakes made by Minecraft mod developers and their solutions.

## Category 1: Registry Issues

### ❌ Mistake: Uppercase Registry Names

**Wrong**:
```java
ITEMS.register("CustomItem", () -> new Item(...))
ITEMS.register("ruby_Sword", () -> new SwordItem(...))
```

**Correct**:
```java
ITEMS.register("custom_item", () -> new Item(...))
ITEMS.register("ruby_sword", () -> new SwordItem(...))
```

**Why**: Minecraft resource locations (ResourceLocation/Identifier) require lowercase. Mixed case causes "Unknown item" errors and missing textures.

**Symptom**: Purple/black checkerboard texture in-game

**Rule**: Always use `snake_case` (lowercase with underscores)

---

### ❌ Mistake: Registry Name Mismatch with Resource Files

**Problem**: Registry name is `ruby_sword` but texture is `RubySword.png`

**Result**: Missing texture (purple/black checkerboard)

**Solution**: **EXACT MATCH REQUIRED**
- Registry name: `ruby_sword`
- Model file: `assets/modid/models/item/ruby_sword.json`
- Texture file: `assets/modid/textures/item/ruby_sword.png`
- Lang key: `item.modid.ruby_sword`

---

### ❌ Mistake: Forgetting to Call register()

**Wrong**:
```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

    public static final RegistryObject<Item> RUBY = ITEMS.register(...);

    // ← Missing registration call!
}

// In main mod class
public MyMod() {
    // ModItems.register(modEventBus);  ← FORGOT THIS!
}
```

**Correct**:
```java
public MyMod(IEventBus modEventBus) {
    ModItems.register(modEventBus);  // ← Must call this!
}
```

**Symptom**: Items don't exist in-game, no errors in console

---

## Category 2: Client/Server Separation

### ❌ Mistake: Using Minecraft.getInstance() in Common Code

**Wrong**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Minecraft.getInstance().player.sendMessage(...);  // ← CRASH!
}
```

**Error**: `java.lang.RuntimeException: Cannot load class net.minecraft.client.Minecraft in environment type SERVER`

**Correct**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    Player player = event.getEntity();
    if (!player.level().isClientSide) {
        player.sendSystemMessage(Component.literal("Welcome!"));
    }
}
```

**Why**: Dedicated servers don't have `Minecraft.getInstance()`. This is the **#1 crash cause** for new modders.

**Rule**: **NEVER** use `Minecraft.getInstance()` outside of client-only code

---

### ❌ Mistake: Client Imports in Common Code

**Wrong**:
```java
// In common package (runs on both sides)
import net.minecraft.client.Minecraft;
import net.minecraft.client.player.LocalPlayer;
import net.minecraft.client.renderer.entity.EntityRenderer;

public class MyCommonClass {
    // Even if you don't use these, having the imports crashes servers!
}
```

**Error**: `ClassNotFoundException` or `NoClassDefFoundError` on dedicated server

**Correct**:
```java
// In common package
import net.minecraft.world.entity.player.Player;  // ← Use common classes
import net.minecraft.server.level.ServerPlayer;  // ← Or server-specific

public class MyCommonClass {
    // Safe - no client imports
}
```

**Rule**: No `net.minecraft.client.*` imports in common/server code

---

### ❌ Mistake: Not Checking isClientSide

**Wrong**:
```java
@SubscribeEvent
public static void onBlockPlace(BlockEvent.EntityPlaceEvent event) {
    // Runs on BOTH client and server!
    BlockPos pos = event.getPos();
    MyData.trackBlock(pos);  // ← Runs twice! (client + server)
}
```

**Problem**: Logic runs twice, causes duplication bugs

**Correct**:
```java
@SubscribeEvent
public static void onBlockPlace(BlockEvent.EntityPlaceEvent event) {
    if (event.getLevel().isClientSide()) return;  // ← Only run on server

    BlockPos pos = event.getPos();
    MyData.trackBlock(pos);  // ← Runs once
}
```

**Rule**: Most game logic should run **server-only**. Check `isClientSide()` in events.

---

### ❌ Mistake: Client-Only Annotations Forgotten

**Wrong**:
```java
// This class has client-only code but no @OnlyIn annotation
public class ClientRenderHelper {
    public static void renderCustomOverlay() {
        Minecraft mc = Minecraft.getInstance();  // ← Crashes on server!
    }
}
```

**Correct (Forge)**:
```java
@OnlyIn(Dist.CLIENT)  // ← Prevents loading on server
public class ClientRenderHelper {
    public static void renderCustomOverlay() {
        Minecraft mc = Minecraft.getInstance();  // ← Safe, only loads on client
    }
}
```

**Correct (Fabric)**:
```java
// Put in separate source set: src/client/java/
@Environment(EnvType.CLIENT)
public class ClientRenderHelper {
    // ...
}
```

---

## Category 3: NBT Data Storage

### ❌ Mistake: Not Checking for NBT Existence

**Wrong**:
```java
public static int getCharges(ItemStack stack) {
    return stack.getTag().getInt("charges");  // ← NPE if no NBT!
}
```

**Error**: `NullPointerException` if ItemStack never had NBT written

**Correct**:
```java
public static int getCharges(ItemStack stack) {
    if (stack.hasTag() && stack.getTag().contains("charges")) {
        return stack.getTag().getInt("charges");
    }
    return 0;  // Default value
}

// Or simpler:
public static int getCharges(ItemStack stack) {
    return stack.getOrCreateTag().getInt("charges");  // ← Returns 0 if not present
}
```

---

### ❌ Mistake: Wrong NBT Type

**Wrong**:
```java
tag.putInt("progress", 0.5);  // ← 0.5 is double, not int!
```

**Problem**: Truncates to 0, loses precision

**Correct**:
```java
tag.putDouble("progress", 0.5);  // ← Use correct type
// Or: tag.putFloat("progress", 0.5F);
```

**NBT Type Reference**:
- `putInt` / `getInt` - Integers
- `putFloat` / `getFloat` - Floating point
- `putDouble` / `getDouble` - Double precision
- `putString` / `getString` - Text
- `putBoolean` / `getBoolean` - True/false
- `put` / `get` (CompoundTag) - Nested data

---

### ❌ Mistake: Not Providing Defaults

**Wrong**:
```java
public static String getOwner(ItemStack stack) {
    return stack.getOrCreateTag().getString("owner");  // ← Returns "" if not set
}

if (getOwner(stack).equals("Notch")) {  // ← Comparing with empty string fails
    // ...
}
```

**Correct**:
```java
public static String getOwner(ItemStack stack) {
    if (!stack.hasTag() || !stack.getTag().contains("owner")) {
        return "Unknown";  // ← Provide meaningful default
    }
    return stack.getTag().getString("owner");
}
```

---

## Category 4: Event Handling

### ❌ Mistake: Non-Static Event Handlers Without Registration

**Wrong**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class MyEvents {
    @SubscribeEvent
    public void onEvent(SomeEvent event) {  // ← NOT STATIC!
        // This will never be called!
    }
}
```

**Problem**: Non-static methods require instance registration, but @EventBusSubscriber only works with static

**Correct Option 1** - Make it static:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)
public class MyEvents {
    @SubscribeEvent
    public static void onEvent(SomeEvent event) {  // ← STATIC
        // This works!
    }
}
```

**Correct Option 2** - Manual registration:
```java
public class MyEvents {
    public MyEvents() {
        MinecraftForge.EVENT_BUS.register(this);  // ← Register instance
    }

    @SubscribeEvent
    public void onEvent(SomeEvent event) {  // ← Can be non-static
        // This works!
    }
}
```

---

### ❌ Mistake: Wrong Event Bus

**Wrong**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.MOD)  // ← MOD bus
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        // This event is on FORGE bus, not MOD bus - never fires!
    }
}
```

**Correct**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)  // ← FORGE bus
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        // Now it works!
    }
}
```

**Rule**:
- **MOD bus**: Lifecycle events (FMLCommonSetupEvent, RegisterEvent, etc.)
- **FORGE bus**: Gameplay events (PlayerEvent, LivingDeathEvent, TickEvent, etc.)

---

### ❌ Mistake: Canceling Non-Cancelable Events

**Wrong**:
```java
@SubscribeEvent
public static void onTick(TickEvent.ServerTickEvent event) {
    event.setCanceled(true);  // ← This event is not cancelable!
}
```

**Error**: Sometimes silent failure, sometimes exception

**Correct**:
```java
// Check if event is cancelable first
@SubscribeEvent
public static void onBlockBreak(BlockEvent.BreakEvent event) {
    if (event.isCancelable()) {  // ← Check first
        event.setCanceled(true);
    }
}
```

---

## Category 5: Resource Files

### ❌ Mistake: Missing parent in Item Model

**Wrong** (`models/item/custom_item.json`):
```json
{
  "textures": {
    "layer0": "modid:item/custom_item"
  }
}
```

**Problem**: No `parent` specified, item appears flat/broken

**Correct**:
```json
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "modid:item/custom_item"
  }
}
```

**Common Parents**:
- `minecraft:item/generated` - Standard 2D item (most items)
- `minecraft:item/handheld` - Tools, weapons (renders in hand)
- `minecraft:block/cube_all` - Simple cube blocks

---

### ❌ Mistake: Wrong Texture Path

**Wrong**:
```json
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "modid:custom_item"  // ← Missing "item/" prefix!
  }
}
```

**Correct**:
```json
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "modid:item/custom_item"  // ← Full path from textures/
  }
}
```

**Path Resolution**:
- `"modid:item/custom_item"` → `assets/modid/textures/item/custom_item.png`
- `"minecraft:block/stone"` → `assets/minecraft/textures/block/stone.png`

---

### ❌ Mistake: Missing Lang Keys

**Problem**: Item shows as `item.modid.custom_item` in-game instead of "Custom Item"

**Solution**: Add to `assets/modid/lang/en_us.json`:
```json
{
  "item.modid.custom_item": "Custom Item",
  "item.modid.ruby_sword": "Ruby Sword",
  "block.modid.custom_block": "Custom Block"
}
```

**Lang Key Format**:
- Items: `item.modid.registry_name`
- Blocks: `block.modid.registry_name`
- Entities: `entity.modid.registry_name`
- Item Groups: `itemGroup.modid.tab_name`

---

## Category 6: Build and Gradle

### ❌ Mistake: Wrong Minecraft Version

**Problem**: Mod built for 1.20.1 doesn't work in 1.20.4

**Solution**: Check `gradle.properties`:
```properties
minecraft_version=1.20.1  # ← Must match target version EXACTLY
forge_version=47.1.0      # ← Use correct Forge version for this Minecraft version
```

**Rule**: Mods are NOT forward/backward compatible across Minecraft versions

---

### ❌ Mistake: Missing Dependencies

**Wrong** (`build.gradle`):
```gradle
dependencies {
    minecraft "net.minecraftforge:forge:${minecraft_version}-${forge_version}"
    // Missing other mod dependencies!
}
```

**Correct**:
```gradle
dependencies {
    minecraft "net.minecraftforge:forge:${minecraft_version}-${forge_version}"

    // If your mod depends on JEI:
    compileOnly fg.deobf("mezz.jei:jei-${minecraft_version}-common-api:${jei_version}")
    runtimeOnly fg.deobf("mezz.jei:jei-${minecraft_version}-forge:${jei_version}")
}
```

---

## Category 7: Performance

### ❌ Mistake: Expensive Operations in Tick Handler

**Wrong**:
```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    // Runs 20 times per second!
    for (Player player : allPlayers) {
        for (Block block : nearbyBlocks) {  // ← O(n²) every tick!
            // Expensive calculation
        }
    }
}
```

**Problem**: Massive lag, server TPS drops

**Correct**: Use interval gating
```java
private static int tickCounter = 0;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;

    tickCounter++;
    if (tickCounter % 20 != 0) return;  // ← Only run once per second

    // Expensive operation now runs 1/sec instead of 20/sec
}
```

---

### ❌ Mistake: Creating Unnecessary Particles

**Wrong**:
```java
// Spawns 100 particles EVERY TICK
for (int i = 0; i < 100; i++) {
    level.addParticle(ParticleTypes.FLAME, x, y, z, 0, 0, 0);
}
```

**Problem**: Particle spam causes FPS drops

**Correct**:
```java
// Spawn reasonable amount with randomness
if (level.random.nextFloat() < 0.1F) {  // ← 10% chance per tick
    level.addParticle(ParticleTypes.FLAME, x, y, z, 0, 0, 0);
}
```

---

## Category 8: Fabric-Specific

### ❌ Mistake: Forgetting fabric.mod.json

**Problem**: Mod doesn't load, no error message

**Solution**: Create `src/main/resources/fabric.mod.json`:
```json
{
  "schemaVersion": 1,
  "id": "mymod",
  "version": "1.0.0",
  "name": "My Mod",
  "entrypoints": {
    "main": [
      "com.example.mymod.MyModInitializer"
    ],
    "client": [
      "com.example.mymod.MyModClient"
    ]
  },
  "depends": {
    "fabricloader": ">=0.14.0",
    "minecraft": "1.20.x"
  }
}
```

---

## Quick Reference: Top 10 Mistakes

1. ❌ Using uppercase in registry names
2. ❌ Using `Minecraft.getInstance()` in common code (server crash!)
3. ❌ Not checking `isClientSide` in events
4. ❌ Non-static event handlers without manual registration
5. ❌ Not checking for NBT existence before reading
6. ❌ Missing resource files (models, textures, lang)
7. ❌ Wrong event bus (MOD vs FORGE)
8. ❌ Registry name mismatch with resource files
9. ❌ Forgetting to call `.register()` on DeferredRegister
10. ❌ Expensive operations in tick handlers (performance)

---

## See Also

- [Main Tutorial Patterns](./SKILL.md)
- [Exercise Templates](./exercise-templates.md)
- [Framework Comparison Guides](./framework-comparisons.md)
