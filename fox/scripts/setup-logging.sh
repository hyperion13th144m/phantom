#!/bin/bash

# アクセスログディレクトリのセットアップスクリプト
# Note: このスクリプトはホストOS用です。Docker コンテナ内では logrotate は不要です。
# コンテナ内では pino-rotating-file-stream が自動的にログをローテーションします。

set -e

LOGDIR="/var/log/fox"
LOGFILE="$LOGDIR/fox.log"
LOGROTATE_CONF="/etc/logrotate.d/fox"

echo "Setting up Fox access logging..."

# 1. ログディレクトリの作成
echo "Creating log directory: $LOGDIR"
if [ ! -d "$LOGDIR" ]; then
    sudo mkdir -p "$LOGDIR"
    sudo chmod 755 "$LOGDIR"
else
    echo "Log directory already exists."
fi

# 2. logrotate 設定をコピー
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -f "$PROJECT_ROOT/scripts/logrotate-fox.conf" ]; then
    echo "Installing logrotate configuration..."
    sudo cp "$PROJECT_ROOT/scripts/logrotate-fox.conf" "$LOGROTATE_CONF"
    echo "Logrotate config installed: $LOGROTATE_CONF"
else
    echo "Warning: logrotate-fox.conf not found"
fi

# 3. logrotate 設定の検証
echo "Validating logrotate configuration..."
sudo logrotate -d "$LOGROTATE_CONF"

echo "Setup complete!"
echo ""
echo "Log directory: $LOGDIR"
echo "Log file: $LOGFILE"
echo "Logrotate config: $LOGROTATE_CONF"
echo ""
echo "To run the application and generate logs:"
echo "  npm run build"
echo "  npm run start"
