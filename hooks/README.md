# Hooks

Hooks enable event-driven automation in your Claude Code workflow, allowing you to validate, enhance, or customize behavior at key points.

## What are Hooks?

Hooks are **event handlers** that run automatically when specific events occur:

- Before/after tool use
- When sessions start/end
- On user prompt submission
- Custom trigger points

Think of hooks as **automated assistants** that watch your workflow and take action.

## When to Use Hooks

Create hooks for:
- **Validation** (check code before committing)
- **Automation** (run tests after edits)
- **Notifications** (alert on build completion)
- **Tracking** (monitor token usage)
- **Enhancement** (add context to prompts)

Don't use hooks for:
- Complex business logic (use agents)
- One-time tasks
- User-facing features (use commands)

## Hook Types

### PreToolUse
Runs **before** a tool executes. Can:
- Block the tool call
- Modify tool parameters
- Add validation

**Use cases**:
- Prevent destructive operations
- Validate file paths
- Check prerequisites

### PostToolUse
Runs **after** a tool completes. Can:
- Process tool results
- Trigger follow-up actions
- Log outcomes

**Use cases**:
- Run tests after code edits
- Update documentation
- Track changes

### UserPromptSubmit
Runs when user submits a prompt. Can:
- Add context to the prompt
- Inject instructions
- Validate requests

**Use cases**:
- Auto-load project context
- Add code standards
- Inject optimization guidelines

### SessionStart
Runs when a Claude Code session begins.

**Use cases**:
- Load project configuration
- Check environment
- Display welcome message

### SessionEnd
Runs when a session ends.

**Use cases**:
- Save session data
- Generate summary
- Cleanup resources

## Creating Hooks

### Configuration File

Create `hooks.json` in this directory:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git push.*)",
        "script": "./handlers/confirm-push.sh",
        "description": "Confirm before git push"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit(.*\\.java)",
        "script": "./handlers/run-checkstyle.sh",
        "description": "Run checkstyle after Java edits"
      }
    ],
    "UserPromptSubmit": [
      {
        "script": "./handlers/add-context.sh",
        "description": "Add project context to prompts"
      }
    ],
    "SessionStart": [
      {
        "script": "./handlers/welcome.sh",
        "description": "Display welcome message"
      }
    ]
  }
}
```

### Matcher Patterns

Hooks can use regex patterns to match specific tool calls:

```json
{
  "matcher": "Bash(gradlew build)",     // Exact match
  "matcher": "Bash(git.*)",             // Any git command
  "matcher": "Edit(.*\\.java)",         // Any Java file edit
  "matcher": "Write(.*/test/.*)",       // Files in test directory
  "matcher": ".*"                       // All tool calls
}
```

### Hook Scripts

Hook scripts receive event data as JSON on stdin and can:
- Return `{ "allow": true }` to proceed
- Return `{ "allow": false, "message": "..." }` to block
- Return `{ "modifications": {...} }` to modify parameters

**Example**: `handlers/confirm-push.sh`

```bash
#!/bin/bash

# Read event data
event=$(cat)

# Ask user for confirmation
read -p "Are you sure you want to push? (y/n) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo '{"allow": true}'
else
  echo '{"allow": false, "message": "Push cancelled by user"}'
fi
```

**Example**: `handlers/run-checkstyle.sh`

```bash
#!/bin/bash

# Get the edited file from event data
file=$(echo "$event" | jq -r '.tool.params.file_path')

# Run checkstyle
checkstyle -c google_checks.xml "$file" 2>&1

# Always allow (just log results)
echo '{"allow": true}'
```

## Best Practices

### 1. Keep Hooks Fast

Hooks block tool execution, so keep them quick:

```bash
# Bad: Slow operation
./handlers/full-test-suite.sh  # Takes 5 minutes

# Good: Quick validation
./handlers/syntax-check.sh     # Takes 1 second
```

### 2. Use Descriptive Messages

```json
{
  "allow": false,
  "message": "Cannot push to main branch. Please push to a feature branch."
}
```

### 3. Handle Errors Gracefully

```bash
#!/bin/bash

# Fail open (allow on error)
if ! command -v checkstyle &> /dev/null; then
  echo '{"allow": true, "message": "Checkstyle not installed, skipping"}' >&2
  exit 0
fi

# Run check...
```

### 4. Use Matchers Wisely

```json
// Too broad - runs on every Bash call
{"matcher": "Bash(.*)"}

// Better - only specific commands
{"matcher": "Bash(git push.*)"}
{"matcher": "Bash(gradlew build)"}
```

### 5. Provide User Feedback

```bash
echo "Running checkstyle on $file..." >&2
# (stderr shows to user, stdout is JSON response)
```

## Hook Environment

Scripts run with:
- Current directory: Project root
- Environment: Same as Claude Code
- Input: Event JSON on stdin
- Output: Response JSON on stdout
- Logs: stderr (visible to user)

### Event JSON Structure

```json
{
  "type": "PreToolUse" | "PostToolUse" | "UserPromptSubmit" | "SessionStart" | "SessionEnd",
  "tool": {
    "name": "Bash",
    "params": {
      "command": "git push origin main"
    }
  },
  "context": {
    "projectPath": "/path/to/project",
    "sessionId": "..."
  }
}
```

## Example Hooks for Minecraft Development

### 1. Validate Build Before Commit

```json
{
  "PreToolUse": [{
    "matcher": "Bash(git commit.*)",
    "script": "./handlers/pre-commit-build.sh",
    "description": "Build mod before committing"
  }]
}
```

```bash
#!/bin/bash
# handlers/pre-commit-build.sh

echo "Building mod before commit..." >&2

if gradlew build --quiet; then
  echo "Build successful" >&2
  echo '{"allow": true}'
else
  echo "Build failed" >&2
  echo '{"allow": false, "message": "Build failed. Fix errors before committing."}'
fi
```

### 2. Track Token Usage

```json
{
  "PostToolUse": [{
    "matcher": ".*",
    "script": "./handlers/track-tokens.sh",
    "description": "Log token usage"
  }]
}
```

```bash
#!/bin/bash
# handlers/track-tokens.sh

# Log to file
echo "$(date): Tool used" >> .claude/token-log.txt

# Always allow
echo '{"allow": true}'
```

### 3. Add Mod Context to Prompts

```json
{
  "UserPromptSubmit": [{
    "script": "./handlers/add-mod-context.sh",
    "description": "Inject mod metadata"
  }]
}
```

```bash
#!/bin/bash
# handlers/add-mod-context.sh

# Read user prompt
prompt=$(echo "$event" | jq -r '.prompt')

# Add context
mod_id=$(grep 'modid=' gradle.properties | cut -d'=' -f2)
context="[Mod ID: $mod_id] $prompt"

# Return modified prompt
echo "{\"modifications\": {\"prompt\": \"$context\"}}"
```

### 4. Auto-run Tests After Java Edits

```json
{
  "PostToolUse": [{
    "matcher": "Edit(.*src/main/java.*\\.java)",
    "script": "./handlers/run-relevant-tests.sh",
    "description": "Run tests after production code changes"
  }]
}
```

## Testing Hooks

1. Create hook script in `handlers/`
2. Make it executable: `chmod +x handlers/script.sh`
3. Add to `hooks.json`
4. Test with matching tool call
5. Check output and behavior

Example test:
```bash
# Test the script directly
echo '{"type":"PreToolUse","tool":{"name":"Bash","params":{"command":"git push"}}}' | \
  ./handlers/confirm-push.sh
```

## Disabling Hooks

### Temporarily
Set environment variable:
```bash
CLAUDE_SKIP_HOOKS=1 claude
```

### Permanently
Remove from `hooks.json` or set:
```json
{
  "enabled": false,
  "matcher": "..."
}
```

## Security Considerations

1. **Validate inputs** from event JSON
2. **Avoid shell injection** (use proper escaping)
3. **Limit permissions** (don't run as root)
4. **Review third-party hooks** before adding

## Next Steps

- Review hook examples
- Create your first validation hook
- Test with Minecraft mod workflow
- Explore advanced patterns

---

**Current Status**: This directory is empty and ready for hook configurations.

To get started:
1. Create `hooks.json` in this directory
2. Create `handlers/` directory for scripts
3. Add your first hook
4. Test the integration
