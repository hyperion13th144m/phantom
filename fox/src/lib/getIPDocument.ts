import fs from "node:fs/promises";
import path from "node:path";
import type { DocumentJson, IPDocument } from "~/interfaces/document";
import { checker, type Block } from "~/interfaces/text-blocks-root";
import { DocumentDate } from "~/lib/doc-date";
import { ApplicationNumber } from "~/lib/doc-number";
import { id2dir } from "~/lib/docId";

export const getIPDocument = async (docId: string) => {
    // document.json が保存されたディレクトリのパスを取得
    const contentRoot = path.join(
        process.cwd(),
        "public",
        "content",
        id2dir(docId),
    );

    // /public の画像などのベースパス
    const basePath = path.join("/content", id2dir(docId));

    // document.json を読み込む
    const documentPath = path.resolve(contentRoot, "document.json");
    const documentRaw = await fs.readFile(documentPath, "utf-8");
    const document: DocumentJson = JSON.parse(documentRaw);

    // IPDocument 用のフィールドを取得・変換
    const applicants = getApplicants(document);
    const inventors = getInventors(document);
    const agents = getAgents(document);
    const submissionDate = new DocumentDate(document.submissionDate);
    const applicationNumber = new ApplicationNumber(
        document.law,
        document.applicationNumber || ""
    );

    // document 内の FigureBlock の画像パスを更新
    updateFigureImagePaths(document, basePath);
    // 画像のパスを絶対パスに変換
    document.images.forEach(img => {
        img.filename = path.join(basePath, img.filename);
    });

    return {
        ...document,
        applicants,
        inventors,
        agents,
        submissionDate,
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
    groupTag: string,
    personTag: string,
    nameTag: string
): string[] => {
    const names = document.textBlocksRoot
        .filter((block) => block.tag === "applicationForm")
        .flatMap((appForm) => appForm.blocks)
        .filter((block) => block.tag === groupTag)
        .flatMap((block) => block.blocks)
        .filter((block) => block && block.tag === personTag)
        .flatMap((block) => block && block.blocks)
        .filter((block) => block && block.tag === nameTag)
        .map((block) => block && 'text' in block ? block.text : undefined)
        .filter((name): name is string => typeof name === "string");
    return names;
}

const getApplicants = (document: DocumentJson): string[] => {
    return getPersonNames(document, "jp:applicants", "jp:applicant", "jp:name");
}

const getInventors = (document: DocumentJson): string[] => {
    return getPersonNames(document, "jp:inventors", "jp:inventor", "jp:name");
}

const getAgents = (document: DocumentJson): string[] => {
    return getPersonNames(document, "jp:agents", "jp:agent", "jp:name");
}

/**
 * document の textBlocksRoot を再帰的に走査し、FigureBlock の画像パスを書き換える
 * @param document - DocumentJson オブジェクト
 * @param basePath - 画像のベースパス
 */
const updateFigureImagePaths = (document: DocumentJson, basePath: string): void => {
    const traverse = (blocks: Block[]): void => {
        for (const block of blocks) {
            if (checker.isFigure(block) || checker.isTables(block)
                || checker.isMaths(block) || checker.isChemistry(block)
                || checker.isImage(block)) {
                if (block.images && Array.isArray(block.images)) {
                    block.images.forEach(image => {
                        // 相対パスを絶対パスに変換
                        image.src = path.join(basePath, image.src);
                    });
                }
            }
            if (block.blocks && Array.isArray(block.blocks)) {
                traverse(block.blocks);
            }
        }
    };

    traverse(document.textBlocksRoot);
};