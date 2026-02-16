/**
 * Convert JSON Schema to JSON Schema with camelCase property names.
 */

const fs = require('fs');
const { camelCase, snakeCase } = require('lodash');

/**
 * Recursively convert all object keys in a JSON Schema to camelCase.
 * This ensures generated TypeScript interfaces use camelCase property names.
 */
function convertKeys(schema, func) {
    if (Array.isArray(schema)) {
        return schema.map((item) => convertKeys(item, func));
    } else if (schema && typeof schema === 'object') {
        const newObj = {};
        for (const [key, value] of Object.entries(schema)) {
            if (key === 'properties' && typeof value === 'object') {
                const newProps = {};
                for (const [propKey, propValue] of Object.entries(value)) {
                    newProps[func(propKey)] = convertKeys(propValue, func);
                }
                newObj[key] = newProps;
            } else if (key === '$defs' && typeof value === 'object') {
                const newProps = {};
                for (const [propKey, propValue] of Object.entries(value)) {
                    newProps[func(propKey)] = convertKeys(propValue, func);
                }
                newObj[key] = newProps;
            } else if (key === 'required' && Array.isArray(value)) {
                newObj[key] = value.map(func);
            } else if (key === '$ref' && typeof value === 'string') {
                const refParts = value.split('/');
                const lastPart = refParts[refParts.length - 1];
                refParts[refParts.length - 1] = func(lastPart);
                newObj[key] = refParts.join('/');
            } else {
                newObj[key] = convertKeys(value, func);
            }
        }
        return newObj;
    }
    return schema;
}

const srcPath = process.argv[2] || 'example.schema.json';
const srcJson = JSON.parse(fs.readFileSync(srcPath, 'utf8'));
const dst = process.argv[3] || 'example.camelCase.json';
const converter = process.argv[4] || 'camelCase';

const converterFunc =
    converter === 'camelCase' ? camelCase :
        converter === 'snake_case' ? snakeCase :
            (s) => s;
const camelSchema = convertKeys(srcJson, converterFunc);

(async () => {
    try {
        fs.writeFileSync(dst, JSON.stringify(camelSchema, null, 2));
        console.log(`✅ camelCase JSON Schema generated: ${dst}`);
    } catch (err) {
        console.error('❌ Error generating types:', err);
        process.exit(1);
    }
})();
