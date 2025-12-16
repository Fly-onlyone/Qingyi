# GitHub Code Search Query Patterns Reference

Comprehensive reference for constructing effective GitHub code search queries for Minecraft modding research.

## Query Syntax Fundamentals

### Basic Structure

```
[keywords] [qualifiers]
```

**Keywords**: What you're searching for (class names, method calls, patterns)
**Qualifiers**: Filters that narrow results (language, path, user, repo)

### Essential Qualifiers

| Qualifier | Purpose | Example |
|-----------|---------|---------|
| `language:` | Filter by programming language | `language:java` |
| `path:` | Search in specific directories | `path:items` |
| `repo:` | Search specific repository | `repo:neoforged/NeoForge` |
| `user:` | Search user's repositories | `user:FabricMC` |
| `org:` | Search organization repos | `org:neoforged` |
| `extension:` | Filter by file extension | `extension:java` |
| `size:` | Filter by file size | `size:>1000` |
| `filename:` | Search by filename | `filename:build.gradle` |

## Minecraft Modding Query Templates

### Template 1: Registry Patterns

**NeoForge Registry Search**:
```javascript
{
  query: "DeferredRegister.create Registries language:java",
  perPage: 15
}
```

**Fabric Registry Search**:
```javascript
{
  query: "Registry.register Registries.ITEM Identifier language:java",
  perPage: 15
}
```

**Multi-Framework Registry**:
```javascript
{
  query: "(DeferredRegister OR Registry.register) custom item language:java",
  perPage: 20
}
```

### Template 2: Event Handler Patterns

**NeoForge Events**:
```javascript
{
  query: "@SubscribeEvent ServerTickEvent language:java",
  perPage: 15
}
```

**Fabric Events**:
```javascript
{
  query: "ServerTickEvents.END_SERVER_TICK.register language:java",
  perPage: 15
}
```

**Event with Specific Action**:
```javascript
{
  query: "ServerTickEvent entity spawn language:java path:event",
  perPage: 20
}
```

### Template 3: Custom Content

**Custom Blocks**:
```javascript
{
  query: "extends Block registerBlock language:java path:blocks",
  perPage: 15
}
```

**Custom Items**:
```javascript
{
  query: "extends Item DeferredRegister language:java path:items",
  perPage: 15
}
```

**Custom Entities**:
```javascript
{
  query: "extends LivingEntity EntityType.Builder language:java path:entity",
  perPage: 15
}
```

### Template 4: Rendering & Client

**Custom Screens/GUIs**:
```javascript
{
  query: "extends Screen renderBackground language:java path:client/gui",
  perPage: 15
}
```

**Rendering Code**:
```javascript
{
  query: "RenderType ShaderInstance language:java path:client/render",
  perPage: 10
}
```

**Audio/Sound**:
```javascript
{
  query: "SoundManager OpenAL language:java path:client/audio",
  perPage: 10
}
```

### Template 5: Data & Persistence

**NBT Serialization**:
```javascript
{
  query: "CompoundTag save load language:java",
  perPage: 15
}
```

**SavedData Patterns**:
```javascript
{
  query: "extends SavedData save language:java",
  perPage: 10
}
```

**Capabilities (Forge) / Attachments (NeoForge)**:
```javascript
// Forge
{
  query: "CapabilityProvider ICapabilityProvider language:java",
  perPage: 10
}

// NeoForge
{
  query: "AttachmentType NeoForge language:java",
  perPage: 10
}
```

### Template 6: Networking

**Packet Handling**:
```javascript
{
  query: "SimpleChannel NetworkEvent context language:java path:network",
  perPage: 15
}
```

**Client-Server Sync**:
```javascript
{
  query: "sendToServer sendToClient packet language:java",
  perPage: 15
}
```

### Template 7: Configuration

**Config Files**:
```javascript
{
  query: "ForgeConfigSpec Builder language:java path:config",
  perPage: 10
}
```

**TOML Configuration**:
```javascript
{
  query: "mods.toml minecraft version",
  perPage: 10
}
```

### Template 8: Data Generation

**Data Generators**:
```javascript
{
  query: "DataGenerator runData language:java path:datagen",
  perPage: 15
}
```

**Recipe Generation**:
```javascript
{
  query: "RecipeProvider shaped shapeless language:java",
  perPage: 10
}
```

## Advanced Search Patterns

### Boolean Operators

**OR (Find any)**:
```javascript
{
  query: "(ServerTickEvent OR LevelTickEvent) spawn",
  perPage: 20
}
```

**NOT (Exclude)**:
```javascript
{
  query: "DeferredRegister NeoForge NOT Forge language:java",
  perPage: 15
}
```

**AND (Require both)**:
```javascript
{
  query: "custom entity AND AI goals language:java",
  perPage: 15
}
```

### Exact Phrase Matching

Use quotes for exact phrases:

```javascript
{
  query: "\"DeferredRegister.create(Registries.ITEM\"",
  perPage: 10
}
```

### Path Wildcards

**Match multiple directories**:
```javascript
{
  query: "custom armor path:items OR path:armor language:java",
  perPage: 15
}
```

**Nested paths**:
```javascript
{
  query: "event handler path:com/example/*/events language:java",
  perPage: 10
}
```

### Repository Filtering

**Specific repo**:
```javascript
{
  query: "DeferredRegister repo:neoforged/NeoForge",
  perPage: 5
}
```

**Organization repos**:
```javascript
{
  query: "Registry org:FabricMC language:java",
  perPage: 10
}
```

**Popular mods only**:
```javascript
{
  query: "custom entity minecraft mod",
  perPage: 20
}
// Then use search_repositories to filter by stars
```

### File Size Filtering

**Large implementation files**:
```javascript
{
  query: "custom entity size:>2000 language:java",
  perPage: 10
}
```

**Exclude large files**:
```javascript
{
  query: "simple event handler size:<500 language:java",
  perPage: 15
}
```

## Framework-Specific Query Libraries

### NeoForge 1.21+ Queries

```javascript
// Registry system
"DeferredRegister.create Registries NeoForge language:java"

// Event bus
"@EventBusSubscriber bus MOD language:java"

// Attachments (new capability system)
"AttachmentType setAttachedData language:java"

// Network packets
"IPayloadHandler SimpleChannel language:java"

// Creative tabs
"CreativeModeTab.builder language:java"
```

### Fabric 1.20+ Queries

```javascript
// Registry
"Registry.register Registries.ITEM Identifier language:java"

// Events
"ServerTickEvents.END_SERVER_TICK.register language:java"

// Mixins
"@Mixin @Inject language:java path:mixin"

// API utilities
"FabricItemSettings language:java"

// Lifecycle events
"ServerLifecycleEvents language:java"
```

### Forge 1.19-1.20 Queries (Legacy)

```javascript
// Registry (old pattern)
"DeferredRegister.create ForgeRegistries language:java"

// Capabilities (deprecated in NeoForge)
"ICapabilityProvider LazyOptional language:java"

// Event bus (old annotation)
"@SubscribeEvent language:java"

// Network (old API)
"SimpleChannel registerMessage language:java"
```

## Migration-Specific Queries

### Finding Migration Examples

**Forge → NeoForge**:
```javascript
{
  query: "ForgeRegistries Registries migration language:java",
  perPage: 20
}

// Or search for PRs
mcp__github__search_pull_requests({
  query: "NeoForge migration merged:>2024-06-01",
  perPage: 10
})
```

**Version Upgrades (1.20 → 1.21)**:
```javascript
{
  query: "minecraft 1.21 breaking changes language:java",
  perPage: 15
}

// Or search commits
mcp__github__list_commits({
  owner: "ExampleMod",
  repo: "ExampleMod",
  query: "1.21 migration"
})
```

**Capability → Attachment Migration**:
```javascript
{
  query: "AttachmentType CapabilityProvider replacement language:java",
  perPage: 10
}
```

### Commit Diff Analysis

```javascript
// Get migration commit
mcp__github__get_commit({
  owner: "ModAuthor",
  repo: "ModName",
  sha: "abc123def456",
  include_diff: true
})
```

**Look for**:
- `- ForgeRegistries` → `+ Registries` (registry changes)
- `- RegistryObject` → `+ Supplier` (type changes)
- `- @Mod.EventBusSubscriber` → `+ @EventBusSubscriber(bus = Bus.MOD)` (annotation changes)

## Real-World Query Examples

### Example 1: Custom Armor with Special Abilities

```javascript
mcp__github__search_code({
  query: "ArmorItem setArmorProtection attribute language:java path:items",
  perPage: 15
})
```

**Expected results**: Armor items with custom protection values, set bonuses, special abilities

### Example 2: Boss Bar Countdown Systems

```javascript
mcp__github__search_code({
  query: "ServerBossEvent BossBarColor progress language:java",
  perPage: 10
})
```

**Expected results**: Mods implementing boss bars for timers, progress tracking, event countdowns

### Example 3: OpenAL Audio Playback

```javascript
mcp__github__search_code({
  query: "OpenAL alGenSources music playback language:java path:client",
  perPage: 10
})
```

**Expected results**: Custom music mods, radio systems, advanced audio implementations

### Example 4: Custom Recipe Types

```javascript
mcp__github__search_code({
  query: "RecipeSerializer RecipeType custom language:java path:recipe",
  perPage: 15
})
```

**Expected results**: Mods with custom crafting systems, machine recipes, processing systems

### Example 5: Multiloader Project Structure

```javascript
mcp__github__search_repositories({
  query: "minecraft mod common fabric forge quilt topic:multiloader",
  perPage: 10
})
```

**Expected results**: Projects using Architectury, multi-loader templates, shared codebases

## Query Optimization Tips

### Tip 1: Start Broad, Then Narrow

```javascript
// Step 1: Broad search
"custom entity minecraft mod"

// Step 2: Add framework
"custom entity NeoForge language:java"

// Step 3: Add path filter
"custom entity NeoForge language:java path:entity"

// Step 4: Add specific pattern
"extends LivingEntity EntityType.Builder NeoForge language:java path:entity"
```

### Tip 2: Use Framework-Specific Terms

**Good** (specific):
- `"DeferredRegister NeoForge"`
- `"Registry.register Fabric"`
- `"@SubscribeEvent Forge"`

**Bad** (too generic):
- `"register item"`
- `"event handler"`
- `"custom block"`

### Tip 3: Combine Class Names with Actions

**Good**:
- `"ItemStack setDamage"`
- `"ServerLevel addFreshEntity"`
- `"BlockState getBlock"`

**Bad**:
- `"ItemStack"`
- `"ServerLevel"`
- `"BlockState"`

### Tip 4: Filter Out Test Code

```javascript
{
  query: "ServerTickEvent spawn NOT path:test language:java",
  perPage: 15
}
```

### Tip 5: Target Active Projects

```javascript
// Use search_repositories first
mcp__github__search_repositories({
  query: "minecraft mod NeoForge stars:>50 pushed:>2024-06-01",
  perPage: 10
})

// Then search code in those repos
```

## Common Pitfalls

### Pitfall 1: Too Broad Queries

**Problem**:
```javascript
query: "minecraft mod"  // Returns 100,000+ results
```

**Solution**:
```javascript
query: "minecraft mod ServerTickEvent entity spawn language:java"
```

### Pitfall 2: Wrong Language Filter

**Problem**:
```javascript
query: "build.gradle"  // Matches Kotlin/Groovy
```

**Solution**:
```javascript
query: "build.gradle minecraft version"
// Groovy files don't need language filter
```

### Pitfall 3: Mixing Framework Patterns

**Problem**:
```javascript
query: "DeferredRegister Registry.register"  // Mixes Forge + Fabric
```

**Solution**: Separate searches per framework

### Pitfall 4: Ignoring File Paths

**Problem**:
```javascript
query: "custom item"  // Returns tests, examples, unused code
```

**Solution**:
```javascript
query: "custom item path:items OR path:content language:java"
```

### Pitfall 5: Not Checking Repository Activity

**Problem**: Finding great code from abandoned projects (outdated patterns)

**Solution**: Check last commit date, verify repo is active

---

## Quick Reference Card

**Most Common Modding Queries**:

```javascript
// Items
"DeferredRegister Item language:java path:items"

// Blocks
"DeferredRegister Block language:java path:blocks"

// Entities
"extends LivingEntity EntityType.Builder language:java path:entity"

// Events
"@SubscribeEvent ServerTickEvent language:java"

// NBT
"CompoundTag save load language:java"

// Rendering
"RenderType renderToBuffer language:java path:client"

// Packets
"SimpleChannel NetworkEvent language:java path:network"

// Config
"ForgeConfigSpec Builder language:java path:config"
```

**Framework Source**:

```javascript
// NeoForge
repo:neoforged/NeoForge path:src/main/java

// Fabric
repo:FabricMC/fabric path:fabric-api

// Forge (archived)
repo:MinecraftForge/MinecraftForge path:src/main/java
```

**Migration Queries**:

```javascript
// Version migration commits
"1.20 to 1.21 migration"

// Framework migration
"Forge to NeoForge migration"

// API changes
"breaking changes deprecated"
```
