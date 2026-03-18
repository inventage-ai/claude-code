---
name: gh-markdown
description: Convert Markdown files to self-contained, standalone HTML with GitHub's rendering style. Uses marked for GFM parsing and inlines github-markdown-css for zero external dependencies. Requires only Node.js. Use when the user asks to "convert md to html", "render markdown as html", "github-style html from markdown", or wants an HTML version of a .md file that looks like GitHub.
---

# GitHub Markdown to HTML

Convert `.md` files to **fully self-contained** `.html` files styled like GitHub's markdown renderer.

## Usage

Run the bundled script:

```bash
node ${CLAUDE_PLUGIN_ROOT}/skills/gh-markdown/scripts/md-to-html.mjs <input.md> [output.html]
```

- If no output path is given, writes `<input-name>.html` next to the source file.
- Requires Node.js (no other dependencies — `marked` is auto-installed on first run).

## What it does

1. Reads the `.md` file
2. Parses it with `marked` (full GFM spec: tables, strikethrough, autolinks, task lists)
3. Wraps the HTML in `<article class="markdown-body">`
4. Inlines `github-markdown-css` v5.8.1 (auto light/dark theme via `prefers-color-scheme`)
5. Writes a single self-contained `.html` file (no JS, no external CSS, no network requests)

## Tech details

- **marked** is a fast CommonMark/GFM parser with `gfm: true` for full GitHub Flavored Markdown support.
- **github-markdown-css** is bundled in `assets/github-markdown.min.css` for offline use.

## Updating the CSS

To update the bundled CSS to a newer version:

```bash
curl -sL "https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/<VERSION>/github-markdown.min.css" \
  -o ${CLAUDE_PLUGIN_ROOT}/skills/gh-markdown/assets/github-markdown.min.css
```
