#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Literal, Optional

from pydantic import BaseModel, ConfigDict, Field, ValidationError


# -----------------------------
# 1) Input: document.json を受けるモデル
# -----------------------------
class DocumentJson(BaseModel):
    """
    libefiling が出力した document.json の受け口。
    ここは「入力に合わせる」層なので、extra='allow' で未知キーを許容しがち。
    """
    model_config = ConfigDict(extra="allow")

    docId: str = Field(..., alias="docId")

    # 元データの情報
    sources: List[SourceFileInfo] = Field(default_factory=list)

    # 法域
    law: Literal["patent", "utilityModel", "design", "trademark"] = Field(..., alias="law")

    # 文書名関連
    documentName: str = Field(..., alias="documentName")
    documentCode: str = Field(..., alias="documentCode")

    # 各種番号
    fileReferenceId: Optional[str] = Field(None, alias="fileReferenceId")
    applicationNumber: Optional[str] = Field(None, alias="applicationNumber")
    internationalApplicationNumber: Optional[str] = Field(None, alias="internationalApplicationNumber")
    registrationNumber: Optional[str] = Field(None, alias="registrationNumber")
    appealReferenceNumber: Optional[str] = Field(None, alias="appealReferenceNumber")
    receiptNumber: Optional[str] = Field(None, alias="receiptNumber")

    # 日付
    submissionDate: Optional[str] = Field(None, alias="submissionDate")
    submissionTime: Optional[str] = Field(None, alias="submissionTime")
    dispatchDate: Optional[str] = Field(None, alias="dispatchDate")
    dispatchTime: Optional[str] = Field(None, alias="dispatchTime")
     
    # 画像
    images: List[ImageInfo] = Field(default_factory=list)
    
    # ocr text
    ocrText: Optional[str] = None

    # text blocks
    textBlocksRoot: List[TextBlock] = Field(default_factory=list)

class SourceFileInfo(BaseModel):
    filename: str
    sha256: str
    byte_size: int
    task: str
    kind: str
    extension: str

class ImageInfo(BaseModel):
    number: str
    filename: str
    kind: str
    sizeTag: str
    width: int
    height: int
    representative: bool
    description: Optional[str] = None
 
class TextBlock(BaseModel):
    model_config = ConfigDict(extra="allow")

    tag: Optional[str] = None
    jpTag: Optional[str] = None
    text: Optional[str] = None
    convertedText: Optional[str] = None
    indentLevel: Optional[str] = None  # 元JSONでは文字列のことがあるので Optional[str] が安全

    blocks: List["TextBlock"] = Field(default_factory=list)

# resolve forward references
TextBlock.model_rebuild()

if __name__ == "__main__":
    import json
    import sys

    # Example usage
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        data = json.load(f)

    try:
        doc = DocumentJson(**data)
        print(doc)
    except ValidationError as e:
        print("Validation error:", e)
        sys.exit(1)
