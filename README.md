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


### `worktree`

Claude Code supports the `--worktree` (`-w`) [flag](https://code.claude.com/docs/en/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees) to create an isolated worktree and start Claude in it. As a new worktree only contains files tracked by `git`, certain files and directories, like `.env` or `node_modules`, may still be missing that are needed to start developing in that worktree.

This `worktree` plugin installs a custom `WorktreeCreate` hook, that will invoke an optional project-specific `worktree-init.sh` script after the worktree has been created. This allows it to finish the worktree setup, like copying any missing files (e.g. `.env` files) or running initialization commands (e.g. `npm install`). The `worktree-init.sh` script must be placed in the repository root and must be executable.

The `WorktreeCreate` hook will also create a new branch whose name corresponds to the worktree name. Any common prefixes like `feature` or `bugfix` will be used as branch prefix (e.g. `feature-new-hook` → `feature/new-hook`).

If the main project directory must be accessed within the `worktree-init.sh` script (e.g. to copy a non-tracked `.env` file), it can be resolved as follows:

```sh
repo_base_dir=$(git worktree list --porcelain | awk '/worktree/ {print $2; exit}')
```

By default, worktrees will be created in the `.claude/worktrees` directory. Override this location by setting the `WORKTREE_BASE_DIR` environment variable (e.g. `WORKTREE_BASE_DIR=../project-worktrees`).

This plugin will also install `WorktreeRemove` hook. Besides removing the worktree, the hook will also delete the created branch, if it contains no commits at all. Otherwise, the branch will be kept and it is up to the user to cleanup the branch when appropriate.


#### Important

For the time being there is an open GitHub [issue](https://github.com/anthropics/claude-code/issues/16288) that hooks provided by plugins are not loaded correctly. As a workaround, the hook must be configured explicitly in the `~/.claude/settings.json` file under `hooks`:

```json
{
  "hooks": {
    "WorktreeCreate": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/plugins/cache/inventage-ai-claude-code/worktree/1.0.1/scripts/create-worktree.sh"
          }
        ]
      }
    ],
    "WorktreeRemove": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/plugins/cache/inventage-ai-claude-code/worktree/1.0.1/scripts/remove-worktree.sh"
          }
        ]
      }
    ]
  }
}
```

#### Sample `worktree-init.sh` script

```sh
#!/usr/bin/env bash
set -euo pipefail

# Worktree initialization script for the worktree@inventage-ai-claude-code plugin

# Non-tracked files to copy into the new worktree
files_to_copy=(
  # Local environment config
  .env
  .envrc

  # Claude Code local config
  CLAUDE.local.md
  .claude/settings.local.json
)

# Directories to run `pnpm install` in
pnpm_base_dirs=(
    frontend
    tests
)


repo_base_dir=$(git worktree list --porcelain | head -n 1 | sed 's/^worktree //')
for f in "${files_to_copy[@]}"; do
  src="$repo_base_dir/$f"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$f")"
    cp "$src" "$f"
  fi
done

for dir in "${pnpm_base_dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    (cd "$dir" && pnpm install --frozen-lockfile 2>&1)
  fi
done

# Allow .env files to be loaded
direnv allow .
```

## Documentation

- [Create plugins](https://code.claude.com/docs/en/plugins) — how to build Claude Code plugins with skills, agents, hooks, and MCP servers
- [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins) — browse marketplaces and install plugins
- [Create and distribute a marketplace](https://code.claude.com/docs/en/plugin-marketplaces) — package and share plugins via marketplaces
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) — complete technical specifications (manifest schema, versioning, debugging)
- [Agent Skills](https://code.claude.com/docs/en/skills) — skill authoring guide

## License

MIT
