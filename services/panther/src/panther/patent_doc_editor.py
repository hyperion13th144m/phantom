#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from typing import Optional

from pydantic import ValidationError

from panther.es_patent_doc import EsPatentDoc
from panther.models.generated.full_text import FullText
from panther.normalize import zenkaku_to_hankaku_all


# -----------------------------
# 3) 編集（変換）用クラス
# -----------------------------
@dataclass(frozen=True)
class PatentDocEditor:
    full_text: FullText

    def to_es_model(self) -> EsPatentDoc:
        # unix epoch seconds to milis
        ### 発送系の jp:file-reference-id は全角になっていることがあるので、半角に変換してからESに入れる。
        fileReferenceId = zenkaku_to_hankaku_all(self.full_text.fileReferenceId or "")
        rejectionReasonArticle = [
            rewrite_rejection_reason_article(r)
            for r in self.full_text.rejectionReasonArticle or []
            if r and r.strip()
        ]
        return EsPatentDoc(
            docId=self.full_text.docId,
            task=self.full_text.task,
            kind=self.full_text.kind,
            extension=self.full_text.extension,
            law=self.full_text.law.value,
            documentName=self.full_text.documentName,
            documentCode=self.full_text.documentCode,
            fileReferenceId=fileReferenceId,
            applicationNumber=self.full_text.applicationNumber,
            internationalApplicationNumber=self.full_text.internationalApplicationNumber,
            registrationNumber=self.full_text.registrationNumber,
            appealReferenceNumber=self.full_text.appealReferenceNumber,
            receiptNumber=self.full_text.receiptNumber,
            datetime=self.full_text.datetime,
            inventors=self.full_text.inventors,
            applicants=self.full_text.applicants,
            agents=self.full_text.agents,
            specialMentionMatterArticle=self.full_text.specialMentionMatterArticle,
            inventionTitle=self.full_text.inventionTitle,
            technicalField=self.full_text.technicalField,
            backgroundArt=self.full_text.backgroundArt,
            techProblem=self.full_text.techProblem,
            techSolution=self.full_text.techSolution,
            advantageousEffects=self.full_text.advantageousEffects,
            embodiments=self.full_text.embodiments,
            industrialApplicability=self.full_text.industrialApplicability,
            referenceToDepositedBiologicalMaterial=self.full_text.referenceToDepositedBiologicalMaterial,
            lawOfIndustrialRegenerate=self.full_text.lawOfIndustrialRegenerate,
            independentClaims=self.full_text.independentClaims,
            dependentClaims=self.full_text.dependentClaims,
            abstract=self.full_text.abstract,
            conclusionPartArticle=self.full_text.conclusionPartArticle,
            draftingBody=self.full_text.draftingBody,
            rejectionReasonArticle=rejectionReasonArticle,
            opinionContentsArticle=self.full_text.opinionContentsArticle,
            contentsOfAmendment=self.full_text.contentsOfAmendment,
            priorityClaims=self.full_text.priorityClaims,
            ocrText=self.full_text.ocrText,
        )

    @staticmethod
    def _none_if_blank(s: Optional[str]) -> Optional[str]:
        if s is None:
            return None
        s2 = s.strip()
        return s2 if s2 else None


def rewrite_rejection_reason_article(text: str) -> str:
    reason_pattern = [
        {
            "pattern": r"^第１７条の２第３項$",
            "replacement": "第１７条の２第３項（新規事項）",
        },
        {"pattern": r"^第２９条の２$", "replacement": "第２９条の２（拡大先願）"},
        {"pattern": r"^第２９条第２項$", "replacement": "第２９条第２項（進歩性）"},
        {"pattern": r"^第３７条$", "replacement": "第３７条（単一性）"},
    ]
    for reason in reason_pattern:
        if re.match(reason["pattern"], text):
            return reason["replacement"]
    else:
        return text


if __name__ == "__main__":
    import json
    import sys

    # Example usage
    # bibliography.json
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        bib = json.load(f)

    # full-text.json
    with open(sys.argv[2], "r", encoding="utf-8") as f:
        full_text = json.load(f)

    # images-information.json
    with open(sys.argv[3], "r", encoding="utf-8") as f:
        images_info = json.load(f)

    try:
        full_text = FullText(**full_text)
        editor = PatentDocEditor(full_text=full_text)
        es_doc = editor.to_es_model()
        print(es_doc.model_dump_json(indent=2, ensure_ascii=False))
    except ValidationError as e:
        print("Validation error:", e)
        sys.exit(1)
