# アクセスログ設定ガイド

このプロジェクトはアクセスログを `/var/log/fox/fox.log` に記録するように設定されています。

## セットアップ手順

### 1. ログディレクトリの作成と権限設定

```bash
sudo mkdir -p /var/log/fox
sudo chown -R root:root /var/log/fox
sudo chmod 755 /var/log/fox
```

### 2. logrotate の設定
※ Docker コンテナでnextjs起動する場合は、不要
```bash
sudo cp scripts/logrotate-fox.conf /etc/logrotate.d/fox
```

### 3. 設定の確認

```bash
# logrotate 設定をテスト
sudo logrotate -d /etc/logrotate.d/fox
```

## ログ形式

アクセスログには以下の情報が JSON 形式で記録されます：

- `timestamp`: リクエスト時刻（ISO 8601 形式）
- `clientIp`: クライアント IP アドレス
- `method`: HTTP メソッド (GET, POST等)
- `pathname`: リクエストパス
- `status`: HTTP ステータスコード
- `duration`: レスポンスタイム（ミリ秒）
- `userAgent`: User-Agent ヘッダー
- `referer`: Referer ヘッダー
- `url`: リクエスト URL

## ログローテーション仕様

- **ローテーション条件**: ファイルサイズが 128KB に達すると自動ローテーション
- **保持世代数**: 5世代
- **圧縮**: 自動的に gzip 圧縮される

## ログファイルの確認

```bash
# 最新のログを確認
tail -f /var/log/fox/fox.log | jq

# ログファイル一覧
ls -lah /var/log/fox/
```

## トラブルシューティング

ログが記録されない場合は、以下を確認してください：

1. ログディレクトリが存在し、アプリケーション実行ユーザーに書き込み権限がある
2. アプリケーションが起動している
3. アプリケーションへのリクエストが実際に発生している

```bash
# ディレクトリの権限確認
ls -ld /var/log/fox
```
