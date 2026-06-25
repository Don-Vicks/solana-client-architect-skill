#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import os from 'os';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SKILL_NAME = 'solana-client-architect-skill';

const usage = `
Usage: npx solana-client-architect-skill [target]

Targets:
  antigravity  - Installs globally for Gemini / Antigravity CLI (~/.gemini/config/...)
  cursor       - Installs locally for Cursor IDE (./.cursor/rules/)
  windsurf     - Installs locally for Windsurf IDE (./.windsurf/)
  local        - Installs locally to a generic ./agent-skills/ directory
  
Example:
  npx solana-client-architect-skill cursor
`;

const target = process.argv[2];

if (!target) {
  console.log(usage);
  process.exit(0);
}

let destDir = '';

switch (target.toLowerCase()) {
  case 'antigravity':
    destDir = path.join(os.homedir(), '.gemini', 'config', 'plugins', 'solana-skills', 'skills', SKILL_NAME);
    break;
  case 'cursor':
    destDir = path.join(process.cwd(), '.cursor', 'rules', SKILL_NAME);
    break;
  case 'windsurf':
    destDir = path.join(process.cwd(), '.windsurf', 'rules', SKILL_NAME);
    break;
  case 'local':
    destDir = path.join(process.cwd(), '.agent-skills', SKILL_NAME);
    break;
  default:
    console.error(`Unknown target: ${target}`);
    console.log(usage);
    process.exit(1);
}

console.log(`Installing ${SKILL_NAME} for ${target}...`);

try {
  // Path to the 'skill' directory inside this package
  const sourceDir = path.join(__dirname, '..', 'skill');
  
  if (!fs.existsSync(sourceDir)) {
    console.error(`Error: Could not find skill directory at ${sourceDir}`);
    process.exit(1);
  }

  fs.mkdirSync(destDir, { recursive: true });
  
  // Recursively copy files
  const copyRecursiveSync = (src, dest) => {
    const exists = fs.existsSync(src);
    const stats = exists && fs.statSync(src);
    const isDirectory = exists && stats.isDirectory();
    
    if (isDirectory) {
      if (!fs.existsSync(dest)) fs.mkdirSync(dest);
      fs.readdirSync(src).forEach((childItemName) => {
        copyRecursiveSync(path.join(src, childItemName), path.join(dest, childItemName));
      });
    } else {
      fs.copyFileSync(src, dest);
    }
  };

  copyRecursiveSync(sourceDir, destDir);

  console.log(`\x1b[32mSuccessfully installed ${SKILL_NAME} to ${destDir}!\x1b[0m`);
  console.log('Your AI agent can now generate frontends from Solana IDLs using modern standards.');
} catch (error) {
  console.error('Failed to install skill:', error.message);
  process.exit(1);
}
