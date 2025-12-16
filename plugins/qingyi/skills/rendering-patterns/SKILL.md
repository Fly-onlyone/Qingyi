---
name: rendering-patterns
description: Minecraft client-side rendering patterns including GUI development, boss bars, overlays, HUD elements, custom screens, and toast notifications. Use when implementing client-only features, custom UI, or visual feedback systems. Covers patterns from real mods and best practices for Forge/NeoForge.
allowed-tools: Read, Grep, Glob
---

# Rendering Patterns

## What This Covers

- Boss bar creation and management
- Toast notifications
- Custom screens and GUIs
- HUD overlays and rendering
- Client-server separation
- GuiGraphics API (modern Minecraft)
- Performance optimization

## When to Use

- Creating custom boss bars for events
- Implementing toast notifications
- Building custom screens or menus
- Rendering HUD overlays
- Displaying progress or status to players
- Client-only visual feedback

---

## Critical Rule: Client-Only Code Separation

**Rendering code MUST be client-only** to avoid crashing dedicated servers.

### Method 1: Separate Package (Recommended)
```
src/main/java/
├── client/              // Client-only package
│   ├── ClientEvents.java
│   ├── screens/
│   └── rendering/
└── common/              // Shared code
```

### Method 2: Runtime Check
```java
if (level.isClientSide) {
    // Client-side rendering code
}
```

### Method 3: Annotation (Forge/NeoForge)
```java
@OnlyIn(Dist.CLIENT)
public class ClientClass {
    // Client-only code
}
```

**For complete separation guide**: See [client-server-separation.md](./client-server-separation.md)

---

## Common Patterns (Quick Reference)

### Pattern 1: Boss Bars

**Create boss bar visible to all players**:
```java
ServerBossEvent bossBar = new ServerBossEvent(
    Component.literal("Apocalypse Starting"),
    BossEvent.BossBarColor.RED,
    BossEvent.BossBarOverlay.PROGRESS
);
bossBar.setVisible(true);
bossBar.setProgress(0.5F);  // 0.0 to 1.0

// Add to specific player
bossBar.addPlayer((ServerPlayer) player);

// Add to all players
server.getPlayerList().getPlayers().forEach(bossBar::addPlayer);
```

**For complete boss bar implementation**: See [boss-bar-guide.md](./boss-bar-guide.md)

### Pattern 2: Toast Notifications

**Show toast notification to player**:
```java
@OnlyIn(Dist.CLIENT)
public static void showToast(Component title, Component message) {
    Minecraft mc = Minecraft.getInstance();
    mc.getToasts().addToast(new SystemToast(
        SystemToast.SystemToastIds.TUTORIAL_HINT,
        title,
        message
    ));
}
```

**For complete toast guide**: See [toast-notifications.md](./toast-notifications.md)

### Pattern 3: Custom Screens

**Basic custom screen**:
```java
@OnlyIn(Dist.CLIENT)
public class CustomScreen extends Screen {
    public CustomScreen() {
        super(Component.literal("Custom Screen"));
    }

    @Override
    public void render(GuiGraphics graphics, int mouseX, int mouseY, float partialTick) {
        this.renderBackground(graphics);
        graphics.drawCenteredString(this.font, this.title,
            this.width / 2, 20, 0xFFFFFF);
        super.render(graphics, mouseX, mouseY, partialTick);
    }
}

// Open screen
Minecraft.getInstance().setScreen(new CustomScreen());
```

**For complete screen development**: See [custom-screens-guide.md](./custom-screens-guide.md)

### Pattern 4: HUD Overlays

**Register overlay renderer**:
```java
@Mod.EventBusSubscriber(modid = MODID, bus = Bus.MOD, value = Dist.CLIENT)
public class ClientSetup {
    @SubscribeEvent
    public static void registerOverlays(RegisterGuiOverlaysEvent event) {
        event.registerAboveAll("custom_overlay", (gui, graphics, partialTick, width, height) -> {
            // Render HUD elements
            graphics.drawString(Minecraft.getInstance().font,
                "Custom HUD", 10, 10, 0xFFFFFF);
        });
    }
}
```

**For complete HUD guide**: See [hud-overlays-guide.md](./hud-overlays-guide.md)

---

## Real-World Example: Apocalypse Boss Bar

**From Apocalypse_TNT mod** (NeoForge):

```java
// Create countdown boss bar
public static void startApocalypse(MinecraftServer server) {
    ServerBossEvent bossBar = new ServerBossEvent(
        Component.literal("Apocalypse in 60 seconds"),
        BossEvent.BossBarColor.RED,
        BossEvent.BossBarOverlay.PROGRESS
    );
    bossBar.setVisible(true);

    // Add to all players
    server.getPlayerList().getPlayers().forEach(bossBar::addPlayer);

    // Update every second
    AtomicInteger countdown = new AtomicInteger(60);
    ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    scheduler.scheduleAtFixedRate(() -> {
        int remaining = countdown.decrementAndGet();
        bossBar.setProgress(remaining / 60.0F);
        bossBar.setName(Component.literal("Apocalypse in " + remaining + " seconds"));

        if (remaining <= 0) {
            bossBar.setVisible(false);
            scheduler.shutdown();
        }
    }, 0, 1, TimeUnit.SECONDS);
}
```

**Key Techniques**:
- Server-side boss bar (ServerBossEvent)
- Dynamic progress updates
- Title text updates
- Scheduled task execution

---

## GuiGraphics API (Modern Minecraft)

**Modern rendering uses GuiGraphics** (1.19.4+):

```java
// Old way (deprecated)
poseStack.pushPose();
// render with PoseStack

// New way (modern)
@Override
public void render(GuiGraphics graphics, int mouseX, int mouseY, float partialTick) {
    // Draw string
    graphics.drawString(font, "Text", x, y, color);

    // Draw centered string
    graphics.drawCenteredString(font, text, centerX, y, color);

    // Draw texture
    graphics.blit(TEXTURE_LOCATION, x, y, u, v, width, height);

    // Draw item
    graphics.renderItem(itemStack, x, y);

    // Draw tooltip
    graphics.renderTooltip(font, Component.literal("Tooltip"), x, y);
}
```

**For complete GuiGraphics reference**: See [gui-graphics-api.md](./gui-graphics-api.md)

---

## Framework Differences

### Forge/NeoForge
- Uses `@OnlyIn(Dist.CLIENT)` for client-only classes
- Event-based overlay registration (`RegisterGuiOverlaysEvent`)
- ServerBossEvent for server-side boss bars
- GuiGraphics API (1.19.4+)

### Fabric
- Uses `@Environment(EnvType.CLIENT)` for client-only classes
- HudRenderCallback for overlays
- BossBar API similar to Forge
- GuiGraphics API (1.19.4+)

**For framework-specific details**: See [framework-comparison.md](./framework-comparison.md)

---

## Best Practices

### Performance
1. **Cache textures** - Load once, reuse
2. **Batch rendering** - Minimize state changes
3. **Cull off-screen elements** - Don't render what's not visible
4. **Use scissor for clipping** - Prevent overdraw

### Client Safety
1. **Always check side** - `level.isClientSide` before rendering
2. **Use client-only packages** - Separate client code physically
3. **Annotate client classes** - `@OnlyIn(Dist.CLIENT)` or `@Environment(EnvType.CLIENT)`

### User Experience
1. **Respect vanilla UI** - Don't obstruct important elements
2. **Make it toggleable** - Allow users to hide overlays
3. **Scale with GUI** - Respect GUI scale settings
4. **Use vanilla colors** - Match Minecraft's aesthetic

---

## Common Pitfalls

### ❌ Server Crash
```java
// BAD: Client-only code in common class
public void onEvent(Event event) {
    Minecraft.getInstance().player.sendMessage(...);  // CRASH on server!
}
```

### ✅ Safe Approach
```java
// GOOD: Check side first
public void onEvent(Event event, Level level) {
    if (level.isClientSide) {
        ClientHelper.showMessage(...);  // Client-only helper
    }
}
```

### ❌ Memory Leak
```java
// BAD: Never remove players from boss bar
bossBar.addPlayer(player);  // Leaks when player disconnects
```

### ✅ Safe Approach
```java
// GOOD: Clean up on disconnect
@SubscribeEvent
public void onPlayerLogout(PlayerEvent.PlayerLoggedOutEvent event) {
    if (bossBar != null) {
        bossBar.removePlayer((ServerPlayer) event.getEntity());
    }
}
```

---

## Supporting Documentation

### Detailed Guides
- [Client-Server Separation](./client-server-separation.md) - Complete guide to keeping client code safe
- [Boss Bar Guide](./boss-bar-guide.md) - Full boss bar implementation with examples
- [Toast Notifications](./toast-notifications.md) - Complete toast notification patterns
- [Custom Screens Guide](./custom-screens-guide.md) - Building custom GUI screens
- [HUD Overlays Guide](./hud-overlays-guide.md) - Creating HUD overlays and widgets
- [GuiGraphics API](./gui-graphics-api.md) - Complete GuiGraphics reference
- [Framework Comparison](./framework-comparison.md) - Forge vs Fabric rendering differences

---

## Quick Decision Tree

**Need to show progress?**
→ Use Boss Bar (server-side, all players see it)

**Need brief notification?**
→ Use Toast (client-side, per-player)

**Need interactive UI?**
→ Use Custom Screen (full screen overlay)

**Need persistent HUD?**
→ Use HUD Overlay (always visible, minimal)

**Need chat message?**
→ Use `player.sendSystemMessage()` (server-side)

---

Use this skill when implementing any client-side visual features to ensure proper client-server separation and follow best practices from real mods.
