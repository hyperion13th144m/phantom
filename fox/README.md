# fox project
特許明細書を HTML にレンダリングする astro プロジェクト

## Project Structure

```text
/
├── dist/              ビルド出力先
├── public/
│   ├── favicon.svg
│   └── content/       レンダリング元の明細書 JSON, webp などファイル群
├── src
│   ├── assets
│   │   └── astro.svg
│   ├── components
│   │   ├── application/   明細書レンダリング関連コンポーネント
│   │   ├── icons/         アイコンコンポーネント
│   │   └── ui/            文書に非依存な UI コンポーネント
│   ├── interfaces        TypeScript インターフェース
│   ├── lib               ヘルパー関数
│   ├── pages
│   │   └── docs/         明細書関連ページ
│   ├── layouts
│   │   ├── PrintingLayout.astro 明細書印刷用レイアウト
│   │   └── Layout.astro 明細書用レイアウト
│   └── styles/
│       └── global.css
└── package.json
```

## Commands

All commands are run from the root of the project, from a terminal:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `yarn install`             | Installs dependencies                            |
| `yarn dev`             | Starts local dev server at `localhost:4321`      |
| `yarn build`           | Build your production site to `./dist/`          |
| `yarn preview`         | Preview your build locally, before deploying     |
| `yarn astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `yarn astro -- --help` | Get help using the Astro CLI                     |
