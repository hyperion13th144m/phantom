/**
 * Generate TypeScript types from JSON Schema with camelCase property names.
 */
const fs = require('fs');
const path = require('path');
const { compile } = require('json-schema-to-typescript');
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
const schemaPath = process.argv[2] || 'example-schema.json';
const schema = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
const dst = process.argv[3] || 'example.d.ts';

// Convert keys to camelCase
const camelSchema = convertKeysToCamelCase(schema);

// Generate TypeScript
(async () => {
    try {
        const ts = await compile(camelSchema, 'Example');
        fs.writeFileSync(dst, ts);
        console.log(`✅ TypeScript definitions generated: ${dst}`);
    } catch (err) {
        console.error('❌ Error generating types:', err);
        process.exit(1);
    }
})();
