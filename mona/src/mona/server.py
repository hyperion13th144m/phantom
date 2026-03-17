import json
from pathlib import Path
from typing import Dict, Iterator

from fastapi import FastAPI
from fastapi.responses import StreamingResponse


def create_app(data_dir: str = "/data-dir") -> FastAPI:
    app = FastAPI(title="mona API", version="0.1.0")
    mapping = get_docid_dict(data_dir)

    def build_not_found_response(message: str) -> StreamingResponse:
        return StreamingResponse(
            iter([json.dumps({"error": message})]),
            media_type="application/json",
            status_code=404,
        )

    def stream_document_file(
        doc_id: str,
        relative_path: Path,
        media_type: str,
        mode: str,
    ) -> StreamingResponse:
        directory = mapping.get(doc_id)
        if not directory:
            return build_not_found_response("Document ID not found")

        file_path = Path(directory) / relative_path
        if not file_path.exists():
            return build_not_found_response("File not found")

        return StreamingResponse(file_path.open(mode), media_type=media_type)

    @app.get("/")
    async def root() -> dict[str, str]:
        return {"message": "mona API server is running"}

    @app.get("/documents/idList")
    async def get_documents_id_list() -> StreamingResponse:
        return StreamingResponse(
            get_all_documents_id(mapping),  # ジェネレータ関数を指定
            media_type="application/json",
        )

    @app.get(
        "/documents/{doc_id}/json/content",
        description="end point returning the content of the document corresponding to the document ID",
    )
    async def get_document_file(doc_id: str) -> StreamingResponse:
        return stream_document_file(
            doc_id=doc_id,
            relative_path=Path("json/document.json"),
            media_type="application/json",
            mode="r",
        )

    @app.get(
        "/documents/{doc_id}/json/images-information",
        description="end point returning the image information of the document corresponding to the document ID",
    )
    async def get_images_information(doc_id: str) -> StreamingResponse:
        return stream_document_file(
            doc_id=doc_id,
            relative_path=Path("json/images-information.json"),
            media_type="application/json",
            mode="r",
        )

    @app.get(
        "/documents/{doc_id}/json/bibliography",
        description="end point returning the bibliographic items of the document corresponding to the document ID",
    )
    async def get_bibliographic_items(doc_id: str) -> StreamingResponse:
        return stream_document_file(
            doc_id=doc_id,
            relative_path=Path("json/bibliography.json"),
            media_type="application/json",
            mode="r",
        )

    @app.get(
        "/documents/{doc_id}/json/full-text",
        description="end point returning the full text of the document corresponding to the document ID",
    )
    async def get_full_text(doc_id: str) -> StreamingResponse:
        return stream_document_file(
            doc_id=doc_id,
            relative_path=Path("json/full-text.json"),
            media_type="application/json",
            mode="r",
        )

    @app.get(
        "/documents/{doc_id}/images/{file_name}",
        description="end point returning the image corresponding to the document ID and the file name",
    )
    async def get_image(doc_id: str, file_name: str) -> StreamingResponse:
        return stream_document_file(
            doc_id=doc_id,
            relative_path=Path("images") / file_name,
            media_type="image/webp",
            mode="rb",
        )

    return app


def get_all_documents_id(mapping: Dict[str, str]) -> Iterator[str]:
    """この関数は、ドキュメントIDのリストを生成するジェネレータ関数です。"""
    for doc_id in mapping.keys():
        yield f'{{"doc_id": "{doc_id}"}}\n'


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


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("mona.server:app", host="0.0.0.0", port=8000, reload=True)
