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
export const BASE_URL = "/images";
