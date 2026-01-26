import fs from "node:fs/promises";
import path from "node:path";
import type { DocumentJson, IPDocument } from "~/interfaces/document";
import { type Block } from "~/interfaces/document-block";
import { DocumentDate } from "~/lib/doc-date";
import { ApplicationNumber } from "~/lib/doc-number";
import { getContentRoot } from "~/lib/path";

export const getIPDocument = async (docId: string) => {
    // document.json が保存されたディレクトリのパスを取得
    const contentRoot = getContentRoot(docId);

    // document.json を読み込む
    const documentPath = path.resolve(contentRoot, "document.json");
    const documentRaw = await fs.readFile(documentPath, "utf-8");
    const document: DocumentJson = JSON.parse(documentRaw);

    // IPDocument 用のフィールドを取得・変換
    const applicants = getApplicants(document);
    const inventors = getInventors(document);
    const agents = getAgents(document);
    const submissionDate = document.submissionDate ? new DocumentDate(document.submissionDate) : null;
    const dispatchDate = document.dispatchDate ? new DocumentDate(document.dispatchDate) : null;
    const applicationNumber = new ApplicationNumber(
        document.law,
        document.applicationNumber || ""
    );

    return {
        ...document,
        applicants,
        inventors,
        agents,
        submissionDate,
        dispatchDate,
        applicationNumber,
    } as IPDocument
}

/**
 * applicationForm から特定のタイプの人物名を取得する汎用関数
 * @param document - DocumentJson オブジェクト
 * @param groupTag - グループのタグ名 (例: "applicants", "inventors", "agents")
 * @param personTag - 個人のタグ名 (例: "applicant", "inventor", "agent")
 * @returns 名前の配列
 */
const getPersonNames = (
    document: DocumentJson,
    personTag: string,
    nameTag: string
): string[] => {
    const names = searchNested<Block & { id: number; name: string }>(
        document.textBlocksRoot,
        (item) => item.tag === personTag
    )
        .flatMap((item) => item.blocks)
        .filter((item) => item.tag === nameTag)
        .map((item) => item && 'text' in item ? item.text : undefined)
        .filter((name): name is string => typeof name === "string");
    return names;
}

const getApplicants = (document: DocumentJson): string[] => {
    return getPersonNames(document, "jp:applicant", "jp:name");
}

const getInventors = (document: DocumentJson): string[] => {
    return getPersonNames(document, "jp:inventor", "jp:name");
}

const getAgents = (document: DocumentJson): string[] => {
    return getPersonNames(document, "jp:agent", "jp:name");
}

/**
 * ネストした JSON を再帰的に検索する関数
 * @param data 検索対象の JSON（オブジェクトまたは配列）
 * @param predicate 検索条件（true を返した要素を結果に含める）
 * @returns 条件に一致した要素の配列
 */
function searchNested<T>(
    data: unknown,
    predicate: (item: any) => boolean
): T[] {
    const results: T[] = [];

    function recurse(value: unknown) {
        if (Array.isArray(value)) {
            // 配列の場合は各要素を再帰的に探索
            for (const item of value) {
                recurse(item);
            }
        } else if (value !== null && typeof value === "object") {
            // オブジェクトの場合
            if (predicate(value)) {
                results.push(value as T);
            }
            // 子要素を再帰的に探索
            for (const key of Object.keys(value)) {
                recurse((value as Record<string, unknown>)[key]);
            }
        }
    }

    recurse(data);
    return results;
}