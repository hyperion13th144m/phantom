# fox project
特許明細書を HTML にレンダリングする astro プロジェクト

## レンダリングの対象のディレクトリ構造
```text
/data_dir/
├── 03
│   └── 36
│       └── 0336492181f26350eff4bcb1e50d661ca2edd1283db2c981d97717c1eded4639
│           ├── images
│           │   ├── JPOXMLDOC01-appb-D000001-large.webp
│           │   ├── JPOXMLDOC01-appb-D000001-middle.webp
│           │   ├── JPOXMLDOC01-appb-D000001-thumbnail.webp
│           │   ├── JPOXMLDOC01-appb-D000002-large.webp
│           │   ├── JPOXMLDOC01-appb-D000002-middle.webp
│           │   ├── JPOXMLDOC01-appb-D000002-thumbnail.webp
│           ├── json
│           │   ├── bibliography.json
│           │   ├── document.json
│           │   ├── full-text.json
│           │   └── images-information.json
│           ├── manifest.json
│           ├── ocr
│           ├── raw
│           │   ├── 06122023286-jpflst.xml
│           │   ├── 06122023286-jpmngt.xml
│           │   ├── 06122023286-jpntce.xml
│           │   ├── JPOXMLDOC01-pkda.xml
│           │   └── JPOXMLDOC01-pkgh.xml
│           └── xml
│               ├── 06122023286-jpflst.xml
│               ├── 06122023286-jpmngt.xml
│               ├── 06122023286-jpntce.xml
│               ├── JPOXMLDOC01-pkda.xml
│               ├── JPOXMLDOC01-pkgh.xml
│               └── procedure.xml   
```
mona がこのようなデータを作成する。一つの特許文書は、docId = "0336492181f26350eff4bcb1e50d661ca2edd1283db2c981d97717c1eded4639" のような文字列で識別される。


## プロジェクトのディレクトリ構造
```text
├── astro.config.mjs
├── package.json
├── public
│   ├── favicon.svg
│   └── images -> /data_dir      # 開発時に画像を参照するためのシンボリックリンク
├── README.md
├── src
│   ├── assets
│   │   ├── astro.svg
│   │   └── background.svg
│   ├── components
│   │   ├── bibliographic-items  # 書誌事項をレンダリングするコンポーネント
│   │   ├── document  # 文書本体をレンダリングするコンポーネント
│   │   │   └── items  # 文書を構成する要素をレンダリングするコンポーネント
│   │   ├── icons
│   │   └── ui  # UI コンポーネント
│   ├── constants.ts
│   ├── interfaces
│   │   ├── carousel-images.ts
│   │   └── generated
│   ├── layouts
│   │   ├── Layout.astro
│   │   └── PrintingLayout.astro
│   ├── lib
│   ├── pages
│   │   └── docs
│   │       └── [docId]
│   │           ├── index.astro
│   │           └── print.astro
│   └── styles
│       └── global.css
├── tsconfig.json
└── yarn.lock
```

### src/pages/docs/[docId]/index.astro
特許文書の詳細ページ。constants.ts DATA_DIR (/data_dir) から、 docId に対応するdocument.json等を読み出す。

### 画像
astro は、document.json を html にレンダリングする際に、画像ファイルのurlを生成する。
```json
{
    "tag": "image-container",
    "file": "image.tif"
}
```
```html
<img src="/images/03/36/0336492181f26350eff4bcb1e50d661ca2edd1283db2c981d97717c1eded4639/images/image.webp">
```
### 開発環境と本番環境での画像の参照
  - 開発環境では、public/images が参照される。
  - 本番環境では、NGINX に /images/* をリクエストすると /data_dir/*/images/* を読み出す。

## 運用
### fox 起動
docker で /data_dir をマウントする。

### nginx
```
  location /images/ {
    alias /data_dir/;
  }
```
として、/images へのアクセスを /data_dir へのアクセスに変換する。 
