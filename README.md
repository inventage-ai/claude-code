# Claude Code Plugins by Inventage

A custom Claude Code plugin marketplace with reusable skills and tools.

## Installation

Add this marketplace to your Claude Code:

```
/plugin marketplace add inventage-ai/claude-code
```

## Available Plugins

### `gh-markdown`

Convert Markdown files to self-contained, GitHub-styled HTML. Requires only Node.js.

```
/plugin install gh-markdown@inventage-ai-claude-code
```

**Usage:**

```
/gh-markdown:md-to-html input.md [output.html]
```

## Documentation

- [Create plugins](https://code.claude.com/docs/en/plugins) — how to build Claude Code plugins with skills, agents, hooks, and MCP servers
- [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins) — browse marketplaces and install plugins
- [Create and distribute a marketplace](https://code.claude.com/docs/en/plugin-marketplaces) — package and share plugins via marketplaces
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) — complete technical specifications (manifest schema, versioning, debugging)
- [Agent Skills](https://code.claude.com/docs/en/skills) — skill authoring guide

## License

MIT
