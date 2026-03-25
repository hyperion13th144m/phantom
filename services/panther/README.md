# Panther
Pantherは、Elasticsearchにインデックスを作成し、キュメントをアップロードするためのツールです。

## 使い方

### インデックスを作成
```bash
$ python src/panther/main.py create-index \
  --index patent-documents \
  --mapping elasticsearch/document-mapping.json
```

### ドキュメントをアップロード
```bash
$ python src/panther/main.py upload \
  --index patent-documents \
  --data-root data
```

### help
```bash
$ python src/panther/main.py --help
$ python src/panther/main.py create-index --help
$ python src/panther/main.py upload --help
```

### 環境変数を使用（共通オプション）
```bash
export ES_URL="http://es01:9200"
export ES_USER="elastic"
export ES_PASSWORD="your-password"

$ python src/panther/main.py create-index \
  --index patent-documents \
  --mapping elasticsearch/document-mapping.json

$ python src/panther/main.py upload-documents \
  --index patent-documents \
  --data-root data

### 一度に実行（インデックス作成→アップロード）
$ python src/panther/main.py create-index \
  --index patent-documents \
  --mapping elasticsearch/document-mapping.json \
  --recreate

$ python src/panther/main.py upload-documents \
  --index patent-documents \
  --data-root data \
  --use-hash-guard \
  --refresh

### mona REST API からドキュメントを取得してアップロード
`--mona-base-url` を指定すると、ローカルファイルの代わりに mona API (`/idList`, `/{doc_id}/json/*`) から取得してアップロードする。

```bash
$ python src/panther/main.py upload-documents \
  --index patent-documents \
  --mona-base-url http://mona:8000 \
  --use-hash-guard \
  --refresh
```

### Panther REST API サーバー
`panther.server:app` を起動すると、ジョブ実行 API を提供する。

```bash
$ uvicorn panther.server:app --host 0.0.0.0 --port 8080
```

- `POST /jobs` : 新規アップロードジョブ開始
- `GET /jobs` : 現在の実行状況（running/latest）
- `GET /jobs/list` : 過去ジョブID一覧
- `GET /jobs/{job_id}` : 指定ジョブの詳細
- `GET /jobs/{job_id}/cancel` : 実行中ジョブのキャンセル要求

### 付加データのインポートとアップロード
#### 付加データ用データベースの初期化
```bash
$ python src/panther/main.py create-db \
  --sqlite-db path/to/patent_documents.db
```
#### データベースへのインポート
sqlite データベースに、データインポート。付加データを作成する前に必要なステップ。
```bash
$ python src/panther/main.py import-extra-data \
  --sqlite-db path/to/patent_documents.db \
  --data-root data
```

### 付加データの追加
sqlite db を直接編集して、担当者、タグ、付加番号を追加することが可能。

docId, 出願番号、出願人、発明者は参考用。assignees（担当者）、tags(タグ)、extraNumbers(付加番号)の列に、データを記入する。複数の場合は、カンマで区切る。

### 付加データアップロード
sqlite db をアップロードする。
```bash
$ python src/panther/main.py upload-extra-data \
  --sqlite-db path/to/patent_documents.db \
  --index patent-documents
```

### 付加データの復元
sqlite db を Elasticsearch に復元する。
```bash
python restore_metadata_to_es.py \
  --sqlite /data/metadata.sqlite3 \
  --table patent_metadata \
  --es-node http://elasticsearch:9200 \
  --index patent-documents
```
### 重要な運用メモ

通常は --upsert なしが安全です
（本文が無いdocIdをESに作らないため。404は notFound として数える）

ESを作り直したときの手順は：

特許JSONをESへ再投入

このスクリプトでSQLiteメタを反映

## 新規文書タイプの追加
とくに実装することなし。
## full-text.json bibliography.json images-information.json
これらが変更されたときは、ES 用JSON生成 patent_doc_editr.py を修正する。
document-mapping.json も合わせて編集する必要がある。
ESのインデックスを削除して、再度作成する必要がある。
