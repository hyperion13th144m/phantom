"""
SQLiteデータベースにpatentDocumentテーブルを作成し、
document.jsonファイルからデータをインポートするスクリプト
"""

import json
import logging
import sqlite3
from pathlib import Path
from typing import Any, Dict

from panther.document_json import DocumentJson
from panther.patent_doc_editor import PatentDocEditor

logger = logging.getLogger(__name__)


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
        applicants = doc_data.get("applicants") or []
        inventors = doc_data.get("inventors") or []
        appNumber = (
            doc_data.get("applicationNumber")
            or doc_data.get("internationalApplicationNumber")
            or doc_data.get("receiptNumber")
            or ""
        )
        cursor.execute(
            """
            INSERT INTO patentDocument (
                docId, law, appNumber, fileReferenceId,
                applicants, inventors
            ) VALUES (?, ?, ?, ?, ?, ?)
        """,
            (
                doc_data.get("docId"),
                doc_data.get("law"),
                appNumber,
                doc_data.get("fileReferenceId") or "",
                ",".join(applicants),
                ",".join(inventors),
            ),
        )
        return True
    except sqlite3.Error as e:
        logger.error(f"  ✗ 挿入エラー: {e}")
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
        logger.error(f"✗ ディレクトリが見つかりません: {data_dir}")
        return

    # document.jsonファイルを再帰的に検索
    json_files = list(data_path.rglob("document.json"))

    if not json_files:
        logger.error(f"✗ document.jsonが見つかりませんでした: {data_dir}")
        return

    logger.info(f"✓ {len(json_files)}個のdocument.jsonを見つけました")

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
                with open(json_file, "r", encoding="utf-8") as f:
                    data = json.load(f)

                _doc_data = DocumentJson(**data)
                editor = PatentDocEditor(src=_doc_data)
                doc_data = editor.to_es_model()

                doc_id = doc_data.docId

                if not doc_id:
                    logger.warning(f"  ⚠ docIdがありません: {json_file}")
                    error_count += 1
                    continue

                # docIdの存在チェック
                if check_doc_exists(cursor, doc_id):
                    logger.info(f"  ⊘ スキップ (既存): {doc_id} ({json_file})")
                    skipped_count += 1
                else:
                    # データを挿入
                    if insert_document(cursor, doc_data.model_dump()):
                        logger.info(f"  ✓ 挿入成功: {doc_id} ({json_file})")
                        inserted_count += 1
                    else:
                        error_count += 1

            except json.JSONDecodeError as e:
                logger.error(f"  ✗ JSON読み取りエラー: {json_file} - {e}")
                error_count += 1
            except Exception as e:
                logger.error(f"  ✗ エラー: {json_file} - {e}")
                error_count += 1

        # コミット
        conn.commit()

        # サマリーを表示
        logger.info(f"\n{'='*60}")
        logger.info(f"処理完了:")
        logger.info(f"  挿入: {inserted_count}件")
        logger.info(f"  スキップ: {skipped_count}件")
        logger.info(f"  エラー: {error_count}件")
        logger.info(f"{'='*60}")

    except Exception as e:
        logger.error(f"✗ 予期しないエラー: {e}")
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
