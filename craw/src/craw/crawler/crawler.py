import shutil
import traceback
from pathlib import Path
from typing import List, Literal, Optional

from libefiling import generate_sha256, parse_archive
from pydantic import BaseModel

from craw.crawler.config import image_params
from craw.crawler.find_archives import find_archives
from craw.crawler.parse import parse


class Result(BaseModel):
    status: Literal["success", "fail", "skip"]
    doc_id: Optional[str] = None
    archive_path: Path
    output_json_dir: Optional[str] = None
    error_message: Optional[str] = None


def crawl(
    src_dir: str,
    output_dir_root: str,
    overwrite: bool,
    doc_codes: Optional[List[str]] = None,
    doc_id: Optional[str] = None,
    max_files: Optional[int] = None,
):
    count = 0
    for item in find_archives(src_dir, doc_codes or []):
        if max_files and count >= max_files:
            break

        archive_path, procedure_path = item

        # ドキュメントIDが指定されている場合、ID(SHA256ハッシュ)が一致しないアーカイブはスキップ
        if doc_id and generate_sha256(str(archive_path)) != doc_id:
            continue

        status = convert(archive_path, procedure_path, Path(output_dir_root), overwrite)
        yield status

        # ドキュメントIDが指定されている場合、処理後にもうfind_archivesする
        # 必要はないので、ループを抜ける
        if doc_id and status.doc_id == doc_id:
            break

        count += 1


def convert(
    archive_path: Path, procedure_path: Path, output_dir_root: Path, overwrite: bool
):
    extracted_dir = None
    output_json_dir = None
    try:
        ### check if already processed
        doc_id = generate_sha256(str(archive_path))
        extracted_dir = get_output_dir(doc_id, output_dir_root)
        output_json_dir = extracted_dir / "json"
        if overwrite is False and extracted_dir.exists():
            return Result(
                doc_id=doc_id,
                archive_path=archive_path,
                output_json_dir=str(output_json_dir),
                status="skip",
                error_message="Already processed",
            )
        if overwrite is True and extracted_dir.exists():
            shutil.rmtree(extracted_dir)

        extracted_dir.mkdir(parents=True, exist_ok=True)

        ### OCR 対象は other-imagesだけ。
        ### other-images は 外国語書面出願、被引用文献 で使われる画像
        parse_archive(
            str(archive_path),
            str(procedure_path),
            str(extracted_dir),
            image_params=image_params,
            ocr_target=["other-images"],
            image_max_workers=0,
        )

        parse(extracted_dir, output_json_dir)
        return Result(
            doc_id=doc_id,
            archive_path=archive_path,
            output_json_dir=str(output_json_dir),
            status="success",
        )
    except Exception:
        if extracted_dir and extracted_dir.exists():
            shutil.rmtree(extracted_dir)
        return Result(
            archive_path=archive_path,
            status="fail",
            error_message=traceback.format_exc(),
        )


def get_output_dir(doc_id: str, base_dir: Path) -> Path:
    """Convert document ID to directory path."""
    return base_dir / f"{doc_id[0:2]}/{doc_id[2:4]}/{doc_id}"
