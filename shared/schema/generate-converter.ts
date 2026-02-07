import fs from "fs";
import path from "path";

const SCHEMA_PATH = path.resolve(__dirname, "../schema/patent-document-schema.json");
const OUTPUT_PATH = path.resolve(__dirname, "../src/convertPatentDocument.ts");

const schema = JSON.parse(fs.readFileSync(SCHEMA_PATH, "utf-8"));

/**
 * 変換コード生成のメイン関数
 */
function generateConverter(schema: any): string {
    const props = schema.properties;
    const lines: string[] = [];

    lines.push(`// AUTO-GENERATED FILE — DO NOT EDIT`);
    lines.push(`// Generated from patent-document-schema.json`);
    lines.push(``);
    lines.push(`import { PatentDocument } from "./types";`);
    lines.push(`import { PatentDocumentObject } from "./domain-types";`);
    lines.push(`import { DocumentDate } from "./DocumentDate";`);
    lines.push(`import { ApplicationNumber } from "./ApplicationNumber";`);
    lines.push(`import { Applicant } from "./Applicant";`);
    lines.push(``);
    lines.push(`export function convertPatentDocument(raw: PatentDocument): PatentDocumentObject {`);
    lines.push(`  return {`);
    lines.push(`    ...raw,`);

    // トップレベルの properties を走査
    for (const [key, value] of Object.entries(props)) {
        // x-transform がある場合
        if (value["x-transform"]) {
            const cls = value["x-transform"];
            const args = value["x-transform-args"] ?? [];
            const argList = ["raw." + key, ...args.map(a => "raw." + a)].join(", ");

            lines.push(
                `    ${key}: raw.${key} ? new ${cls}(${argList}) : null,`
            );
            continue;
        }

        // fields の中の x-transform-item を処理
        if (key === "fields" && value.type === "object") {
            const fieldsProps = value.properties ?? {};
            for (const [subKey, subValue] of Object.entries(fieldsProps)) {
                if (subValue["x-transform-item"]) {
                    const cls = subValue["x-transform-item"];
                    lines.push(
                        `    ${subKey}: raw.fields.${subKey}.map(v => new ${cls}(v)),`
                    );
                } else {
                    // 変換不要な fields.* はそのままコピー
                    lines.push(`    ${subKey}: raw.fields.${subKey},`);
                }
            }
            continue;
        }

        // 変換不要なトップレベルフィールドはそのまま
        lines.push(`    ${key}: raw.${key},`);
    }

    lines.push(`  };`);
    lines.push(`}`);
    lines.push(``);

    return lines.join("\n");
}

// 生成してファイルに書き出す
const output = generateConverter(schema);
fs.writeFileSync(OUTPUT_PATH, output);

console.log("Generated:", OUTPUT_PATH);