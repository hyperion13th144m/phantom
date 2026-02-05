#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# -----------------------------
# 1) Input: document.json を受けるモデル
# -----------------------------

from __future__ import annotations

from typing import List, Literal, Optional

from pydantic import BaseModel, ConfigDict, Field, ValidationError


class TextFields(BaseModel):
    inventionTitle: Optional[str] = None
    technicalField: Optional[str] = None
    backgroundArt: Optional[str] = None
    techProblem: Optional[str] = None
    techSolution: Optional[str] = None
    advantageousEffects: Optional[str] = None
    embodiments: Optional[str] = None
    industrialApplicability: Optional[str] = None
    referenceToDepositedBiologicalMaterial: Optional[str] = None
    lawOfIndustrialRegenerate: Optional[str] = None
    independentClaims: Optional[List[str]] = None
    dependentClaims: Optional[List[str]] = None
    abstract: Optional[str] = None
    applicants: Optional[List[str]] = None
    inventors: Optional[List[str]] = None
    agents: Optional[List[str]] = None
    specialMentionMatterArticle: Optional[List[str]] = None
    conclusionPartArticle: Optional[str] = None
    draftingBody: Optional[str] = None
    contentsOfAmendment: Optional[List[str]] = None
    opinionContentsArticle: Optional[str] = None
    rejectionReasonArticle: Optional[List[str]] = None


class DocumentJson(BaseModel):
    """
    phantom/mona が出力した document.json の受け口。
    ここは「入力に合わせる」層なので、extra='allow' で未知キーを許容しがち。
    """

    model_config = ConfigDict(extra="allow")

    docId: str = Field(..., alias="docId")

    # 元データの情報
    sources: List[SourceFileInfo] = Field(default_factory=list)

    # 法域
    law: Literal["patent", "utilityModel", "design", "trademark"] = Field(
        ..., alias="law"
    )

    # 文書名関連
    documentName: str = Field(..., alias="documentName")
    documentCode: str = Field(..., alias="documentCode")

    # 各種番号
    fileReferenceId: Optional[str] = Field(None, alias="fileReferenceId")
    applicationNumber: Optional[str] = Field(None, alias="applicationNumber")
    internationalApplicationNumber: Optional[str] = Field(
        None, alias="internationalApplicationNumber"
    )
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
    blocks: List[TextBlock] = Field(default_factory=list)

    # text fields for fulltext search
    fields: TextFields = Field(default_factory=TextFields)


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
    indentLevel: Optional[str] = (
        None  # 元JSONでは文字列のことがあるので Optional[str] が安全
    )

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
