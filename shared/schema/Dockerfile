# ============================
# Stage 1: Node (TS tools)
# ============================
FROM node:20-slim AS node_builder

# json-schema-to-typescript をインストール
RUN npm install -g json-schema-to-typescript

# ============================
# Stage 2: Python (Pydantic tools)
# ============================
FROM python:3.12-slim AS python_builder

# datamodel-code-generator をインストール
RUN pip install --no-cache-dir 'datamodel-code-generator[ruff]' pydantic

# ============================
# Stage 3: Final image
# ============================
FROM python:3.12-slim

# Node 実行環境を丸ごとコピー
COPY --from=node_builder /usr/local/bin /usr/local/bin
COPY --from=node_builder /usr/local/lib /usr/local/lib
COPY --from=node_builder /opt /opt
RUN pip install --no-cache-dir ruff

# Python のツールをコピー
COPY --from=python_builder /usr/local/bin/datamodel-codegen /usr/local/bin/
COPY --from=python_builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages

# Node 実行環境も必要なので node をインストール
RUN apt-get update && apt-get install -y nodejs npm && apt-get clean

RUN addgroup pyuser && adduser --ingroup pyuser pyuser
USER pyuser
WORKDIR /schema

# スキーマとビルドスクリプトをコピー
COPY . .

# デフォルトコマンド
CMD ["sh", "build-all.sh"]