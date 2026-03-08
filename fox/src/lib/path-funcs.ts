import fs from "node:fs/promises";
import path from "node:path";
import { BASE_URL, DATA_DIR } from "~/constants";
import type { ImagesInformation } from "~/interfaces/generated/images-information";
import cfg from "../interfaces/generated/config/storage-config.json";


// docId で特定されるコンテンツが保存されたディレクトリのパスを取得
export const getContentRoot = (docId: string) => {
    return path.join(DATA_DIR, id2dir(docId));
};

function id2dir(docId: string) {
    // docId をディレクトリ名に変換するロジックをここに実装
    // このロジックは、画像を保存するツールと一致する必要がある
    return computePath(docId);
    //return `${docId.substring(0, 2)}/${docId.substring(2, 4)}/${docId}`;
}

// docId で特定されるコンテンツのベースURLパスを取得
export const getBaseUrl = (docId: string) => {
    return path.join(BASE_URL, id2dir(docId), "images");
};

export const getDocument = async (docId: string): Promise<Array<any>> => {
    const txt = await fs.readFile(
        path.join(getContentRoot(docId), "json/document.json"),
        "utf-8",
    );
    const json: Array<any> = JSON.parse(txt);
    return json;
}

export const getImageUrl = async (docId: string, imageName: string, sizeTag: string) => {
    const txt = await fs.readFile(
        path.join(getContentRoot(docId), "json/images-information.json"),
        "utf-8",
    );
    const json: ImagesInformation[] = JSON.parse(txt);
    const derived = json
        .filter((info) => info.filename === imageName)
        .flatMap((info) => info.derived)
        .filter((derived) => derived.attributes?.some(
            (attr) => (attr.key === "sizeTag" && attr.value === sizeTag)))
        .at(0);
    return {
        url: path.join(getBaseUrl(docId), derived ? derived.filename : ""),
        width: derived?.width || 0,
        height: derived?.height || 0,
    };
};

function computePath(docId: string): string {
    if (cfg.mode === "prod") {
        return cfg.pattern
            .replace("{0}", docId[0])
            .replace("{1}", docId[1])
            .replace("{2}", docId[2])
            .replace("{3}", docId[3])
            .replace("{docId}", docId);
    } else {
        const devPath: { [key: string]: string } = cfg.devMap;
        if (!(docId in devPath)) {
            throw new Error(`docId ${docId} not found in devMap`);
        }
        return devPath[docId];
    }
}
