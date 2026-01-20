#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field, ValidationError

from .document_json import ImageInfo


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
    documentName: str
    documentCode: str

    # 各種番号
    fileReferenceId: Optional[str] = None
    applicationNumber: Optional[str] = None
    internationalApplicationNumber: Optional[str] = None
    registrationNumber: Optional[str] = None
    appealReferenceNumber: Optional[str] = None

    # 日付
    submissionDate: Optional[str] = None
    dispatchDate: Optional[str] = None
 
    # 画像
    images: List[ImageInfo] = Field(default_factory=list)

    # ocr text
    ocrText: Optional[str] = None

    # 以下、変換で作る派生・正規化フィールド
    ### 願書など書誌事項から取れるフィールド群
    applicants: List[str] = Field(default_factory=list)
    inventors: List[str] = Field(default_factory=list)
    agents: List[str] = Field(default_factory=list)
    specialMentionMatterArticle: List[str] = Field(default_factory=list)
    lawOfIndustrialRegenerate: Optional[str] = None

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
    independentClaims: Optional[str] = None
    dependentClaims: Optional[str] = None
    abstract: Optional[str] = None

    ### 拒絶理由、拒絶査定関連フィールド
    conclusionPartArticle: Optional[str] = None
    draftingBody: Optional[str] = None
    rejectionReasonArticle: List[str] = Field(default_factory=list)

    # document.json ではアップロードしない。sqliteから取ってくる。
    assignee: List[str] = Field(default_factory=list)
    tags: List[str] = Field(default_factory=list)


if __name__ == "__main__":
    pass
