# Qingyi Minecraft Development Plugin

A Claude Code plugin with specialized agents and skills designed to improve code accuracy and token efficiency for Minecraft mod development.

## Overview

This plugin provides a comprehensive toolkit for Minecraft modders working with Forge, NeoForge, Fabric, and Quilt frameworks. It includes:

- **Custom Agents**: Specialized AI assistants for different aspects of mod development
- **Skills**: Reusable knowledge modules that Claude can invoke automatically
- **Commands**: Quick-access slash commands for common workflows
- **Hooks**: Event automation for validation and assistance

## Features

### 🤖 Specialized Agents (Coming Soon)

Future agents will include:
- **Minecraft Architect**: System design and architecture planning
- **Mod Developer**: Feature implementation specialist
- **Code Reviewer**: Quality assurance and best practices
- **Testing Specialist**: Testing and debugging expert
- **Documentation Writer**: Documentation generation

### 📚 Skills Library (Coming Soon)

Planned skills include:
- **Minecraft API Knowledge**: Core API reference and usage
- **Forge Setup**: Forge/NeoForge environment configuration
- **Gradle Configuration**: Build system expertise
- **Mixin Development**: Mixin patching techniques
- **Performance Optimization**: Profiling and optimization
- **Debugging Techniques**: Advanced debugging methods

## Project Structure

```
Qingyi/
├── .claude-plugin/
│   └── plugin.json         # Plugin manifest
├── agents/                 # Custom subagents (empty)
├── skills/                 # Knowledge modules (empty)
├── commands/               # Slash commands (empty)
├── hooks/                  # Event hooks (empty)
├── examples/               # Example templates
├── docs/                   # Comprehensive guides
├── README.md               # This file
├── LICENSE                 # MIT License
├── CHANGELOG.md            # Version history
└── CONTRIBUTING.md         # Contribution guidelines
```

## Installation

### For Local Development

1. Clone or download this repository
2. Link to your Claude Code configuration:
   ```bash
   # Option 1: Symlink (recommended)
   ln -s /path/to/Qingyi ~/.claude/plugins/qingyi-minecraft-dev

   # Option 2: Copy
   cp -r /path/to/Qingyi ~/.claude/plugins/qingyi-minecraft-dev
   ```

### Using in Projects

Add to your project's `.claude/` directory or reference as a plugin in your Claude Code configuration.

## Quick Start

This is currently an **empty template project**. To start adding content:

1. **Create Your First Agent**
   - Read [agents/README.md](agents/README.md)
   - Check [examples/example-agent.md](examples/example-agent.md)
   - Add your agent file to `agents/`

2. **Create Your First Skill**
   - Read [skills/README.md](skills/README.md)
   - Check [examples/example-skill/](examples/example-skill/)
   - Create a directory in `skills/` with `SKILL.md`

3. **Add Custom Commands** (optional)
   - Read [commands/README.md](commands/README.md)
   - Add command files to `commands/`

## Documentation

- [Agent Creation Guide](docs/AGENTS.md) - Comprehensive guide to creating agents
- [Skills Creation Guide](docs/SKILLS.md) - How to build skills
- [Architecture Overview](docs/ARCHITECTURE.md) - Plugin design and patterns
- [Usage Instructions](docs/USAGE.md) - How to use the plugin

## Development Status

**Version**: 0.1.0 (Pre-release)

This is an empty template structure ready for population with Minecraft modding knowledge and tools. The plugin is designed for incremental development:

- ✅ Project structure complete
- ✅ Documentation framework ready
- ✅ Example templates provided
- ⏳ Agents to be added
- ⏳ Skills to be added
- ⏳ Commands to be added

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Recommended Development Order

1. **Phase 1: Foundation Skills**
   - minecraft-api (Core API knowledge)
   - forge-setup (Environment setup)
   - gradle-configuration (Build systems)

2. **Phase 2: Specialized Agents**
   - minecraft-architect (Design)
   - mod-developer (Implementation)
   - code-reviewer (Quality)

3. **Phase 3: Advanced Features**
   - Framework-specific skills
   - Performance optimization
   - Custom commands and hooks

## Target Frameworks

- **Forge**: 1.19.x, 1.20.x
- **NeoForge**: 1.20.x, 1.21.x
- **Fabric**: 1.19.x, 1.20.x, 1.21.x
- **Quilt**: 1.19.x, 1.20.x

## Use Cases

- Setting up new mod projects
- Implementing items, blocks, and entities
- Debugging mod issues
- Optimizing performance
- Following best practices
- Understanding framework APIs
- Reviewing code quality

## License

MIT License - See [LICENSE](LICENSE) for details.

## Links

- [Claude Code Documentation](https://code.claude.com/docs)
- [Plugin Development Guide](https://code.claude.com/docs/en/plugins.md)
- [Agent SDK Documentation](https://platform.claude.com/docs/en/agent-sdk)

## Support

For issues, questions, or suggestions:
- Check the [docs/](docs/) directory
- Review [examples/](examples/) for templates
- Refer to the official Claude Code documentation

---

**Note**: This plugin is currently a template structure. Agents and skills will be added incrementally based on development needs.
