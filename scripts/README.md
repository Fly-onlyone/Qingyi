# Qingyi Plugin Development Scripts

This directory contains scripts and documentation for plugin development and quality assurance.

## Plugin Auto-Update

Claude Code now has **built-in auto-update functionality** for local plugins. When you modify plugin source files (agents, skills, CLAUDE.md, etc.), Claude Code automatically detects changes and reloads the plugin.

**No manual reinstall required!**

## Available Scripts

### Quality Assurance

**validate-plugin.ps1** - Validates plugin structure and configuration:
```powershell
.\scripts\validate-plugin.ps1
```

Checks:
- ✅ YAML frontmatter syntax in agents and skills
- ✅ File structure and naming conventions
- ✅ Cross-references between components
- ✅ Markdown formatting and links

**quality-check.md** - Quality assurance checklist for plugin development. Review before releases.

## Development Workflow

**Recommended pattern**:

```
1. Work on plugin features (add agents, skills, etc.)
   ↓
2. Run validation script to check for errors
   ↓
3. Review changes with git
   ↓
4. Commit to version control
   ↓
5. Claude Code auto-reloads plugin
   ↓
6. Test new features
```

## Integration with Orchestrator

The `qingyi-orchestrator` agent is configured to:
- **Always work in source directory** (not installed plugin location)
- **Rely on auto-update** for changes to take effect
- **Validate changes** using the validation script

This ensures a smooth development workflow when the orchestrator improves the plugin through pattern learning.

## Version Control Note

These scripts are checked into git because:
- They're part of the development workflow
- They help maintain plugin quality
- They should be shared with contributors
