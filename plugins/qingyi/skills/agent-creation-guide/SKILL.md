---
name: agent-creation-guide
description: Guide for creating new Claude Code agents and skills for Qingyi plugin. Covers file format, frontmatter configuration, system prompt structure, and best practices. Use when creating new plugin components.
---

# Agent and Skill Creation Guide

## What This Covers

- When to create agents vs skills
- Agent file format and frontmatter
- Skill file format and structure
- System prompt templates
- Best practices and validation

## When to Use

- Creating new agents for Qingyi plugin
- Creating new skills for knowledge modules
- Understanding plugin architecture
- Validating agent/skill configurations

---

## Component Decision Tree

### Create Agent When:
- ✅ Task requires multi-step execution with decision-making
- ✅ Complex enough to warrant dedicated expertise
- ✅ Frequent enough to justify specialization
- ✅ Distinct domain not covered by existing agents

**Examples**:
- ✅ `audio-expert` for audio systems across multiple mods
- ✅ `world-gen-expert` for complex world generation
- ❌ `item-color-expert` (too narrow, use existing agent)

### Create Skill When:
- ✅ Need reference knowledge that agents can load
- ✅ Pattern is reusable across multiple tasks
- ✅ Information is static (API docs, patterns, examples)
- ✅ Token efficiency: Load only when needed

**Examples**:
- ✅ `audio-api-patterns` for OpenAL integration
- ✅ `world-gen-examples` for biome generation
- ❌ Single-use documentation (doesn't justify skill)

---

## Agent File Format

### File Location
```
agents/agent-name.md
```

### YAML Frontmatter Template

```yaml
---
name: agent-name
description: Expert in [domain]. Use PROACTIVELY for [tasks].
tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
permissionMode: default
skills: skill1, skill2, skill3
---
```

**Required Fields**:
- `name`: kebab-case identifier
- `description`: Clear description. Include "Use PROACTIVELY" for auto-invocation
- `tools`: Comma-separated list of allowed tools
- `model`: sonnet, opus, haiku, or inherit
- `permissionMode`: default, acceptEdits, bypassPermissions, or plan
- `skills`: Pre-loaded skills (optional)

### Agent Body Template

```markdown
# Agent Name - Role Title

You are an expert in [domain] for Minecraft mod development. Your role is to [primary responsibility].

## Core Responsibilities

1. **[Responsibility 1]**: [Description]
2. **[Responsibility 2]**: [Description]
3. **[Responsibility 3]**: [Description]

## Behavioral Guidelines

### DO:
- ✅ [Guideline 1]
- ✅ [Guideline 2]

### DON'T:
- ❌ [Anti-pattern 1]
- ❌ [Anti-pattern 2]

## Workflow

### Step 1: [Phase Name]
[What to do in this phase]

### Step 2: [Phase Name]
[What to do in this phase]

## Code Examples

**Pattern 1: [Pattern Name]**
```java
// Example code from real mod
```

## Common Patterns

[Reusable patterns relevant to this agent's domain]

## Troubleshooting

[Common issues this agent should handle]
```

---

## Skill File Format

### File Location
```
skills/skill-name/SKILL.md
skills/skill-name/supporting-file-1.md  (optional)
```

### YAML Frontmatter Template

```yaml
---
name: skill-name
description: [What this skill provides. Include keywords for auto-matching.]
allowed-tools: Read, Grep, Glob
---
```

**Required Fields**:
- `name`: kebab-case identifier
- `description`: Clear description with keywords for matching
- `allowed-tools`: Optional, defaults to all tools

### Skill Body Template

```markdown
# Skill Name

## What This Covers

- [Topic 1]
- [Topic 2]
- [Topic 3]

## When to Use

- [Use case 1]
- [Use case 2]
- [Use case 3]

---

## Core Concepts

### Concept 1
[Explanation with code examples]

### Concept 2
[Explanation with code examples]

## Common Patterns

### Pattern 1: [Name]
```java
// Real code example
```

### Pattern 2: [Name]
```java
// Real code example
```

## Supporting Documentation

### Detailed Guides
- [Guide Name](./guide-name.md) - [Description]

---

Use this skill when [conditions for using this skill].
```

---

## Validation Checklist

### Agent Validation
- [ ] YAML frontmatter is valid
- [ ] Name is kebab-case
- [ ] Description includes "Use PROACTIVELY" if auto-invoke desired
- [ ] Tools list is comma-separated
- [ ] Model is valid: sonnet, opus, haiku, or inherit
- [ ] PermissionMode is valid: default, acceptEdits, bypassPermissions, or plan
- [ ] Skills are comma-separated and exist
- [ ] Body provides clear responsibilities
- [ ] Examples use real code patterns

### Skill Validation
- [ ] YAML frontmatter is valid
- [ ] Name is kebab-case
- [ ] Description includes relevant keywords
- [ ] Main file is ≤350 lines (ideally ≤200)
- [ ] Supporting files referenced with markdown links
- [ ] Examples are concrete and tested
- [ ] Uses progressive loading pattern

---

## Best Practices

### Agent Best Practices

1. **Clear Scope**: Agent should have well-defined domain
2. **Real Examples**: Use code from actual mods, not pseudocode
3. **Behavioral Guidelines**: Specify what agent should/shouldn't do
4. **Workflow Structure**: Provide step-by-step process
5. **Auto-Invocation**: Use "Use PROACTIVELY" for automatic usage

### Skill Best Practices

1. **Token Efficiency**: Keep main file ≤200 lines ideal, ≤350 max
2. **Progressive Loading**: Link to supporting files for details
3. **Concrete Examples**: Real code, not generic templates
4. **Clear Keywords**: Include search terms in description
5. **Reference Format**: Quick reference tables and patterns

---

## Quick Templates

### Minimal Agent
```yaml
---
name: example-agent
description: Expert in examples. Use PROACTIVELY for example tasks.
tools: Read, Write, Edit
model: sonnet
permissionMode: default
---

# Example Agent

You are an expert in [domain].

## Responsibilities
1. [Task 1]
2. [Task 2]

## Workflow
[Step-by-step process]
```

### Minimal Skill
```yaml
---
name: example-skill
description: Example patterns for demonstration purposes.
---

# Example Skill

## What This Covers
- [Topic]

## When to Use
- [Condition]

## Pattern Example
```java
// Code
```
```

---

## Supporting Documentation

### Detailed Guides
- [Agent Architecture](./agent-architecture.md) - Deep dive into agent design patterns
- [Skill Progressive Loading](./skill-progressive-loading.md) - Token optimization strategies
- [YAML Configuration Reference](./yaml-configuration-reference.md) - Complete frontmatter options

---

Use this skill when creating new agents or skills for the Qingyi plugin to ensure proper structure and functionality.
