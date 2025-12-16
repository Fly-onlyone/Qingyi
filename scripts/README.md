# Qingyi Plugin Update Scripts

This directory contains scripts to streamline the plugin reinstall process after making changes to agents, skills, or other plugin components.

## Why These Scripts Exist

Claude Code does **not** have auto-update or watch mode for local plugins. After modifying plugin source files, you must manually:
1. Uninstall the current version
2. Reinstall from the marketplace
3. Restart Claude Code

These scripts automate steps 1-2.

## Available Scripts

### Windows

**Batch Script** (Command Prompt):
```bash
scripts\reinstall-plugin.bat
```

**PowerShell Script**:
```powershell
.\scripts\reinstall-plugin.ps1
```

### Linux/macOS

**Bash Script**:
```bash
./scripts/reinstall-plugin.sh
```

## Usage

### After Making Plugin Changes

1. **Edit plugin files** (agents, skills, CLAUDE.md, etc.)
2. **Run the appropriate script** for your platform
3. **Restart Claude Code** to load changes
4. **Test the updated plugin**

### From Command Line

**Windows (Command Prompt)**:
```cmd
cd "C:\Users\PC\Documents\Minecraft\My Project\Qingyi"
scripts\reinstall-plugin.bat
```

**Windows (PowerShell)**:
```powershell
cd "C:\Users\PC\Documents\Minecraft\My Project\Qingyi"
.\scripts\reinstall-plugin.ps1
```

**Linux/macOS**:
```bash
cd "/path/to/Qingyi"
./scripts/reinstall-plugin.sh
```

### From Claude Code (via Bash tool)

The orchestrator agent will automatically run the script when creating/updating plugin components:

```bash
bash scripts/reinstall-plugin.bat
```

## What the Scripts Do

1. **Uninstall** current plugin version from Claude Code
2. **Install** updated version from `qingyi-marketplace`
3. **Display status** and remind you to restart Claude Code

## Prerequisites

Before running these scripts, ensure:

- ✅ **Marketplace is configured**: `marketplace.json` exists in `.claude-plugin/` directory
- ✅ **Marketplace is added**: `/plugin marketplace add "C:\Users\PC\Documents\Minecraft\My Project\Qingyi"`
- ✅ **Plugin was previously installed**: `/plugin install qingyi@qingyi-marketplace`

## Troubleshooting

### "Plugin not found" error

**Cause**: Marketplace not added or plugin never installed

**Solution**:
```bash
# Add marketplace
/plugin marketplace add "C:\Users\PC\Documents\Minecraft\My Project\Qingyi"

# Install plugin
/plugin install qingyi@qingyi-marketplace
```

### Script doesn't work

**Cause**: `claude` command not in PATH

**Solution**: Use the full path to claude CLI or add it to your PATH

### Changes not reflected after reinstall

**Cause**: Claude Code caches plugin data

**Solution**: Fully restart Claude Code (close and reopen)

## Development Workflow

**Recommended pattern**:

```
1. Work on plugin features (add agents, skills, etc.)
   ↓
2. Review changes with git
   ↓
3. Commit to version control
   ↓
4. Run reinstall script
   ↓
5. Restart Claude Code
   ↓
6. Test new features
```

## Integration with Orchestrator

The `qingyi-orchestrator` agent is configured to:
- **Always work in source directory** (not installed plugin location)
- **Automatically run reinstall script** after creating/updating components
- **Prompt user to restart** Claude Code

This ensures a smooth development workflow when the orchestrator improves the plugin through pattern learning.

## Version Control Note

These scripts are checked into git because:
- They're part of the development workflow
- They reference project-specific paths/marketplace names
- They should be shared with contributors

If you fork this plugin, update the marketplace name in the scripts to match your setup.
