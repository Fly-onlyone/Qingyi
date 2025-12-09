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

## Core Knowledge

### Client-Only Code Separation

**Critical Rule**: Rendering code MUST be client-only to avoid crashing dedicated servers.

**Method 1: Separate Class Files**:
```
src/main/java/
├── client/              // Client-only package
│   ├── ClientEvents.java
│   ├── screens/
│   │   └── CustomScreen.java
│   └── rendering/
│       └── CustomOverlay.java
└── common/              // Shared code
    └── CommonEvents.java
```

**Method 2: Runtime Check**:
```java
if (level.isClientSide) {
    // Client-side rendering code
}

// In events
if (event.getSide().isClient()) {
    // Client event handling
}
```

**Method 3: Annotation (Legacy)**:
```java
@OnlyIn(Dist.CLIENT)
public class ClientClass {
    // Client-only code
}
```

## Pattern 1: Boss Bar Management (from Apocalypse_TNT)

### BossBarHelper Utility Class

**Complete Implementation**:
```java
public class BossBarHelper {
    private static ServerBossEvent bossBar;

    /**
     * Create a new boss bar visible to all players
     */
    public static void createBossBar(Component title, BossEvent.BossBarColor color) {
        bossBar = new ServerBossEvent(title, color, BossEvent.BossBarOverlay.PROGRESS);
        bossBar.setVisible(true);
    }

    /**
     * Update boss bar progress (0.0 to 1.0)
     */
    public static void updateProgress(float progress) {
        if (bossBar != null) {
            bossBar.setProgress(Math.max(0.0F, Math.min(1.0F, progress)));
        }
    }

    /**
     * Update boss bar title text
     */
    public static void updateTitle(Component newTitle) {
        if (bossBar != null) {
            bossBar.setName(newTitle);
        }
    }

    /**
     * Change boss bar color
     */
    public static void updateColor(BossEvent.BossBarColor color) {
        if (bossBar != null) {
            bossBar.setColor(color);
        }
    }

    /**
     * Add player to see the boss bar
     */
    public static void addPlayer(ServerPlayer player) {
        if (bossBar != null) {
            bossBar.addPlayer(player);
        }
    }

    /**
     * Remove player from seeing the boss bar
     */
    public static void removePlayer(ServerPlayer player) {
        if (bossBar != null) {
            bossBar.removePlayer(player);
        }
    }

    /**
     * Remove all players from the boss bar
     */
    public static void removeAllPlayers() {
        if (bossBar != null) {
            bossBar.removeAllPlayers();
        }
    }

    /**
     * Clean up and hide the boss bar
     */
    public static void removeBossBar() {
        if (bossBar != null) {
            bossBar.setVisible(false);
            bossBar.removeAllPlayers();
            bossBar = null;
        }
    }

    /**
     * Check if boss bar exists
     */
    public static boolean exists() {
        return bossBar != null;
    }
}
```

### Boss Bar Usage Example

**Countdown Timer with Boss Bar**:
```java
// Create boss bar
BossBarHelper.createBossBar(
    Component.literal("Apocalypse in 60s"),
    BossEvent.BossBarColor.YELLOW
);

// Add all players
server.getPlayerList().getPlayers().forEach(BossBarHelper::addPlayer);

// Update every second in tick handler
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        if (++tickCounter >= 20) { // Once per second
            tickCounter = 0;
            remainingSeconds--;

            // Update progress (60 seconds total)
            float progress = remainingSeconds / 60.0F;
            BossBarHelper.updateProgress(progress);

            // Update title
            BossBarHelper.updateTitle(
                Component.literal("Apocalypse in " + remainingSeconds + "s")
            );

            // Change color based on time
            if (remainingSeconds <= 10) {
                BossBarHelper.updateColor(BossEvent.BossBarColor.RED);
            }

            // Cleanup when done
            if (remainingSeconds <= 0) {
                BossBarHelper.removeBossBar();
            }
        }
    }
}
```

**Adding Players on Join**:
```java
@SubscribeEvent
public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    if (event.getEntity() instanceof ServerPlayer serverPlayer) {
        if (BossBarHelper.exists()) {
            BossBarHelper.addPlayer(serverPlayer);
        }
    }
}
```

### Boss Bar Colors and Styles

**Colors**:
```java
BossEvent.BossBarColor.PINK
BossEvent.BossBarColor.BLUE
BossEvent.BossBarColor.RED
BossEvent.BossBarColor.GREEN
BossEvent.BossBarColor.YELLOW
BossEvent.BossBarColor.PURPLE
BossEvent.BossBarColor.WHITE
```

**Overlays** (Visual Style):
```java
BossEvent.BossBarOverlay.PROGRESS      // Smooth bar
BossEvent.BossBarOverlay.NOTCHED_6     // 6 segments
BossEvent.BossBarOverlay.NOTCHED_10    // 10 segments
BossEvent.BossBarOverlay.NOTCHED_12    // 12 segments
BossEvent.BossBarOverlay.NOTCHED_20    // 20 segments
```

## Pattern 2: Toast Notifications (from MusicMod)

### Custom Toast Implementation

**Toast Class**:
```java
public class TaskToast implements Toast {
    private final Component title;
    private final Component description;
    private long lastChanged;
    private boolean changed;

    public TaskToast(Component title, Component description) {
        this.title = title;
        this.description = description;
    }

    @Override
    public Visibility render(GuiGraphics graphics, ToastComponent toastComponent, long timeSinceLastVisible) {
        // Render toast background (160x32 default size)
        graphics.blit(TEXTURE, 0, 0, 0, 0, this.width(), this.height());

        // Render title (line 1)
        graphics.drawString(
            toastComponent.getMinecraft().font,
            title,
            7, 7,
            0xFFFFFF  // White text
        );

        // Render description (line 2)
        graphics.drawString(
            toastComponent.getMinecraft().font,
            description,
            7, 18,
            0xAAAAAA  // Gray text
        );

        // Display duration (5 seconds)
        return timeSinceLastVisible >= 5000L ? Visibility.HIDE : Visibility.SHOW;
    }

    @Override
    public int width() {
        return 160;
    }

    @Override
    public int height() {
        return 32;
    }
}
```

**Showing Toast (Client-Only)**:
```java
// Simple notification
Minecraft.getInstance().getToasts().addToast(
    new TaskToast(
        Component.literal("Task Complete"),
        Component.literal("You broke 10 logs!")
    )
);
```

**Toast with Custom Duration**:
```java
public class CustomDurationToast implements Toast {
    private final long displayDuration;

    public CustomDurationToast(Component title, long durationMs) {
        this.displayDuration = durationMs;
    }

    @Override
    public Visibility render(GuiGraphics graphics, ToastComponent toastComponent, long timeSinceLastVisible) {
        // Render toast...

        return timeSinceLastVisible >= displayDuration ? Visibility.HIDE : Visibility.SHOW;
    }
}
```

## Pattern 3: Custom Screen (from MusicMod)

### Screen Class Implementation

**Basic Screen**:
```java
public class MusicAdvancementScreen extends Screen {

    protected MusicAdvancementScreen() {
        super(Component.literal("Music Advancements"));
    }

    @Override
    protected void init() {
        super.init();

        // Add widgets (buttons, text fields, etc.)
        this.addRenderableWidget(Button.builder(
            Component.literal("Close"),
            button -> this.onClose()
        ).bounds(this.width / 2 - 50, this.height - 30, 100, 20).build());
    }

    @Override
    public void render(GuiGraphics graphics, int mouseX, int mouseY, float partialTick) {
        // Render background
        this.renderBackground(graphics);

        // Draw title (centered)
        graphics.drawCenteredString(
            this.font,
            this.title,
            this.width / 2,
            20,
            0xFFFFFF
        );

        // Draw custom content
        graphics.drawString(
            this.font,
            "Custom content here",
            10, 40,
            0xAAAAAA
        );

        // Render widgets (buttons, etc.)
        super.render(graphics, mouseX, mouseY, partialTick);
    }

    @Override
    public boolean isPauseScreen() {
        return false;  // Don't pause game when open
    }

    @Override
    public void onClose() {
        // Cleanup before closing
        super.onClose();
    }
}
```

**Opening Screen (Client-Only)**:
```java
Minecraft.getInstance().setScreen(new MusicAdvancementScreen());
```

### Container Screen (with Menu)

**Screen with Background Image**:
```java
public class CustomContainerScreen extends AbstractContainerScreen<CustomMenu> {
    private static final ResourceLocation TEXTURE =
        new ResourceLocation(MODID, "textures/gui/container.png");

    public CustomContainerScreen(CustomMenu menu, Inventory inventory, Component title) {
        super(menu, inventory, title);
        this.imageWidth = 176;
        this.imageHeight = 166;
    }

    @Override
    protected void init() {
        super.init();
        // Calculate leftPos and topPos (automatic)
        // this.leftPos = (this.width - this.imageWidth) / 2;
        // this.topPos = (this.height - this.imageHeight) / 2;
    }

    @Override
    protected void renderBg(GuiGraphics graphics, float partialTick, int mouseX, int mouseY) {
        // Draw background texture
        graphics.blit(TEXTURE, this.leftPos, this.topPos, 0, 0, this.imageWidth, this.imageHeight);
    }

    @Override
    public void render(GuiGraphics graphics, int mouseX, int mouseY, float partialTick) {
        this.renderBackground(graphics);
        super.render(graphics, mouseX, mouseY, partialTick);
        this.renderTooltip(graphics, mouseX, mouseY);
    }

    @Override
    protected void renderLabels(GuiGraphics graphics, int mouseX, int mouseY) {
        // Draw text labels (relative to leftPos/topPos)
        graphics.drawString(this.font, this.title, 8, 6, 0x404040);
        graphics.drawString(this.font, this.playerInventoryTitle, 8, this.imageHeight - 96 + 2, 0x404040);
    }
}
```

## Pattern 4: HUD Overlay Rendering (from MusicMod)

### Overlay Event Handler

**Render Custom Overlay**:
```java
@Mod.EventBusSubscriber(modid = MODID, value = Dist.CLIENT)
public class ClientRenderEvents {

    @SubscribeEvent
    public static void onRenderOverlay(RenderGuiOverlayEvent.Pre event) {
        // Render on top of chat overlay
        if (event.getOverlay().id().equals(VanillaGuiOverlay.CHAT.id())) {
            Minecraft mc = Minecraft.getInstance();
            GuiGraphics graphics = event.getGuiGraphics();

            int screenWidth = mc.getWindow().getGuiScaledWidth();
            int screenHeight = mc.getWindow().getGuiScaledHeight();

            renderCustomOverlay(graphics, screenWidth, screenHeight);
        }
    }

    private static void renderCustomOverlay(GuiGraphics graphics, int screenWidth, int screenHeight) {
        // Example: Rainbow bar with text
        int barWidth = 200;
        int barHeight = 20;
        int x = (screenWidth - barWidth) / 2;
        int y = 10;

        // Render colored rectangles
        for (int i = 0; i < barWidth; i++) {
            int color = getRainbowColor(i, barWidth);
            graphics.fill(x + i, y, x + i + 1, y + barHeight, color);
        }

        // Render text on top
        String text = "Now Playing: Song Title";
        int textX = x + (barWidth - graphics.font.width(text)) / 2;
        graphics.drawString(graphics.font, text, textX, y + 5, 0xFFFFFF);
    }

    private static int getRainbowColor(int index, int total) {
        float hue = (float) index / total;
        return java.awt.Color.HSBtoRGB(hue, 1.0F, 1.0F);
    }
}
```

### GuiGraphics API (Modern Minecraft 1.20+)

**Drawing Methods**:
```java
// Draw text
graphics.drawString(font, text, x, y, color);
graphics.drawCenteredString(font, text, x, y, color);

// Draw textures
graphics.blit(texture, x, y, u, v, width, height);
graphics.blit(texture, x, y, blitOffset, u, v, width, height, textureWidth, textureHeight);

// Draw rectangles
graphics.fill(x1, y1, x2, y2, color);
graphics.fillGradient(x1, y1, x2, y2, colorFrom, colorTo);

// Draw items
graphics.renderItem(itemStack, x, y);
graphics.renderItemDecorations(font, itemStack, x, y);

// Pose stack (transformations)
PoseStack poseStack = graphics.pose();
poseStack.pushPose();
poseStack.translate(x, y, 0);
poseStack.scale(scale, scale, 1.0F);
// ... render transformed content
poseStack.popPose();
```

## Best Practices

### 1. Always Check Side

**Client-Only Code**:
```java
// ✅ Good - runtime check
if (level.isClientSide) {
    Minecraft.getInstance().setScreen(new CustomScreen());
}

// ❌ Bad - crashes dedicated server
Minecraft.getInstance().setScreen(new CustomScreen());
```

### 2. Scale-Aware Rendering

**Get Scaled Dimensions**:
```java
// ✅ Good - works on any GUI scale
int scaledWidth = minecraft.getWindow().getGuiScaledWidth();
int scaledHeight = minecraft.getWindow().getGuiScaledHeight();

// ❌ Bad - hardcoded for specific resolution
int x = 960;  // Breaks on 1920x1080 with GUI scale 3
```

### 3. Clean Up Resources

**Screen Cleanup**:
```java
@Override
public void onClose() {
    // Clean up before closing
    audioPlayer.dispose();
    clearCache();
    super.onClose();
}

@Override
public void removed() {
    super.removed();
    // Additional cleanup
}
```

### 4. Use GuiGraphics API

**Modern (1.20+)**:
```java
// ✅ Good
public void render(GuiGraphics graphics, int mouseX, int mouseY, float partialTick) {
    graphics.drawString(font, text, x, y, color);
}

// ❌ Old (pre-1.20)
public void render(PoseStack poseStack, int mouseX, int mouseY, float partialTick) {
    font.draw(poseStack, text, x, y, color);
}
```

### 5. Throttle Expensive Overlays

**Avoid Every Frame**:
```java
private static int renderCounter = 0;

@SubscribeEvent
public static void onRenderOverlay(RenderGuiOverlayEvent.Pre event) {
    if (++renderCounter >= 20) { // Update every 20 frames (~1 second at 20 FPS)
        renderCounter = 0;
        updateExpensiveOverlay();
    }
    renderCachedOverlay(event.getGuiGraphics());
}
```

## Anti-Patterns

### 1. ❌ Client Code on Server

```java
// ❌ Crashes dedicated server
@SubscribeEvent
public static void onPlayerTick(TickEvent.PlayerTickEvent event) {
    Minecraft mc = Minecraft.getInstance(); // CLIENT-ONLY!
}

// ✅ Check side first
if (event.side.isClient()) {
    Minecraft mc = Minecraft.getInstance();
}
```

### 2. ❌ Not Disposing Resources

```java
// ❌ Memory leak
public class CustomScreen extends Screen {
    private OpenALPlayer audioPlayer;

    // Missing cleanup
}

// ✅ Clean up
@Override
public void onClose() {
    audioPlayer.dispose();
    super.onClose();
}
```

### 3. ❌ Heavy Rendering Every Frame

```java
// ❌ Lags client
@SubscribeEvent
public static void onRender(RenderGuiOverlayEvent.Pre event) {
    // Expensive calculation every frame (60+ FPS)
    calculateComplexOverlay();
}

// ✅ Cache or throttle
private static OverlayData cachedOverlay;

if (cachedOverlay == null || shouldUpdate()) {
    cachedOverlay = calculateComplexOverlay();
}
renderCachedOverlay(cachedOverlay);
```

### 4. ❌ Hardcoded Screen Positions

```java
// ❌ Breaks on different resolutions/GUI scales
graphics.drawString(font, text, 500, 300, color);

// ✅ Use relative positioning
int centerX = screenWidth / 2;
int centerY = screenHeight / 2;
graphics.drawString(font, text, centerX, centerY, color);
```

### 5. ❌ Forgetting to Call Super

```java
// ❌ Widgets won't render
@Override
public void render(GuiGraphics graphics, int mouseX, int mouseY, float partialTick) {
    graphics.drawString(font, text, 10, 10, color);
    // Missing: super.render(graphics, mouseX, mouseY, partialTick);
}

// ✅ Always call super for widgets
super.render(graphics, mouseX, mouseY, partialTick);
```

## Performance Optimization

### Caching Rendered Content

**Cache Static Elements**:
```java
private static Component cachedTitle;
private static List<Component> cachedLines;
private static long lastCacheTime;

private static void updateCacheIfNeeded() {
    long now = System.currentTimeMillis();
    if (cachedTitle == null || now - lastCacheTime > 1000) {
        cachedTitle = calculateTitle();
        cachedLines = calculateLines();
        lastCacheTime = now;
    }
}
```

### Batching Render Calls

**Batch Similar Operations**:
```java
// ✅ Good - batch texture blits
graphics.blit(texture, x1, y1, u, v, w, h);
graphics.blit(texture, x2, y2, u, v, w, h);
graphics.blit(texture, x3, y3, u, v, w, h);

// Instead of switching between different operations
```

## Verification Checklist

- [ ] Client-only code properly separated (package, @OnlyIn, or runtime check)
- [ ] No `Minecraft.getInstance()` on server side
- [ ] Boss bars cleaned up with `removeAllPlayers()`
- [ ] Resources disposed in `onClose()` or `removed()`
- [ ] GUI scales handled (use scaled width/height)
- [ ] Super methods called (`super.render()`, `super.init()`)
- [ ] Heavy overlays throttled or cached
- [ ] No hardcoded screen positions
- [ ] Toast display duration appropriate (3-5 seconds)
- [ ] Progress bars clamped (0.0F to 1.0F)

## See Also

- [gui-development](../gui-development/SKILL.md) - Advanced GUI patterns
- [sound-system-api](../sound-system-api/SKILL.md) - Audio integration
- Official GuiGraphics: https://docs.minecraftforge.net/en/latest/gui/
