const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../..');
const i18nDir = path.join(root, 'assets/i18n');
const forbiddenRoots = new Set(['main', 'page']);

function flatten(value, prefix = '') {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return prefix ? [prefix] : [];
  }
  return Object.keys(value).flatMap((key) =>
    flatten(value[key], prefix ? `${prefix}.${key}` : key),
  );
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(path.join(i18nDir, file), 'utf8'));
}

const files = fs
  .readdirSync(i18nDir)
  .filter((file) => file.endsWith('.json') && file.includes('-'))
  .sort();

if (files.length === 0) {
  throw new Error('No i18n JSON files found.');
}

const parsed = new Map(files.map((file) => [file, readJson(file)]));
for (const [file, content] of parsed) {
  for (const rootKey of Object.keys(content)) {
    if (forbiddenRoots.has(rootKey)) {
      throw new Error(`${file} contains forbidden m1 root key: ${rootKey}`);
    }
  }
}

const baseFile = files.includes('zh-CN.json') ? 'zh-CN.json' : files[0];
const baseKeys = flatten(parsed.get(baseFile)).sort();
const baseSet = new Set(baseKeys);

for (const [file, content] of parsed) {
  const keys = flatten(content).sort();
  const keySet = new Set(keys);
  const missing = baseKeys.filter((key) => !keySet.has(key));
  const extra = keys.filter((key) => !baseSet.has(key));
  if (missing.length || extra.length) {
    const detail = [
      missing.length ? `missing: ${missing.join(', ')}` : '',
      extra.length ? `extra: ${extra.join(', ')}` : '',
    ]
      .filter(Boolean)
      .join('; ');
    throw new Error(`${file} key mismatch against ${baseFile}: ${detail}`);
  }
}

console.log(`i18n validation ok: ${files.length} files, ${baseKeys.length} keys`);
