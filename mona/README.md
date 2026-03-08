# Mona
インターネット出願ソフトの電子出願のアーカイブを解析・変換するツールです。

## requrements
- Python 3.8以上
- poetry
- tesseract-ocr tesseract-ocr-jpn

## setup
```bash
apt-get update
apt-get install tesseract-ocr tesseract-ocr-jpn
pip install poetry
poetry install
```

## usage
```bash
$ poetry run python src/mona/main.py mona input_root_dir output_root_dir document_code
```
- `input_root_dir`にはインターネット出願ソフトで作成された電子出願のアーカイブが格納されたディレクトリを指定します。  
- `output_root_dir`には変換後のデータを格納するディレクトリを指定します。
- `document_code`には変換対象の電子出願の文書コードを指定します。
- 詳細なオプションは`poetry run python src/mona/main.py --help`で確認できます。

### 注意
 - 実行時に環境変数 OMP_THREAD_LIMIT=1 を設定することを推奨します。これにより、マルチプロセッシングの際のスレッド数が制限され、安定した動作が期待できます。


## 新規文書タイプ追加
### 設定追加
  parse.py doctype_path_map に doctype と doc_dir/hogehoge.json の key/value 追加
```python
doctype_path_map: DoctypePathMap = {
    "attaching-document": str(doc_dir / "attaching-document.json"),
}
```

### json生成確認
json生成されるか確認
```bash
$ uv run src/mona/parse.py ../test-data/amnd/a1527/ out
```

### json copy
正解jsonをtest-data json にコピー
```bash
$ cp attaching-document.json ../test-data/amnd/a1527/json
```

### 全体テスト確認
```bash
$ scripts/run-test.sh
```
