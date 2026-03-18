#!/usr/bin/env node

// GitHub Markdown to self-contained HTML converter
// Uses marked for GFM parsing + github-markdown-css

import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, basename, resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const SKILL_DIR = dirname(__dirname);
const CSS_FILE = join(SKILL_DIR, 'assets', 'github-markdown.min.css');

// Auto-install marked if not available
let marked;
try {
  ({ marked } = await import('marked'));
} catch {
  console.error('marked not found, installing...');
  execSync('npm install --no-save marked', { cwd: SKILL_DIR, stdio: 'inherit' });
  ({ marked } = await import('marked'));
}

// CLI
const args = process.argv.slice(2);
if (args.length < 1) {
  console.error(`Usage: ${basename(__filename)} <input.md> [output.html]`);
  process.exit(1);
}

const input = resolve(args[0]);
let md;
try {
  md = readFileSync(input, 'utf-8');
} catch {
  console.error(`Error: File not found: ${args[0]}`);
  process.exit(1);
}

const output = args[1] ? resolve(args[1]) : input.replace(/\.md$/, '.html');
const title = basename(input, '.md');

// Parse markdown with GFM enabled
const htmlContent = marked(md, { gfm: true });

// Read bundled CSS
const css = readFileSync(CSS_FILE, 'utf-8');

// Write self-contained HTML
const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${title}</title>
  <style>
${css}
    .markdown-body {
      box-sizing: border-box;
      max-width: 980px;
      margin: 0 auto;
      padding: 45px;
    }
    @media (max-width: 767px) {
      .markdown-body {
        padding: 15px;
      }
    }
  </style>
</head>
<body>
  <article class="markdown-body">
${htmlContent}
  </article>
</body>
</html>`;

writeFileSync(output, html);
console.log(`Written: ${output}`);
