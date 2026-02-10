/**
 * Convert JSON Schema to JSON Schema with camelCase property names.
 */

const fs = require('fs');
const { camelCase, snakeCase } = require('lodash');

/**
 * Recursively convert all object keys in a JSON Schema to camelCase.
 * This ensures generated TypeScript interfaces use camelCase property names.
 */
function convertKeys(schema, converter) {
    if (Array.isArray(schema)) {
        return schema.map(convertKeys);
    } else if (schema && typeof schema === 'object') {
        const newObj = {};
        for (const [key, value] of Object.entries(schema)) {
            // Only convert property names in "properties" section
            if (key === 'properties' && typeof value === 'object') {
                const newProps = {};
                for (const [propKey, propValue] of Object.entries(value)) {
                    newProps[converter(propKey)] = convertKeys(propValue, converter);
                }
                newObj[key] = newProps;
            } else if (key === 'required' && Array.isArray(value)) {
                newObj[key] = value.map(converter);
            } else {
                newObj[key] = convertKeys(value, converter);
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
const converter = process.argv[4] || 'camelCase';

// Convert keys to camelCase
const converterFunc =
    converter === 'camelCase' ? camelCase :
        converter === 'snake_case' ? snakeCase :
            (s) => s;
const camelSchema = convertKeys(srcJson, converterFunc);
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
