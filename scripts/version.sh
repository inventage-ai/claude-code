#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MARKETPLACE="$REPO_ROOT/.claude-plugin/marketplace.json"
PLUGINS_DIR="$REPO_ROOT/plugins"

usage() {
  cat <<EOF
Usage: $0 <command> [args]

Commands:
  list                          Show all plugins and their current versions
  bump <plugin> <patch|minor|major>  Bump a plugin's version in plugin.json and marketplace.json
EOF
  exit 1
}

# Read a JSON string field using node
json_read() {
  local file="$1" field="$2"
  node -e "console.log(JSON.parse(require('fs').readFileSync('$file','utf8')).$field)"
}

# Bump a semver component
semver_bump() {
  local version="$1" part="$2"
  IFS='.' read -r major minor patch <<< "$version"
  case "$part" in
    major) echo "$((major + 1)).0.0" ;;
    minor) echo "$major.$((minor + 1)).0" ;;
    patch) echo "$major.$minor.$((patch + 1))" ;;
    *) echo "Error: invalid bump type '$part' (use patch, minor, or major)" >&2; exit 1 ;;
  esac
}

# Update a version field in a JSON file using node
json_set_version() {
  local file="$1" new_version="$2"
  node -e "
    const fs = require('fs');
    const data = JSON.parse(fs.readFileSync('$file', 'utf8'));
    data.version = '$new_version';
    fs.writeFileSync('$file', JSON.stringify(data, null, 2) + '\n');
  "
}

# Update version for a specific plugin in marketplace.json
marketplace_set_version() {
  local file="$1" plugin_name="$2" new_version="$3"
  node -e "
    const fs = require('fs');
    const data = JSON.parse(fs.readFileSync('$file', 'utf8'));
    const plugin = data.plugins.find(p => p.name === '$plugin_name');
    if (!plugin) { console.error('Plugin \"$plugin_name\" not found in marketplace.json'); process.exit(1); }
    plugin.version = '$new_version';
    fs.writeFileSync('$file', JSON.stringify(data, null, 2) + '\n');
  "
}

cmd_list() {
  echo "Plugins:"
  for plugin_json in "$PLUGINS_DIR"/*/.claude-plugin/plugin.json; do
    [ -f "$plugin_json" ] || continue
    local name version
    name="$(json_read "$plugin_json" "name")"
    version="$(json_read "$plugin_json" "version")"
    printf "  %-20s %s\n" "$name" "$version"
  done
}

cmd_bump() {
  local plugin="$1" part="$2"
  local plugin_json="$PLUGINS_DIR/$plugin/.claude-plugin/plugin.json"

  if [ ! -f "$plugin_json" ]; then
    echo "Error: plugin '$plugin' not found at $plugin_json" >&2
    exit 1
  fi

  local old_version new_version
  old_version="$(json_read "$plugin_json" "version")"
  new_version="$(semver_bump "$old_version" "$part")"

  # Update both files
  json_set_version "$plugin_json" "$new_version"
  marketplace_set_version "$MARKETPLACE" "$plugin" "$new_version"

  echo "$plugin: $old_version -> $new_version"
  echo ""
  echo "Suggested git commands:"
  echo "  git add plugins/$plugin/.claude-plugin/plugin.json .claude-plugin/marketplace.json"
  echo "  git commit -m 'chore: bump $plugin to $new_version'"
  echo "  git tag $plugin@$new_version"
}

# --- Main ---

[ $# -lt 1 ] && usage

case "$1" in
  list)
    cmd_list
    ;;
  bump)
    [ $# -lt 3 ] && { echo "Error: bump requires <plugin> and <patch|minor|major>" >&2; usage; }
    cmd_bump "$2" "$3"
    ;;
  *)
    echo "Error: unknown command '$1'" >&2
    usage
    ;;
esac
