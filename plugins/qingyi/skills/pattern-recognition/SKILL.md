---
name: pattern-recognition
description: Identify reusable code patterns, architectural designs, and best practices in Minecraft mods. Use when analyzing code for common patterns, comparing implementations across projects, extracting abstractions, or determining if a pattern should be documented or turned into a skill/agent.
---

# Pattern Recognition for Minecraft Mods

This skill helps identify, analyze, and extract reusable patterns from Minecraft mod codebases.

## What This Skill Covers

- Architectural pattern identification (Singleton, Facade, Strategy, etc.)
- Framework-specific patterns (DeferredRegister, Capabilities, Mixins)
- Code organization patterns (package structures, separation of concerns)
- Best practice patterns (client-server separation, thread safety)
- Anti-pattern detection (common mistakes to avoid)

## When to Use This Skill

- Analyzing a mod's codebase for learning
- Comparing two similar mods to find commonalities
- Deciding if a pattern should become a skill or agent
- Documenting patterns in CLAUDE.md
- Proposing refactoring opportunities

## Pattern Categories

### 1. Architectural Patterns

**Singleton Pattern**
- Single instance across mod lifecycle
- Common in service/manager classes
- Example: `MusicService.getInstance()`

**Facade Pattern**
- Simplified interface to complex subsystem
- Hides implementation details
- Example: `MusicService` wrapping `MusicPlayerManager`, `MusicStateTracker`

**Strategy Pattern**
- Interchangeable algorithms/behaviors
- Common in entity AI, data generation
- Example: Different `DisasterAction` implementations

**Observer Pattern**
- Event-driven communication
- Forge events, Fabric callbacks
- Example: `@SubscribeEvent` methods

### 2. Minecraft-Specific Patterns

**Registry Pattern**
- Centralized object registration
- DeferredRegister (Forge/NeoForge)
- Registry.register (Fabric)

**Capability Pattern** (Forge/NeoForge)
- Attach data to game objects
- NBT serialization
- Example: `MusicStateCapability`

**Mixin Pattern** (Fabric/Quilt)
- Modify existing code without replacing
- `@Inject`, `@Redirect`, `@ModifyVariable`

**Data Component Pattern** (Modern Minecraft)
- Attach components to items/entities
- Replaces some capability uses

### 3. State Management Patterns

**SavedData Pattern**
- World-level persistent state
- NBT-based serialization
- Example: `ApocalypseSavedData`

**Client-Server Sync Pattern**
- Packet-based communication
- State synchronization
- Example: `MusicStateS2CPacket`

**Tick-Based State Pattern**
- Time-based progression
- Countdown, timers, periodic actions
- Example: `CountdownManager`, `DisasterManager`

### 4. Code Organization Patterns

**Package by Feature**
```
mod/
├── audio/          (all audio-related)
├── advancement/    (all advancement-related)
├── network/        (all network-related)
```

**Package by Layer**
```
mod/
├── core/      (core logic)
├── client/    (client-only)
├── common/    (shared)
├── data/      (data generation)
```

**Separation of Concerns**
- Event handlers separate from logic
- Client code separate from server
- Data separate from behavior

## Pattern Recognition Workflow

### Step 1: Identify

Scan code for:
- Repeated structures
- Common method signatures
- Similar class hierarchies
- Shared dependencies

### Step 2: Classify

Determine pattern type:
- Is it architectural?
- Is it framework-specific?
- Is it Minecraft-specific?
- Is it project-specific?

### Step 3: Evaluate

Assess reusability:
- **High**: Universal pattern, applies to many mods
- **Medium**: Framework-specific, useful for that framework
- **Low**: Project-specific, not reusable

### Step 4: Recommend

Suggest action:
- **High reusability** → Create agent or skill
- **Medium reusability** → Document in CLAUDE.md
- **Low reusability** → No action needed

## Comparison Guidelines

### When Comparing Projects

**DO compare** if:
- Same topic/domain (MusicMod: TheFatRat vs MusicMod: NCS)
- Similar features (both have custom entities)
- Same framework (both Forge 1.20)

**DON'T compare** if:
- Different topics (MusicMod vs Apocalypse_TNT)
- Incompatible frameworks (Forge vs Fabric fundamentally different)
- Vastly different complexity

### What to Look For

**Common structures**:
- Same package organization?
- Similar class names/purposes?
- Identical framework API usage?

**Shared solutions**:
- How do both handle X?
- What's the common approach?
- Which implementation is better?

**Differences worth noting**:
- Why did they diverge?
- Which approach is more maintainable?
- Are there trade-offs?

## Anti-Pattern Detection

### Common Anti-Patterns

**❌ Static State on Server**
- Static fields for server-side data
- Breaks on multiplayer servers
- Use Capabilities/SavedData instead

**❌ Client API on Server**
- Calling client-only code from server
- Crashes dedicated servers
- Check `@OnlyIn` or side checks

**❌ Blocking I/O on Game Thread**
- Loading files, network calls on main thread
- Causes lag/freezes
- Use async loading

**❌ Memory Leaks**
- Not clearing static collections
- Not disposing native resources
- Not unregistering listeners

**❌ Thread Unsafe Singletons**
- Singleton without synchronization
- Race conditions in initialization
- Use proper locking or lazy init

## Pattern Documentation Template

```markdown
### Pattern: [Name]

**Type**: [Architectural/Framework/Organizational]
**Applicability**: [When to use]
**Complexity**: [Simple/Medium/Complex]

**Problem**:
[What problem does this solve?]

**Solution**:
[How does it solve it?]

**Example**:
```java
// Real code example
```

**Trade-offs**:
- Pro: [Benefit 1]
- Pro: [Benefit 2]
- Con: [Drawback 1]

**When NOT to use**:
- [Scenario 1]
- [Scenario 2]

**Alternatives**:
- [Alternative approach 1]
- [Alternative approach 2]
```

## Pattern Extraction Checklist

When analyzing code:

- [ ] Identify the pattern name/type
- [ ] Understand the problem it solves
- [ ] Extract minimal working example
- [ ] Document trade-offs
- [ ] Note framework versions
- [ ] Check if already documented
- [ ] Assess reusability
- [ ] Recommend action (skill/doc/nothing)

## Examples from User's Mods

### Singleton Service Pattern (MusicMod)

**Identified in**: `MusicService.java`
**Type**: Architectural
**Reusability**: High
**Recommendation**: Document in CLAUDE.md

```java
public class MusicService {
    private static MusicService INSTANCE;

    public static MusicService getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new MusicService();
        }
        return INSTANCE;
    }
}
```

### Orchestrator Pattern (Apocalypse_TNT)

**Identified in**: `ApocalypseOrchestrator.java`
**Type**: Architectural
**Reusability**: Medium-High
**Recommendation**: Document in CLAUDE.md

Delegates responsibilities to specialized managers:
- CountdownManager
- DisasterManager
- StateManager

### SavedData Pattern (Apocalypse_TNT)

**Identified in**: `ApocalypseSavedData.java`
**Type**: Framework-specific (Minecraft)
**Reusability**: High
**Recommendation**: Include in nbt-serialization-patterns skill

Standard Minecraft pattern for world-level persistence.

---

**Use this skill to systematically identify valuable patterns and grow the plugin's knowledge base.**
