def compute_path(doc_id: str) -> str:
    return f"{doc_id[0:2]}/{doc_id[2:4]}/{doc_id}"


if __name__ == "__main__":
    import sys

    doc_id = sys.argv[1]
    print(compute_path(doc_id))
