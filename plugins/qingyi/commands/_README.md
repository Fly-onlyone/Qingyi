# Commands

Custom slash commands provide quick access to common workflows in your Minecraft mod development process.

## What are Commands?

Commands are **user-invoked shortcuts** that expand into prompts for Claude. They:

- Start with `/` (e.g., `/build-mod`)
- Can accept arguments
- Expand into full prompts that guide Claude's response
- Appear in command autocomplete

Think of commands as **saved prompt templates** for frequently-used workflows.

## When to Use Commands

Create commands for:
- **Repetitive workflows** (build, test, deploy)
- **Complex multi-step processes** (setup environment, generate boilerplate)
- **Standardized checks** (code review, compatibility check)
- **Quick reference** (show API docs, list registered items)

Don't create commands for:
- One-time tasks
- Highly variable workflows
- Tasks better suited for agents

## Creating a Command

### File Location

Place command files in this directory:

```
commands/
└── command-name.md
```

### File Format

Commands are simple Markdown files:

```markdown
---
description: Brief description shown in command list
---

Your prompt that Claude will execute goes here.

You can use:
- Multiple lines
- Markdown formatting
- Specific instructions

Arguments: {0}, {1}, {2}, etc.
```

### Basic Example

**File**: `build-mod.md`

```markdown
---
description: Build the mod and report any errors
---

Please build the Minecraft mod:

1. Run the Gradle build command
2. Report any compilation errors
3. If successful, show the output JAR location
4. Suggest fixes for any errors found
```

Usage: `/build-mod`

### Command with Arguments

**File**: `create-item.md`

```markdown
---
description: Create a new custom item (usage: /create-item <item-name>)
---

Create a new custom item named "{0}" for this Minecraft mod:

1. Create the item class in the appropriate package
2. Register it in the mod's item registry
3. Create the item model JSON
4. Create the item texture placeholder
5. Add the English translation
6. Show a summary of files created
```

Usage: `/create-item ruby_sword`

The `{0}` is replaced with `ruby_sword`.

## Command Best Practices

### 1. Clear Descriptions

```markdown
---
# Bad
description: Build stuff

# Good
description: Build the mod and report compilation errors with suggested fixes
---
```

### 2. Explicit Steps

Guide Claude with numbered steps:

```markdown
1. Run gradlew build
2. Check for errors in the output
3. If errors exist, explain each error
4. Suggest specific fixes
5. If successful, confirm and show JAR location
```

### 3. Specify Context

Tell Claude where to work:

```markdown
In the current Minecraft mod project:
1. Locate the main mod class
2. ...
```

### 4. Define Output Format

```markdown
Provide the results in this format:

## Build Status
[Success/Failed]

## Errors (if any)
- Error description
- Suggested fix

## Output
[JAR location or error details]
```

### 5. Use Arguments Effectively

```markdown
---
description: Create new block (usage: /create-block <name> <material>)
---

Create a custom block named "{0}" with material type "{1}":
...
```

Usage: `/create-block ruby_ore stone`

## Example Commands

See [examples/example-command.md](../examples/example-command.md) for templates.

### Suggested Commands for Minecraft Development

1. **build-mod**
   - Build and report errors
   - Show JAR output location

2. **run-client**
   - Launch Minecraft client with mod
   - Report launch status

3. **run-tests**
   - Execute mod tests
   - Report coverage and failures

4. **create-item**
   - Generate item class
   - Create associated resources

5. **create-block**
   - Generate block class
   - Create blockstate/model/texture files

6. **create-entity**
   - Generate entity class
   - Set up renderer and resources

7. **check-compat**
   - Check mod compatibility
   - Verify dependencies

8. **generate-docs**
   - Generate documentation
   - Create README for the mod

9. **setup-workspace**
   - Initialize mod project
   - Set up Gradle configuration

10. **review-code**
    - Run code quality checks
    - Identify best practice violations

## Advanced: Command Chaining

You can invoke multiple commands or combine with agents:

```markdown
---
description: Complete mod setup and review
---

1. Use /setup-workspace to initialize
2. Use the minecraft-architect agent to plan structure
3. Report when ready for development
```

## Command Organization

For many commands, organize by category:

```
commands/
├── build/
│   ├── build-mod.md
│   ├── clean-build.md
│   └── publish.md
├── create/
│   ├── create-item.md
│   ├── create-block.md
│   └── create-entity.md
├── test/
│   ├── run-tests.md
│   └── test-coverage.md
└── util/
    ├── check-compat.md
    └── generate-docs.md
```

## Invoking Commands

### In Chat
```
/build-mod
/create-item diamond_ingot
/create-block ruby_ore stone
```

### List Available Commands
```
/help
```

## Testing Your Command

1. Create the command file in this directory
2. Restart Claude Code (if needed)
3. Type `/` to see your command in autocomplete
4. Execute the command
5. Verify Claude follows the instructions
6. Refine the prompt if needed

## Common Patterns

### Pattern: Setup Workflow
```markdown
Set up a new [component]:

1. Create necessary directories
2. Generate boilerplate code
3. Register in appropriate registry
4. Create resource files
5. Show checklist of created files
```

### Pattern: Validation Check
```markdown
Verify [aspect] of the mod:

1. Scan relevant files
2. Check for common issues
3. List any problems found
4. Suggest specific fixes
5. Confirm if all checks pass
```

### Pattern: Build and Deploy
```markdown
Build and deploy the mod:

1. Clean previous build
2. Run Gradle build
3. Run tests
4. Copy JAR to [location]
5. Report success/failure
```

## Next Steps

- Review [examples/example-command.md](../examples/example-command.md)
- Create your first workflow command
- Test with common Minecraft mod tasks

---

**Current Status**: This directory is empty and ready for your custom commands.
