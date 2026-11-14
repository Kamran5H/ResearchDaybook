const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const root = path.resolve(__dirname, '..');

test('ResearchDaybook daybook.html exists and embedded scripts compile cleanly', () => {
  const htmlPath = path.join(root, 'daybook.html');
  assert.ok(fs.existsSync(htmlPath), 'daybook.html must exist');
  const html = fs.readFileSync(htmlPath, 'utf8');
  assert.ok(html.includes('Research Daybook'), 'daybook.html must include Research Daybook title');

  const scriptRegex = /<script\b[^>]*>([\s\S]*?)<\/script>/gi;
  let match;
  let scriptCount = 0;
  while ((match = scriptRegex.exec(html)) !== null) {
    const code = match[1].trim();
    if (!code) continue;
    scriptCount++;
    assert.doesNotThrow(() => new vm.Script(code), `Embedded script #${scriptCount} must have valid JS syntax`);
  }
  assert.ok(scriptCount >= 1, 'daybook.html must contain at least one embedded script');
});
