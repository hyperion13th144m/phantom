import json
import logging
import os
import sys
from pathlib import Path
from typing import Dict, List

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse

from mona.logger import setup_logger
from mona.models.documents import PatentDocument
from mona.models.generated.bibliographic_items import BibliographicItems
from mona.models.generated.full_text import FullText
from mona.models.generated.images_information import ImagesInformation


def create_app(data_dir: Path) -> FastAPI:
    app = FastAPI(title="mona API", version="0.1.0")

    dir_map = get_docid_dict(data_dir)
    logger.info(f"Loaded {len(dir_map)} documents from {data_dir}")

    @app.get("/documents/idList", response_model=list[str])
    async def get_documents_id_list() -> JSONResponse:
        keys = list(dir_map.keys())
        return JSONResponse(json.dumps(keys))

    @app.get(
        "/documents/{doc_id}/json/content",
        description="this returns the content of the document for rendering to html",
        response_model=List[PatentDocument],
    )
    async def get_document_file(doc_id: str) -> JSONResponse | FileResponse:
        return response(
            doc_id=doc_id,
            relative_path=Path("json/document.json"),
            media_type="application/json",
        )

    @app.get(
        "/documents/{doc_id}/json/images-information",
        description="this returns the image information of the document",
        response_model=ImagesInformation,
    )
    async def get_images_information(doc_id: str) -> JSONResponse | FileResponse:
        return response(
            doc_id=doc_id,
            relative_path=Path("json/images-information.json"),
            media_type="application/json",
        )

    @app.get(
        "/documents/{doc_id}/json/bibliographic-items",
        description="this returns the bibliographic items of the document",
        response_model=BibliographicItems,
    )
    async def get_bibliographic_items(doc_id: str) -> JSONResponse | FileResponse:
        return response(
            doc_id=doc_id,
            relative_path=Path("json/bibliographic-items.json"),
            media_type="application/json",
        )

    @app.get(
        "/documents/{doc_id}/json/full-text",
        description="this returns the full text of the document",
        response_model=FullText,
    )
    async def get_full_text(doc_id: str) -> JSONResponse | FileResponse:
        return response(
            doc_id=doc_id,
            relative_path=Path("json/full-text.json"),
            media_type="application/json",
        )

    @app.get(
        "/documents/{doc_id}/images/{file_name}",
        description="this returns the image body",
        response_model=None,  # 画像は response_model を定義しない (FileResponse で返すため)
    )
    async def get_image(doc_id: str, file_name: str) -> FileResponse | JSONResponse:
        return response(
            doc_id=doc_id,
            relative_path=Path("images") / file_name,
            media_type="image/webp",
        )

    def response(
        doc_id: str,
        relative_path: Path,
        media_type: str,
    ) -> JSONResponse | FileResponse:
        directory = dir_map.get(doc_id)
        if not directory:
            raise HTTPException(status_code=404, detail="Document ID not found")

        file_path = Path(directory) / relative_path
        if not file_path.exists():
            raise HTTPException(status_code=404, detail="File not found")

        if media_type == "application/json":
            return JSONResponse(json.loads(file_path.read_text()))
        elif media_type.startswith("image/"):
            return FileResponse(file_path, media_type=media_type)
        else:
            raise HTTPException(status_code=400, detail="Unsupported media type")

    return app


def get_docid_dict(data_dir: Path) -> Dict[str, str]:
    """
    this function returns dictionary mapping docId to directory
    containing files related to the docId.
    """
    results = {}
    for file in data_dir.rglob("manifest.json"):
        # search for directory contains manifest.json and read docId from it
        with file.open() as f:
            manifest = json.load(f)
            # treat sources.archive.sha256 as docId
            doc_id = manifest.get("sources", {}).get("archive", {}).get("sha256", None)
            if doc_id:
                results[doc_id] = str(file.parent)
    return results


data_dir = Path(os.environ.get("DATA_DIR", "/data-dir"))
log_dir = Path(os.environ.get("LOG_DIR", "/var/log/mona"))
log_level = os.environ.get("LOG_LEVEL", "INFO")

if data_dir is None:
    print("DATA_DIR environment variable is not set")
    sys.exit(1)

if not log_dir.is_dir():
    print("LOG_DIR environment variable is not set or is not a directory")
    sys.exit(1)

setup_logger(log_dir=Path(log_dir), log_level=log_level)
logger = logging.getLogger("mona.server")


app = create_app(data_dir)
