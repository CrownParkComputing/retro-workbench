#!/usr/bin/env node
// Compare this repo's verbatim-contract files against every Retro app.
import fs from 'node:fs';
import crypto from 'node:crypto';
import { execSync } from 'node:child_process';

const TOKEN = process.env.GITHUB_TOKEN || execSync('gh auth token', { encoding: 'utf8' }).trim();
const APPS = [
  { repo: 'Retro-Amiga', lib: 'app/lib' },
  { repo: 'Retro-C64', lib: 'flutter_app/lib' },
  { repo: 'Retro-Dosbox', lib: 'flutter_app/lib', ref: 'flutter-rewrite' },
  { repo: 'Retro-Saturn', lib: 'flutter_app/lib' },
  { repo: 'Retro-Spectrum', lib: 'flutter_app/lib' },
  { repo: 'Retro-AtariST', lib: 'flutter_app/lib' },
];
const FILES = ['widgets/sidebar.dart', 'widgets/movable_control.dart'];

// git blob sha of a local file: sha1("blob <len>\0" + bytes)
const blob = (path) => {
  const b = fs.readFileSync(path);
  return crypto.createHash('sha1').update(`blob ${b.length}\0`).update(b).digest('hex');
};

for (const rel of FILES) {
  const want = blob(`lib/${rel}`);
  console.log(`\n${rel}  (${want.slice(0, 10)})`);
  for (const app of APPS) {
    const url = `https://api.github.com/repos/CrownParkComputing/${app.repo}/contents/${app.lib}/${rel}${app.ref ? `?ref=${app.ref}` : ''}`;
    const res = await fetch(url, { headers: { Authorization: `Bearer ${TOKEN}` } });
    const status = res.status === 404 ? 'MISSING'
      : (await res.json()).sha === want ? 'verbatim' : 'DIVERGED';
    console.log(`  ${app.repo.padEnd(16)} ${status}`);
  }
}
