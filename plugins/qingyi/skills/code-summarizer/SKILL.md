---
name: code-summarizer
description: Token-efficient code analysis that extracts key information into structured summaries. Use when analyzing large files, limited token budget, or needing quick code structure understanding without reading full implementation.
allowed-tools: Read
---

# Code Summarizer

## What This Covers

- Token-efficient code analysis techniques
- Structured summary generation
- Pattern and architecture recognition
- Progressive context loading strategies

## When to Use

- Analyzing large files (>500 lines)
- Limited token budget (<30k remaining)
- Quick codebase understanding needed
- Finding patterns across multiple files
- Identifying dependencies before modification

---

## Abstraction Levels

### Level 1: File Overview (Fastest)
**Contents**: Purpose, key classes, main patterns

**Example**:
```
ModItems.java:
- Registry: 15 items via DeferredRegister
- Pattern: Forge deferred registration
- Notable: RUBY_SWORD (custom effect), MAGICAL_DUST (rare ingredient)
```

### Level 2: Component Summary
**Contents**: Classes, methods, dependencies, data flow

**Example**:
```
MusicService.java:
- Singleton audio service
- Methods: play(), pause(), seek(), tickMusicPlayback()
- Deps: OpenAL, MusicRegistry
- Flow: Advancement granted → Registry lookup → Audio stream
```

### Level 3: Detailed Analysis
**Contents**: Implementation details, design decisions, technical notes

---

## Quick Summarization Patterns

### Pattern 1: Registry Summary
```
Registry: [Type]
Location: [File]
Pattern: [Implementation]
Count: [N entries]
Notable: [Key items]
```

### Pattern 2: Event Handler Summary
```
Event: [EventType]
Handler: [Method]
Trigger: [Condition]
Action: [Behavior]
Side: [Client/Server]
```

### Pattern 3: Data Flow Summary
```
Flow: [Name]
Source → Transform → Sink
```

### Pattern 4: Architectural Summary
```
Components: [List with responsibilities]
Patterns: [Design patterns used]
Dependencies: [External libs]
Entry Points: [Main classes]
```

---

## Summarization Workflow (7-10 minutes)

### Step 1: High-Level Scan (30s)
```
1. Read build.gradle → Framework/deps
2. Read main mod class → Entry point
3. Scan package structure → Organization
```

### Step 2: Component ID (2min)
```
1. Registry files → Content
2. Event handlers → Behavior
3. Data classes → State/persistence
4. UI classes → Interaction
```

### Step 3: Pattern Recognition (3min)
```
1. Design patterns
2. Framework patterns
3. Anti-patterns/debt
```

### Step 4: Document (2min)
```
1. Fill template
2. Add observations
3. Note questions
```

---

## Pattern Recognition

### Common Minecraft Patterns

**Singleton**:
```java
public class Service {
    private static Service instance;
    public static Service getInstance() { ... }
}
```
Summary: "Singleton for [purpose]"

**Deferred Registration**:
```java
DeferredRegister<Item> ITEMS = DeferredRegister.create(...)
```
Summary: "Forge deferred registration"

**Event Handler**:
```java
@SubscribeEvent
public static void onEvent(...) { ... }
```
Summary: "[Side] [event] handler for [purpose]"

**SavedData**:
```java
public class Data extends SavedData { ... }
```
Summary: "World-persistent data"

---

## Best Practices

### DO:
- ✅ Focus on "what" and "why", not "how"
- ✅ Use concrete examples from code
- ✅ Identify patterns, not implementations
- ✅ Note architecture decisions
- ✅ Document entry points

### DON'T:
- ❌ Line-by-line explanations
- ❌ List every class/method
- ❌ Large code block copy-paste
- ❌ Assume without verification

---

## Supporting Documentation

### Detailed Guides
- [Pattern Recognition Catalog](./pattern-recognition-catalog.md) - Common Minecraft mod patterns
- [Architectural Analysis](./architectural-analysis-guide.md) - Deep-dive techniques
- [Documentation Templates](./documentation-templates.md) - Ready-to-use templates

---

Use this skill for efficient code analysis that captures essential information without token waste.
