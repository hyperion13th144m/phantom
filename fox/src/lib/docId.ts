export function id2dir(docId: string) {
    // docId をディレクトリ名に変換するロジックをここに実装
    // このロジックは、画像を保存するツールと一致する必要がある
    return `${docId.substring(0, 2)}/${docId.substring(2, 4)}/${docId}`;
}

