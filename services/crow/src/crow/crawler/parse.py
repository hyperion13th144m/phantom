import tempfile
from pathlib import Path

from libefiling import Manifest
from queen.translate_all import DoctypePathMap, translate_all

from crow.crawler.merge_json import merge_jsons_as_array


def parse(src_dir: Path, dst_dir: Path):

    manifest_path = src_dir / "manifest.json"
    manifest = Manifest.model_validate_json(manifest_path.open(encoding="utf-8").read())

    with tempfile.TemporaryDirectory() as temp_dir:
        # images-information.json, bibliographic-items.json, full-text.json
        # are directly stored in dst_dir, and the rest are stored in temp_dir
        # and merged into document.json in dst_dir at the end

        dst_dir.mkdir(exist_ok=True, parents=True)
        doc_dir = Path(temp_dir)

        # setup output file names for each doctype
        doctype_path_map: DoctypePathMap = {
            "images-information": str(dst_dir / "images-information.json"),
            "bibliographic-items": str(dst_dir / "bibliographic-items.json"),
            "full-text": str(dst_dir / "full-text.json"),  # full_text_path,
            "application-body": str(doc_dir / "application-body.json"),
            "foreign-language-body": str(doc_dir / "foreign-language-body.json"),
            "pat-app-doc": str(doc_dir / "pat-app-doc.json"),
            "pat-amnd": str(doc_dir / "pat-amnd.json"),
            "pat-rspn": str(doc_dir / "pat-rspn.json"),
            "pat-etc": str(doc_dir / "pat-etc.json"),
            "cpy-notice-pat-exam": str(doc_dir / "cpy-notice-pat-exam.json"),
            "cpy-notice-pat-exam-rn": str(doc_dir / "cpy-notice-pat-exam-rn.json"),
            "cpy-notice-pat-frm": str(doc_dir / "cpy-notice-pat-frm.json"),
            "attaching-document": str(doc_dir / "attaching-document.json"),
        }

        xml_dir = src_dir / manifest.paths.xml_dir
        xml_files = [str(xml_dir / x.filename) for x in manifest.xml_files]
        translate_all(
            src_xml=xml_files, doctype_path_map=doctype_path_map, prettify=True
        )

        merge_jsons_as_array(
            [str(f) for f in doc_dir.glob("*.json")],
            str(dst_dir / "document.json"),
        )


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Parse the archive and output json files."
    )
    parser.add_argument("src_dir", type=Path, help="Path to the src dir.")
    parser.add_argument("dst_dir", type=Path, help="Path to the dst dir.")
    args = parser.parse_args()
    parse(src_dir=args.src_dir, dst_dir=args.dst_dir)
    from pathlib import Path

    p = Path("hoge")
