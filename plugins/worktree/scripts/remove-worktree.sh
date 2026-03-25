#!/usr/bin/env bash
set -euo pipefail

# WorktreeRemove hook: Removes a git worktree and deletes its associated branch if it contains no commits.
# Input: JSON on stdin from Claude Code with `worktree_path` property, representing the branch path.

worktree_path=$(jq -r '.worktree_path')

if [[ -z "$worktree_path" || "$worktree_path" == "null" ]]; then
  echo "ERROR: No 'worktree_path' property provided in hook input" >&2
  exit 1
elif [[ ! -d "$worktree_path" ]]; then
  echo "ERROR: Worktree path '$worktree_path' does not exist" >&2
  exit 1
fi

cd "$worktree_path"
branch=$(git branch --show-current)
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
commit_count=$(git rev-list --count "$(git merge-base "$default_branch" "$branch")".."$branch")

repo_base_dir=$(git worktree list --porcelain | awk '/worktree/ {print $2; exit}')
cd "$repo_base_dir"
git worktree remove "$worktree_path"

if [[ "$commit_count" -eq 0 ]]; then
  git branch --delete "$branch"
fi
