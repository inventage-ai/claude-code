# Project Overview

Claude Code plugin marketplace by Inventage. Contains reusable skills/tools distributed via the plugin system.

## Structure

- `.claude-plugin/marketplace.json` — marketplace manifest (plugin registry)
- `plugins/<name>/` — individual plugins, each with:
  - `.claude-plugin/plugin.json` — plugin manifest
  - `skills/<skill-name>/SKILL.md` — skill definition
  - `skills/<skill-name>/scripts/` — skill scripts

## Adding a New Plugin

1. Create `plugins/<name>/.claude-plugin/plugin.json` with name, description, version, author, license
2. Add skill(s) under `plugins/<name>/skills/<skill-name>/` with `SKILL.md` and supporting files
3. Register the plugin in `.claude-plugin/marketplace.json` under the `plugins` array

## Conventions

- Plugin names use kebab-case
- Each plugin must be self-contained (no shared dependencies between plugins)
- Skills should document their requirements (e.g., Node.js) in `SKILL.md`
- Commit messages follow conventional commits format (`feat:`, `fix:`, `docs:`)
