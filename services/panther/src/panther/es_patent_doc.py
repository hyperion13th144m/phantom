#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field, ValidationError


class ImageInfo(BaseModel):
    filename: str
    width: int
    height: int
    number: str
    kind: str
    representative: bool
    description: Optional[str] = None
    sizeTag: str


# -----------------------------
# 2) ES投入用モデル（最終形を固定）
# -----------------------------
class EsPatentDoc(BaseModel):
    """
    Elasticsearch に投入する最終スキーマ。
    ここは extra='forbid' にして「想定外を入れない」方が運用が安定します。
    """

    model_config = ConfigDict(extra="forbid")

    docId: str

    task: str
    kind: str
    law: str
    extension: str
    documentName: str
    documentCode: str

    # 各種番号
    fileReferenceId: Optional[str] = None
    applicationNumber: Optional[str] = None
    internationalApplicationNumber: Optional[str] = None
    registrationNumber: Optional[str] = None
    appealReferenceNumber: Optional[str] = None
    receiptNumber: Optional[str] = None

    # 日付
    date: Optional[str] = None
    # submissionDate: Optional[str] = None
    # dispatchDate: Optional[str] = None
    # 上二つのどちらか。date = submissionDate or dispatchDate として使う。両方ない場合は None。

    # ocr text
    ocrText: Optional[str] = None

    # 以下、変換で作る派生・正規化フィールド
    ### 願書など書誌事項から取れるフィールド群
    applicants: Optional[List[str]] = Field(default_factory=list)
    inventors: Optional[List[str]] = Field(default_factory=list)
    agents: Optional[List[str]] = Field(default_factory=list)
    specialMentionMatterArticle: Optional[List[str]] = Field(default_factory=list)
    lawOfIndustrialRegenerate: Optional[str] = None
    priorityClaims: Optional[List[str]] = Field(default_factory=list)

    ### 明細書関連フィールド
    inventionTitle: Optional[str] = None
    technicalField: Optional[str] = None
    backgroundArt: Optional[str] = None
    techProblem: Optional[str] = None
    techSolution: Optional[str] = None
    advantageousEffects: Optional[str] = None
    embodiments: Optional[str] = None
    industrialApplicability: Optional[str] = None
    referenceToDepositedBiologicalMaterial: Optional[str] = None

    ### 請求の範囲・要約書関連フィールド
    independentClaims: Optional[List[str]] = Field(default_factory=list)
    dependentClaims: Optional[List[str]] = Field(default_factory=list)
    abstract: Optional[str] = None

    ### 拒絶理由、拒絶査定関連フィールド
    conclusionPartArticle: Optional[str] = None
    draftingBody: Optional[str] = None
    rejectionReasonArticle: Optional[List[str]] = Field(default_factory=list)

    ### 意見書、補正書関連フィールド
    opinionContentsArticle: Optional[str] = None
    contentsOfAmendment: Optional[List[str]] = Field(default_factory=list)

    # document.json ではアップロードしない。sqliteから取ってくる。
    assignees: Optional[List[str]] = Field(default_factory=list)
    tags: Optional[List[str]] = Field(default_factory=list)
    extraNumbers: Optional[List[str]] = Field(default_factory=list)


if __name__ == "__main__":
    pass
