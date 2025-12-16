# Run Client & Server - Testing Minecraft Mods In-Game

Detailed guide for using runClient and runServer configurations for testing and debugging Minecraft mods.

## runClient Configuration

### Purpose and Use Cases

**runClient** launches the Minecraft client (graphical game) with your mod loaded.

**Best for**:
- Visual features (items appear correctly, textures load)
- GUI elements (custom screens, overlays, HUDs)
- Rendering (models, particles, lighting)
- Client-side sounds and music
- Keybindings and controls
- Creative mode tab organization
- Client-side config screens

**Example scenarios**:
```
✅ "Does my ruby sword have the right texture?"
✅ "Does the custom GUI open correctly?"
✅ "Does the particle effect render properly?"
✅ "Is the item in the right creative tab?"
```

### Default Configuration (ForgeGradle)

```groovy
// build.gradle
minecraft {
    runs {
        client {
            workingDirectory project.file('run')
            property 'forge.logging.console.level', 'debug'

            args '--username', 'Dev'

            mods {
                mymod {
                    source sourceSets.main
                }
            }
        }
    }
}
```

### Default Configuration (Fabric Loom)

```groovy
// build.gradle
loom {
    runs {
        client {
            client()
            name 'Fabric Client'
            source sourceSets.main
        }
    }
}
```

### Program Arguments

**Common client arguments**:

| Argument | Purpose | Example |
|----------|---------|---------|
| `--username <name>` | Set player name | `--username DevPlayer` |
| `--uuid <uuid>` | Set player UUID | `--uuid 12345678-...` |
| `--accessToken <token>` | Auth token (dev: dummy) | `--accessToken dev_token` |
| `--gameDir <path>` | Save location | `--gameDir run/` |
| `--width <pixels>` | Window width | `--width 1280` |
| `--height <pixels>` | Window height | `--height 720` |

**Example**:
```groovy
args '--username', 'DevTester', '--width', '1920', '--height', '1080'
```

### JVM Options for Client

**Memory allocation**:
```
-Xms2G   // Initial heap: 2GB
-Xmx4G   // Max heap: 4GB
```

**Performance**:
```
-XX:+UseG1GC              // G1 garbage collector
-Dsun.rmi.dgc.server.gcInterval=2147483646  // Reduce GC pauses
```

**Development**:
```
-Dmixin.debug.verbose=true     // Mixin debugging (Fabric)
-Dforge.logging.console.level=debug  // Detailed Forge logs
```

**Example**:
```groovy
jvmArgs '-Xmx4G', '-Xms2G', '-XX:+UseG1GC'
```

### Testing Workflow

**Quick test**:
1. Run runClient
2. Wait for main menu (30-90s)
3. Singleplayer → Create New World
4. Creative mode
5. Open inventory (E)
6. Find mod's creative tab
7. Verify items appear with correct textures
8. Test item/block functionality
9. Exit game

**Debug workflow**:
1. Set breakpoint in code (IntelliJ)
2. Debug runClient (bug icon)
3. Load world in-game
4. Trigger code path (use item, place block)
5. Execution pauses at breakpoint
6. Inspect variables
7. Step through code (F8 = step over, F7 = step into)
8. Identify and fix issue
9. Resume or restart

### Debugging Tips

**Setting breakpoints**:
```
IntelliJ: Click line number gutter → red dot appears

Best places for breakpoints:
- Item.use() method (when item right-clicked)
- Block.onPlace() (when block placed)
- Event handlers (when events fire)
- Custom GUI constructors (when GUI opens)
```

**Conditional breakpoints**:
```
Right-click breakpoint → Add condition
Example: player.getName().equals("Dev")
→ Only pauses for specific player
```

**Log output**:
```java
LOGGER.info("Item used by: {}", player.getName());
LOGGER.debug("Position: {}", pos);
→ Appears in console output
```

### Performance Tuning

**Slow startup**:
```
Cause: Asset downloading, large modpack
Fix:
- Allocate more RAM: -Xmx6G
- Increase timeout: timeout=180000 (3min)
- Clear cache: delete run/ directory
```

**Low FPS in-game**:
```
Cause: Rendering overhead, many entities
Fix:
- Reduce render distance
- Close other applications
- Use OptiFine (optional)
- Profile code (find bottlenecks)
```

---

## runServer Configuration

### Purpose and Use Cases

**runServer** launches a dedicated Minecraft server (no graphics).

**Best for**:
- Server-side commands
- World generation testing
- Multi-player mechanics
- Server-only logic
- Performance testing (no rendering)
- Dedicated server compatibility

**Example scenarios**:
```
✅ "Does my /giveitems command work?"
✅ "Does my custom ore generate in the world?"
✅ "Can players trade items on the server?"
✅ "Does the server tick handler work?"
```

### Default Configuration (ForgeGradle)

```groovy
minecraft {
    runs {
        server {
            workingDirectory project.file('run-server')
            property 'forge.logging.console.level', 'debug'

            args '--nogui'  // No server GUI window

            mods {
                mymod {
                    source sourceSets.main
                }
            }
        }
    }
}
```

### Default Configuration (Fabric Loom)

```groovy
loom {
    runs {
        server {
            server()
            name 'Fabric Server'
            source sourceSets.main
        }
    }
}
```

### Server Configuration Files

**server.properties** (created after first run):
```properties
# run-server/server.properties
server-port=25565
gamemode=creative
difficulty=easy
level-name=world
max-players=20
online-mode=false  # Disable auth for testing
pvp=true
```

**eula.txt** (must accept EULA):
```
# run-server/eula.txt
eula=true
```

### Server Testing Workflow

**Start server**:
1. Run runServer
2. Wait for "Done! Server listening on port 25565" (20-60s)
3. Server ready for connections

**Connect as client**:
1. Launch Minecraft client (separately)
2. Multiplayer → Add Server
3. Server Address: `localhost` or `127.0.0.1`
4. Join server
5. Test features
6. Check server console for logs

**Test commands**:
```
In server console:
/help mymod            # List mod commands
/giveitems DevPlayer   # Test custom command
/stop                  # Stop server
```

### Multi-Player Testing

**Simulate multiple players** (requires multiple Minecraft instances):

```
Player 1:
- Launch runServer
- Connect from main Minecraft client

Player 2:
- Launch second Minecraft instance
- Connect to localhost
- Interact with Player 1

Test:
- Item trading
- Chat messages
- Shared world state
```

**Network packet testing**:
```
1. Send packet from client to server
2. Check server console for "Received packet: ..."
3. Server processes packet
4. Send response packet to client
5. Verify client receives and handles response
```

### Console Commands

**Standard commands**:
```
/help           # List all commands
/list           # List connected players
/op Player      # Give operator permissions
/gamemode creative Player
/time set day
/weather clear
/stop           # Stop server
```

**Mod commands** (from your mod):
```
/mymod help
/mymod give ruby_sword
/mymod reload config
```

### Performance Testing

**Server tick monitoring**:
```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    long start = System.nanoTime();
    // Your code
    long duration = System.nanoTime() - start;
    if (duration > 50_000_000) {  // 50ms
        LOGGER.warn("Tick lag: {}ms", duration / 1_000_000);
    }
}
```

**TPS (Ticks Per Second)**:
```
Normal: 20 TPS
Lag: < 20 TPS
Check: /tps command (if Forge/Fabric TPS mod installed)
```

---

## Common Issues

### Client won't start

**Error**: Window opens and immediately closes

**Causes**:
- Missing resources (models, textures)
- Code crash during initialization
- Invalid configuration

**Fix**:
1. Check console output for errors
2. Verify resources exist in src/main/resources/
3. Check mod initialization code for null pointers

### Server port conflict

**Error**: "Failed to bind to port 25565"

**Causes**:
- Another server already running
- Zombie process holding port

**Fix**:
```bash
# Check for running servers
./gradlew --stop

# Or change port in server.properties
server-port=25566
```

### Can't connect to server

**Error**: "Connection refused" or "Can't reach server"

**Causes**:
- Server not fully started yet
- Wrong IP/port
- Firewall blocking connection

**Fix**:
1. Wait for "Server listening on port 25565" in console
2. Verify using localhost or 127.0.0.1
3. Check server-port in server.properties matches

### Missing textures in client

**Error**: Purple/black checkerboard texture

**Causes**:
- Missing texture file
- Wrong file path
- Model references wrong texture

**Fix**:
1. Check assets/modid/textures/item/item_name.png exists
2. Check model file texture path matches
3. Verify file names match registry name

---

## Summary

**runClient**: Visual, GUI, rendering testing
**runServer**: Commands, world gen, multi-player testing

**Quick start**: Run config → Wait for startup → Test in-game

**Debugging**: Set breakpoints → Debug mode → Inspect variables

**Performance**: Allocate RAM, profile code, monitor TPS

For data generation workflows, see [Data Generation](./data-generation.md).

For advanced configurations, see [Custom Configurations](./custom-configurations.md).
