#!/usr/bin/env python3
"""
Convert JSON Schema to JSON Schema with camelCase or snake_case property names.
"""

import json
import sys
import re
from pathlib import Path


def to_camel_case(text: str) -> str:
    """Convert snake_case string to camelCase."""
    components = text.split('_')
    # Keep the first component as-is, capitalize the rest
    return components[0] + ''.join(x.title() for x in components[1:])


def to_snake_case(text: str) -> str:
    """Convert camelCase string to snake_case."""
    # Insert underscore before uppercase letters (except at the start)
    text = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', text)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', text).lower()


def convert_keys(schema, converter_func):
    """
    Recursively convert all object keys in a JSON Schema.
    
    This function converts keys while preserving special handling for:
    - properties: Converts property names
    - $defs: Converts definition names
    - required: Converts list items (required property names)
    - $ref: Converts the last part of the reference path
    """
    if isinstance(schema, list):
        return [convert_keys(item, converter_func) for item in schema]
    elif isinstance(schema, dict):
        new_obj = {}
        for key, value in schema.items():
            if key == 'properties' and isinstance(value, dict):
                new_props = {}
                for prop_key, prop_value in value.items():
                    new_props[converter_func(prop_key)] = convert_keys(prop_value, converter_func)
                new_obj[key] = new_props
            elif key == '$defs' and isinstance(value, dict):
                new_props = {}
                for prop_key, prop_value in value.items():
                    new_props[converter_func(prop_key)] = convert_keys(prop_value, converter_func)
                new_obj[key] = new_props
            elif key == 'required' and isinstance(value, list):
                new_obj[key] = [converter_func(item) for item in value]
            elif key == '$ref' and isinstance(value, str):
                ref_parts = value.split('/')
                ref_parts[-1] = converter_func(ref_parts[-1])
                new_obj[key] = '/'.join(ref_parts)
            else:
                new_obj[key] = convert_keys(value, converter_func)
        return new_obj
    else:
        return schema


def main():
    # Parse command line arguments
    src_path = sys.argv[1] if len(sys.argv) > 1 else 'example.schema.json'
    dst_path = sys.argv[2] if len(sys.argv) > 2 else 'example.camelCase.json'
    converter_type = sys.argv[3] if len(sys.argv) > 3 else 'camelCase'

    # Select converter function
    if converter_type == 'camelCase':
        converter_func = to_camel_case
    elif converter_type == 'snake_case':
        converter_func = to_snake_case
    else:
        converter_func = lambda s: s

    try:
        # Read source JSON
        with open(src_path, 'r', encoding='utf-8') as f:
            src_json = json.load(f)

        # Convert keys
        converted_schema = convert_keys(src_json, converter_func)

        # Write output JSON
        with open(dst_path, 'w', encoding='utf-8') as f:
            json.dump(converted_schema, f, indent=2, ensure_ascii=False)

        print(f"✅ Converted JSON Schema generated: {dst_path}")
    except FileNotFoundError:
        print(f"❌ Error: Cannot find source file: {src_path}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"❌ Error decoding JSON: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
