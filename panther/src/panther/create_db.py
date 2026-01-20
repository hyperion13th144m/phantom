"""
SQLiteデータベースにpatentDocumentテーブルを作成し、
document.jsonファイルからデータをインポートするスクリプト
"""

import sqlite3


def cmd_create_db(db_path: str = "patent.db"):
    """
    patentDocumentテーブルを作成する

    Args:
        db_path: データベースファイルのパス（デフォルト: patent.db）
    """
    # データベースに接続
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # テーブル作成SQL
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS patentDocument (
        docId TEXT PRIMARY KEY,
        law TEXT,
        appNumber TEXT,
        fileReferenceId TEXT,
        applicants TEXT,
        inventors TEXT,
        assignees TEXT,
        tags TEXT
    )
    """

    try:
        # テーブルを作成
        cursor.execute(create_table_sql)
        conn.commit()
        print(f"✓ テーブル 'patentDocument' を作成しました（データベース: {db_path}）")

        # テーブル情報を表示
        cursor.execute("PRAGMA table_info(patentDocument)")
        columns = cursor.fetchall()
        print("\nカラム情報:")
        for col in columns:
            print(f"  - {col[1]} ({col[2]}){' PRIMARY KEY' if col[5] else ''}")

        return 0

    except sqlite3.Error as e:
        print(f"✗ エラーが発生しました: {e}")
        return 1
    finally:
        conn.close()


if __name__ == "__main__":
    # データベースファイルのパスを指定（必要に応じて変更）
    db_path = "patent.db"
    data_dir = "/data_dir"

    # テーブルを作成
    cmd_create_db(db_path)
