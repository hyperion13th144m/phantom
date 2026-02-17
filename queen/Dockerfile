FROM python:3.12-slim
# 公式イメージからuvをコピー
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

ARG USERNAME=pyuser
ARG GROUPNAME=pygroup
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID $GROUPNAME && useradd -m -s /bin/zsh -u $UID -g $GID $USERNAME
USER pyuser

# 依存関係ファイルのコピー
COPY pyproject.toml uv.lock ./

## 依存関係のインストール
# uv sync creates .venv in default.
RUN uv sync --frozen --no-cache

COPY . .
