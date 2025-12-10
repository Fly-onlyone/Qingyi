# Custom Configurations - Advanced Testing and Debugging Setups

Guide for creating custom run configurations for specialized testing scenarios, debugging, performance profiling, and CI/CD integration.

## Why Custom Configurations?

**Standard configurations** (runClient, runServer, runData) cover most needs, but custom configs enable:

- ✅ Testing specific scenarios (multiplayer, specific worlds)
- ✅ Performance profiling and benchmarking
- ✅ Advanced debugging with custom breakpoints
- ✅ Automated testing in CI/CD pipelines
- ✅ Multi-loader testing (Forge vs Fabric comparison)

---

## Creating Custom Run Configurations

### Method 1: IntelliJ GUI

**Steps**:
1. Run → Edit Configurations
2. Click `+` → Gradle or Application
3. Configure settings:
   - **Name**: Custom config name
   - **Main class**: `net.minecraft.client.main.Main` (client) or `net.minecraft.server.Main` (server)
   - **Program arguments**: Custom args
   - **JVM options**: Custom JVM args
   - **Working directory**: Custom directory
4. Apply → OK

### Method 2: build.gradle Configuration

**Forge/NeoForge**:

```groovy
minecraft {
    runs {
        // Custom client config
        testClient {
            workingDirectory project.file('run-test')
            property 'forge.logging.console.level', 'debug'

            // Custom arguments
            args '--username', 'TestUser'
            args '--width', '1920'
            args '--height', '1080'

            // Custom JVM args
            jvmArgs '-Xmx6G', '-Xms2G'
            jvmArgs '-Dmymod.test.mode=true'

            mods {
                mymod {
                    source sourceSets.main
                }
            }
        }

        // Custom server config
        testServer {
            workingDirectory project.file('run-test-server')
            args '--nogui'
            args '--world', 'TestWorld'

            mods {
                mymod {
                    source sourceSets.main
                }
            }
        }
    }
}
```

**Fabric**:

```groovy
loom {
    runs {
        testClient {
            client()
            name 'Test Client'
            source sourceSets.main

            programArgs '--username=TestUser'
            vmArgs '-Xmx6G', '-Dmymod.test.mode=true'
        }

        testServer {
            server()
            name 'Test Server'
            source sourceSets.main

            programArgs '--nogui'
        }
    }
}
```

**Reload Gradle**: After editing build.gradle, reload Gradle project to see new configs

---

## Common Custom Configuration Patterns

### Pattern 1: Multiplayer Testing

**Goal**: Test mod in multiplayer environment

**Server config** (`multiplayerServer`):
```groovy
multiplayerServer {
    workingDirectory project.file('run-mp-server')
    args '--nogui'
    property 'forge.logging.console.level', 'info'

    // Disable authentication for testing
    args '--online-mode', 'false'
}
```

**Client config** (`multiplayerClient`):
```groovy
multiplayerClient {
    workingDirectory project.file('run-mp-client')
    args '--username', 'Player1'

    // Auto-connect to server (custom argument parsed by mod)
    args '--autoConnect', 'localhost:25565'
}
```

**Workflow**:
1. Start `multiplayerServer`
2. Wait for "Server listening on port 25565"
3. Start `multiplayerClient`
4. Client auto-connects (if implemented)
5. Test multiplayer features

### Pattern 2: Specific World Testing

**Goal**: Test mod with a pre-configured world

**Preparation**:
1. Create world manually or programmatically
2. Save to `run/saves/TestWorld/`

**Config**:
```groovy
worldTest {
    workingDirectory project.file('run')
    args '--username', 'WorldTester'

    // Custom system property to auto-load world
    jvmArgs '-Dmymod.autoload.world=TestWorld'
}
```

**Mod code to auto-load world**:
```java
@SubscribeEvent
public static void onClientSetup(FMLClientSetupEvent event) {
    String worldName = System.getProperty("mymod.autoload.world");
    if (worldName != null) {
        // Auto-load world on client start
        event.enqueueWork(() -> {
            // Implementation to select and load world
        });
    }
}
```

### Pattern 3: Performance Profiling

**Goal**: Identify performance bottlenecks

**Config**:
```groovy
profile {
    workingDirectory project.file('run-profile')

    // Enable profiling
    jvmArgs '-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005'
    jvmArgs '-XX:+UnlockDiagnosticVMOptions'
    jvmArgs '-XX:+DebugNonSafepoints'
    jvmArgs '-XX:+FlightRecorder'

    // Allocate more memory for profiling overhead
    jvmArgs '-Xmx8G', '-Xms4G'

    // Enable detailed GC logging
    jvmArgs '-Xlog:gc*:file=gc.log'
}
```

**Profiling tools**:
- **VisualVM**: Connect to port 5005, monitor CPU/memory
- **JProfiler**: Attach to running JVM
- **Spark**: In-game profiler plugin (fabric mod)

**Workflow**:
1. Start `profile` config
2. Connect profiler tool
3. Perform actions to profile
4. Analyze results

### Pattern 4: Debug with Breakpoints

**Goal**: Advanced debugging with specific conditions

**Config**:
```groovy
debugClient {
    workingDirectory project.file('run-debug')

    // Suspend on start (wait for debugger)
    jvmArgs '-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005'

    // Enable assertions
    jvmArgs '-ea'

    // Verbose class loading (debug mixin issues)
    jvmArgs '-verbose:class'

    // Mixin debug
    jvmArgs '-Dmixin.debug.verbose=true'
    jvmArgs '-Dmixin.debug.export=true'
}
```

**IntelliJ**:
1. Debug `debugClient` (bug icon)
2. Set breakpoints in code
3. Add conditional breakpoints: Right-click breakpoint → Condition
   ```java
   player.getName().getString().equals("Dev") && itemStack.getCount() > 1
   ```
4. Use evaluate expression (Alt+F8) during pause

### Pattern 5: CI/CD Automated Testing

**Goal**: Run mod in headless environment for automated testing

**Config**:
```groovy
ciTest {
    workingDirectory project.file('run-ci')

    // Headless mode (no GUI)
    args '--nogui'

    // Auto-exit after test
    jvmArgs '-Dmymod.ci.mode=true'
    jvmArgs '-Dmymod.test.timeout=60000'  // Exit after 60s

    // Disable unnecessary features
    jvmArgs '-Dminecraft.skipAssetVerification=true'
}
```

**Mod code**:
```java
@EventBusSubscriber(modid = MODID)
public class CITestHandler {
    @SubscribeEvent
    public static void onServerStarted(ServerStartedEvent event) {
        if (Boolean.getBoolean("mymod.ci.mode")) {
            // Run automated tests
            runTests();

            // Exit after timeout
            int timeout = Integer.getInteger("mymod.test.timeout", 60000);
            new Timer().schedule(new TimerTask() {
                @Override
                public void run() {
                    System.exit(0);
                }
            }, timeout);
        }
    }
}
```

**GitHub Actions workflow**:
```yaml
name: CI Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v2
        with:
          java-version: '17'
      - run: ./gradlew ciTest
```

---

## Multi-Loader Testing

### Pattern: Compare Forge and Fabric Behavior

**Forge config** (`testForge`):
```groovy
// In forge/build.gradle
minecraft {
    runs {
        testForge {
            workingDirectory project.file('../run-forge-test')
            args '--username', 'ForgeTest'
            jvmArgs '-Dloader=forge'
        }
    }
}
```

**Fabric config** (`testFabric`):
```groovy
// In fabric/build.gradle
loom {
    runs {
        testFabric {
            client()
            name 'Fabric Test'
            source sourceSets.main
            programArgs '--username=FabricTest'
            vmArgs '-Dloader=fabric'
        }
    }
}
```

**Workflow**:
1. Test feature on Forge: `./gradlew :forge:testForge`
2. Test same feature on Fabric: `./gradlew :fabric:testFabric`
3. Compare behavior, verify consistency

---

## Advanced JVM Options

### Memory Tuning

**Large modpacks** (100+ mods):
```groovy
jvmArgs '-Xmx10G', '-Xms6G'
jvmArgs '-XX:+UseG1GC'
jvmArgs '-XX:G1HeapRegionSize=4M'
jvmArgs '-XX:MaxGCPauseMillis=50'
```

**Low memory testing**:
```groovy
jvmArgs '-Xmx2G', '-Xms1G'  // Test with limited RAM
```

### Debugging Options

**Enable all assertions**:
```groovy
jvmArgs '-ea'  // -enableassertions
```

**Verbose output**:
```groovy
jvmArgs '-verbose:gc'      // GC events
jvmArgs '-verbose:class'   // Class loading
jvmArgs '-verbose:jni'     // JNI calls
```

**Mixin debugging** (Fabric/Quilt):
```groovy
jvmArgs '-Dmixin.debug.verbose=true'
jvmArgs '-Dmixin.debug.export=true'
jvmArgs '-Dmixin.debug.countInjections=true'
```

**Access Transformer debugging** (Forge):
```groovy
jvmArgs '-Dforge.logging.console.level=debug'
jvmArgs '-Dfml.earlyprogresswindow=false'  // Disable loading screen
```

### Performance Options

**Optimize for server**:
```groovy
jvmArgs '-server'  // Server VM mode
jvmArgs '-XX:+UseLargePages'
jvmArgs '-XX:LargePageSizeInBytes=2M'
```

**Optimize for client**:
```groovy
jvmArgs '-client'  // Client VM mode (faster startup)
jvmArgs '-XX:+AggressiveOpts'
```

---

## Custom Program Arguments

### Minecraft Arguments

**Window size**:
```groovy
args '--width', '1920', '--height', '1080'
args '--fullscreen'
```

**Player name and UUID**:
```groovy
args '--username', 'CustomPlayer'
args '--uuid', '12345678-1234-1234-1234-123456789abc'
```

**Demo mode**:
```groovy
args '--demo'  // Limited playtime
```

**Quick play** (1.20+):
```groovy
args '--quickPlaySingleplayer', 'WorldName'
args '--quickPlayMultiplayer', 'localhost:25565'
args '--quickPlayRealms', 'RealmID'
```

### Custom Mod Arguments

**Parse in mod code**:
```java
public static void main(String[] args) {
    for (int i = 0; i < args.length; i++) {
        if (args[i].equals("--mymod-debug")) {
            DEBUG_MODE = true;
        }
        if (args[i].equals("--mymod-config") && i + 1 < args.length) {
            CONFIG_PATH = args[i + 1];
        }
    }
}
```

**Use in config**:
```groovy
args '--mymod-debug'
args '--mymod-config', 'custom-config.json'
```

---

## Best Practices

### DO

- ✅ Use descriptive names for custom configs (`multiplayerServer`, not `test2`)
- ✅ Document what each custom config is for
- ✅ Use separate working directories for different configs
- ✅ Commit custom configs to version control (in build.gradle)
- ✅ Test configs locally before using in CI/CD

### DON'T

- ❌ Share working directories between configs (causes conflicts)
- ❌ Use production credentials in test configs
- ❌ Enable all debug options in production configs
- ❌ Hardcode file paths (use `project.file()`)
- ❌ Forget to reload Gradle after editing configs

---

## Summary

**Custom run configurations** enable specialized testing scenarios beyond standard runClient/runServer/runData.

**Common patterns**:
- Multiplayer testing (server + client configs)
- Specific world testing (auto-load worlds)
- Performance profiling (profiler integration)
- Advanced debugging (conditional breakpoints)
- CI/CD automation (headless testing)

**Configuration methods**:
- IntelliJ GUI (quick, one-off configs)
- build.gradle (shareable, version-controlled)

**Key options**:
- JVM args: Memory, debugging, profiling
- Program args: Window size, player name, custom flags

For standard configurations, see [Run Client & Server](./run-client-server.md).

For data generation, see [Data Generation](./data-generation.md).
