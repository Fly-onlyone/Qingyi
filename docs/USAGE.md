# Plugin Usage Guide

How to use the Qingyi Minecraft Development Plugin.

## Installation

### Local Development

```bash
# Navigate to plugin directory
cd "C:\Users\PC\Documents\Minecraft\My Project\Qingyi"

# Plugin is automatically discovered by Claude Code
# when run from this directory or parent projects
```

### Using in Projects

Reference in your project's `.claude/` configuration or copy plugin components.

## Using Agents

### Automatic Invocation

Claude automatically selects agents based on task:

```
"Design architecture for my boss mob mod"
→ Automatically uses minecraft-architect agent
```

### Explicit Invocation

```
Use the minecraft-architect agent to plan my mod structure
```

### List Available Agents

```
/agents
```

## Using Skills

Skills load automatically when relevant. You don't invoke them directly.

Claude detects when a skill is needed based on:
- Keywords in your request
- Task requirements
- Agent configuration

## Using Commands

```bash
# List available commands
/help

# Use a command (when created)
/command-name

# Command with arguments
/command-name arg1 arg2
```

## Best Practices

1. **Be specific** in requests to trigger right agents
2. **Trust automatic selection** - Claude knows when to use agents
3. **Use explicit invocation** when you need a specific agent
4. **Review agent outputs** for quality and accuracy

## Troubleshooting

**Agent not invoked?**
- Check agent description includes relevant keywords
- Try explicit invocation
- Verify agent file has proper frontmatter

**Skill not loaded?**
- Check skill description keywords
- Verify SKILL.md exists in skill directory
- Check for syntax errors in frontmatter

## Next Steps

- Create your first agent
- Add Minecraft-specific skills
- Configure hooks for your workflow
