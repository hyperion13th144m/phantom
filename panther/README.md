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
