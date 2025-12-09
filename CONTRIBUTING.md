# Contributing to Qingyi Minecraft Development Plugin

Thank you for considering contributing to this plugin! This document provides guidelines for contributing.

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. Check existing issues first
2. Create a new issue with:
   - Clear title
   - Detailed description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes**
4. **Test your changes**
5. **Commit with clear messages**
   ```bash
   git commit -m "Add: Description of what you added"
   ```
6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request**

## Development Guidelines

### Adding Agents

1. Create agent file in `agents/`
2. Use proper YAML frontmatter
3. Write clear, focused system prompts
4. Include example scenarios
5. Document in agent file header

Template:
```markdown
---
name: agent-name
description: Clear description with use cases
tools: Read, Write, Edit
model: sonnet
---

# Agent Name
[System prompt here]
```

### Adding Skills

1. Create directory in `skills/skill-name/`
2. Add `SKILL.md` with frontmatter
3. Include comprehensive description with keywords
4. Add supporting files as needed
5. Organize content logically

Template:
```markdown
---
name: skill-name
description: What it does, when to use, keywords
---

# Skill Name
[Content here]
```

### Adding Commands

1. Create `.md` file in `commands/`
2. Include description in frontmatter
3. Write clear step-by-step instructions
4. Document argument usage if applicable

Template:
```markdown
---
description: Command description
---

Instructions for Claude...
```

### Adding Documentation

- Keep documentation up-to-date
- Use clear, concise language
- Include examples
- Link related content

## Code Style

### Markdown
- Use ATX-style headers (`#` not `===`)
- One blank line between sections
- Code blocks with language tags
- Consistent bullet lists (use `-`)

### YAML Frontmatter
- Lowercase field names
- Use kebab-case for identifiers
- Comma-separated lists for arrays
- Include required fields

### Code Examples
- Use real, working code
- Include comments for complex logic
- Follow Minecraft modding conventions
- Specify framework (Forge/Fabric/Quilt)

## Testing

Before submitting:

1. **Validate structure**
   - All frontmatter is valid YAML
   - Required fields are present
   - File names follow conventions

2. **Test functionality**
   - Agents invoke correctly
   - Skills load when expected
   - Commands execute properly
   - Hooks trigger appropriately

3. **Check documentation**
   - All links work
   - Examples are accurate
   - No typos or grammar errors

## Commit Message Guidelines

Use conventional commit format:

```
Type: Brief description

Detailed explanation if needed
```

Types:
- `Add`: New feature or component
- `Update`: Modification to existing component
- `Fix`: Bug fix
- `Docs`: Documentation changes
- `Refactor`: Code restructuring
- `Test`: Test additions or updates

Examples:
```
Add: minecraft-architect agent for system design

Update: forge-setup skill with NeoForge support

Fix: SKILL.md frontmatter syntax error

Docs: Add examples to agent creation guide
```

## Pull Request Process

1. **Ensure all tests pass**
2. **Update documentation** if needed
3. **Update CHANGELOG.md** under `[Unreleased]`
4. **Request review** from maintainers
5. **Address review feedback**
6. **Squash commits** if requested

## Review Criteria

PRs will be reviewed for:

- **Correctness**: Does it work as intended?
- **Quality**: Is the code/content well-written?
- **Documentation**: Is it properly documented?
- **Consistency**: Does it follow existing patterns?
- **Testing**: Has it been tested?

## Questions?

If you have questions:

- Check the [docs/](docs/) directory
- Review [examples/](examples/)
- Open a discussion issue

## Code of Conduct

- Be respectful and constructive
- Welcome newcomers
- Focus on the work, not the person
- Assume good intentions

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to make Minecraft mod development with Claude Code better!
