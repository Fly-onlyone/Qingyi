---
name: code-summarizer
description: Token-efficient code analysis tool that extracts key information from Java files into structured JSON format. Use when analyzing large files (>500 lines), when token budget is limited (<30k remaining), or when you need quick understanding of code structure without reading full implementation.
allowed-tools: Read
---

# Code Summarizer

## What This Covers

- Extracting key information from Java files
- Generating structured JSON summaries
- Token-efficient code analysis
- Progressive context loading strategies
- Design pattern identification
- API usage extraction

## When to Use

**Automatic Triggers**:
- File exceeds 500 lines
- Token budget below 30,000 remaining
- User explicitly requests summary

**Manual Use**:
- Quick understanding of unfamiliar codebase
- Analyzing multiple files for patterns
- Identifying dependencies before modification
- Finding API usage examples

## Summary Output Format

### JSON Structure

```json
{
  "file": "path/to/File.java",
  "purpose": "Brief 1-2 sentence description of what this class does",
  "classType": "Service|Manager|Controller|Entity|Item|Block|Util|Config|...",
  "publicApi": [
    {
      "method": "methodName",
      "signature": "public ReturnType methodName(ParamType param)",
      "purpose": "What this method does",
      "frameworkApi": ["API calls this method makes"],
      "sideSpecific": "client|server|common"
    }
  ],
  "dependencies": [
    "com.example.InternalDependency",
    "net.minecraft.world.level.Level",
    "net.minecraftforge.event.TickEvent"
  ],
  "designPatterns": [
    "Singleton (getInstance())",
    "Facade (wraps complex subsystem)",
    "Observer (event listener)"
  ],
  "frameworkCalls": [
    {
      "api": "MinecraftForge.EVENT_BUS.register",
      "purpose": "Registers event handlers",
      "location": "line 45"
    },
    {
      "api": "AL10.alGenBuffers",
      "purpose": "Creates OpenAL audio buffer",
      "location": "line 120"
    }
  ],
  "stateManagement": {
    "fields": [
      {
        "name": "fieldName",
        "type": "FieldType",
        "visibility": "private|public|protected",
        "static": true,
        "purpose": "What this field stores"
      }
    ],
    "persistence": "None|NBT|Capability|SavedData",
    "synchronization": "None|Packet|BossBar|Toast"
  },
  "potentialIssues": [
    "Thread safety: field X accessed without synchronization",
    "Memory leak: static collection never cleared",
    "Client-only code in common class (crashes dedicated server)"
  ],
  "improvements": [
    "Consider using @NotNull annotations for null safety",
    "Extract magic numbers to named constants",
    "Add JavaDoc comments for public API methods"
  ]
}
```

## Extraction Guidelines

### 1. File Purpose

**What to Include**:
- Main responsibility of the class
- Role in the mod architecture
- When/why it's used

**Examples**:
- "Service facade managing music playback state and OpenAL audio"
- "Boss bar helper providing static utilities for countdown display"
- "SavedData implementation persisting apocalypse phase across sessions"

### 2. Class Type Classification

**Common Types**:
- `Service` - Business logic facade (MusicService)
- `Manager` - Orchestrates subsystems (DisasterManager)
- `Helper` - Static utility methods (BossBarHelper)
- `Capability` - Forge capability data holder
- `SavedData` - World-level persistence
- `Entity` - Custom entity implementation
- `Item/Block` - Game content
- `Config` - Configuration holder
- `Event Handler` - Event listener class

### 3. Public API Extraction

**What to Include**:
- All public methods
- Method signature (return type, parameters)
- Brief purpose (1 sentence)
- Framework APIs called within
- Side specificity (client/server/common)

**Example**:
```json
{
  "method": "playMusic",
  "signature": "public void playMusic(ResourceLocation sound, float elapsedSeconds, float volume)",
  "purpose": "Plays OGG audio file using OpenAL with optional seek position",
  "frameworkApi": [
    "AL10.alGenBuffers",
    "AL10.alBufferData",
    "AL10.alSourcePlay",
    "STBVorbis.stb_vorbis_decode_filename"
  ],
  "sideSpecific": "client"
}
```

### 4. Dependencies

**Extract**:
- All import statements
- Group by type (internal, Minecraft, Forge, third-party)
- Identify key dependencies

**Example**:
```json
"dependencies": [
  "Internal: com.example.mod.MusicPlayerManager",
  "Minecraft: net.minecraft.client.Minecraft",
  "Minecraft: net.minecraft.resources.ResourceLocation",
  "Forge: net.minecraftforge.event.TickEvent",
  "LWJGL: org.lwjgl.openal.AL10",
  "LWJGL: org.lwjgl.stb.STBVorbis"
]
```

### 5. Design Patterns

**Identify Common Patterns**:
- Singleton: `private static INSTANCE`, `getInstance()`
- Factory: `create()`, `build()` methods
- Builder: Fluent API with chaining
- Observer: Event listeners
- Facade: Simplifies complex subsystem
- Strategy: Pluggable algorithms
- Command: Encapsulates requests
- Orchestrator: Delegates to managers

### 6. Framework API Calls

**Extract Important Calls**:
- Registry operations
- Event registration
- Network packets
- NBT operations
- Rendering calls
- Audio operations

**Prioritize**:
- Non-obvious API usage
- Complex framework interactions
- Common pitfalls (e.g., forgetting to call `setDirty()`)

### 7. State Management

**Identify**:
- Instance fields (state)
- Static fields (shared state)
- Persistence mechanism (NBT, Capability, SavedData)
- Client-server synchronization method

### 8. Potential Issues

**Look For**:
- Thread safety issues (static mutable state without synchronization)
- Memory leaks (static collections, unclosed resources)
- Client-only code in common classes
- Missing null checks
- Unbounded growth (lists without size limits)
- Missing `setDirty()` calls in SavedData
- Not calling `super` methods
- Wrong event bus (MOD vs FORGE)

### 9. Improvements

**Suggest**:
- Code quality improvements (null safety, constants)
- Documentation gaps (missing JavaDoc)
- Performance optimizations (caching, throttling)
- Better patterns (extract method, reduce complexity)

## Progressive Loading Strategy

### Level 1: Broad Overview (Minimal Tokens)

**Extract**:
- File path and package
- Class name and type
- Public method signatures only (no implementation)
- Top-level dependencies

**Use When**: Initial exploration, many files to analyze

**Token Usage**: ~500-1000 tokens per file

### Level 2: Focused Analysis (Moderate Tokens)

**Extract**:
- Level 1 content +
- Method purposes
- Design patterns
- Framework API calls
- State management

**Use When**: Understanding specific subsystem

**Token Usage**: ~1000-2000 tokens per file

### Level 3: Detailed Implementation (Full Context)

**Extract**:
- Level 2 content +
- Full method implementations
- Inline comments
- Complex logic explanations

**Use When**: Modifying or debugging code

**Token Usage**: Full file content

## Usage Examples

### Example 1: Summarizing MusicService.java

**Input**:
```
File: src/main/java/com/example/musicmod/client/MusicService.java (450 lines)
```

**Output**:
```json
{
  "file": "client/MusicService.java",
  "purpose": "Client-side singleton service managing music playback state, delegating to OpenALMusicPlayer for audio operations and handling pause/resume logic",
  "classType": "Service",
  "publicApi": [
    {
      "method": "getInstance",
      "signature": "public static MusicService getInstance()",
      "purpose": "Returns singleton instance, creates if not exists",
      "frameworkApi": [],
      "sideSpecific": "client"
    },
    {
      "method": "playCustomMusic",
      "signature": "public void playCustomMusic(ResourceLocation sound, float startSeconds)",
      "purpose": "Starts music playback with optional seek position",
      "frameworkApi": ["MusicPlayerManager.playMusic"],
      "sideSpecific": "client"
    },
    {
      "method": "pauseCustomPlayer",
      "signature": "public void pauseCustomPlayer()",
      "purpose": "Pauses current music playback",
      "frameworkApi": ["MusicPlayerManager.pause"],
      "sideSpecific": "client"
    }
  ],
  "dependencies": [
    "Internal: com.example.musicmod.client.OpenALMusicPlayer",
    "Minecraft: net.minecraft.client.Minecraft",
    "Minecraft: net.minecraft.resources.ResourceLocation"
  ],
  "designPatterns": [
    "Singleton (private constructor, getInstance())",
    "Facade (wraps OpenALMusicPlayer complexity)"
  ],
  "frameworkCalls": [],
  "stateManagement": {
    "fields": [
      {
        "name": "INSTANCE",
        "type": "MusicService",
        "visibility": "private",
        "static": true,
        "purpose": "Singleton instance"
      },
      {
        "name": "isPaused",
        "type": "boolean",
        "visibility": "private",
        "static": false,
        "purpose": "Tracks pause state"
      }
    ],
    "persistence": "None (client-side transient state)",
    "synchronization": "None (client-only service)"
  },
  "potentialIssues": [
    "Thread safety: Static INSTANCE accessed without synchronization (acceptable for client-only singleton)",
    "No dispose() method for cleanup on client shutdown"
  ],
  "improvements": [
    "Add JavaDoc comments for public API",
    "Consider adding dispose() method for cleanup",
    "Extract constants for magic numbers"
  ]
}
```

### Example 2: Summarizing ApocalypseSavedData.java

**Input**:
```
File: src/main/java/com/example/apocalypse/data/ApocalypseSavedData.java (180 lines)
```

**Output**:
```json
{
  "file": "data/ApocalypseSavedData.java",
  "purpose": "SavedData implementation persisting apocalypse event state (phase, countdown) across world saves/loads",
  "classType": "SavedData",
  "publicApi": [
    {
      "method": "get",
      "signature": "public static ApocalypseSavedData get(ServerLevel level)",
      "purpose": "Gets or creates SavedData instance for the level",
      "frameworkApi": ["DimensionDataStorage.computeIfAbsent"],
      "sideSpecific": "server"
    },
    {
      "method": "setPhase",
      "signature": "public void setPhase(Phase phase)",
      "purpose": "Updates current apocalypse phase and marks data dirty",
      "frameworkApi": ["SavedData.setDirty"],
      "sideSpecific": "server"
    }
  ],
  "dependencies": [
    "Minecraft: net.minecraft.world.level.saveddata.SavedData",
    "Minecraft: net.minecraft.nbt.CompoundTag",
    "Minecraft: net.minecraft.server.level.ServerLevel"
  ],
  "designPatterns": [
    "Singleton per dimension (static get() method with computeIfAbsent)"
  ],
  "frameworkCalls": [
    {
      "api": "SavedData.setDirty",
      "purpose": "Marks data as needing save to disk",
      "location": "Called in all setter methods"
    },
    {
      "api": "DimensionDataStorage.computeIfAbsent",
      "purpose": "Gets or creates SavedData instance",
      "location": "line 45 (get method)"
    }
  ],
  "stateManagement": {
    "fields": [
      {
        "name": "currentPhase",
        "type": "Phase",
        "visibility": "private",
        "static": false,
        "purpose": "Current apocalypse event phase"
      },
      {
        "name": "remainingSeconds",
        "type": "int",
        "visibility": "private",
        "static": false,
        "purpose": "Countdown timer value"
      }
    ],
    "persistence": "SavedData (automatic via Minecraft)",
    "synchronization": "None (server-side only, no client sync needed)"
  },
  "potentialIssues": [],
  "improvements": [
    "Consider adding data versioning for future schema changes",
    "Add validation in setters (e.g., remainingSeconds >= 0)"
  ]
}
```

## Implementation Strategy

### For Agents Using This Skill

**When to Trigger**:
```
IF file_size > 500 lines OR token_budget < 30000:
    Generate summary instead of reading full file
ELSE:
    Read full file normally
```

**How to Use Summary**:
1. Extract relevant information from JSON
2. Only request full file read if summary insufficient
3. Use summary to guide which sections to focus on

**Example Agent Usage**:
```
User: "How does music playback work in MusicMod?"

Agent:
1. Detects MusicService.java is 450 lines
2. Generates summary (1200 tokens instead of 8000)
3. Reads summary: "Singleton service, delegates to OpenALMusicPlayer"
4. Identifies relevant methods: playCustomMusic, pauseCustomPlayer
5. Reads full implementation of those specific methods only (if needed)
6. Answers user's question with token savings
```

## Best Practices

1. **Always generate summaries for files >500 lines** unless user explicitly requests full read

2. **Use Level 1 for exploration**, Level 2 for understanding, Level 3 for modification

3. **Cache summaries** during a session (don't regenerate for same file)

4. **Include line numbers** for important framework calls to enable targeted full reads

5. **Prioritize actionable information** over comprehensive detail

6. **Identify patterns** across multiple files (e.g., "5 files use Singleton pattern")

## Verification Checklist

- [ ] Purpose clearly states class responsibility
- [ ] All public methods extracted with signatures
- [ ] Framework API calls identified with line numbers
- [ ] Design patterns correctly identified
- [ ] Potential issues are actionable (not vague)
- [ ] Improvements are specific and helpful
- [ ] Side specificity marked (client/server/common)
- [ ] JSON is valid and well-formatted

## See Also

- [pattern-recognition](../pattern-recognition/SKILL.md) - Pattern identification across files
- Official Claude API: https://docs.anthropic.com/claude/reference
