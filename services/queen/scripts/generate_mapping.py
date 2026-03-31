#!/usr/bin/env python3
"""
generate-mapping.py: JSON Schema から Elasticsearch インデックスマッピングを生成する

Usage:
    python generate-mapping.py [--schema SCHEMA] [--config CONFIG] [--output OUTPUT]

デフォルト変換ルール (mapping-config.json の field_overrides で上書き可能):
    string              -> keyword
    array of string     -> keyword  (ES は配列をネイティブにサポートするためフラット化)
    integer             -> long
    number              -> double
    boolean             -> boolean
    object              -> object (プロパティを再帰的に変換)
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent

DEFAULT_SCHEMA = REPO_ROOT / "generated" / "json-schema" / "full-text.json"
DEFAULT_CONFIG = SCRIPT_DIR / "mapping-config.json"
DEFAULT_OUTPUT = REPO_ROOT / "reference" / "document-mapping.json"

# JSON Schema type -> Elasticsearch type のデフォルト変換表
_DEFAULT_ES_TYPE: dict[str, dict[str, Any]] = {
    "string": {"type": "keyword"},
    "integer": {"type": "long"},
    "number": {"type": "double"},
    "boolean": {"type": "boolean"},
}


def _convert_property(field_name: str, prop: dict[str, Any]) -> dict[str, Any]:
    """
    JSON Schema のプロパティ定義を ES マッピングエントリに変換する。
    オーバーライドは呼び出し前に適用すること。
    """
    js_type = prop.get("type")

    # array -> items の型でフラット化 (ES は配列をネイティブサポート)
    if js_type == "array":
        items = prop.get("items", {})
        return _convert_property(field_name, items)

    # object -> 再帰的にプロパティを変換
    if js_type == "object":
        sub_props = prop.get("properties", {})
        es_obj: dict[str, Any] = {"type": "object"}
        if sub_props:
            es_obj["properties"] = {
                k: _convert_property(k, v) for k, v in sub_props.items()
            }
        return es_obj

    return _DEFAULT_ES_TYPE.get(js_type or "string", {"type": "keyword"})


def build_properties(
    schema_props: dict[str, Any],
    field_overrides: dict[str, Any],
    exclude_fields: list[str],
    extra_fields: dict[str, Any],
) -> dict[str, Any]:
    """
    JSON Schema の properties から ES mapping の properties を構築する。

    Args:
        schema_props: JSON Schema の properties オブジェクト
        field_overrides: フィールドごとの ES マッピング上書き (None でそのフィールドを除外)
        exclude_fields: マッピングから除外するフィールド名一覧
        extra_fields: JSON Schema にないが ES マッピングに追加するフィールド
    """
    result: dict[str, Any] = {}

    for field_name, prop_def in schema_props.items():
        # 明示的除外
        if field_name in exclude_fields:
            continue

        override = field_overrides.get(field_name)
        if override is None and field_name in field_overrides:
            # null が明示的にセットされている場合は除外
            continue

        if override is not None:
            result[field_name] = override
        else:
            result[field_name] = _convert_property(field_name, prop_def)

    # スキーマ外の追加フィールドを末尾に追加
    for field_name, mapping in extra_fields.items():
        result[field_name] = mapping

    return result


def main() -> None:
    parser = argparse.ArgumentParser(
        description="JSON Schema から Elasticsearch マッピングを生成する"
    )
    parser.add_argument(
        "--schema",
        default=str(DEFAULT_SCHEMA),
        help=f"JSON Schema ファイルのパス (デフォルト: {DEFAULT_SCHEMA})",
    )
    parser.add_argument(
        "--config",
        default=str(DEFAULT_CONFIG),
        help=f"マッピング設定ファイルのパス (デフォルト: {DEFAULT_CONFIG})",
    )
    parser.add_argument(
        "--output",
        default=str(DEFAULT_OUTPUT),
        help=f"出力先マッピング JSON ファイルのパス (デフォルト: {DEFAULT_OUTPUT})",
    )
    args = parser.parse_args()

    schema_path = Path(args.schema)
    config_path = Path(args.config)
    output_path = Path(args.output)

    if not schema_path.exists():
        print(f"ERROR: schema file not found: {schema_path}", file=sys.stderr)
        sys.exit(1)
    if not config_path.exists():
        print(f"ERROR: config file not found: {config_path}", file=sys.stderr)
        sys.exit(1)

    schema: dict[str, Any] = json.loads(schema_path.read_text(encoding="utf-8"))
    config: dict[str, Any] = json.loads(config_path.read_text(encoding="utf-8"))

    settings: dict[str, Any] = config.get("settings", {})
    field_overrides: dict[str, Any] = config.get("field_overrides", {})
    exclude_fields: list[str] = config.get("exclude_fields", [])
    extra_fields: dict[str, Any] = config.get("extra_fields", {})

    schema_props: dict[str, Any] = schema.get("properties", {})

    properties = build_properties(
        schema_props, field_overrides, exclude_fields, extra_fields
    )

    mapping: dict[str, Any] = {
        "settings": settings,
        "mappings": {"properties": properties},
    }

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(mapping, indent=4, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"Generated: {output_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
