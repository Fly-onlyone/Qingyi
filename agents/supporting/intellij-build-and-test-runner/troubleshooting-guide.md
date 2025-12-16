# Troubleshooting Guide

Error scenarios, timeout handling, crash detection, and recovery strategies for Minecraft mod testing.

## Error Handling

### Timeout Handling

**Scenario**: Startup exceeds timeout

```
Error: Run configuration timed out after 120000ms

Possible causes:
1. First-time asset download (slow internet)
2. Large modpack (many mods loading)
3. Infinite loop in mod code
4. Deadlock during initialization

Recommend:
- Increase timeout to 180000ms (3 minutes)
- Check for infinite loops in mod init code
- Review console output for stuck operations
```

**Adjust timeout**:
```
execute_run_configuration("runClient", timeout=180000)  // 3 minutes
```

### Crash Detection

**Scenario**: Minecraft crashes during startup

```
Error: Process exited with code 1

Console excerpt:
[FATAL] Exception during mod loading
java.lang.NullPointerException
  at com.mod.MyMod.init(MyMod.java:25)

Analysis:
- Crash occurred in MyMod.init() at line 25
- NullPointerException suggests uninitialized variable

Action required:
- Check MyMod.java line 25
- Add null check or initialize variable
- Review initialization order
```

### Port Conflicts (Server)

**Scenario**: Port 25565 already in use

```
Error: Failed to bind to port 25565

Cause: Another Minecraft server running or port in use

Recommend:
- Stop other Minecraft servers
- Check for zombie processes: ./gradlew --stop
- Use different port: configure in server.properties
```

### Missing Resources

**Scenario**: Missing model or texture

```
Warning: Missing model for item: mymod:ruby_sword

Impact: Item appears with missing texture (purple/black checkerboard)

Action required:
- Create assets/mymod/models/item/ruby_sword.json
- Create assets/mymod/textures/item/ruby_sword.png
- Verify file names match registry name
```

---

## Common Error Patterns

### NoSuchMethodError

**Error**:
```
java.lang.NoSuchMethodError: net.minecraft.world.item.Item.getDefaultInstance()
```

**Cause**: API version mismatch (wrong Minecraft version)

**Fix**:
```
1. Check build.gradle: minecraft_version property
2. Verify Forge/Fabric version compatibility
3. Update dependencies to matching versions
4. Run ./gradlew --refresh-dependencies
5. Retest
```

### NullPointerException

**Error**:
```
java.lang.NullPointerException
  at com.mod.items.CustomItem.use(CustomItem.java:42)
```

**Cause**: Uninitialized variable or null reference

**Fix**:
```
1. Navigate to CustomItem.java line 42
2. Identify the null reference
3. Add null check or initialization
4. Common culprits:
   - Uninitialized static fields
   - Missing mod initialization
   - Incorrect registration order
```

### IllegalArgumentException (Duplicate Registry)

**Error**:
```
java.lang.IllegalArgumentException: Registry name already exists: mymod:ruby_sword
```

**Cause**: Duplicate registry entry

**Fix**:
```
1. Search codebase for all "ruby_sword" registrations
2. Remove duplicate ITEMS.register() calls
3. Check for accidental copy-paste errors
4. Verify unique names for all registered objects
```

### Missing Dependency

**Error**:
```
Missing or unsupported mandatory dependencies:
  Mod ID: 'requiredmod', Requested by: 'mymod'
```

**Cause**: Declared dependency not installed

**Fix**:
```
Option 1 (Remove dependency):
- Edit mods.toml or fabric.mod.json
- Remove "requiredmod" from dependencies section

Option 2 (Install dependency):
- Download requiredmod JAR
- Place in mods/ folder
- Retest
```

---

## Gradle Issues

### Project Not Synced

**Symptom**: No run configurations available

**Fix**:
```
1. Close IntelliJ IDEA
2. Run: ./gradlew --refresh-dependencies
3. Run: ./gradlew genIntellijRuns (Forge) or ./gradlew genSources (Fabric)
4. Reopen IntelliJ IDEA
5. File → Reload All Gradle Projects
6. Wait for indexing to complete
```

### Build Fails

**Error**:
```
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':compileJava'.
> Compilation failed; see the compiler error output for details.
```

**Fix**:
```
1. Read full error output (scroll up in console)
2. Identify specific compilation error
3. Common issues:
   - Missing imports
   - Syntax errors
   - Type mismatches
4. Fix code errors
5. Run ./gradlew clean build
```

### Zombie Processes

**Symptom**: Can't start server, port already in use

**Fix**:
```
1. Stop Gradle daemon: ./gradlew --stop
2. Kill Java processes:
   - Windows: taskkill /F /IM java.exe
   - Linux/Mac: pkill -9 java
3. Wait 5 seconds
4. Retry runServer
```

---

## Recovery Strategies

### Clean Build

**When to use**: After major changes or unexplained errors

**Process**:
```
1. ./gradlew clean
2. Delete build/ directory
3. Delete .gradle/ directory (nuclear option)
4. ./gradlew --refresh-dependencies
5. ./gradlew build
6. Retest
```

### Reset IDE State

**When to use**: IntelliJ not recognizing changes

**Process**:
```
1. File → Invalidate Caches / Restart
2. Select "Invalidate and Restart"
3. Wait for re-indexing
4. File → Reload All Gradle Projects
5. Retest
```

### Rollback Changes

**When to use**: Test passed before recent changes

**Process**:
```
1. Identify last working commit (git log)
2. git diff HEAD <last-working-commit>
3. Review changes
4. Revert problematic changes
5. Retest
```
