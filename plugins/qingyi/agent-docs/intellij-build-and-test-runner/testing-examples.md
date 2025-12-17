# Testing Examples

Real-world testing workflows for common Minecraft mod development scenarios.

## Example 1: Test New Item

**User request**: "Create a ruby sword and test it"

### Workflow

```
1. registry-and-content-expert creates RubySword class
2. minecraft-code-validator validates code (no errors)
3. build-and-test-runner:
   - get_run_configurations() → finds "runClient"
   - execute_run_configuration("runClient", timeout=120000)
   - Monitor console:
     [INFO] Loading mod mymod version 1.0.0
     [INFO] Registered item: ruby_sword
     [INFO] Minecraft client started
   - Verification: ✅ Item registered, no errors
4. Report: "Ruby sword created, validated, and tested in-game ✅"
```

### Success Output

```
✅ Testing complete

Mod loading: SUCCESS
- mod mymod version 1.0.0 loaded
- Registered 1 item: ruby_sword

In-game verification:
- Ruby sword appears in creative tab (manual check recommended)
- No errors in console

Test passed. Feature ready for use.
```

---

## Example 2: Generate Data Files

**User request**: "Generate recipe files for all items"

### Workflow

```
1. data-and-persistence-expert creates RecipeProvider class
2. build-and-test-runner:
   - get_run_configurations() → finds "runData"
   - execute_run_configuration("runData", timeout=60000)
   - Monitor console:
     [INFO] Starting data generation
     [INFO] Generating recipes for mymod
     [INFO] Generated 5 recipe files
     [INFO] Data generation complete
   - Verification: Files created in src/generated/resources/
3. Report: "Generated 5 recipes successfully ✅"
```

### Success Output

```
✅ Data generation complete

Files generated:
- src/generated/resources/data/mymod/recipes/ruby_sword.json
- src/generated/resources/data/mymod/recipes/ruby_pickaxe.json
- src/generated/resources/data/mymod/recipes/ruby_axe.json
- src/generated/resources/data/mymod/recipes/ruby_shovel.json
- src/generated/resources/data/mymod/recipes/ruby_hoe.json

Next steps:
- Review generated files
- Copy to src/main/resources/ if satisfied
- Commit to version control
```

---

## Example 3: Build Mod JAR

**User request**: "Build the mod"

### Workflow

```
1. build-and-test-runner:
   - execute_terminal_command("./gradlew build", timeout=300000)
   - Monitor console:
     > Task :compileJava
     > Task :processResources
     > Task :classes
     > Task :jar
     BUILD SUCCESSFUL in 45s
   - Verification: build/libs/mymod-1.0.0.jar created
2. Report: "Build successful. JAR created: build/libs/mymod-1.0.0.jar ✅"
```

### Success Output

```
✅ Build complete

Build result: BUILD SUCCESSFUL in 45s
Tasks executed: 15 tasks

Output artifact:
- build/libs/mymod-1.0.0.jar (256 KB)

Ready to:
- Test in Minecraft (install JAR in mods/ folder)
- Publish to CurseForge/Modrinth
- Share with users
```

---

## Example 4: Test Event Handler

**User request**: "Create a player join event handler and verify it works"

### Workflow

```
1. events-and-lifecycle-expert creates PlayerJoinHandler
2. Adds logging: LOGGER.info("Player {} joined!", player.getName())
3. minecraft-code-validator validates code
4. build-and-test-runner:
   - execute_run_configuration("runClient")
   - Manual step required: User creates world and joins game
   - Monitor console for: "[INFO] [mymod] Player joined!"
5. Verification:
   - No errors during mod load ✅
   - Event handler registered ✅
   - Manual verification: Log appears when player joins ✅
```

### Success Output

```
✅ Event handler tested

Mod loading: SUCCESS
- Event handler registered on FORGE bus ✅

Manual verification needed:
1. Create new world (Creative mode)
2. Watch console for "[INFO] [mymod] Player joined!"
3. Verify log appears

Auto-verification:
- No errors during registration ✅
- Event class loaded successfully ✅
```

---

## Example 5: Test Server-Side Command

**User request**: "Create /givecoins command and test it"

### Workflow

```
1. events-and-lifecycle-expert creates GiveCoinsCommand
2. minecraft-code-validator validates code
3. build-and-test-runner:
   - execute_run_configuration("runServer")
   - Monitor console:
     [INFO] Registering command: givecoins
     [INFO] Done! Server is ready
   - Verification: Command registered ✅
4. Manual testing:
   - Connect to localhost:25565
   - Run: /givecoins Player 100
   - Verify: Command executes
```

### Success Output

```
✅ Server testing complete

Server startup: SUCCESS
- Server started in 35 seconds
- Command registered: /givecoins ✅
- Server listening on port 25565

Manual testing required:
1. Connect Minecraft client to localhost:25565
2. Run: /givecoins <player> <amount>
3. Verify command works

Auto-verification:
- No errors during registration ✅
- Server accepts connections ✅
```

---

## Example 6: Test Multi-Loader Build

**User request**: "Build for both Forge and Fabric"

### Workflow

```
1. intellij-project-analyzer identifies multi-loader structure
2. build-and-test-runner:
   - execute_terminal_command("./gradlew build")
   - Monitor console:
     > Task :common:build
     > Task :forge:build
     > Task :fabric:build
     BUILD SUCCESSFUL in 60s
   - Verification: 3 JARs created
3. Test each module:
   - execute_run_configuration("Forge Client")
   - execute_run_configuration("Fabric Client")
4. Report: "Both loaders tested successfully ✅"
```

### Success Output

```
✅ Multi-loader build complete

Build result: BUILD SUCCESSFUL in 60s

Artifacts created:
- common/build/libs/mymod-common-1.0.0.jar (128 KB)
- forge/build/libs/mymod-forge-1.0.0.jar (256 KB)
- fabric/build/libs/mymod-fabric-1.0.0.jar (245 KB)

Testing results:
- Forge Client: ✅ Mod loaded successfully
- Fabric Client: ✅ Mod loaded successfully

Both loaders verified. Ready for release.
```

---

## Example 7: Test After Bug Fix

**User request**: "I fixed the crash, test it again"

### Workflow

```
1. User made code changes
2. minecraft-code-validator re-validates code
3. build-and-test-runner:
   - execute_terminal_command("./gradlew clean")  // Fresh build
   - execute_terminal_command("./gradlew build")
   - execute_run_configuration("runClient")
   - Monitor for previous crash location
4. Verification:
   - Previous error not present ✅
   - Mod loads successfully ✅
```

### Success Output

```
✅ Bug fix verified

Previous error:
❌ java.lang.NullPointerException at CustomItem.java:42

Current status:
✅ No NullPointerException
✅ Mod loaded successfully
✅ All items registered

Bug fix successful. Testing complete.
```

---

## Integration Example

**Complex workflow**: "Add new ore, generate recipes, and test in-game"

### Full Workflow

```
1. registry-and-content-expert:
   - Creates RubyOreBlock class
   - Creates RubyOreItem class
   - Registers both to DeferredRegister

2. data-and-persistence-expert:
   - Creates RecipeProvider for smelting recipe
   - Creates LootTableProvider for ore drops

3. minecraft-code-validator:
   - Validates all code (no errors)

4. build-and-test-runner (first run):
   - execute_run_configuration("runData")
   - Generates recipes and loot tables ✅
   - Copies generated files to src/main/resources/

5. build-and-test-runner (second run):
   - execute_run_configuration("runClient")
   - Verifies:
     - Ruby ore registered ✅
     - Ruby item registered ✅
     - Recipe works (manual check) ✅

6. orchestrator:
   - Confirms task complete to user
```

### Success Output

```
✅ Complete ore feature implemented and tested

Implementation:
- RubyOreBlock: Created and registered ✅
- RubyOreItem: Created and registered ✅
- Smelting recipe: Generated ✅
- Ore loot table: Generated ✅

Testing:
- Data generation: 2 files created ✅
- In-game verification: Mod loaded ✅

Manual verification recommended:
1. Find ruby ore in world (Creative mode: /give)
2. Place ore, mine it (should drop ruby item)
3. Smelt ore in furnace (should produce ruby)
```
