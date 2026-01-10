"""document.json の型定義"""

from typing import Any, Literal, NotRequired, TypedDict


class TextBlock(TypedDict):
    """テキストブロックの型定義"""

    tag: str
    text: NotRequired[str]
    jpTag: NotRequired[str]
    convertedText: NotRequired[str]
    indentLevel: NotRequired[str]
    number: NotRequired[str]
    isLastSentence: NotRequired[bool]
    blocks: NotRequired[list["TextBlock"]]


class TextBlockRoot(TypedDict):
    """ルートレベルのテキストブロックの型定義"""

    tag: str
    jpTag: NotRequired[str]
    blocks: list[TextBlock]

class Image(TypedDict):
    """画像ブロックの型定義"""

    number: str
    filename: str
    kind: str
    sizeTag: str
    width: int
    height: int
    representative: bool
    description: str | None

class Document(TypedDict):
    """document.json 全体の型定義"""

    docId: str
    archive: str
    procedure: str
    schemaVer: str
    ext: str
    kind: str
    task: str
    law: str
    documentName: str
    documentCode: str
    fileReferenceId: str | None
    registrationNumber: str | None
    applicationNumber: str | None
    internationalApplicationNumber: str | None
    appealReferenceNumber: str | None
    submissionDate: str
    submissionTime: str
    receiptNumber: str
    textBlocksRoot: list[TextBlockRoot]
    image: list[Image]
    ocrText: str
