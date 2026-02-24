import fs from "node:fs/promises";
import path from "node:path";

//
// /data_dir
// |
// +-- id2dir/docId/
// |           +--json/
// |           |    +--document.json
// |           +--images/
//                  +-- *.webp

// astro reads each document.json from /data_dir
// nginx serves static contents from /data_dir as /static/*

// document.json などのコンテンツが置かれているディレクトリ
export const DATA_DIR = "/data_dir";

// 静的コンテンツのベースURLパス.
const BASE_URL = "/static";

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