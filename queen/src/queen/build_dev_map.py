import json
import os
import tempfile

import saxonche

def main(data_dir: str, config_path: str, template_path: str, mode: str) -> None:
    """build devMap in `config_path` json
    
    find 'manifest.json' in data_dir recursively.
    read docId from the manifest.json
    build devMap as following
    devMap ={
        [docId]: [path to the directory containing manifest.json]
    }
    put devMap into config_path json

    Args:
        data_dir (str): root dir to search for manifest.json files
        config_path (str): path to the JSON config file to update
        template_path (str): path to the JSON template config file to be referenced when updating config_path
        mode (str): "dev" or "prod", to be added to config_path json
    """
    # Load existing config
    if os.path.isfile(template_path):
        with open(template_path, "r", encoding="utf-8") as f:
            config = json.load(f)
    else:
        config = {}

    dev_map = {}
    if mode == "dev":
        for root, dirs, files in os.walk(data_dir):
            if "manifest.json" in files:
                manifest_path = os.path.join(root, "manifest.json")
                with open(manifest_path, "r", encoding="utf-8") as f:
                    manifest = json.load(f)
                    doc_id = manifest.get("document", {}).get("doc_id")
                    if doc_id:
                        dev_map[doc_id] = os.path.relpath(root, data_dir)

    # Update devMap in config
    config["devMap"] = dev_map

    # add mode
    config["mode"] = mode
    
    # Save updated config
    with open(config_path, "w", encoding="utf-8") as f:
        json.dump(config, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Build devMap in config JSON")
    parser.add_argument("data_dir", help="Root directory to search for manifest.json files")
    parser.add_argument("config_path", help="Path to the JSON config file to update")
    parser.add_argument("template_path", help="Path to the JSON template config file to be referenced when updating config_path")
    parser.add_argument("--mode", choices=["dev", "prod"], default="prod")
    args = parser.parse_args()
    main(args.data_dir, args.config_path, args.template_path, args.mode)
