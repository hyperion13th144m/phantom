# phantom

## setup
以下のURLはソースつき。いずれソースなしの運用版も公開予定。
```bash
git clone https://github.com/hyperion13th144m/phantom
cd phantom
docker pull
```

## init
elasticsearch のインデックスを作成する。
追加データベースも作成する。
```
./scripts/setup.sh -p
```
開発用なら -d

## operations
 - 特許文書を収集する
 - 特許文書をElasticsearchにアップロードする

### 特許文書を収集する
```bash
./scripts/crawl.sh -p [ -m NUMBER_OF_PROCESSES ] [ -o ] [ -t TARGETS ]
```
 - -p: 必須, 開発用なら -d
 - `-m NUMBER_OF_PROCESSES`: 並列処理の数を指定します。デフォルトは1です。1-4 の範囲で指定できます。
 - `-o`: 既存のデータを上書きします。指定しない場合、既存のデータは保持されます。
 - `-t TARGETS`: クロールする特許文書のターゲットを指定します。複数のターゲットをカンマ区切りで指定できます。例: `-t ALL` なにも指定しない場合は全てのターゲットをクロールします。
   - ALL: 全文書
   - APP_DOC : 出願文書系
   - AMND : 補正書系
   - RSPN : 意見書系
   - ETC : その他
   - NOTICE : 発送書類系
 
### 特許文書をElasticsearchにアップロードする
```bash
./scripts/upload.sh -p [ -s ]
```
 - '-p': 必須。開発用なら -d
 - '-s': Elasticsearch に同じデータがあるならば,アップロードしない。

### データの復旧
```bash
./scripts/setup.sh -p
./scripts/crawl.sh -p
./scripts/upload.sh -p
./scripts/extra-data.sh -p
```
