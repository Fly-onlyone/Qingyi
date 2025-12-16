# Run Configuration Reference

Complete reference for runClient, runServer, runData configurations and Gradle task execution.

## Run Configuration Types

### runClient (Minecraft Client)

**Purpose**: Test mod in Minecraft client (graphical game)

**When to use**:
- Visual features (items appear in inventory)
- GUI elements (custom screens, HUDs)
- Rendering (custom models, textures)
- Sounds and music
- Client-side keybindings
- Creative tab organization

**Startup sequence**:
```
1. Launch Java process
2. Load Minecraft assets
3. Load resource packs
4. Initialize rendering engine
5. Load mods (including yours)
6. Register items/blocks/entities
7. Open main menu
```

**Typical console output**:
```
[INFO] Minecraft starting...
[INFO] Backend library: LWJGL version 3.3.1
[INFO] Loading resource packs
[INFO] Mod mymod version 1.0.0 loading...
[INFO] Registered 15 items
[INFO] Minecraft main menu ready
```

**Success criteria**:
- No ERROR or FATAL messages
- "Mod loaded successfully" (if implemented)
- Game reaches main menu
- Mod appears in mods list (F12 or Mod Menu)

**Interactive testing** (manual):
```
After runClient completes:
1. Create new world (Creative mode)
2. Open inventory
3. Check creative tab for mod items ✅
4. Place blocks, use items
5. Verify functionality
```

### runServer (Dedicated Server)

**Purpose**: Test mod on dedicated server (no graphics)

**When to use**:
- Server-side features (commands, world gen)
- Multi-player mechanics
- Server-only logic
- Performance testing (no rendering overhead)

**Startup sequence**:
```
1. Launch Java process
2. Load server configuration
3. Load mods (server-side only)
4. Generate/load world
5. Start listening on port 25565
```

**Typical console output**:
```
[INFO] Starting Minecraft server...
[INFO] Loading properties
[INFO] Mod mymod version 1.0.0 loading...
[INFO] Preparing level "world"
[INFO] Done! Server is ready
[INFO] Server listening on port 25565
```

**Success criteria**:
- "Done! Server is ready"
- No ERROR or FATAL messages
- Server accepts connections

**Testing**:
```
After runServer completes:
1. Server running on localhost:25565
2. Connect with Minecraft client
3. Test server-side features
4. Check server console for mod logs
```

### runData (Data Generation)

**Purpose**: Generate data files (recipes, loot tables, tags, models) from code

**When to use**:
- After creating data providers
- Updating recipes/loot programmatically
- Generating JSON files automatically
- Mass-creating similar files

**Startup sequence**:
```
1. Launch minimal Minecraft
2. Load data providers
3. Execute generation
4. Write files to src/generated/resources/
5. Exit
```

**Typical console output**:
```
[INFO] Starting data generation...
[INFO] Generating recipes for mymod
[INFO] Generated 5 recipe files
[INFO] Generating loot tables
[INFO] Generated 3 loot table files
[INFO] Data generation complete
[INFO] Process finished with exit code 0
```

**Success criteria**:
- "Data generation complete"
- Exit code 0
- Files created in src/generated/resources/

**Verification**:
```
After runData completes:
1. Check src/generated/resources/data/mymod/recipes/
   - Files created ✅
2. Validate JSON structure (no syntax errors)
3. Copy to src/main/resources/ if satisfied
```

---

## Gradle Task Execution

### Common Build Tasks

**build** (Compile and package):
```
execute_terminal_command("./gradlew build", timeout=300000)

Output:
BUILD SUCCESSFUL in 45s
15 actionable tasks: 15 executed

Creates:
- build/libs/mymod-1.0.0.jar
```

**clean** (Delete artifacts):
```
execute_terminal_command("./gradlew clean")

Output:
BUILD SUCCESSFUL in 2s
1 actionable task: 1 executed
```

**test** (Run unit tests):
```
execute_terminal_command("./gradlew test")

Output:
> Task :test
MyModTest > testItemRegistration() PASSED
MyModTest > testBlockProperties() PASSED

BUILD SUCCESSFUL in 8s
```

**publish** (Deploy to Maven/CurseForge):
```
execute_terminal_command("./gradlew publish")

Requires configuration in build.gradle
```

### Multi-Module Build (Multi-Loader)

**Build all modules**:
```
execute_terminal_command("./gradlew build")

Output:
> Task :common:build
> Task :forge:build
> Task :fabric:build

BUILD SUCCESSFUL in 60s

Creates:
- common/build/libs/mymod-common-1.0.0.jar
- forge/build/libs/mymod-forge-1.0.0.jar
- fabric/build/libs/mymod-fabric-1.0.0.jar
```

**Build specific module**:
```
execute_terminal_command("./gradlew :forge:build")

Builds only Forge module
```
