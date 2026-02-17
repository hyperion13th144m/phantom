Python のモノレポ（monorepo）で ローカルパッケージ を扱う場合、
複数プロジェクト間でコードを共有しつつ、依存関係をきれいに管理する方法はいくつかあります。
以下では、標準的な構成例と依存関係の設定方法を解説します。

1. ディレクトリ構成例
my-monorepo/
├── packages/
│   ├── common_lib/        # 共有ライブラリ
│   │   ├── common_lib/
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


2. ローカルパッケージの依存関係設定
方法A: pip install -e（開発モード）
service_a から common_lib を使いたい場合:
Bashcd packages/service_a
pip install -e ../common_lib


メリット: 変更が即反映される（再インストール不要）
デメリット: 手動で依存関係を管理する必要あり


方法B: pyproject.toml の path 依存
service_a/pyproject.toml に以下を追加:
Toml[project]
name = "service_a"
version = "0.1.0"
dependencies = [
    "common-lib @ file:///${PROJECT_ROOT}/packages/common_lib"
]


メリット: Poetry や uv などのツールで自動解決可能
デメリット: ツール依存（pip だけだとやや面倒）


方法C: uv ワークスペース（最新推奨）
uv を使うと、モノレポ全体の依存関係を一括管理できます。
pyproject.toml（ルート）:
Toml[workspace]
members = [
    "packages/common_lib",
    "packages/service_a",
    "packages/service_b"
]

各パッケージの pyproject.toml では通常通り依存を記述し、
uv sync で全パッケージがリンクされます。

3. 実行時の PYTHONPATH 設定（補助的）
開発中に一時的にローカルパッケージを使う場合:
Bashexport PYTHONPATH="${PYTHONPATH}:$(pwd)/packages/common_lib"
python packages/service_a/main.py


4. 推奨

小規模・簡易 → 方法A（pip install -e）
Poetry / uv などのモダン環境 → 方法B or C
長期運用・チーム開発 → 方法C（uv ワークスペース）


✅ 次のステップとして、
もし希望があれば uv を使った Python モノレポの完全テンプレート を作成できます。
これなら依存関係の同期やローカルリンクが自動化されます。

作りますか？
そうすれば、common_lib を更新したら service_a / service_b に即反映される環境ができます。





====================
なるほど、
service_a を Docker コンテナで動かすときに、モノレポ内の common_lib をどう参照するかですね。
モノレポ構成だと、Docker ビルド時に common_lib を一緒にコンテナに入れるか、ホストからマウントするの2パターンがあります。
以下にそれぞれの方法を解説します。

1. ビルド時に同梱する方法（推奨：本番向け）
ディレクトリ構成
my-monorepo/
├── packages/
│   ├── common_lib/
│   │   └── pyproject.toml
│   └── service_a/
│       ├── Dockerfile
│       └── pyproject.toml

Dockerfile（service_a）
DockerfileFROM python:3.11-slim

# 作業ディレクトリ
WORKDIR /app

# 依存パッケージを先にコピー（キャッシュ効率化）
COPY packages/common_lib /app/common_lib
COPY packages/service_a /app/service_a

# common_lib をインストール（開発モードなら -e）
RUN pip install --no-cache-dir -e ./common_lib
RUN pip install --no-cache-dir -e ./service_a

# デフォルトコマンド
CMD ["python", "-m", "service_a"]

ポイント

COPY で common_lib をコンテナに入れる
pip install -e ./common_lib でローカルパッケージとしてインストール
本番なら -e を外して固定バージョンにする


2. 開発時にホストからマウントする方法（即時反映）
docker-compose.yml 例:
Yamlversion: "3.9"
services:
  service_a:
    build:
      context: .
      dockerfile: packages/service_a/Dockerfile
    volumes:
      - ./packages/service_a:/app/service_a
      - ./packages/common_lib:/app/common_lib
    command: python -m service_a

Dockerfile（service_a）:
DockerfileFROM python:3.11-slim
WORKDIR /app

# 依存関係だけ先にインストール
COPY packages/service_a/pyproject.toml /app/service_a/
COPY packages/common_lib/pyproject.toml /app/common_lib/
RUN pip install --no-cache-dir -e ./common_lib
RUN pip install --no-cache-dir -e ./service_a

ポイント

volumes でホストの common_lib をコンテナにマウント
コード変更が即コンテナに反映される
開発効率は高いが、本番では非推奨


3. uv ワークスペースを使う場合
もし uv を使っているなら、ルートで uv sync してから
Dockerfile 内で ルートごとコピーすれば依存リンクが維持されます。
DockerfileFROM python:3.11-slim
WORKDIR /app

COPY . /app
RUN pip install uv && uv sync --frozen

CMD ["python", "-m", "service_a"]


まとめ

本番 → COPY で common_lib を同梱し、pip install でインストール
開発 → volumes でホストの common_lib をマウント（即時反映）
uv / Poetry → ワークスペース機能で依存解決し、ルートごとコピー


もし希望があれば、
この モノレポ + Docker + uv ワークスペース の完全テンプレートを作って、
common_lib の変更が即 service_a に反映される開発環境を作れます。
これ、作りますか？
そうすれば開発と本番の両方に対応できます。
