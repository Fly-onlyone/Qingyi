---
name: agent-creation-guide
description: Guide for creating new Claude Code agents and skills for the Qingyi plugin. Use when the orchestrator needs to create new agents or skills based on discovered patterns, gaps in coverage, or user needs. Covers file format, frontmatter configuration, system prompt structure, and best practices.
---

# Agent and Skill Creation Guide

This skill provides templates and guidelines for creating new agents and skills in the Qingyi plugin.

## When to Create New Components

### Create a New Agent When:

- Task requires **multi-step execution** with decision-making
- Concept is **complex enough** to warrant dedicated expertise
- **Frequent enough** to justify specialization
- **Distinct domain** not covered by existing agents

**Examples**:
- ✅ Create `audio-expert` if you handle audio in 3+ mods
- ✅ Create `world-gen-expert` for complex world generation
- ❌ Don't create `item-color-expert` (too narrow, use registry-expert)

### Create a New Skill When:

- Need **reference knowledge** that agents can load
- Pattern is **reusable** across multiple tasks
- Information is **static** (API docs, patterns, examples)
- **Token efficiency**: Load only when needed

**Examples**:
- ✅ Create `openal-audio-playback` skill (reference for audio API)
- ✅ Create `mixin-injection-points` skill (Fabric reference)
- ❌ Don't create `how-to-register-item` skill (too specific, put in registry-api skill)

## Agent File Format

### File Location
```
Qingyi/agents/agent-name.md
```

### Template

```markdown
---
name: agent-name
description: [When to use this agent]. Use PROACTIVELY for [scenarios]. Expert in [domain, framework, version].
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
permissionMode: default
skills: skill-1, skill-2, skill-3
---

# Agent Display Name

You are a [role] specializing in [domain] for Minecraft modding.

## Core Expertise

### [Area 1]
- Capability 1
- Capability 2

### [Area 2]
- Capability 1
- Capability 2

## Responsibilities

When invoked, you will:

1. **[Primary Task]** - Description
2. **[Secondary Task]** - Description
3. **[Quality Check]** - Description

## Specific Instructions

### Before Starting
- Prerequisite 1
- Prerequisite 2

### During Execution
- Guideline 1
- Guideline 2

### After Completion
- Verification 1
- Verification 2

## Framework-Specific Knowledge

### Forge
- [Forge-specific details]

### NeoForge
- [NeoForge-specific details]

### Fabric
- [Fabric-specific details]

## Example Scenarios

### Scenario 1: [Title]
**Request**: [User request]
**Response**: [How you handle it]

### Scenario 2: [Title]
**Request**: [User request]
**Response**: [How you handle it]

## What NOT to Do

- ❌ [Anti-pattern 1]
- ❌ [Anti-pattern 2]

## Success Criteria

- ✅ [Criterion 1]
- ✅ [Criterion 2]
```

### Frontmatter Fields

#### name (Required)
- **Format**: Lowercase with hyphens
- **Max length**: 64 characters
- **Example**: `registry-and-content-expert`

#### description (Required)
- **Purpose**: When/why to invoke
- **Include**: "Use PROACTIVELY" for automatic invocation
- **Include**: Trigger keywords (framework names, concepts)
- **Example**: `Expert in Forge event systems. Use PROACTIVELY for event handling, tick handlers, and mod lifecycle. Covers @SubscribeEvent, event buses, and event priority.`

#### tools (Optional)
- **Default**: Inherits all tools
- **Common sets**:
  - Read-only: `Read, Grep, Glob`
  - Implementation: `Read, Write, Edit, Bash`
  - Research: `Read, Grep, Glob, WebFetch`

#### model (Optional)
- **Options**: `sonnet` (default), `opus`, `haiku`, `inherit`
- **Guidelines**:
  - `haiku`: Fast, simple tasks
  - `sonnet`: Balanced (recommended)
  - `opus`: Complex reasoning

#### permissionMode (Optional)
- **Options**:
  - `default`: Normal permissions
  - `acceptEdits`: Auto-accept file edits
  - `bypassPermissions`: Skip all permission requests
  - `plan`: Read-only planning mode

#### skills (Optional)
- **Format**: Comma-separated skill names
- **Example**: `forge-registry-api, neoforge-registry-api`
- **Purpose**: Auto-load these skills when agent is invoked

---

## Skill File Format

### Directory Structure
```
skills/skill-name/
├── SKILL.md              # Required
├── supporting-file.md    # Optional
├── examples/             # Optional
│   └── example.java
└── templates/            # Optional
    └── template.java
```

### SKILL.md Template

```markdown
---
name: skill-name
description: [What this covers]. Use when [scenarios]. Keywords: [keyword1, keyword2, keyword3]. Covers [frameworks/versions].
allowed-tools: Read, Grep, Glob  # Optional
---

# Skill Display Name

## What This Covers

- Topic 1
- Topic 2
- Topic 3

## When to Use

- Scenario 1
- Scenario 2
- Scenario 3

## Core Knowledge

### [Concept 1]

Explanation...

**Example**:
```java
// Code example
```

### [Concept 2]

Explanation...

## Common Patterns

### Pattern 1: [Name]

**Use when**: [Scenario]

**Implementation**:
```java
// Implementation
```

**Pitfalls**:
- ❌ [What to avoid]

### Pattern 2: [Name]

...

## Version Differences

### Forge 1.20.x
- [Specifics]

### NeoForge 1.21.x
- [Changes from Forge]

### Fabric 1.20.x
- [Different approach]

## Best Practices

1. [Practice 1]
2. [Practice 2]

## Anti-Patterns

1. ❌ [Anti-pattern 1] - [Why to avoid]
2. ❌ [Anti-pattern 2] - [Why to avoid]

## See Also

- [Related skill](../related-skill/SKILL.md)
- [Supporting file](supporting-file.md)
```

---

## Creation Workflow

### For Agents

1. **Analyze need**
   - What task does this handle?
   - Is it distinct from existing agents?
   - How often will it be used?

2. **Define scope**
   - Core responsibilities (3-5 items)
   - Required expertise
   - Tools needed

3. **Write system prompt**
   - Clear role definition
   - Specific instructions
   - Example scenarios
   - Success criteria

4. **Specify skills**
   - Which skills should auto-load?
   - What knowledge does it need?

5. **Test agent**
   - Invoke with sample task
   - Verify it handles correctly
   - Refine if needed

### For Skills

1. **Gather knowledge**
   - Official docs
   - User's code examples
   - API source code
   - Community best practices

2. **Organize content**
   - Main SKILL.md (overview)
   - Supporting files (details)
   - Examples (real code)
   - Templates (boilerplate)

3. **Write description**
   - Include trigger keywords
   - Specify use cases
   - Mention frameworks/versions

4. **Create examples**
   - Real code from user's projects
   - Official API usage
   - Common patterns

5. **Test skill**
   - Check if agents load it
   - Verify it helps solve problems
   - Ensure examples are accurate

---

## Best Practices

### Agent System Prompts

**DO**:
- ✅ Be specific about role and responsibilities
- ✅ Provide concrete examples
- ✅ Include "what NOT to do" section
- ✅ Define success criteria
- ✅ Use framework-specific terminology

**DON'T**:
- ❌ Be vague ("helps with stuff")
- ❌ Overlap with existing agents
- ❌ Mix multiple unrelated domains
- ❌ Assume knowledge (list it in skills)

### Skill Descriptions

**DO**:
- ✅ Include many relevant keywords
- ✅ Specify frameworks and versions
- ✅ Describe use cases clearly
- ✅ Use action verbs

**DON'T**:
- ❌ Be too generic ("Minecraft knowledge")
- ❌ Forget to mention frameworks
- ❌ Miss important keywords
- ❌ Duplicate existing skills

---

## File Creation Steps

### Create Agent File

```bash
# 1. Create file
cd /path/to/Qingyi/agents
touch new-agent.md

# 2. Add frontmatter and content
# [Use template above]

# 3. Test
# Invoke agent with sample task
```

### Create Skill Directory

```bash
# 1. Create directory
cd /path/to/Qingyi/skills
mkdir new-skill

# 2. Create SKILL.md
cd new-skill
touch SKILL.md

# 3. Add frontmatter and content
# [Use template above]

# 4. Add supporting files (optional)
touch examples.md
mkdir examples
```

---

## Quality Checklist

### For Agents

- [ ] Name is descriptive and unique
- [ ] Description includes "Use PROACTIVELY"
- [ ] Description has trigger keywords
- [ ] Tools list is appropriate
- [ ] Skills list includes needed knowledge
- [ ] System prompt is clear and specific
- [ ] Responsibilities are well-defined
- [ ] Example scenarios are provided
- [ ] Success criteria are defined
- [ ] Tested with sample task

### For Skills

- [ ] Name clearly indicates content
- [ ] Description is keyword-rich
- [ ] Use cases are specified
- [ ] Content is well-organized
- [ ] Examples are real and accurate
- [ ] Version differences noted
- [ ] Best practices included
- [ ] Anti-patterns documented
- [ ] Supporting files linked correctly
- [ ] Tested by loading in agent

---

## Examples from Qingyi Plugin

### Example Agent: registry-and-content-expert

**Good description**:
```yaml
description: Expert in Minecraft registry systems for items, blocks, and entities. Use PROACTIVELY when creating game content, registering objects, or working with DeferredRegister (Forge/NeoForge) or Registry.register (Fabric). Handles creative tabs, properties, and registration lifecycle.
```

**Why it's good**:
- ✅ "Use PROACTIVELY" included
- ✅ Keywords: registry, items, blocks, entities, DeferredRegister, Fabric
- ✅ Specific frameworks mentioned
- ✅ Clear use cases

### Example Skill: forge-registry-api

**Good description**:
```yaml
description: Forge and NeoForge registry API reference for items, blocks, and entities. Use when implementing game content registration, working with DeferredRegister, RegistryObject, or creative tabs. Covers Forge 1.19-1.20 and NeoForge 1.20-1.21 differences.
```

**Why it's good**:
- ✅ Keywords: Forge, NeoForge, registry, DeferredRegister, RegistryObject
- ✅ Use cases specified
- ✅ Version coverage mentioned
- ✅ Action-oriented

---

**Use this guide to create high-quality agents and skills that expand the Qingyi plugin's capabilities!**
