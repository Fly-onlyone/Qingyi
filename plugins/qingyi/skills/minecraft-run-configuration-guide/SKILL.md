---
name: minecraft-run-configuration-guide
description: IntelliJ run configurations for Minecraft modding. Covers runClient, runServer, runData, program arguments, JVM options, data generation providers, testing workflows. Use when executing or debugging Minecraft mods.
allowed-tools: mcp__intellij__get_run_configurations, mcp__intellij__execute_run_configuration
---

# Minecraft Run Configuration Guide

## What This Covers

- IntelliJ run configurations for Minecraft modding
- runClient, runServer, runData configuration types
- Testing and debugging workflows
- Data generation with datagen providers
- JVM options and program arguments

## When to Use

- Testing mod features in Minecraft
- Debugging code with breakpoints
- Generating data files (recipes, loot, models)
- Running automated tests
- Verifying features work in-game

---

## Run Configuration Types (Quick Reference)

### runClient
**Purpose**: Launch Minecraft client with mod loaded (graphical game)

**Use for**:
- Visual features (items, blocks, textures)
- GUI testing (custom screens, HUDs)
- Client-side rendering, sounds, music
- Keybindings and creative tabs

**Startup time**: 30-90 seconds

**Test workflow**:
1. Run configuration
2. Create new world (Creative mode)
3. Open inventory → Check creative tab
4. Test functionality

### runServer
**Purpose**: Launch dedicated server (no graphics)

**Use for**:
- Server-side logic (commands, events)
- Multiplayer features
- World generation
- Performance testing (no rendering overhead)

**Startup time**: 15-45 seconds

**Test workflow**:
1. Run configuration
2. Wait for "Done!" message
3. Connect from Minecraft client (localhost)
4. Test server-side features

### runData
**Purpose**: Generate data files (recipes, loot tables, models, etc.)

**Use for**:
- Creating recipe JSON files
- Generating loot tables
- Creating block/item models
- Tag generation

**Output location**: `src/generated/resources/`

**Test workflow**:
1. Run configuration
2. Wait for completion
3. Check `generated/resources/` for output
4. Copy to `src/main/resources/` if needed

### runGameTest (Optional)
**Purpose**: Run automated game tests

**Use for**:
- Automated feature testing
- Integration tests
- CI/CD pipelines

**Requires**: GameTest framework setup

---

## Using IntelliJ MCP Tools

### Get Available Run Configurations

```
mcp__intellij__get_run_configurations()

Returns:
[
  {name: "runClient", type: "Gradle", command: "runClient"},
  {name: "runServer", type: "Gradle", command: "runServer"},
  {name: "runData", type: "Gradle", command: "runData"}
]
```

### Execute Run Configuration

```
mcp__intellij__execute_run_configuration(
  configurationName: "runClient",
  timeout: 120000  // 2 minutes
)
```

**Monitoring Output**:
- Watch for "Mod loading complete" → Successful startup
- Check for errors in console
- Verify resources loaded correctly

---

## Common Configuration Patterns

### Pattern 1: Test New Item

1. Add item to mod code
2. Run `runClient`
3. Create world → Open inventory
4. Verify item appears with correct texture
5. Test item functionality

### Pattern 2: Generate Recipes

1. Create DataGenerator class with recipe provider
2. Run `runData`
3. Check `generated/resources/data/modid/recipes/`
4. Copy to `src/main/resources/` if satisfied

### Pattern 3: Test Server Commands

1. Add command to mod
2. Run `runServer`
3. Wait for "Done!" message
4. Type command in server console
5. Verify command works correctly

---

## Data Generation Setup

### Forge/NeoForge Data Generation

**Main class setup**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Mod.EventBusSubscriber.Bus.MOD)
public class DataGenerators {

    @SubscribeEvent
    public static void gatherData(GatherDataEvent event) {
        DataGenerator generator = event.getGenerator();
        PackOutput output = generator.getPackOutput();
        ExistingFileHelper fileHelper = event.getExistingFileHelper();

        // Recipes
        generator.addProvider(event.includeServer(),
            new ModRecipeProvider(output));

        // Loot tables
        generator.addProvider(event.includeServer(),
            new ModLootTableProvider(output));

        // Block states and models
        generator.addProvider(event.includeClient(),
            new ModBlockStateProvider(output, MODID, fileHelper));

        // Item models
        generator.addProvider(event.includeClient(),
            new ModItemModelProvider(output, MODID, fileHelper));
    }
}
```

**Run**: Execute `runData` configuration

**Output**: `src/generated/resources/`

### Fabric Data Generation

**Main class setup**:
```java
public class ModDataGenerator implements DataGeneratorEntrypoint {

    @Override
    public void onInitializeDataGenerator(FabricDataGenerator fabricDataGenerator) {
        FabricDataGenerator.Pack pack = fabricDataGenerator.createPack();

        // Recipes
        pack.addProvider(ModRecipeProvider::new);

        // Loot tables
        pack.addProvider(ModLootTableProvider::new);

        // Models
        pack.addProvider(ModModelProvider::new);
    }
}
```

**Register in fabric.mod.json**:
```json
"entrypoints": {
  "datagen": [
    "com.mod.datagen.ModDataGenerator"
  ]
}
```

**Run**: Execute `runData` configuration

---

## JVM Options and Program Arguments

### Common JVM Options

**Increase memory allocation**:
```
-Xmx4G  // Max heap size: 4GB
-Xms2G  // Initial heap size: 2GB
```

**Enable debugging**:
```
-Xdebug
-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005
```

**Performance profiling**:
```
-XX:+UnlockDiagnosticVMOptions
-XX:+LogCompilation
```

### Common Program Arguments

**Skip splash screen** (faster startup):
```
--nogui  // For runServer
```

**Specify data generation**:
```
--mod modid --all --output src/generated/resources/
```

**Enable mixins debug**:
```
-Dmixin.debug=true
```

**For detailed configuration**: See [JVM Options and Arguments](./jvm-options-and-arguments.md)

---

## Testing Workflow Best Practices

### 1. Quick Feature Test (runClient)
```
1. Make code changes
2. Run runClient
3. Create test world
4. Verify feature works
5. Iterate as needed
```

### 2. Server-Only Feature Test (runServer)
```
1. Make code changes
2. Run runServer
3. Wait for startup
4. Test via server console or by connecting
5. Check server logs for errors
```

### 3. Data Generation Workflow (runData)
```
1. Create/modify data providers
2. Run runData
3. Check generated/ folder
4. Review generated files
5. Copy to main resources if correct
```

### 4. Full Integration Test
```
1. Run runClient → Test client features
2. Run runServer → Test server features
3. Run runData → Generate resources
4. Build JAR → Test in clean environment
```

---

## Common Issues and Solutions

### Issue 1: Configuration Not Found
**Symptom**: IntelliJ doesn't show run configurations

**Solution**:
1. Refresh Gradle project (Gradle tool window → Reload)
2. Run `./gradlew genIntellijRuns` (Forge) or `./gradlew idea` (Fabric)
3. Restart IntelliJ

### Issue 2: Mod Not Loading
**Symptom**: Mod doesn't appear in game

**Check**:
- Console output for mod loading messages
- `mods.toml` or `fabric.mod.json` syntax
- Correct modid in all files
- Main mod class has proper annotations

### Issue 3: Long Startup Time
**Solutions**:
- Increase JVM memory (`-Xmx4G`)
- Disable unnecessary mods in development
- Use SSD for project files
- Skip splash screen with `--nogui` (server)

### Issue 4: Data Generation Fails
**Check**:
- DataGenerator class registered correctly
- Providers added to event
- Output directory permissions
- No syntax errors in provider classes

**For comprehensive troubleshooting**: See [Troubleshooting Guide](./troubleshooting-guide.md)

---

## Supporting Documentation

### Detailed Guides
- [Detailed Run Config Reference](./detailed-run-config-reference.md) - Complete docs for each configuration type with startup sequences
- [JVM Options and Arguments](./jvm-options-and-arguments.md) - JVM tuning, program arguments, debugging setup
- [Data Generation Guide](./data-generation-guide.md) - Complete data generation setup for recipes, loot, models, tags
- [Troubleshooting Guide](./troubleshooting-guide.md) - Common issues, error messages, fixes

---

## Quick Decision Tree

**Need to test visual features?**
→ Use `runClient`

**Need to test server logic?**
→ Use `runServer`

**Need to generate data files?**
→ Use `runData`

**Need automated testing?**
→ Use `runGameTest` (requires setup)

**Mod not loading?**
→ Check console output, verify mod metadata

**Slow startup?**
→ Increase JVM memory, use SSD

---

Use this skill when working with IntelliJ run configurations to test, debug, and generate data for Minecraft mods efficiently.
