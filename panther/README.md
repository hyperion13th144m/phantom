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

$ python src/panther/main.py upload \
  --index patent-documents \
  --data-root data

### 一度に実行（インデックス作成→アップロード）
$ python src/panther/main.py create-index \
  --index patent-documents \
  --mapping elasticsearch/document-mapping.json \
  --recreate

$ python src/panther/main.py upload \
  --index patent-documents \
  --data-root data \
  --use-hash-guard \
  --refresh
```
