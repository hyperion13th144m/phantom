"""
SQLiteデータベースにpatentDocumentテーブルを作成し、
document.jsonファイルからデータをインポートするスクリプト
"""
import json
import sqlite3
from pathlib import Path
from typing import Any, Dict

from panther.ip_document import load_ip_document


def check_doc_exists(cursor: sqlite3.Cursor, doc_id: str) -> bool:
    """
    指定されたdocIdがテーブルに存在するかチェック

    Args:
        cursor: データベースカーソル
        doc_id: チェックするdocId

    Returns:
        存在する場合True、しない場合False
    """
    cursor.execute("SELECT 1 FROM patentDocument WHERE docId = ?", (doc_id,))
    return cursor.fetchone() is not None


def insert_document(cursor: sqlite3.Cursor, doc_data: Dict[str, Any]) -> bool:
    """
    document.jsonのデータをテーブルに挿入

    Args:
        cursor: データベースカーソル
        doc_data: JSONから読み取ったドキュメントデータ

    Returns:
        挿入成功の場合True、失敗の場合False
    """
    try:
        cursor.execute(
            """
            INSERT INTO patentDocument (
                docId, law, appNumber, fileReferenceId,
                applicants, inventors, assignees, tags
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """,
            (
                doc_data.get("docId"),
                doc_data.get("law"),
                doc_data.get("applicationNumber"),
                doc_data.get("fileReferenceId"),
                ",".join(doc_data.get("applicants")),
                ",".join(doc_data.get("inventors")),
                "",
                "",
            ),
        )
        return True
    except sqlite3.Error as e:
        print(f"  ✗ 挿入エラー: {e}")
        return False


def cmd_import_extra_data(data_dir: str = "/data_dir", db_path: str = "patent.db"):
    """
    指定ディレクトリから再帰的にdocument.jsonを検索し、
    データベースにインポートする

    Args:
        data_dir: 検索を開始するディレクトリ
        db_path: データベースファイルのパス
    """
    data_path = Path(data_dir)

    if not data_path.exists():
        print(f"✗ ディレクトリが見つかりません: {data_dir}")
        return

    # document.jsonファイルを再帰的に検索
    json_files = list(data_path.rglob("document.json"))

    if not json_files:
        print(f"✗ document.jsonが見つかりませんでした: {data_dir}")
        return

    print(f"✓ {len(json_files)}個のdocument.jsonを見つけました")

    # データベースに接続
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    inserted_count = 0
    skipped_count = 0
    error_count = 0

    try:
        for json_file in json_files:
            try:
                # JSONファイルを読み込む
                doc_data = load_ip_document(json_file)
                doc_id = doc_data.get("docId")

                if not doc_id:
                    print(f"  ⚠ docIdがありません: {json_file}")
                    error_count += 1
                    continue

                # docIdの存在チェック
                if check_doc_exists(cursor, doc_id):
                    print(f"  ⊘ スキップ (既存): {doc_id} ({json_file})")
                    skipped_count += 1
                else:
                    # データを挿入
                    if insert_document(cursor, doc_data):
                        print(f"  ✓ 挿入成功: {doc_id} ({json_file})")
                        inserted_count += 1
                    else:
                        error_count += 1

            except json.JSONDecodeError as e:
                print(f"  ✗ JSON読み取りエラー: {json_file} - {e}")
                error_count += 1
            except Exception as e:
                print(f"  ✗ エラー: {json_file} - {e}")
                error_count += 1

        # コミット
        conn.commit()

        # サマリーを表示
        print(f"\n{'='*60}")
        print(f"処理完了:")
        print(f"  挿入: {inserted_count}件")
        print(f"  スキップ: {skipped_count}件")
        print(f"  エラー: {error_count}件")
        print(f"{'='*60}")

    except Exception as e:
        print(f"✗ 予期しないエラー: {e}")
        conn.rollback()
    finally:
        conn.close()


if __name__ == "__main__":
    # データベースファイルのパスを指定（必要に応じて変更）
    db_path = "patent.db"
    data_dir = "/data_dir"

    # データをインポート
    print("\n" + "=" * 60)
    print("document.jsonのインポートを開始します...")
    print("=" * 60 + "\n")
    cmd_import_extra_data(data_dir, db_path)
