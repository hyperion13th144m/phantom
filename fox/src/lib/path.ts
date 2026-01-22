import path from "node:path";

export function id2dir(docId: string) {
    // docId をディレクトリ名に変換するロジックをここに実装
    // このロジックは、画像を保存するツールと一致する必要がある
    return `${docId.substring(0, 2)}/${docId.substring(2, 4)}/${docId}`;
}

// docId で特定されるコンテンツが保存されたディレクトリのパスを取得
export const getContentRoot = (docId: string) => {
    return path.join(process.cwd(), "public", "content", id2dir(docId));
};

// docId で特定されるコンテンツのベースURLパスを取得
export const getBaseUrlPath = (docId: string) => {
    return path.join("/content", id2dir(docId));
};
