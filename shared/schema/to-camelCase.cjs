/**
 * Convert JSON Schema to JSON Schema with camelCase property names.
 */

const fs = require('fs');
const { camelCase } = require('lodash');

/**
 * Recursively convert all object keys in a JSON Schema to camelCase.
 * This ensures generated TypeScript interfaces use camelCase property names.
 */
function convertKeysToCamelCase(schema) {
    if (Array.isArray(schema)) {
        return schema.map(convertKeysToCamelCase);
    } else if (schema && typeof schema === 'object') {
        const newObj = {};
        for (const [key, value] of Object.entries(schema)) {
            // Only convert property names in "properties" section
            if (key === 'properties' && typeof value === 'object') {
                const newProps = {};
                for (const [propKey, propValue] of Object.entries(value)) {
                    newProps[camelCase(propKey)] = convertKeysToCamelCase(propValue);
                }
                newObj[key] = newProps;
            } else if (key === 'required' && Array.isArray(value)) {
                newObj[key] = value.map(camelCase);
            } else {
                newObj[key] = convertKeysToCamelCase(value);
            }
        }
        return newObj;
    }
    return schema;
}

// Example schema file
const srcPath = process.argv[2] || 'example.schema.json';
const srcJson = JSON.parse(fs.readFileSync(srcPath, 'utf8'));
const dst = process.argv[3] || 'example.camelCase.json';

// Convert keys to camelCase
const camelSchema = convertKeysToCamelCase(srcJson);
// Generate TypeScript

(async () => {
    try {
        fs.writeFileSync(dst, JSON.stringify(camelSchema, null, 2));
        console.log(`✅ camelCase JSON Schema generated: ${dst}`);
    } catch (err) {
        console.error('❌ Error generating types:', err);
        process.exit(1);
    }
})();
