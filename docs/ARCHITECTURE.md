# Plugin Architecture

Overview of the Qingyi Minecraft Development Plugin architecture.

## Components

### 1. Plugin Manifest
`.claude-plugin/plugin.json` - Metadata and configuration

### 2. Agents
Specialized AI assistants for task execution
- Located in `agents/`
- Isolated context per invocation
- Tool-restricted execution

### 3. Skills
Knowledge modules auto-loaded by Claude
- Located in `skills/`
- Progressive loading of content
- Shared across agents

### 4. Commands
User-invoked prompt templates
- Located in `commands/`
- Accept arguments
- Expand into prompts

### 5. Hooks
Event-driven automation
- Located in `hooks/`
- Pre/post tool execution
- Session lifecycle events

## Data Flow

```
User Request
    ↓
Claude Code
    ↓
[Determine if agent needed]
    ↓
Agent Selection (based on description matching)
    ↓
Agent Execution (with pre-loaded skills)
    ↓
Tool Calls (validated by hooks)
    ↓
Results returned to main conversation
```

## Integration Points

### With Claude Code
- Plugin discovery via `.claude-plugin/`
- Agent registration from `agents/`
- Skill auto-loading from `skills/`
- Command registration from `commands/`

### Between Components
- **Agents use Skills**: Via `skills:` field in frontmatter
- **Commands invoke Agents**: Via prompt instructions
- **Hooks validate Tools**: Via matcher patterns

## Extension Points

- Add agents: Create `.md` in `agents/`
- Add skills: Create folder in `skills/` with `SKILL.md`
- Add commands: Create `.md` in `commands/`
- Add hooks: Update `hooks/hooks.json`

## Design Principles

1. **Separation of Concerns**: Each component has single responsibility
2. **Progressive Loading**: Load content only when needed
3. **Composability**: Components work together seamlessly
4. **Extensibility**: Easy to add new components
