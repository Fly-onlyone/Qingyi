# Minecraft-Specific IntelliJ Inspections Catalog

Complete catalog of IntelliJ IDEA inspections relevant to Minecraft mod development, organized by category with explanations, causes, and fixes.

---

## Registry Errors

### Error: Cannot resolve symbol 'MODID'

**IntelliJ Description**: `Cannot resolve symbol 'MODID'`

**What it means**: The MODID constant is not defined or not in scope.

**Common causes**:
- MODID constant not defined in main mod class
- MODID defined in different class but not imported
- Typo in variable name

**Example**:
```java
public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);  // ❌ MODID not defined
}
```

**Fix**:
```java
// Option 1: Define in same class
public class ModItems {
    public static final String MODID = "yourmodid";

    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, MODID);  // ✓ Now defined
}

// Option 2: Import from main mod class
import com.example.yourmod.YourMod;

public class ModItems {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, YourMod.MODID);  // ✓ Imported
}
```

**Auto-fixable?**: ❌ No - Requires user to provide value

---

### Error: Type mismatch in DeferredRegister

**IntelliJ Description**: `Type mismatch: cannot convert from DeferredRegister<Item> to DeferredRegister<Block>`

**What it means**: Generic type parameter doesn't match the registry type.

**Example**:
```java
public static final DeferredRegister<Block> BLOCKS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);  // ❌ Block vs Items
```

**Fix**:
```java
// Change ForgeRegistries to match generic type
public static final DeferredRegister<Block> BLOCKS =
    DeferredRegister.create(ForgeRegistries.BLOCKS, MODID);  // ✓ Block matches BLOCKS
```

**Auto-fixable?**: ❌ No - Requires semantic understanding

---

### Warning: Field 'RUBY' may not be initialized

**IntelliJ Description**: `Field 'RUBY' may not be initialized`

**What it means**: RegistryObject field declared but DeferredRegister never registered.

**Example**:
```java
@Mod("mymod")
public class MyMod {
    public static final DeferredRegister<Item> ITEMS =
        DeferredRegister.create(ForgeRegistries.ITEMS, "mymod");

    public static final RegistryObject<Item> RUBY = ITEMS.register("ruby", ...);

    public MyMod() {
        // ❌ Forgot to call ITEMS.register(bus)
    }
}
```

**Fix**:
```java
public MyMod() {
    IEventBus modBus = FMLJavaModLoadingContext.get().getModEventBus();
    ITEMS.register(modBus);  // ✓ Register the DeferredRegister
}
```

**Auto-fixable?**: ❌ No - Requires architectural understanding

---

## Event Handler Errors

### Warning: Missing @Mod.EventBusSubscriber

**IntelliJ Description**: `Method annotated with @SubscribeEvent but class lacks @Mod.EventBusSubscriber`

**What it means**: Static event handler method exists but class isn't annotated for automatic registration.

**Example**:
```java
public class EventHandler {  // ❌ Missing annotation
    @SubscribeEvent
    public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
        // Implementation
    }
}
```

**Fix**:
```java
@Mod.EventBusSubscriber(modid = "yourmodid", bus = Mod.EventBusSubscriber.Bus.FORGE)
public class EventHandler {  // ✓ Now annotated
    @SubscribeEvent
    public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
        // Implementation
    }
}
```

**Auto-fixable?**: ✅ Yes - Standard pattern, can infer bus from event type

**Auto-fix logic**:
1. Detect event parameter type
2. Determine bus (Registry events → MOD, Gameplay events → FORGE)
3. Add annotation with correct bus

---

### Warning: Non-static @SubscribeEvent method

**IntelliJ Description**: `Non-static @SubscribeEvent method may not be registered`

**What it means**: Event handler is not static, requires manual registration.

**Example**:
```java
public class EventHandler {
    @SubscribeEvent
    public void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {  // ❌ Not static
        // Implementation
    }
}
```

**Fix Option 1 (Preferred)**: Make method static
```java
public class EventHandler {
    @SubscribeEvent
    public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {  // ✓ Static
        // Implementation
    }
}
```

**Fix Option 2**: Manually register instance
```java
public class EventHandler {
    @SubscribeEvent
    public void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
        // Implementation
    }
}

// In main mod class constructor:
MinecraftForge.EVENT_BUS.register(new EventHandler());
```

**Auto-fixable?**: ✅ Partially - Can make static if class has no instance fields

---

### Warning: Wrong event bus

**IntelliJ Description**: `PlayerEvent.PlayerLoggedInEvent fires on FORGE bus, not MOD bus`

**What it means**: Event is registered on wrong bus and won't fire.

**Event Bus Reference**:
- **MOD bus**: Registry events, mod lifecycle (FMLCommonSetupEvent, FMLClientSetupEvent)
- **FORGE bus**: Gameplay events (PlayerEvent, LivingEvent, BlockEvent, TickEvent, etc.)

**Example**:
```java
@Mod.EventBusSubscriber(modid = "mymod", bus = Mod.EventBusSubscriber.Bus.MOD)  // ❌ Wrong bus
public class EventHandler {
    @SubscribeEvent
    public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
        // Will never fire!
    }
}
```

**Fix**:
```java
@Mod.EventBusSubscriber(modid = "mymod", bus = Mod.EventBusSubscriber.Bus.FORGE)  // ✓ Correct bus
public class EventHandler {
    @SubscribeEvent
    public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {
        // Will fire correctly
    }
}
```

**Auto-fixable?**: ❌ No - Requires event type analysis (but could be enhanced with lookup table)

---

### Warning: Generic event parameter type

**IntelliJ Description**: `Event handler parameter should be specific event type, not base class`

**What it means**: Using base event class instead of specific event type.

**Example**:
```java
@SubscribeEvent
public static void onPlayerEvent(PlayerEvent event) {  // ❌ Too generic
    // Which player event? Login? Logout? Respawn?
}
```

**Fix**:
```java
@SubscribeEvent
public static void onPlayerLogin(PlayerEvent.PlayerLoggedInEvent event) {  // ✓ Specific
    // Now it's clear this handles login
}
```

**Auto-fixable?**: ❌ No - Requires semantic understanding of intent

---

## Client/Server Safety Errors

### Error: Missing @OnlyIn for client-only code

**IntelliJ Description**: `Minecraft.getInstance() not available on dedicated server. Add @OnlyIn(Dist.CLIENT)`

**What it means**: Using client-only API without annotation, will crash dedicated server.

**Example**:
```java
public class ModEvents {
    @SubscribeEvent
    public static void onClientTick(TickEvent.ClientTickEvent event) {  // ❌ No @OnlyIn
        Minecraft.getInstance().player.sendSystemMessage(...);
    }
}
```

**Fix**:
```java
@OnlyIn(Dist.CLIENT)  // ✓ Annotated as client-only
public class ModEvents {
    @SubscribeEvent
    public static void onClientTick(TickEvent.ClientTickEvent event) {
        Minecraft.getInstance().player.sendSystemMessage(...);
    }
}
```

**Auto-fixable?**: ✅ Yes - Can detect client-only APIs and add annotation

---

### Error: Client class imported in common code

**IntelliJ Description**: `Cannot import client-only class in server-safe code`

**What it means**: Client class (`net.minecraft.client.*`) imported in code that runs on server.

**Example**:
```java
package com.example.mymod;

import net.minecraft.client.Minecraft;  // ❌ Client-only import

public class CommonHandler {
    public void doSomething() {
        // This class needs to work on dedicated server!
    }
}
```

**Fix Option 1**: Move to client package
```java
package com.example.mymod.client;  // ✓ Client package

import net.minecraft.client.Minecraft;

@OnlyIn(Dist.CLIENT)
public class ClientHandler {
    public void doSomething() {
        // This is explicitly client-only
    }
}
```

**Fix Option 2**: Use DistExecutor
```java
package com.example.mymod;

import net.minecraftforge.fml.DistExecutor;

public class CommonHandler {
    public void doSomething() {
        DistExecutor.unsafeRunWhenOn(Dist.CLIENT, () -> () -> ClientHandler.doClientStuff());
    }
}
```

**Auto-fixable?**: ❌ No - Requires architectural decision

---

### Error: Minecraft.getInstance() without safety check

**IntelliJ Description**: `Minecraft.getInstance() call may crash on dedicated server`

**What it means**: Calling client-only API in code that could run on server.

**Example**:
```java
public class Utils {
    public static void showMessage(String text) {
        Minecraft.getInstance().player.sendSystemMessage(...);  // ❌ Crashes on server
    }
}
```

**Fix Option 1**: Add @OnlyIn
```java
@OnlyIn(Dist.CLIENT)
public class Utils {
    public static void showMessage(String text) {
        Minecraft.getInstance().player.sendSystemMessage(...);  // ✓ Client-only
    }
}
```

**Fix Option 2**: Side check
```java
public class Utils {
    public static void showMessage(String text) {
        if (FMLEnvironment.dist.isClient()) {  // ✓ Runtime check
            Minecraft.getInstance().player.sendSystemMessage(...);
        }
    }
}
```

**Auto-fixable?**: ❌ No - Requires understanding of call context

---

## NBT Serialization Errors

### Warning: Missing serialization interface

**IntelliJ Description**: `Class should implement INBTSerializable for persistence`

**What it means**: Class stores data but doesn't implement serialization interface.

**Example**:
```java
public class CustomCapability implements ICapabilityProvider {  // ❌ No serialization
    private int progress = 0;

    // No save/load methods
}
```

**Fix**:
```java
public class CustomCapability implements ICapabilityProvider, INBTSerializable<CompoundTag> {
    private int progress = 0;

    @Override
    public CompoundTag serializeNBT() {
        CompoundTag tag = new CompoundTag();
        tag.putInt("progress", progress);
        return tag;
    }

    @Override
    public void deserializeNBT(CompoundTag tag) {
        progress = tag.getInt("progress");
    }
}
```

**Auto-fixable?**: ❌ No - Requires understanding of what data to serialize

---

### Error: Wrong NBT tag type

**IntelliJ Description**: `putInt expects int, but found double`

**What it means**: Using wrong NBT method for data type.

**NBT Type Reference**:
- `putByte()` - byte
- `putShort()` - short
- `putInt()` - int
- `putLong()` - long
- `putFloat()` - float
- `putDouble()` - double
- `putString()` - String
- `putBoolean()` - boolean
- `putUUID()` - UUID

**Example**:
```java
CompoundTag tag = new CompoundTag();
tag.putInt("progress", 0.5);  // ❌ putInt expects int, not double
tag.putString("count", 42);   // ❌ putString expects String, not int
```

**Fix**:
```java
CompoundTag tag = new CompoundTag();
tag.putDouble("progress", 0.5);  // ✓ Correct type
tag.putInt("count", 42);         // ✓ Correct type
```

**Auto-fixable?**: ❌ No - Requires type analysis

---

## Resource Location Errors

### Error: Invalid resource location format

**IntelliJ Description**: `Resource location namespace must be lowercase`

**What it means**: ResourceLocation namespace contains uppercase letters (invalid).

**Example**:
```java
new ResourceLocation("MyMod:custom_item");  // ❌ Uppercase namespace
new ResourceLocation("myMod", "Custom_Item");  // ❌ Uppercase in path
```

**Fix**:
```java
new ResourceLocation("mymod:custom_item");  // ✓ All lowercase
new ResourceLocation("mymod", "custom_item");  // ✓ All lowercase
```

**Auto-fixable?**: ✅ Yes - Can convert to lowercase

**Auto-fix logic**:
```java
// Before: new ResourceLocation("MyMod:custom_item")
// After:  new ResourceLocation("mymod:custom_item")
```

---

### Warning: Missing resource files

**IntelliJ Description**: `Sound file assets/modid/sounds/custom_sound.ogg not found`

**What it means**: Code references resource file that doesn't exist.

**Example**:
```java
public static final SoundEvent CUSTOM_SOUND = SoundEvent.createVariableRangeEvent(
    new ResourceLocation(MODID, "custom_sound")  // ⚠️ File doesn't exist
);
```

**Expected location**: `src/main/resources/assets/modid/sounds/custom_sound.ogg`

**Fix**: Create the missing resource file or fix the reference

**Auto-fixable?**: ❌ No - File must be created manually

---

## Code Formatting Issues

### Info: Unused import

**IntelliJ Description**: `Unused import 'java.util.List'`

**What it means**: Import statement not used anywhere in the file.

**Example**:
```java
import java.util.List;  // ❌ Unused
import net.minecraft.world.item.Item;

public class ModItems {
    // List is never used
}
```

**Fix**: Remove the unused import (automatically handled by reformat)

**Auto-fixable?**: ✅ Yes - `reformat_file` automatically removes unused imports

---

### Info: Wrong indentation

**IntelliJ Description**: `Statement is indented incorrectly`

**What it means**: Indentation doesn't match code style settings.

**Example**:
```java
public class ModItems {
public static final DeferredRegister<Item> ITEMS = ...;  // ❌ No indentation
    public static final RegistryObject<Item> RUBY = ...;  // ❌ Wrong indentation (2 vs 4 spaces)
}
```

**Fix**: Apply consistent 4-space indentation

**Auto-fixable?**: ✅ Yes - `reformat_file` fixes all indentation

---

### Info: Missing spaces around operators

**IntelliJ Description**: `Missing space around '='`

**What it means**: Code style requires spaces around operators.

**Example**:
```java
public static final int MAX_COUNT=64;  // ❌ No spaces around =
public static final String NAME ="ruby";  // ❌ Space only on one side
```

**Fix**:
```java
public static final int MAX_COUNT = 64;  // ✓ Spaces on both sides
public static final String NAME = "ruby";  // ✓ Consistent spacing
```

**Auto-fixable?**: ✅ Yes - `reformat_file` adds proper spacing

---

### Info: Long line without wrapping

**IntelliJ Description**: `Line exceeds 120 characters`

**What it means**: Line is too long and should be wrapped for readability.

**Example**:
```java
public static final RegistryObject<Item> CUSTOM_SWORD = ITEMS.register("custom_sword", () -> new SwordItem(Tiers.DIAMOND, 5, -2.4F, new Item.Properties().tab(CreativeModeTab.TAB_COMBAT)));  // ❌ Too long
```

**Fix**:
```java
public static final RegistryObject<Item> CUSTOM_SWORD = ITEMS.register("custom_sword",
    () -> new SwordItem(Tiers.DIAMOND, 5, -2.4F,
        new Item.Properties().tab(CreativeModeTab.TAB_COMBAT)));  // ✓ Wrapped appropriately
```

**Auto-fixable?**: ✅ Yes - `reformat_file` wraps long lines

---

## Summary Table

| Category | Total Inspections | Auto-fixable | Requires User |
|----------|------------------|--------------|---------------|
| Registry | 4 | 1 (25%) | 3 (75%) |
| Event Handlers | 4 | 2 (50%) | 2 (50%) |
| Client/Server | 3 | 1 (33%) | 2 (67%) |
| NBT Serialization | 2 | 0 (0%) | 2 (100%) |
| Resource Locations | 2 | 1 (50%) | 1 (50%) |
| Code Formatting | 4 | 4 (100%) | 0 (0%) |
| **Total** | **19** | **9 (47%)** | **10 (53%)** |

---

## Usage in minecraft-code-validator

This catalog serves as the knowledge base for the `minecraft-code-validator` agent to:

1. **Identify** inspection types from `get_file_problems` output
2. **Explain** what each inspection means in Minecraft modding context
3. **Determine** if inspection is auto-fixable
4. **Apply fixes** for auto-fixable issues
5. **Report** non-fixable issues with detailed guidance

For detailed validation workflow, see [SKILL.md](./SKILL.md).
