# Agents

Agents are specialized AI assistants that handle specific types of tasks in your Minecraft mod development workflow.

## What are Agents?

Agents are **custom subagents** that Claude Code can invoke to handle specialized tasks. Each agent:

- Has its own focused expertise and system prompt
- Can use specific tools (or inherit all tools)
- Operates in a separate context window
- Returns results back to the main conversation

Think of agents as **expert consultants** you can call upon for specific jobs.

## When to Use Agents

Use agents for:
- **Complex, multi-step workflows** (e.g., designing mod architecture)
- **Specialized domains** (e.g., Mixin development, performance optimization)
- **Task delegation** (e.g., separate code review from implementation)
- **Clean context separation** (agent gets fresh context for focused work)

Don't use agents for:
- Simple, single-step tasks
- Quick information lookups (use skills instead)
- Tasks that need conversation history

## Creating an Agent

### File Location

Place agent files in this directory:
```
agents/
└── your-agent-name.md
```

### File Format

Each agent is a **Markdown file with YAML frontmatter**:

```markdown
---
name: agent-name
description: When and why to use this agent. Include "Use PROACTIVELY" for automatic invocation.
tools: Read, Write, Edit, Bash
model: sonnet
permissionMode: default
skills: skill-name-1, skill-name-2
---

# Agent Display Name

Your agent's system prompt goes here.

## Responsibilities

- What this agent does
- When to invoke it
- What it should deliver

## Instructions

Detailed instructions for the agent...
```

### Required Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Lowercase with hyphens (e.g., `minecraft-architect`) |
| `description` | Yes | When/why to use. Include key terms for matching |

### Optional Fields

| Field | Default | Description |
|-------|---------|-------------|
| `tools` | All tools | Comma-separated list of allowed tools |
| `model` | `inherit` | `sonnet`, `opus`, `haiku`, or `inherit` |
| `permissionMode` | `default` | `default`, `acceptEdits`, `bypassPermissions`, `plan` |
| `skills` | None | Comma-separated skills to auto-load |

## Best Practices

### 1. Write Clear Descriptions

**Bad**:
```yaml
description: Helps with architecture
```

**Good**:
```yaml
description: Software architect specializing in Minecraft mod architecture. Use PROACTIVELY for architectural decisions, system design, and design patterns for Forge, Fabric, and Quilt.
```

### 2. Include "Use PROACTIVELY"

This encourages Claude to invoke your agent automatically when appropriate:

```yaml
description: Expert code reviewer for Minecraft mods. Use PROACTIVELY for code review, quality checks, and best practices validation.
```

### 3. Focus the System Prompt

Give specific instructions about:
- What the agent should do
- What it should NOT do
- Expected output format
- Constraints and guidelines

### 4. Limit Tool Access

Only grant tools the agent actually needs:

```yaml
# Read-only agent
tools: Read, Grep, Glob

# Implementation agent
tools: Read, Write, Edit, Bash

# Research agent
tools: Read, Grep, Glob, WebFetch
```

### 5. Load Relevant Skills

Pre-load skills the agent will commonly use:

```yaml
skills: minecraft-api, gradle-configuration
```

## Example Agents

See [examples/example-agent.md](../examples/example-agent.md) for a complete template.

### Suggested Agents for Minecraft Development

1. **minecraft-architect**
   - System design and architecture
   - Framework selection advice
   - Design pattern recommendations

2. **mod-developer**
   - Feature implementation
   - Code writing following best practices
   - Registry and event handling

3. **code-reviewer**
   - Code quality checks
   - Best practices validation
   - Performance review

4. **testing-specialist**
   - Test strategy design
   - Debugging assistance
   - Test implementation

5. **documentation-writer**
   - Code documentation
   - README generation
   - Tutorial creation

## Invocation

### Automatic (Recommended)

Claude will automatically select agents based on:
- Agent descriptions matching the task
- Keywords in the user's request
- Context of the conversation

### Explicit

Users can explicitly invoke agents:
```
Use the minecraft-architect agent to design my mod structure
```

## Agent vs Skill

| Aspect | Agents | Skills |
|--------|--------|--------|
| **Purpose** | Complex task execution | Knowledge/capability module |
| **Invocation** | Delegated from main conversation | Loaded into main conversation |
| **Context** | Separate, clean context | Shares main context |
| **Use Case** | Multi-step workflows | Specific expertise needed |

**Rule of thumb**: If it's a **task to complete**, use an agent. If it's **knowledge to apply**, use a skill.

## Testing Your Agent

1. Place the agent file in this directory
2. Restart Claude Code (if needed)
3. Test invocation:
   ```
   Use the [agent-name] agent to [task]
   ```
4. Verify the agent loads with correct tools and skills
5. Check output quality and adherence to instructions

## Next Steps

- Review [examples/example-agent.md](../examples/example-agent.md)
- Read comprehensive guide in [docs/AGENTS.md](../docs/AGENTS.md)
- Create your first agent for Minecraft mod development

---

**Current Status**: This directory is empty and ready for your custom agents.
