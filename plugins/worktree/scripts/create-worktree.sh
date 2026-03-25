#!/usr/bin/env bash
set -euo pipefail

# WorktreeCreate hook: Creates a new git worktree and runs an optional `worktree-init.sh` script from the repository's root directory.
# Input: JSON on stdin from Claude Code with `name` property, representing the worktree name and branch to be created.
#
# By default, worktrees will be created in the `.claude/worktrees` directory. Override this location by setting the `WORKTREE_BASE_DIR`
# environment variable (e.g. `WORKTREE_BASE_DIR=../project-worktrees`).
#
# If present, a `worktree-init.sh` script in the repository's root directory will be executed in the context of the new worktree. This
# allows to setup the worktree with regards to files that are not tracked by `git` — e.g. to copy any `.env` files into the worktree, or to
# execute `npm install` or similar initializing commands. The init script may resolve the project's main directory with the following
# statement: `repo_base_dir=$(git worktree list --porcelain | awk '/worktree/ {print $2; exit}')`

name=$(jq -r '.name')

if [[ -z "$name" || "$name" == "null" ]]; then
  echo "ERROR: No 'name' property provided in hook input" >&2
  exit 1
elif [[ ! "$name" =~ ^[A-Za-z0-9_-]+$ ]]; then
  echo "ERROR: Worktree name '$name' contains invalid characters (allowed: letters, digits, dashes, underscores)" >&2
  exit 1
fi

git_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "ERROR: Not inside a git repository" >&2
  exit 1
}

worktree_base="${WORKTREE_BASE_DIR:-$git_root/.claude/worktrees}"
worktree_dir="$worktree_base/$name"

if [[ -d "$worktree_dir" ]]; then
  echo "ERROR: Worktree directory already exists: $worktree_dir" >&2
  exit 1
fi

branch="$name"
if [[ "$name" =~ ^(feature|feat|bugfix|hotfix|fix|chore|test|docs|refactor|release)-(.+)$ ]]; then
  branch="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
  echo "ERROR: Branch '$branch' already exists" >&2
  exit 1
fi

git worktree add "$worktree_dir" -b "$branch" HEAD >&2
cd "$worktree_dir"
if [[ -f "worktree-init.sh" ]]; then
  if [[ ! -x "worktree-init.sh" ]]; then
    echo "ERROR: worktree-init.sh is not executable" >&2
    exit 1
  fi
  "./worktree-init.sh" >&2
fi

echo "$worktree_dir"
