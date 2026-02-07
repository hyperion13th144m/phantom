#!/usr/bin/env node
const fs = require('fs');
const path = require("path");

function resolveRefs(obj, baseDir) {
    if (Array.isArray(obj)) {
        return obj.map((item) => resolveRefs(item, baseDir));
    }

    if (obj && typeof obj === "object") {

        // ローカル参照はそのまま
        if (obj.$ref && obj.$ref.startsWith("#/")) {
            return obj;
        }

        // ファイル参照だけ解決
        if (obj.$ref && typeof obj.$ref === "string") {
            const refPath = path.resolve(baseDir, obj.$ref);
            const refContent = JSON.parse(fs.readFileSync(refPath, "utf8"));
            return resolveRefs(refContent, path.dirname(refPath));
        }

        const result = {};
        for (const key of Object.keys(obj)) {
            result[key] = resolveRefs(obj[key], baseDir);
        }
        return result;
    }

    return obj;
}

const srcDir = process.argv[2];
const outFile = process.argv[3];

let files = fs.readdirSync(srcDir).filter(f => f.endsWith(".json")).sort();

// root.json を最初に
files.sort((a, b) => (a === "root.json" ? -1 : b === "root.json" ? 1 : a.localeCompare(b)));

let root = null;

const processedDefs = new Set();
for (const file of files) {
    const fullPath = path.join(srcDir, file);
    const content = JSON.parse(fs.readFileSync(fullPath, "utf8"));

    if (file === "root.json") {
        root = content;


        // root.$defs の $ref を解決
        if (root.$defs) {
            for (const key of Object.keys(root.$defs)) {
                const def = root.$defs[key];
                if (def.$ref && !def.$ref.startsWith("#/")) {
                    const refPath = path.resolve(srcDir, def.$ref);
                    const refContent = JSON.parse(fs.readFileSync(refPath, "utf8"));
                    root.$defs[key] = resolveRefs(refContent, srcDir);

                    // このファイルはもう処理済み
                    processedDefs.add(path.basename(def.$ref));
                }
            }
        }

        continue;
    }

    // def*.json は $defs に入れるが、root.$defs で処理済みならスキップ
    if (file.startsWith("def")) {
        if (!processedDefs.has(file)) {
            const key = file.replace(".json", "");
            root.$defs[key] = resolveRefs(content, srcDir);
        }
        continue;
    }

    // それ以外は properties に入れる
    const key = file.replace(".json", "");
    root.properties[key] = resolveRefs(content, srcDir);
}

// 出力
fs.writeFileSync(outFile, JSON.stringify(root, null, 2), "utf8");
console.log(`Schema merged → ${outFile}`);