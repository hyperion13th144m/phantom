import json
from importlib import resources


def get_config():
    j = (
        resources.files("mona")
        .joinpath("generated")
        .joinpath("config")
        .joinpath("storage-config.json")
    )
    with resources.as_file(j) as f:
        return json.load(f.open())


def compute_path(doc_id: str) -> str:
    cfg = get_config()
    p = cfg["pattern"]
    return p.format(doc_id[0], doc_id[1], doc_id[2], doc_id[3], docId=doc_id)


if __name__ == "__main__":
    import sys

    doc_id = sys.argv[1]
    print(compute_path(doc_id))
