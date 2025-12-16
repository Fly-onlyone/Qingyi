# Real-World Brave Search Examples

Practical examples of using Brave MCP search for actual Minecraft modding research tasks.

## Example 1: NeoForge Migration Research

**Context**: User wants to migrate a Forge 1.20.1 mod to NeoForge 1.21.3

### Step 1: Find Official Migration Guide

```javascript
brave_web_search({
  query: "Forge to NeoForge migration guide 1.20 to 1.21",
  allowed_domains: ["docs.neoforged.net", "neoforged.net"],
  count: 5,
  freshness: "py"
})
```

**Expected Results:**
- NeoForge official migration documentation
- Breaking changes list
- API mapping guides

### Step 2: Find Community Migration Examples

```javascript
brave_web_search({
  query: "NeoForge 1.21 migration example site:github.com",
  count: 15,
  freshness: "pm"
})
```

**Expected Results:**
- GitHub repositories with migration commits
- Pull requests showing before/after code
- Community mod examples

### Step 3: Research Specific Breaking Changes

```javascript
brave_web_search({
  query: "NeoForge 1.21 DeferredRegister changes from Forge",
  result_filter: ["discussions", "web"],
  freshness: "pm",
  count: 10
})
```

**Expected Results:**
- Forum discussions about registry changes
- StackOverflow questions
- GitHub issue discussions

### Step 4: Find Video Walkthroughs

```javascript
brave_video_search({
  query: "Forge to NeoForge migration tutorial 1.21",
  freshness: "pm",
  count: 20
})
```

**Expected Results:**
- Video tutorials by TurtyWurty, McJty, etc.
- Step-by-step migration guides
- Live coding sessions

**Output Format:**

```markdown
# NeoForge Migration Research: Forge 1.20.1 → NeoForge 1.21.3

## Official Documentation

According to the [NeoForge Migration Guide](https://docs.neoforged.net/docs/1.21.x/migration/),
the key changes are:

1. **Registry Changes**: DeferredRegister now uses `NeoForgeRegistries` instead of `ForgeRegistries`
2. **Event Bus Changes**: `@EventBusSubscriber` annotation requires `bus = Bus.MOD`
3. **Capability System**: Removed in favor of attachment system

## Migration Examples

The [ExampleMod repository](https://github.com/neoforged/ExampleMod) shows:
```java
// Before (Forge 1.20.1)
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

// After (NeoForge 1.21.3)
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(Registries.ITEM, MODID);
```

## Community Insights

A [discussion on the NeoForge Forums](https://forums.neoforged.net/topic/...)
highlights common migration issues:
- Capability replacements require rewriting data attachment logic
- Event priorities may need adjustment
- Mixin targets may have changed due to Mojang mappings updates

## Video Resources

- [TurtyWurty's NeoForge Migration Guide](https://youtube.com/...) - Complete walkthrough
- [McJty's Registry System Changes](https://youtube.com/...) - Focus on DeferredRegister
```

---

## Example 2: Audio Playback Research

**Context**: User wants to implement music playback similar to MusicMod project

### Step 1: Find Minecraft Audio API Documentation

```javascript
brave_web_search({
  query: "Minecraft Java Edition audio playback SoundManager API",
  allowed_domains: ["minecraft.wiki", "fabricmc.net", "docs.neoforged.net"],
  count: 10
})
```

### Step 2: Research OpenAL Integration

```javascript
brave_web_search({
  query: "Minecraft OpenAL custom sound playback mod",
  result_filter: ["web", "discussions"],
  freshness: "py",
  count: 15
})
```

### Step 3: Find Existing Audio Mod Examples

```javascript
brave_web_search({
  query: "Minecraft music mod source code site:github.com",
  count: 20
})
```

### Step 4: Search for Audio Codec Libraries

```javascript
brave_web_search({
  query: "Java audio decoder library MP3 OGG FLAC",
  result_filter: ["web"],
  count: 10
})
```

### Step 5: Generate Comprehensive Summary

```javascript
const results = brave_web_search({
  query: "Minecraft mod custom audio playback OpenAL JavaSound",
  count: 15,
  summary: true,
  freshness: "py"
})

brave_summarizer({
  key: results.summarizer.key,
  inline_references: true
})
```

**Output Format:**

```markdown
# Audio Playback Research for MusicMod

## Minecraft Audio Architecture

According to the [Minecraft Wiki](https://minecraft.wiki/w/Sounds.json), Minecraft's
audio system uses:
- **SoundManager**: High-level API for playing game sounds
- **OpenAL Backend**: Low-level audio rendering via LWJGL's OpenAL bindings
- **Sound Resources**: JSON-defined sound events in resource packs

## Custom Audio Implementation Approaches

### Approach 1: Using SoundManager (Recommended for Short Clips)

[FabricMC Sound Tutorial](https://fabricmc.net/wiki/tutorial:sounds) shows:
```java
SoundManager soundManager = MinecraftClient.getInstance().getSoundManager();
soundManager.play(new PositionedSoundInstance(...));
```

**Pros**: Integrates with Minecraft's audio settings
**Cons**: Limited control over playback (no seeking, pause)

### Approach 2: Direct OpenAL (Recommended for Music Playback)

[OpenAL Tutorial](https://www.lwjgl.org/guide) demonstrates:
```java
long device = alcOpenDevice((ByteBuffer) null);
long context = alcCreateContext(device, (IntBuffer) null);
alcMakeContextCurrent(context);
int source = alGenSources();
```

**Pros**: Full control (seeking, volume, looping)
**Cons**: More complex, need to manage OpenAL context

## Audio Decoding Libraries

- [JLayer](http://www.javazoom.net/javalayer/javalayer.html) - MP3 decoder
- [Vorbis-Java](https://github.com/Gagravarr/VorbisJava) - OGG Vorbis decoder
- [JFLAC](http://jflac.sourceforge.net/) - FLAC decoder

## Example Implementation

The [Radio Mod](https://github.com/user/RadioMod) shows a complete implementation
using OpenAL for internet radio streaming with seeking and volume control.
```

---

## Example 3: GUI Rendering Research

**Context**: User wants to create a custom advancement screen like MusicMod

### Step 1: Find Vanilla Screen Structure

```javascript
brave_web_search({
  query: "Minecraft AdvancementsScreen source code decompiled",
  count: 10
})
```

### Step 2: Research Custom Screen Patterns

```javascript
brave_web_search({
  query: "Minecraft custom GUI screen tutorial NeoForge 2025",
  result_filter: ["web", "videos"],
  freshness: "pm",
  count: 15
})
```

### Step 3: Find Rendering Examples

```javascript
brave_image_search({
  query: "Minecraft custom advancement screen GUI",
  count: 50,
  safesearch: "strict"
})
```

### Step 4: Research Widget System

```javascript
brave_web_search({
  query: "Minecraft GUI widget AbstractWidget button rendering",
  allowed_domains: ["minecraft.wiki", "fabricmc.net"],
  count: 10
})
```

**Output Format:**

```markdown
# Custom Advancement Screen Research

## Vanilla Implementation Analysis

The [Minecraft Wiki](https://minecraft.wiki/w/Advancements) describes the
advancement screen structure:
- **AdvancementsScreen**: Main container
- **AdvancementTab**: Individual tabs
- **AdvancementWidget**: Individual advancement icons

## Rendering Architecture

According to [FabricMC GUI Tutorial](https://fabricmc.net/wiki/tutorial:screens):

```java
public class CustomScreen extends Screen {
    @Override
    public void render(DrawContext context, int mouseX, int mouseY, float delta) {
        this.renderBackground(context, mouseX, mouseY, delta);
        // Custom rendering here
        super.render(context, mouseX, mouseY, delta);
    }
}
```

## Visual Examples

![Custom Advancement Screen](https://i.imgur.com/example.png)
*Example custom advancement UI from CommunityMod*

## Widget Integration

[NeoForge Screen Tutorial](https://docs.neoforged.net/docs/gui/screens) shows
widget registration:

```java
@Override
protected void init() {
    super.init();
    this.addRenderableWidget(ButtonWidget.builder(
        Component.literal("Play"),
        button -> onPlayClicked()
    ).bounds(x, y, width, height).build());
}
```
```

---

## Example 4: Entity Spawning Research

**Context**: User wants to implement TNT spawning waves like Apocalypse_TNT

### Step 1: Find Entity Registration Patterns

```javascript
brave_web_search({
  query: "NeoForge 1.21 custom entity registration DeferredRegister",
  allowed_domains: ["docs.neoforged.net"],
  count: 5
})
```

### Step 2: Research Entity Spawning APIs

```javascript
brave_web_search({
  query: "Minecraft ServerLevel addFreshEntity spawn entity programmatically",
  result_filter: ["web", "discussions"],
  freshness: "py",
  count: 10
})
```

### Step 3: Find Wave Spawning Patterns

```javascript
brave_web_search({
  query: "Minecraft mob spawner wave system tick handler",
  count: 15
})
```

### Step 4: Research Boss Bar Integration

```javascript
brave_web_search({
  query: "Minecraft BossEvent custom boss bar ServerBossEvent",
  allowed_domains: ["minecraft.wiki", "fabricmc.net", "docs.neoforged.net"],
  count: 10
})
```

**Output Format:**

```markdown
# Entity Spawning Wave System Research

## Entity Registration

[NeoForge Entity Tutorial](https://docs.neoforged.net/docs/1.21.x/entities/)
shows registration:

```java
public static final DeferredRegister<EntityType<?>> ENTITIES =
    DeferredRegister.create(Registries.ENTITY_TYPE, MODID);

public static final Supplier<EntityType<CustomEntity>> CUSTOM_ENTITY =
    ENTITIES.register("custom_entity", () -> EntityType.Builder
        .of(CustomEntity::new, MobCategory.MISC)
        .sized(0.98f, 0.98f)
        .build("custom_entity"));
```

## Spawning Entities

According to [Minecraft Wiki - Spawning](https://minecraft.wiki/w/Spawning):

```java
ServerLevel level = (ServerLevel) entity.level();
CustomEntity spawned = new CustomEntity(level);
spawned.setPos(x, y, z);
level.addFreshEntity(spawned);
```

## Wave Management with Tick Handlers

[NeoForge Event Tutorial](https://docs.neoforged.net/docs/events/) demonstrates:

```java
@SubscribeEvent
public static void onServerTick(TickEvent.ServerTickEvent event) {
    if (event.phase == TickEvent.Phase.END) {
        waveManager.tick(event.getServer());
    }
}
```

## Boss Bar Integration

[Minecraft Boss Bar Guide](https://minecraft.wiki/w/Boss_bar) shows:

```java
ServerBossEvent bossBar = new ServerBossEvent(
    Component.literal("Wave 1/10"),
    BossEvent.BossBarColor.RED,
    BossEvent.BossBarOverlay.PROGRESS
);
bossBar.setProgress(0.5f);  // 50% progress
player.connection.send(new ClientboundBossEventPacket(
    ClientboundBossEventPacket.Operation.ADD, bossBar
));
```
```

---

## Example 5: Multi-Framework Comparison

**Context**: User wants to understand registry differences between Forge, NeoForge, and Fabric

### Research Strategy

```javascript
// Search 1: Forge Pattern
const forgeResults = brave_web_search({
  query: "Forge 1.20.1 DeferredRegister registration pattern",
  allowed_domains: ["docs.minecraftforge.net", "mcforge.readthedocs.io"],
  count: 5
})

// Search 2: NeoForge Pattern
const neoResults = brave_web_search({
  query: "NeoForge 1.21 DeferredRegister registration pattern",
  allowed_domains: ["docs.neoforged.net"],
  count: 5
})

// Search 3: Fabric Pattern
const fabricResults = brave_web_search({
  query: "Fabric 1.21 Registry.register registration pattern",
  allowed_domains: ["fabricmc.net"],
  count: 5
})

// Search 4: Comparison Articles
const comparisons = brave_web_search({
  query: "Forge vs NeoForge vs Fabric registry comparison 2025",
  result_filter: ["web", "discussions"],
  freshness: "pm",
  count: 10
})
```

**Output Format:**

```markdown
# Registry System Comparison: Forge vs NeoForge vs Fabric

## Forge 1.20.1

According to [Forge Documentation](https://docs.minecraftforge.net/):

```java
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(ForgeRegistries.ITEMS, MODID);

public static final RegistryObject<Item> CUSTOM_ITEM =
    ITEMS.register("custom_item", () -> new Item(new Item.Properties()));
```

**Key Features:**
- DeferredRegister handles registration timing
- RegistryObject provides lazy initialization
- ForgeRegistries contains all vanilla registries

## NeoForge 1.21

According to [NeoForge Documentation](https://docs.neoforged.net/):

```java
public static final DeferredRegister<Item> ITEMS =
    DeferredRegister.create(Registries.ITEM, MODID);

public static final Supplier<Item> CUSTOM_ITEM =
    ITEMS.register("custom_item", () -> new Item(new Item.Properties()));
```

**Key Differences from Forge:**
- Uses `Registries` instead of `ForgeRegistries` (Mojang mappings)
- Returns `Supplier<T>` instead of `RegistryObject<T>`
- Simplified API, fewer deprecated methods

## Fabric 1.21

According to [Fabric Documentation](https://fabricmc.net/wiki/):

```java
public static final Item CUSTOM_ITEM = Registry.register(
    Registries.ITEM,
    new Identifier(MODID, "custom_item"),
    new Item(new FabricItemSettings())
);
```

**Key Differences:**
- Immediate registration (no deferred pattern)
- Uses `Identifier` for resource locations
- `FabricItemSettings` instead of `Item.Properties`

## Summary Table

| Feature | Forge 1.20 | NeoForge 1.21 | Fabric 1.21 |
|---------|------------|---------------|-------------|
| Registration | Deferred | Deferred | Immediate |
| Return Type | RegistryObject<T> | Supplier<T> | T |
| Registry Access | ForgeRegistries | Registries | Registries |
| Resource Location | ResourceLocation | ResourceLocation | Identifier |
| Settings Class | Item.Properties | Item.Properties | FabricItemSettings |

## Migration Implications

When migrating between frameworks:
- **Forge → NeoForge**: Change registry access, update return types
- **Forge → Fabric**: Rewrite to immediate registration, change settings
- **Fabric → NeoForge**: Wrap in DeferredRegister, change Identifier to ResourceLocation
```

---

## Example 6: Troubleshooting Build Errors

**Context**: User gets "class file not found" error during Gradle build

### Step 1: Search Exact Error

```javascript
brave_web_search({
  query: "\"class file for net.neoforged.neoforge.registries.DeferredRegister not found\"",
  result_filter: ["discussions", "web"],
  freshness: "py",
  count: 10
})
```

### Step 2: Search Gradle Dependency Issues

```javascript
brave_web_search({
  query: "NeoForge Gradle dependency resolution error",
  result_filter: ["discussions"],
  freshness: "pm",
  count: 10
})
```

### Step 3: Check Official Issue Tracker

```javascript
brave_web_search({
  query: "DeferredRegister class not found site:github.com/neoforged/NeoForge/issues",
  count: 10
})
```

**Output Format:**

```markdown
# Troubleshooting: DeferredRegister Class Not Found

## Root Cause

According to [GitHub Issue #123](https://github.com/neoforged/NeoForge/issues/123),
this error occurs when:

1. Gradle cache is corrupted
2. NeoForge dependency version mismatch
3. IDE not synced with Gradle changes

## Solution

[NeoForge Forums Discussion](https://forums.neoforged.net/topic/...) recommends:

```bash
# Step 1: Clear Gradle cache
./gradlew clean --refresh-dependencies

# Step 2: Regenerate IDE files
./gradlew eclipse  # or genIntellijRuns

# Step 3: Refresh IDE
# IntelliJ: File → Invalidate Caches → Invalidate and Restart
```

## Prevention

Ensure `build.gradle` has correct NeoForge version:

```gradle
minecraft {
    version = '1.21.3'
}

dependencies {
    minecraft "net.neoforged:neoforge:21.3.0-beta"
}
```

Match version numbers in `gradle.properties`:
```properties
minecraft_version=1.21.3
neo_version=21.3.0-beta
```
```

---

## Best Practices Summary

### Always Include in Queries:
1. ✅ Framework name (NeoForge, Fabric, Forge)
2. ✅ Version number (1.21.3, 1.20.1)
3. ✅ Current year (2025)
4. ✅ Specific API names (DeferredRegister, Registry.register)

### Always Apply Filters:
1. ✅ `freshness` for version-specific topics
2. ✅ `allowed_domains` for official documentation
3. ✅ `result_filter` to target specific content types
4. ✅ `count` to minimize token usage

### Always Cite Sources:
1. ✅ Use markdown hyperlinks: `[Source](URL)`
2. ✅ Include domain in source name for clarity
3. ✅ Verify information across multiple sources
4. ✅ Prioritize official docs over community tutorials

### Progressive Research Pattern:
1. Start broad → Official documentation
2. Narrow down → Community tutorials
3. Specific examples → GitHub repositories
4. Edge cases → Forum discussions
5. Synthesis → Summarizer (if needed)
