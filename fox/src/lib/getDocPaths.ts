import fs from "node:fs/promises";
import path from "node:path";
import type { IPDocument } from "~/interfaces/document";
import { id2dir } from "~/lib/docId";

export async function getDocIds() {
    // document.json を探し、docIdを返す。

    let results: string[] = [];
    const contentDir = path.join(process.cwd(), "public", "content");
    try {
        const dirents = await fs.readdir(contentDir, {
            recursive: true,
            withFileTypes: true,
        });
        results = await Promise.all(dirents
            .filter((dirent) => dirent.isFile())
            .filter((dirent) => dirent.name === "document.json")
            .map(async (dirent) => {
                const txt = await fs.readFile(path.join(dirent.parentPath, dirent.name), "utf-8");
                const json = JSON.parse(txt);
                return json['docId'] as string;
            }));
    } catch (err) {
        console.error("Error reading content directory:", err);
    }
    return results.map((docId) => ({ params: { docId } }));
}

export const getDocument = async (docId: string) => {
    // json が保存されたディレクトリのパスを取得
    const contentRoot = path.join(
        process.cwd(),
        "public",
        "content",
        id2dir(docId),
    );

    // /public の画像などのベースパス
    const basePath = path.join("/content", id2dir(docId));

    // テキストブロック
    const documentPath = path.resolve(contentRoot, "document.json");
    const documentRaw = await fs.readFile(documentPath, "utf-8");
    const document: IPDocument = JSON.parse(documentRaw);


    const thumbnails = document.images.filter((img: any) => img.sizeTag === "thumbnail")
        .sort((a: any, b: any) => a.number.localeCompare(b.number));
    const srcImages = document.images.filter((img: any) => img.sizeTag === "middle")
        .sort((a: any, b: any) => a.number.localeCompare(b.number));

    const images = srcImages.map((img: any, index: number) => {
        return {
            src: path.join(basePath, img.filename),
            thumbSrc: path.join(
                basePath,
                thumbnails[index].filename
            ),
            alt: img.description,
            rotation: 0,
            width: parseInt(img.width),
            height: parseInt(img.height),
            kind: img.kind,
            sizeTag: img.sizeTag,
            number: img.number,
        };
    });

    return { basePath, document, images };
}
