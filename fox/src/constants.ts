import fs from "node:fs/promises";
import path from "node:path";
import type { ImagesInformation } from "./interfaces/generated/images-information";

// astro
// public/images (sym link to /data_dir)
//  開発時に画像をみるために public/images にシンボリックリンクを張る。
//  ビルド時には public/images はコピーされないように astro.config.mjs に設定されている。
// source で /images/* とすると、開発時は
//   public/images の実体 /data_dir/*/*.webp が参照されレンダリングされる。

// /data_dir
// |
// +-- id2dir/docId/
// |           +--json/
// |           |    +--document.json
// |           +--images/
// |                +-- *.webp
// /wwwroot (astro build の出力先。nginx で配信される htmlが置かれる)

// nginx 
//   /images/* -> /data_dir/*/images/*
//   /docs/*   -> /wwwroot/docs/* (astro がビルドして出力するコンテンツ)


// document.json などのコンテンツが置かれているディレクトリ
export const DATA_DIR = "/data_dir";

// 静的コンテンツのベースURLパス.
const BASE_URL = "/images";

// docId で特定されるコンテンツが保存されたディレクトリのパスを取得
export const getContentRoot = (docId: string) => {
    return path.join(DATA_DIR, id2dir(docId));
};

function id2dir(docId: string) {
    // docId をディレクトリ名に変換するロジックをここに実装
    // このロジックは、画像を保存するツールと一致する必要がある
    return `${docId.substring(0, 2)}/${docId.substring(2, 4)}/${docId}`;
}

// docId で特定されるコンテンツのベースURLパスを取得
export const getBaseUrl = (docId: string) => {
    return path.join(BASE_URL, id2dir(docId));
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
        url: path.join(getBaseUrl(docId), "images", derived ? derived.filename : ""),
        width: derived?.width || 0,
        height: derived?.height || 0,
    };
};
