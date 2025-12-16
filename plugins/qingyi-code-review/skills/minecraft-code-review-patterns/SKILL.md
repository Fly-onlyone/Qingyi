---
name: minecraft-code-review-patterns
description: Code review checklists for Minecraft mods covering registry validation, event handler safety, client/server separation, NBT security, performance patterns, and resource file validation. Use when reviewing mod implementations or conducting security audits.
---

# Minecraft Code Review Patterns

## Overview

This skill provides comprehensive code review checklists and patterns specific to Minecraft mod development, with emphasis on security, performance, and correctness across Forge, NeoForge, and Fabric frameworks.

## When to Use This Skill

- Reviewing pull requests for Minecraft mods
- Conducting security audits of mod code
- Pre-release code validation
- Identifying common mod bugs and vulnerabilities
- Performance optimization reviews

## Registry System Review

### Checklist

- ✅ **DeferredRegister used correctly** (Forge/NeoForge)
  - Static final field
  - Registered to correct event bus
  - RegistryObject for type-safe references

- ✅ **Registry.register used correctly** (Fabric)
  - Identifier namespace matches mod ID
  - Registry name lowercase snake_case

- ✅ **Registry names match resource files**
  - `assets/modid/models/item/registry_name.json`
  - `assets/modid/textures/item/registry_name.png`
  - `item.modid.registry_name` in lang files

- ❌ **No hardcoded registry references**
  - Don't use `ForgeRegistries.ITEMS.getValue(...)` in business logic
  - Use RegistryObject or item tags instead

**Example Review**:
```java
// ❌ BAD: Registry name doesn't match file name
public static final RegistryObject<Item> CUSTOM_ITEM = ITEMS.register("customItem", ...);
// File: custom_item.json ← Mismatch!

// ✅ GOOD: Exact match
public static final RegistryObject<Item> CUSTOM_ITEM = ITEMS.register("custom_item", ...);
// File: custom_item.json ← Match!
```

---

## Event Handler Review

### Checklist

- ✅ **@Mod.EventBusSubscriber annotation present**
  - Correct bus (MOD vs FORGE)
  - Correct Dist if client-only

- ✅ **Static methods or manual registration**
  - Non-static requires instance registration
  - Document why non-static if used

- ✅ **Correct event bus**
  - MOD bus: Lifecycle events (FMLCommonSetupEvent, RegisterEvent)
  - FORGE bus: Gameplay events (PlayerEvent, LivingDeathEvent, TickEvent)

- ✅ **Event cancellation checked before proceeding**
  - Check `isCancelable()` before `setCanceled(true)`
  - Respect other mods' cancellations

- ❌ **No heavy computation in event handlers**
  - Tick events: Profile performance, use interval gating
  - Block break/place: Avoid expensive lookups

**Example Review**:
```java
// ❌ BAD: Wrong bus
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.MOD)  // ← MOD bus
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        // This event is on FORGE bus - never fires!
    }
}

// ✅ GOOD: Correct bus
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.FORGE)  // ← FORGE bus
public class MyEvents {
    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        // Now it works!
    }
}
```

---

## Client/Server Separation Review (CRITICAL)

### Checklist

- ✅ **No `net.minecraft.client.*` imports in common code**
  - Crashes dedicated servers instantly
  - Move to client package with @OnlyIn(Dist.CLIENT)

- ✅ **No `Minecraft.getInstance()` outside client code**
  - Use Player/ServerPlayer instead
  - Check `level.isClientSide` for conditional logic

- ✅ **@OnlyIn(Dist.CLIENT) on client-only code**
  - Renderers, GUIs, key bindings
  - Client event handlers

- ✅ **Logical side checks before operations**
  - `if (!level.isClientSide)` before server operations
  - `if (level.isClientSide)` before client operations

- ❌ **Particles spawned only on client**
  - `level.addParticle()` should check `isClientSide`

- ❌ **Entities spawned only on server**
  - `level.addFreshEntity()` should check `!isClientSide`

**Security Impact**: Client/server violations can be exploited for DoS attacks (crash servers)

**Example Review**:
```java
// ❌ CRITICAL BUG: Crashes dedicated server
public class CommonCode {
    @SubscribeEvent
    public static void onEvent(SomeEvent event) {
        Minecraft.getInstance().player.sendMessage(...);  // ← CRASH!
    }
}

// ✅ FIXED: Server-safe
public class CommonCode {
    @SubscribeEvent
    public static void onEvent(SomeEvent event) {
        Player player = event.getPlayer();
        if (!player.level().isClientSide) {
            player.sendSystemMessage(...);  // ← Safe
        }
    }
}
```

---

## NBT Serialization Review

### Checklist

- ✅ **Proper tag types**
  - `putInt` for integers, `putDouble` for doubles
  - Don't mix types (e.g., `putInt` then `getDouble`)

- ✅ **Null checks before reading NBT**
  - `stack.hasTag()` before `stack.getTag()`
  - Provide default values for missing tags

- ✅ **Default values for missing tags**
  - Don't assume tag exists
  - `tag.contains("key")` before reading

- ❌ **No unbounded NBT growth**
  - Lists/arrays with size limits
  - Prevent save corruption from huge NBT

- ❌ **No sensitive data in NBT without encryption**
  - NBT can be edited externally (NBT editors)
  - Don't store passwords, API keys, etc.

**Security Issue**: NBT can be edited externally → item duplication, privilege escalation

**Example Review**:
```java
// ❌ BAD: No null check, no default
public static int getCharges(ItemStack stack) {
    return stack.getTag().getInt("charges");  // ← NPE if no NBT!
}

// ✅ GOOD: Null-safe with default
public static int getCharges(ItemStack stack) {
    return stack.getOrCreateTag().getInt("charges");  // ← Returns 0 if not present
}

// ❌ BAD: Unbounded list growth
public void addHistory(CompoundTag tag, String entry) {
    ListTag list = tag.getList("history", Tag.TAG_STRING);
    list.add(StringTag.valueOf(entry));  // ← No size limit!
    tag.put("history", list);
}

// ✅ GOOD: Size-limited
public void addHistory(CompoundTag tag, String entry) {
    ListTag list = tag.getList("history", Tag.TAG_STRING);
    if (list.size() < 100) {  // ← Limit to 100 entries
        list.add(StringTag.valueOf(entry));
    }
    tag.put("history", list);
}
```

---

## Resource File Validation

### Checklist

- ✅ **models/item JSON exists for all registered items**
  - Parent: `minecraft:item/generated` or `minecraft:item/handheld`
  - Texture path correct: `modid:item/registry_name`

- ✅ **Textures exist at correct paths**
  - `assets/modid/textures/item/registry_name.png`
  - PNG format, power-of-2 dimensions (16x16, 32x32, etc.)

- ✅ **Lang keys present for all content**
  - `item.modid.registry_name` for items
  - `block.modid.registry_name` for blocks
  - `entity.modid.registry_name` for entities

- ❌ **No missing resources**
  - Missing model = purple/black checkerboard
  - Missing lang key = `item.modid.registry_name` shown in-game

**Example Review**:
```java
// Registry:
ITEMS.register("ruby_sword", () -> new SwordItem(...));

// Required files:
// ✅ assets/mymod/models/item/ruby_sword.json
// ✅ assets/mymod/textures/item/ruby_sword.png
// ✅ assets/mymod/lang/en_us.json: "item.mymod.ruby_sword": "Ruby Sword"
```

---

## Performance Review

### Checklist

- ✅ **Tick handlers with interval gating**
  - Not every tick for expensive operations
  - Use `tickCounter % 20` for 1/sec execution

- ✅ **Efficient data structures**
  - HashMap for O(1) lookups, not ArrayList with linear search
  - Set for membership tests, not List

- ✅ **Reasonable particle counts**
  - Not 100+ particles per tick
  - Use random chance for particle spawning

- ❌ **No O(n²) operations in tick handlers**
  - Nested loops over entities/blocks
  - Profile expensive operations

**Example Review**:
```java
// ❌ BAD: Every-tick expensive operation
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    for (Player player : allPlayers) {
        for (Block block : nearbyBlocks) {  // ← O(n²) every tick!
            // Expensive calculation
        }
    }
}

// ✅ GOOD: Interval-gated
private static int tickCounter = 0;

@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase != TickEvent.Phase.END) return;

    tickCounter++;
    if (tickCounter % 20 != 0) return;  // ← Only 1/sec

    // Expensive operation runs 1/sec instead of 20/sec
}
```

---

## Security Review Checklist

### Vulnerability Categories

**1. Server Crash (DoS)**:
- Client code in common/server paths → Dedicated server crash
- Unbounded NBT growth → Out of memory
- Exception in tick handler → Server freeze

**2. Item Duplication**:
- Registry name mismatch → Items turn to AIR, can be duped
- NBT tampering → External NBT editors modify item data

**3. Privilege Escalation**:
- NBT stores admin status → Can be edited externally
- Client-side permission checks → Bypassed by modified client

**4. Data Corruption**:
- Unbounded SavedData growth → World save corruption
- Missing NBT defaults → Crash when loading old saves

### Mitigation Strategies

**For DoS**:
- Always test on dedicated server
- Catch exceptions in tick handlers
- Limit NBT growth (max list sizes)

**For Item Duplication**:
- Registry names must be stable across versions
- Use MissingMappingsEvent to handle renames
- Server-side validation of NBT values

**For Privilege Escalation**:
- Never store permissions in client-accessible data
- All permission checks on server
- Use server-side player data storage

**For Data Corruption**:
- Provide NBT defaults for all reads
- Version NBT data (`tag.putInt("version", 1)`)
- Migration logic for old saves

---

## Code Review Template

```markdown
## Code Review: [Pull Request Title]

### Security Review

**Client/Server Separation**: ✅ Pass / ❌ Fail
- [ ] No client imports in common code
- [ ] No Minecraft.getInstance() outside client code
- [ ] Proper @OnlyIn annotations

**NBT Security**: ✅ Pass / ❌ Fail
- [ ] Null checks before reading
- [ ] Bounded collections
- [ ] No sensitive data

**DoS Prevention**: ✅ Pass / ❌ Fail
- [ ] No expensive tick operations
- [ ] Exception handling
- [ ] Resource limits

### Performance Review

- [ ] Tick handlers interval-gated
- [ ] Efficient data structures (HashMap vs ArrayList)
- [ ] Reasonable particle counts

### Correctness Review

- [ ] Registry names match resources
- [ ] Event handlers on correct bus
- [ ] Resources present (models, textures, lang)

### Issues Found

**Critical** (Must fix before merge):
1. [Issue description with line number]

**High** (Should fix):
1. [Issue description with line number]

**Medium** (Consider fixing):
1. [Issue description with line number]

### Recommendations

1. [Improvement suggestion]
2. [Alternative approach]
```

---

## Integration with minecraft-code-validator

**When to use code-reviewer** (this skill):
- Comprehensive review of implementation logic
- Security vulnerability scanning
- Performance optimization suggestions
- Design pattern evaluation
- Educational explanations

**When to use minecraft-code-validator** (Qingyi agent):
- After code generation by specialist agents
- IntelliJ inspection-based error detection
- Auto-fixing simple issues (imports, formatting)
- Quick validation cycles

**They complement each other**:
- **validator** = Fast, automated, IntelliJ-based
- **code-reviewer** = Deep, AI-powered, educational

---

## See Also

- [Security Vulnerabilities Database](./security-vulnerabilities.md) - Common exploits
- [Performance Anti-Patterns](./performance-antipatterns.md) - Performance issues
