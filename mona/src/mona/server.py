import json
import logging
from pathlib import Path
from typing import Dict, List, Optional

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from pydantic import BaseModel

from mona.generated.bibliographic_items import BibliographicItems
from mona.generated.full_text import FullText
from mona.generated.images_information import ImagesInformation
from mona.logger import setup_logger


### PatentDocument は PatAppDoc などの構造であるが、
### ここでは全プロパティを optional として定義する。
### 正確に PatAppDoc の構造を定義することも可能だが、
### 再帰が深く、/docs の参照で固まる。
### どうせ API を利用する側で 自動生成したインタフェースを利用するから
### fastapi の response_model は簡単に。
class PatentDocument(BaseModel):
    tag: str
    jpTag: Optional[str]
    indentLevel: Optional[str]
    text: Optional[str]
    convertedText: Optional[str]
    number: Optional[str]
    imageKind: Optional[str]
    file: Optional[str]
    isLastSentence: Optional[bool]
    isIndependent: Optional[bool]
    blocks: Optional[List["PatentDocument"]]


PatentDocument.model_rebuild()

setup_logger()
logger = logging.getLogger("mona.server")

# 画像以外の API はあとで response model を定義して response_model=XXX とする予定


def create_app(data_dir: str = "/data-dir") -> FastAPI:
    app = FastAPI(title="mona API", version="0.1.0")
    dir_map = get_docid_dict(data_dir)

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

    @app.get("/")
    async def root() -> dict[str, str]:
        logger.info("Root endpoint accessed")
        return {"message": "mona API server is running"}

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

    return app


def get_docid_dict(data_dir: str) -> Dict[str, str]:
    """
    this function returns dictionary mapping docId to directory
    containing files related to the docId.
    """
    results = {}
    for file in Path(data_dir).rglob("manifest.json"):
        # search for directory contains manifest.json and read docId from it
        with file.open() as f:
            manifest = json.load(f)
            doc_id = manifest.get("document", {}).get("doc_id", None)
            if doc_id:
                results[doc_id] = str(file.parent)
    return results


app = create_app()
