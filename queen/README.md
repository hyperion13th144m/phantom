# Queen インターネット出願ソフト XML 変換ライブラリ
## 機能
- インターネット出願ソフトが出力する XML を JSON に変換する
- 生成されたJSONの JSON Schema を Python, typescript 用のインタフェースに変換
## 必要な環境
- Ubuntu 
- Python 3.11 以降
- uv

## インストール
### 1. ディレクトリ構成例
```bash
my-monorepo/
├── packages/
│   ├── queen/        # this library
│   │   ├── src/
│   │   │   └── __init__.py
│   │   └── pyproject.toml
│   ├── service_a/
│   │   ├── service_a/
│   │   │   └── __init__.py
│   │   └── pyproject.toml
│   └── service_b/
│       ├── service_b/
│       │   └── __init__.py
│       └── pyproject.toml
└── README.md
```

### 2. ローカルパッケージの依存関係設定
#### 方法A: pip install -e（開発モード）
service_a から queen を使いたい場合:
```bash
cd packages/service_a
pip install -e ../queen
```

- メリット: 変更が即反映される（再インストール不要）
- デメリット: 手動で依存関係を管理する必要あり

#### 方法B: pyproject.toml の path 依存
service_a/pyproject.toml に以下を追加:
```Toml
[project]
name = "service_a"
version = "0.1.0"
dependencies = [
    "queen @ file:///${PROJECT_ROOT}/packages/queen"
]
```

- メリット: Poetry や uv などのツールで自動解決可能
- デメリット: ツール依存（pip だけだとやや面倒）

#### 方法C: uv ワークスペース（最新推奨）
uv を使うと、モノレポ全体の依存関係を一括管理できます。
pyproject.toml（ルート）:
```Toml
[workspace]
members = [
    "packages/queen",
    "packages/service_a",
    "packages/service_b"
]
```

各パッケージの pyproject.toml では通常通り依存を記述し、
uv sync で全パッケージがリンクされます。

### 3. 実行時の PYTHONPATH 設定（補助的）
開発中に一時的にローカルパッケージを使う場合:
```bash
export PYTHONPATH="${PYTHONPATH}:$(pwd)/packages/queen"
python packages/service_a/main.py
```

### 4. 推奨
 - 小規模・簡易 → 方法A（pip install -e）
 - Poetry / uv などのモダン環境 → 方法B or C
 - 長期運用・チーム開発 → 方法C（uv ワークスペース）


## Docker コンテナでのモノレポ管理
service_a を Docker コンテナで動かすときに、モノレポ内の queen をどう参照するか。
モノレポ構成だと、Docker ビルド時に queen を一緒にコンテナに入れるか、ホストからマウントするの2パターンがあります。
以下にそれぞれの方法を解説します。

### 1. ビルド時に同梱する方法（推奨：本番向け）
ディレクトリ構成
```bash
my-monorepo/
├── packages/
│   ├── queen/
│   │   └── pyproject.toml
│   └── service_a/
│       ├── Dockerfile
│       └── pyproject.toml
```

Dockerfile（service_a）
```Dockerfile
FROM python:3.11-slim

# 作業ディレクトリ
WORKDIR /app

# 依存パッケージを先にコピー（キャッシュ効率化）
COPY packages/queen /app/queen
COPY packages/service_a /app/service_a

# queen をインストール（開発モードなら -e）
RUN pip install --no-cache-dir -e ./queen
RUN pip install --no-cache-dir -e ./service_a

# デフォルトコマンド
CMD ["python", "-m", "service_a"]
```

ポイント

COPY で queen をコンテナに入れる
pip install -e ./queen でローカルパッケージとしてインストール
本番なら -e を外して固定バージョンにする


### 2. 開発時にホストからマウントする方法（即時反映）
docker-compose.yml 例:
```yaml
Yamlversion: "3.9"
services:
  service_a:
    build:
      context: .
      dockerfile: packages/service_a/Dockerfile
    volumes:
      - ./packages/service_a:/app/service_a
      - ./packages/queen:/app/queen
    command: python -m service_a
```

Dockerfile（service_a）:
```Dockerfile
FROM python:3.11-slim
WORKDIR /app

# 依存関係だけ先にインストール
COPY packages/service_a/pyproject.toml /app/service_a/
COPY packages/queen/pyproject.toml /app/queen/
RUN pip install --no-cache-dir -e ./queen
RUN pip install --no-cache-dir -e ./service_a
```

ポイント

volumes でホストの queen をコンテナにマウント
コード変更が即コンテナに反映される
開発効率は高いが、本番では非推奨

### 3. uv ワークスペースを使う場合
もし uv を使っているなら、ルートで uv sync してから
Dockerfile 内で ルートごとコピーすれば依存リンクが維持されます。
```Dockerfile
FROM python:3.11-slim
WORKDIR /app

COPY . /app
RUN pip install uv && uv sync --frozen

CMD ["python", "-m", "service_a"]
```

### まとめ
 - 本番 → COPY で queen を同梱し、pip install でインストール
 - 開発 → volumes でホストの queen をマウント（即時反映）
 - uv / Poetry → ワークスペース機能で依存解決し、ルートごとコピー

## 使い方
```python
from queen.translate_all import translate_all
src_xml = ["path/to/input1.xml", "path/to/input2.xml"]
output_dir = "path/to/output"

# doctypeキーと出力パスのマッピング
doctype_path_map = {
    "bibliography": "path/to/bibliography.json",
    "pat-app-doc": "path/to/pat-app-doc.json",
}

# doctype_path_map 省略パターン
# output_dir にデフォルト名で保存される
translate_all(
    src_xml=src_xml, output_dir=output_dir, prettify=True
)

# output_dir 省略パターン
# doctype_path_map に従って保存される
translate_all(
    src_xml=src_xml, doctype_path_map=doctype_path_map, prettify=True
)

# どちらも指定するパターン
# output_dir が doctype_path_map のファイル名の先頭に追加され、そのパスに保存される。
translate_all(
    src_xml=src_xml, doctype_path_map=doctype_path_map,
    output_dir=output_dir, prettify=True
)
```
引数
- src_xml (list[str]): XMLファイルのパスを含むリスト. 
- doctype_path_map (DoctypePathMap | None): xml の doctype とその変換結果を保存するパスの辞書
- output_dir (str | None): 出力先ディレクトリのパス

src_xml は 文字コードが UTF-8であること。
libefiling parse_archive で出力された xml ディレクトリにあるxml を想定している。

## 型生成
```bash
scripts/
├── build-all.sh
├── build-schema.sh
├── translate-all.sh
└── translate.sh
```
 - translate-all.sh: src_xml 配下の全ての xml を変換
 - translate.sh: src_xml 配下の特定の xml を変換
 - build-all.sh: xsl を json schema に変換し、 fox, panther にコピー
 - build-schema.sh: build-all.sh から呼ばれる


xsl のschemaを更新したら build-fox.sh, build-panther.sh を実行して型を生成する。


## 新規文書タイプ追加
### xsl 作成
 - doctypeから元になるxslを探す。
 - xslを編集  xsl template, schema
 - config.py に設定追加
 - 変換チェック
```bash
$ scripts/translate-all.sh xml_dir out_dir [--debug]
```

### 正解のjsonをテスト用にコピー
最初は、生成した xslをコピー。以後、xsl編集したら、必要に応じて正解のjsonも更新する。
```bash
$ cp *.josn test-data/*/xml-to-json
```

### 全体テストとおるか確認
```bash
$ scripts/run-test.sh
```

### json schema 生成
 - xslを↓のスクリプトに追加
 - scripts/build-all.sh  if 文書本体のxslのみ
 - scripts/build-schema.sh  if 文書本体のxsl,文書本体から参照されるxsl
 - json schema 生成、fox/panther にコピーされるか確認
