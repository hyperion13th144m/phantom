/**
 * Convert JSON Schema to JSON Schema with camelCase property names.
 */

const fs = require('fs');
const { generateTypeScript } = require('schema-typescript');

const srcPath = process.argv[2] || 'example.schema.json';
const srcJson = JSON.parse(fs.readFileSync(srcPath, 'utf8'));
const dst = process.argv[3] || 'example.ts';

const ts = generateTypeScript(srcJson);

(async () => {
    try {
        fs.writeFileSync(dst, ts);
        console.log(`✅ TypeScript generated: ${dst}`);
    } catch (err) {
        console.error('❌ Error generating types:', err);
        process.exit(1);
    }
})();
