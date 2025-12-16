# Detailed Testing Guide

Complete step-by-step testing workflow and console monitoring patterns for Minecraft mod testing.

## Testing Workflow (Detailed)

### Step 1: Discover Run Configurations

Use `mcp__intellij__get_run_configurations()`:

```
get_run_configurations()

Expected return:
[
  {name: "runClient", type: "Application", ...},
  {name: "runServer", type: "Application", ...},
  {name: "runData", type: "Application", ...}
]

Analysis:
- runClient found → Forge/Fabric client setup ✅
- runServer found → Server testing available ✅
- runData found → Data generation configured ✅
```

**If no configurations found**:
```
Error: No run configurations available

Possible causes:
1. Gradle project not synced
2. ForgeGradle/Loom not applied
3. Run configurations not generated

Recommend:
- Run ./gradlew --refresh-dependencies
- Check build.gradle for ForgeGradle/Loom plugin
```

### Step 2: Select Appropriate Configuration

**Based on feature type**:

| Feature Type | Run Config | Reason |
|--------------|------------|--------|
| Items, blocks, entities (general) | runClient | Visual testing needed |
| GUI, rendering, sounds | runClient | Client-side only |
| Commands, world gen | runServer | Server-side feature |
| Data generation | runData | Generate recipes/loot |
| Network packets | Both | Test client-server communication |

**User request mapping**:
```
"test the mod" → runClient (default)
"test server" → runServer
"generate data" → runData
"test in-game" → runClient
```

### Step 3: Execute Run Configuration

Use `mcp__intellij__execute_run_configuration(name, timeout, maxLinesCount)`:

```
execute_run_configuration(
    "runClient",
    timeout=120000,  // 2 minutes (startup can be slow)
    maxLinesCount=200  // Last 200 lines of console
)

Typical startup time:
- Client: 30-90 seconds
- Server: 20-60 seconds
- Data gen: 10-30 seconds
```

**Timeout considerations**:
- First run: Slower (downloading assets)
- Subsequent runs: Faster (cached)
- Large mods: May need longer timeout
- Data generation: Usually quick

### Step 4: Monitor Startup Progress

**Watch for key log messages**:

**Minecraft loading phases**:
```
[INFO] Minecraft starting...
[INFO] Loading resource packs...
[INFO] Initializing game engine...
[INFO] Loading mods...               ← Mod loading begins
[INFO] Loading mod mymod version 1.0.0  ← Our mod detected
[INFO] Registering items...
[INFO] Registered 15 items            ← Registry success
[INFO] Minecraft client started       ← Client ready
```

**Progress indicators**:
```
Early: "Initializing Minecraft Engine"
Middle: "Loading mods"
Late: "Minecraft client started"
```

**Filter output** (focus on mod-specific logs):
```
Search console for: "mymod" or MOD_ID
Ignore: Vanilla Minecraft logs (unless errors)
```

### Step 5: Verify Mod Loading

**Success indicators**:

**Forge/NeoForge**:
```
[INFO] [mymod/]: Loading mod mymod version 1.0.0
[INFO] [mymod/]: Registered 15 items
[INFO] [mymod/]: Registered 8 blocks
[INFO] [mymod/]: Mod mymod loaded successfully
```

**Fabric**:
```
[INFO] Loading mod mymod 1.0.0
[INFO] [mymod] Registering items...
[INFO] [mymod] Registered 15 items
```

**Feature-specific logs** (from implemented code):
```
[INFO] [mymod/]: Custom entity registered: ruby_golem
[INFO] [mymod/]: Event handler registered: PlayerJoinHandler
[INFO] [mymod/]: Configuration loaded: maxEnergy=1000
```

**Error indicators**:
```
❌ [ERROR] [mymod/]: Failed to load mod
❌ [FATAL] Exception during mod loading
❌ java.lang.NullPointerException
❌ java.lang.NoSuchMethodError
❌ Missing dependency: requiredmod
```

### Step 6: Report Results

**Success report**:
```
✅ Mod loaded successfully

Console verification:
- Loading mod mymod version 1.0.0 ✅
- Registered 15 items ✅
- Registered 8 blocks ✅
- Minecraft client started ✅

No errors detected in console output.

Feature verification:
- Ruby sword item appears in creative tab ✅
- Custom entity spawns correctly ✅
- Event handler logs confirm execution ✅

Testing complete. Mod is ready for use.
```

**Failure report**:
```
❌ Mod failed to load

Error detected:
[ERROR] [mymod/]: Failed to register item: ruby_sword
java.lang.IllegalArgumentException: Registry name already exists

Root cause: Duplicate registry entry

Action required:
- Check ModItems.java for duplicate "ruby_sword" registration
- Verify no other mod registers same name
- Fix registration code and retest

Console excerpt:
[Full error stack trace...]
```

---

## Console Monitoring Patterns

### Success Indicators

**General mod loading**:
```
✅ "Loading mod {modid}"
✅ "Mod {modid} version {version}"
✅ "Registered X items/blocks/entities"
✅ "Successfully loaded mod"
✅ "Minecraft client/server started"
```

**Registry events**:
```
✅ "Registering items for {modid}"
✅ "Registered item: {item_name}"
✅ "Registry event completed successfully"
```

**Feature-specific** (from your code):
```
✅ "[mymod] Custom feature initialized"
✅ "[mymod] Configuration loaded: {values}"
✅ "[mymod] Event handler registered"
```

### Error Indicators

**Critical errors**:
```
❌ "[ERROR]" (any error message)
❌ "[FATAL]" (fatal error, crash)
❌ "java.lang.Exception" (exception occurred)
❌ "Failed to load mod"
❌ "Missing dependency"
```

**Common errors and meanings**:

**NoSuchMethodError**:
```
java.lang.NoSuchMethodError: net.minecraft.world.item.Item.getDefaultInstance()

Cause: API version mismatch (wrong Minecraft version)
Fix: Update Minecraft/Forge/Fabric version in build.gradle
```

**NullPointerException**:
```
java.lang.NullPointerException
  at com.mod.items.CustomItem.use(CustomItem.java:42)

Cause: Uninitialized variable or null reference
Fix: Check line 42 in CustomItem.java, add null check
```

**IllegalArgumentException (Registry)**:
```
java.lang.IllegalArgumentException: Registry name already exists: mymod:ruby_sword

Cause: Duplicate registry entry
Fix: Remove duplicate registration or rename item
```

**Missing dependency**:
```
Missing or unsupported mandatory dependencies:
  Mod ID: 'requiredmod', Requested by: 'mymod'

Cause: Declared dependency not installed
Fix: Remove dependency from mods.toml/fabric.mod.json or install required mod
```

### Progress Tracking

**Startup phases**:
```
Phase 1 (0-20s): "Initializing Minecraft Engine"
Phase 2 (20-40s): "Loading mods"
Phase 3 (40-60s): "Registering items/blocks"
Phase 4 (60-80s): "Loading world" (if applicable)
Phase 5 (80-90s): "Minecraft started"
```

**Long-running operations**:
```
World generation: "Preparing spawn area: X%"
Data generation: "Generating recipes..."
Asset loading: "Reloading resource packs"
```
