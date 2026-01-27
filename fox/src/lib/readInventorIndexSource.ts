// src/lib/readInventorIndexSource.ts
// document.json から発明者名を抽出し、Inventor Index を作成するモジュール
import fs from "node:fs/promises";
import path from "node:path";
import type { DocumentJson } from "~/interfaces/document";
import type { Block } from "~/interfaces/document-block";
import { type InventorIndexEntry } from "~/interfaces/index/inventor-index";
import { ApplicationNumber } from "~/lib/doc-number";
import { id2dir } from "~/lib/path";
import { generateId } from "./generate-id";


export async function readInventorIndexSource(docId: string): Promise<Record<string, InventorIndexEntry> | null> {
    const contentRoot = path.join(process.cwd(), "public", "content", id2dir(docId));
    const documentPath = path.resolve(contentRoot, "document.json");
    const raw = await fs.readFile(documentPath, "utf-8");
    const document: DocumentJson = JSON.parse(raw);

    // inventorsだけ抽出（重い searchNested は使わない）
    const inventorNames = extractNamesFromTextBlocks(document.textBlocksRoot, "jp:inventor", "jp:name");
    const inventorAddrs = extractNamesFromTextBlocks(document.textBlocksRoot, "jp:inventor", "jp:text");

    // 発明者がいない場合はnullを返す
    if (inventorNames.length === 0 || document.applicationNumber === null) {
        return null
    }
    const inventorSlugs = inventorNames.map((name, index) => {
        const addr = inventorAddrs[index] || "";
        return generateId(`${name} ${addr}`.trim());
    });

    const an = document.applicationNumber ?? document.internationalApplicationNumber ?? document.receiptNumber ?? "";
    const app = new ApplicationNumber(document.law, an);
    const applicationNumberString = app.toString();
    const applicationNumberSlug = app.slug;

    const fileReferenceId = (document as any).fileReferenceId ?? null;

    return Object.fromEntries(inventorSlugs.map((inv, index) => (
        [inv, {
            name: inventorNames[index],
            address: inventorAddrs[index] || "",
            documents: [
                {
                    docId,
                    applicationNumberString,
                    applicationNumberSlug,
                    fileReferenceId,
                }
            ]
        }]
    )));
}

/** Blockツリー専用の軽量トラバース：inventorブロック直下だけ見る */
function extractNamesFromTextBlocks(root: Block[], personTag: string, nameTag: string): string[] {
    const names: string[] = [];
    const stack: any[] = Array.isArray(root) ? [...root] : [];

    while (stack.length) {
        const b = stack.pop();
        if (!b || typeof b !== "object") continue;

        if (b.tag === personTag && Array.isArray(b.blocks)) {
            for (const child of b.blocks) {
                if (child?.tag === nameTag && typeof child.text === "string") {
                    names.push(child.text);
                }
            }
            continue;
        }

        if (Array.isArray(b.blocks)) stack.push(...b.blocks);
    }
    return names;
}
