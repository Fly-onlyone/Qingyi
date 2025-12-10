---
name: minecraft-run-configuration-guide
description: IntelliJ run configurations for Minecraft modding. Covers runClient, runServer, runData, program arguments, JVM options, data generation providers, testing workflows. Use when executing or debugging Minecraft mods.
allowed-tools: mcp__intellij__get_run_configurations, mcp__intellij__execute_run_configuration
---

# Minecraft Run Configuration Guide - IntelliJ Run Configurations for Modding

This skill provides comprehensive guidance on using IntelliJ IDEA run configurations for Minecraft mod development, including testing, debugging, and data generation.

## Overview

### What Are Run Configurations?

**Run configurations** are IntelliJ project templates that define how to launch Minecraft with your mod loaded.

**Created by**:
- **ForgeGradle** (Forge/NeoForge mods)
- **Fabric Loom** (Fabric/Quilt mods)

**Common configurations**:
- `runClient` - Launch Minecraft client
- `runServer` - Launch dedicated server
- `runData` - Generate data files
- `runGameTest` - Run automated tests (if configured)

### Why Use Run Configurations?

**Benefits**:
- ✅ Test mod in real Minecraft environment
- ✅ Debug code with breakpoints
- ✅ Verify features work in-game
- ✅ Generate data files (recipes, loot, models)
- ✅ Catch runtime issues before release

**Without run configurations**: Manual JAR installation, slow testing cycle

**With run configurations**: One-click testing, instant feedback

---

## Run Configuration Types

### runClient

**Purpose**: Launch Minecraft client with mod loaded (graphical game)

**Use for**:
- ✅ Visual features (items, blocks, models, textures)
- ✅ GUI testing (custom screens, HUDs)
- ✅ Client-side rendering
- ✅ Sounds and music
- ✅ Keybindings
- ✅ Creative tab organization

**Startup process**:
1. Launches Java with Minecraft client
2. Loads resource packs and assets
3. Initializes rendering engine (LWJGL)
4. Loads mods (including yours)
5. Registers items/blocks/entities
6. Opens main menu

**Typical time**: 30-90 seconds

**Access mod**:
1. Create new world (Creative mode)
2. Open inventory
3. Check creative tab for mod items
4. Test functionality

**Example usage**:
```
Feature: New ruby sword item
Test: runClient
Verify: Item appears in creative tab, correct texture, works correctly
```

### runServer

**Purpose**: Launch dedicated Minecraft server (no graphics)

**Use for**:
- ✅ Server-side features (commands, world generation)
- ✅ Multi-player mechanics
- ✅ Server-only logic
- ✅ Performance testing (no rendering overhead)

**Startup process**:
1. Launches Java with Minecraft server
2. Loads server configuration (server.properties)
3. Loads mods (server-side only)
4. Generates or loads world
5. Starts listening on port 25565

**Typical time**: 20-60 seconds

**Connect to server**:
1. Launch Minecraft client separately
2. Multiplayer → Add Server
3. Address: `localhost` or `127.0.0.1`
4. Join and test

**Example usage**:
```
Feature: Custom /givebronze command
Test: runServer
Verify: Command works, gives items to player
```

### runData

**Purpose**: Generate data files from code (recipes, loot tables, tags, models)

**Use for**:
- ✅ Recipe generation (crafting, smelting)
- ✅ Loot table generation
- ✅ Model/blockstate generation
- ✅ Tag generation (item tags, block tags)
- ✅ Language file generation

**Startup process**:
1. Launches minimal Minecraft
2. Loads DataProvider classes
3. Executes generation
4. Writes files to `src/generated/resources/`
5. Exits

**Typical time**: 10-30 seconds

**Output location**: `src/generated/resources/data/modid/`

**Example usage**:
```
Feature: RecipeProvider for all tools
Test: runData
Verify: 5 recipe JSON files created in src/generated/resources/
```

---

## Detecting Run Configurations

### Using IntelliJ MCP

**Check available configurations**:
```
mcp__intellij__get_run_configurations()

Returns:
[
  {name: "runClient", type: "Application"},
  {name: "runServer", type: "Application"},
  {name: "runData", type: "Application"}
]

→ All standard configurations available
```

**If empty**:
```
Returns: []

Possible causes:
1. Gradle not synced: Run ./gradlew --refresh-dependencies
2. ForgeGradle/Loom not applied: Check build.gradle
3. IntelliJ not loaded project: Open project in IntelliJ
```

### Manually in IntelliJ

**Location**: Run menu → Edit Configurations

**Should see**:
- runClient (Gradle task or Application)
- runServer (Gradle task or Application)
- runData (Gradle task or Application)

**If missing**: Re-sync Gradle project

---

## Executing Run Configurations

### Using IntelliJ MCP

**Basic execution**:
```
mcp__intellij__execute_run_configuration("runClient", timeout=120000)

Parameters:
- name: "runClient" (required)
- timeout: 120000ms = 2 minutes (optional, default varies)
- maxLinesCount: 200 (optional, default varies)

Returns:
- console output (last N lines)
- exit code
- execution status
```

**With custom timeout**:
```
mcp__intellij__execute_run_configuration(
    "runClient",
    timeout=180000,  // 3 minutes for slow startup
    maxLinesCount=500  // Capture more output
)
```

### Manually in IntelliJ

**Run**: Click green play button next to configuration

**Debug**: Click green bug button (enables breakpoints)

**Stop**: Click red stop button

---

## Program Arguments

### What Are Program Arguments?

**Program arguments** customize Minecraft launch behavior.

**Common arguments**:

**Username** (change player name):
```
--username PlayerName
```

**UUID** (set player UUID):
```
--uuid 12345678-1234-1234-1234-123456789abc
```

**Access token** (simulate authentication):
```
--accessToken dummy_token
```

**Game directory** (custom saves location):
```
--gameDir run/
```

**Example configuration**:
```
Program arguments: --username TestPlayer --uuid 00000000-0000-0000-0000-000000000000
```

### Setting Arguments in build.gradle

**ForgeGradle**:
```groovy
minecraft {
    runs {
        client {
            args '--username', 'DevPlayer'
        }
    }
}
```

**Fabric Loom**:
```groovy
loom {
    runs {
        client {
            programArgs '--username=DevPlayer'
        }
    }
}
```

---

## JVM Options

### What Are JVM Options?

**JVM options** configure Java Virtual Machine behavior.

**Common options**:

**Memory allocation**:
```
-Xms2G   // Initial heap size: 2 GB
-Xmx4G   // Maximum heap size: 4 GB
```

**Debugging**:
```
-Xdebug  // Enable debugging
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005  // Debug port
```

**Performance**:
```
-XX:+UseG1GC  // Use G1 garbage collector (recommended)
```

**Development**:
```
-Dmixin.debug.verbose=true  // Mixin debugging (Fabric)
-Dmixin.debug.export=true   // Export transformed classes
```

### Setting JVM Options in build.gradle

**ForgeGradle**:
```groovy
minecraft {
    runs {
        client {
            jvmArgs '-Xmx4G', '-Xms2G'
        }
    }
}
```

**Fabric Loom**:
```groovy
loom {
    runs {
        client {
            vmArgs '-Xmx4G', '-Xms2G'
        }
    }
}
```

---

## Testing Workflows

### Workflow 1: Quick Feature Test

**Goal**: Verify feature works

**Steps**:
1. Implement feature (e.g., new item)
2. Run `runClient`
3. Create new world (Creative)
4. Check creative tab for item
5. Verify texture, name, functionality
6. Exit Minecraft

**Time**: 2-3 minutes total

### Workflow 2: Debug with Breakpoints

**Goal**: Find and fix bug

**Steps**:
1. Set breakpoint in code (click line number in IntelliJ)
2. Debug `runClient` (bug icon)
3. Trigger code path in-game
4. Execution pauses at breakpoint
5. Inspect variables, step through code
6. Identify issue, fix code
7. Restart and retest

**Time**: 5-15 minutes

### Workflow 3: Server Testing

**Goal**: Test server-side feature

**Steps**:
1. Run `runServer`
2. Wait for "Server listening on port 25565"
3. Launch Minecraft client separately
4. Connect to localhost
5. Test feature (commands, world gen, etc.)
6. Check server console for logs
7. Stop server

**Time**: 3-5 minutes

### Workflow 4: Data Generation

**Goal**: Generate recipe/loot files

**Steps**:
1. Create DataProvider classes
2. Run `runData`
3. Wait for "Data generation complete"
4. Check `src/generated/resources/data/modid/`
5. Verify files created
6. Review generated JSON
7. Copy to `src/main/resources/` if satisfied

**Time**: 1-2 minutes

---

## Progressive Skill Loading

This skill uses **progressive loading** to optimize token usage. For detailed guides on specific configurations and patterns, see:

### Supporting Files

1. **[Run Client & Server](./run-client-server.md)** (~200 lines)
   - Detailed runClient configuration
   - Detailed runServer configuration
   - Program arguments reference
   - JVM options reference
   - Debugging workflows
   - Performance tuning
   - Multi-player testing

2. **[Data Generation](./data-generation.md)** (~250 lines)
   - DataProvider architecture
   - Recipe generation (crafting, smelting, blasting, smoking)
   - Loot table generation
   - Model and blockstate generation
   - Tag generation
   - Language file generation
   - Real code examples
   - Troubleshooting common issues

3. **[Custom Configurations](./custom-configurations.md)** (~150 lines)
   - Creating custom run configs
   - Testing specific scenarios
   - Performance profiling configurations
   - Debugging configurations
   - Multi-loader testing (Forge vs Fabric)
   - CI/CD integration

### When to Load Supporting Files

**Load [Run Client & Server](./run-client-server.md)** when:
- Need detailed runClient/runServer setup
- Configuring program arguments or JVM options
- Setting up debugging
- Performance issues

**Load [Data Generation](./data-generation.md)** when:
- Implementing data providers
- Generating recipes or loot tables
- Need data generation examples
- Troubleshooting datagen failures

**Load [Custom Configurations](./custom-configurations.md)** when:
- Creating specialized run configs
- Need performance profiling
- Setting up CI/CD
- Testing edge cases

---

## Quick Reference

### Configuration Selection Guide

| Task | Configuration | Notes |
|------|---------------|-------|
| Test new item/block | runClient | Visual verification needed |
| Test GUI/rendering | runClient | Client-only feature |
| Test commands | runServer | Server-side feature |
| Test world generation | runServer | Server-side feature |
| Generate recipes | runData | DataProvider required |
| Generate loot tables | runData | DataProvider required |
| Debug crash | runClient (Debug) | Use breakpoints |
| Performance test | runServer | No rendering overhead |

### Common Issues

**Issue**: No run configurations found

**Fix**: Run `./gradlew --refresh-dependencies` and reload Gradle project

**Issue**: Minecraft won't start (timeout)

**Fix**: Increase timeout, check for infinite loops in code

**Issue**: Missing textures in-game

**Fix**: Verify resource files in `src/main/resources/assets/modid/`

**Issue**: Data generation fails

**Fix**: Check DataProvider classes for errors, verify registration

**Issue**: Server port already in use

**Fix**: Stop other Minecraft servers, run `./gradlew --stop`

---

## Best Practices

### DO

- ✅ Use runClient for visual feature testing
- ✅ Use runServer for server-side logic
- ✅ Use runData to generate JSON files
- ✅ Set breakpoints for debugging
- ✅ Allocate sufficient memory (Xmx)
- ✅ Check console output for errors
- ✅ Test before releasing to users

### DON'T

- ❌ Skip in-game testing (code may compile but crash)
- ❌ Ignore console errors/warnings
- ❌ Test only on client (server may have different behavior)
- ❌ Commit generated files from src/generated/ (review first)
- ❌ Use production credentials in dev environment
- ❌ Run multiple instances simultaneously (port conflicts)

---

## Summary

**Run configurations** enable rapid testing and debugging of Minecraft mods.

**Types**:
- **runClient**: Graphical game testing
- **runServer**: Server-side testing
- **runData**: Data file generation

**Detection**: Use `get_run_configurations()` to discover available configs

**Execution**: Use `execute_run_configuration()` to run with timeout

**Customization**:
- Program arguments: Player name, UUID, game directory
- JVM options: Memory, debugging, performance

**Testing Workflow**:
1. Implement feature
2. Run appropriate configuration
3. Verify in-game
4. Check console for errors
5. Fix issues, repeat

For detailed configuration guides, see the supporting files linked above.
