# Mona
インターネット出願ソフトの電子出願のアーカイブを解析・変換する。

## requrements
- Python 3.8以上
- uv
- tesseract-ocr tesseract-ocr-jpn

## setup
```bash
apt-get update
apt-get install tesseract-ocr tesseract-ocr-jpn
pip install uv
uv install
```

## usage
```bash
usage: uv run src/mona/main.py [-h] [-l {info,debug}] [-m {1,2,3,4}] [-o] [--mode {production,development}]
               src_dir output_dir
               {A101,A102,A1131,A1191,A130,A163,A263,A1631,A1632,A1634,A151,A1523,A2523,A1529,A1527,A15211,A153,A1781,A1871,A1872,A2242623}
```
- `src_dir` にはインターネット出願ソフトで作成された電子出願のアーカイブが格納されたディレクトリを指定します。  
- --mode development を指定した場合、src_dir 内のサブディレクトリを走査して、document_code に一致する文書コードを持つ, 展開済みの電子出願のアーカイブを変換します。
- --mode production を指定した場合、src_dir 内のサブディレクトリを走査して、document_code に一致する文書コードを持つ電子出願のアーカイブを変換します。 
- `output_dir`には変換後のデータを格納するディレクトリを指定します。
- `document_code`には変換対象の電子出願の文書コードを指定します。
- 詳細なオプションは`uv run src/mona/main.py --help`で確認できます。

## 注意
 - 実行時に環境変数 OMP_THREAD_LIMIT=1 を設定することを推奨します。これにより、マルチプロセッシングの際のスレッド数が制限され、安定した動作が期待できます。


## 新規文書タイプ追加
### 設定追加
  parse.py doctype_path_map に doctype と doc_dir/hogehoge.json の key/value 追加
```python
doctype_path_map: DoctypePathMap = {
    "attaching-document": str(doc_dir / "attaching-document.json"),
}
```

### config に A1524など取り込み可能な文書のコードを追加
新規文書が 新たな文書コードであれば、config.py の TARGET_DOCUMENT_CODES に追加
```python
TARGET_DOCUMENT_CODES = [
    "A1524",
    "A1527",
]
```
phantom/scripts/crawl.sh にも同様にコードを追加

### json生成確認
json生成されるか確認
```bash
$ uv run src/mona/parse.py /src-dir/amnd/a1527/ out
```

### json copy
正解jsonをtest-data json にコピー
```bash
$ cp attaching-document.json /src-dir/amnd/a1527/json
```

### 全体テスト確認
```bash
$ scripts/run-test.sh
```
/src-dir/amnd/a1527/ のデータからjsonを生成し、/src-dir/amnd/a1527/json のファイルと比較する。一致しなければテスト失敗

## REST API

