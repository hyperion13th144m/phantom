#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional
from zoneinfo import ZoneInfo

from pydantic import ValidationError

from panther.document_json import DocumentJson, SourceFileInfo, TextBlock
from panther.es_patent_doc import EsPatentDoc


# -----------------------------
# 3) 編集（変換）用クラス
# -----------------------------
@dataclass(frozen=True)
class PatentDocEditor:
    src: DocumentJson

    def to_es_model(self) -> EsPatentDoc:
        task, kind = extract_from_sources(self.src.sources)
        return EsPatentDoc(
            docId=self.src.docId,
            task=task,
            kind=kind,
            law=self.src.law,
            documentName=self.src.documentName,
            documentCode=self.src.documentCode,
            fileReferenceId=self.src.fileReferenceId,
            applicationNumber=self._none_if_blank(self.src.applicationNumber),
            internationalApplicationNumber=self._none_if_blank(
                self.src.internationalApplicationNumber
            ),
            registrationNumber=self._none_if_blank(self.src.registrationNumber),
            appealReferenceNumber=self._none_if_blank(self.src.appealReferenceNumber),
            submissionDate=get_date(self.src.submissionDate, self.src.submissionTime),
            dispatchDate=get_date(self.src.dispatchDate, self.src.dispatchTime),
            images=self.src.images,
            ocrText=self._none_if_blank(self.src.ocrText),
            inventors=self.src.fields.inventors,
            applicants=self.src.fields.applicants,
            agents=self.src.fields.agents,
            specialMentionMatterArticle=self.src.fields.specialMentionMatterArticle,
            inventionTitle=self.src.fields.inventionTitle,
            technicalField=self.src.fields.technicalField,
            backgroundArt=self.src.fields.backgroundArt,
            techProblem=self.src.fields.techProblem,
            techSolution=self.src.fields.techSolution,
            advantageousEffects=self.src.fields.advantageousEffects,
            embodiments=self.src.fields.embodiments,
            industrialApplicability=self.src.fields.industrialApplicability,
            referenceToDepositedBiologicalMaterial=self.src.fields.referenceToDepositedBiologicalMaterial,
            lawOfIndustrialRegenerate=self.src.fields.lawOfIndustrialRegenerate,
            independentClaims=self.src.fields.independentClaims,
            dependentClaims=self.src.fields.dependentClaims,
            abstract=self.src.fields.abstract,
            conclusionPartArticle=self.src.fields.conclusionPartArticle,
            draftingBody=self.src.fields.draftingBody,
            rejectionReasonArticle=self.src.fields.rejectionReasonArticle,
            opinionContentsArticle=self.src.fields.opinionContentsArticle,
            contentsOfAmendment=self.src.fields.contentsOfAmendment,
        )

    @staticmethod
    def _none_if_blank(s: Optional[str]) -> Optional[str]:
        if s is None:
            return None
        s2 = s.strip()
        return s2 if s2 else None


def extract_from_sources(sources: List[SourceFileInfo]) -> tuple[str, str]:
    for s in sources:
        if s.extension == "XML":
            continue  # XMLは除外
        return (s.task, s.kind)
    else:
        return (None, None)


def get_date(date_str: str, time_str: str) -> str | None:
    if not date_str or not time_str:
        return None
    if re.match(r"^\d{8}$", date_str) is None:
        return None
    if re.match(r"^\d{6}$", time_str) is None:
        return None
    dt = datetime.strptime(f"{date_str}{time_str}", "%Y%m%d%H%M%S")
    dt_jst = dt.replace(tzinfo=ZoneInfo("Asia/Tokyo"))
    epoch_millis = int(dt_jst.timestamp() * 1000)
    return str(epoch_millis)


if __name__ == "__main__":
    import json
    import sys

    # Example usage
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        data = json.load(f)

    try:
        doc = DocumentJson(**data)
        editor = PatentDocEditor(src=doc)
        es_doc = editor.to_es_model()
        print(es_doc.model_dump_json(indent=2, ensure_ascii=False))
    except ValidationError as e:
        print("Validation error:", e)
        sys.exit(1)
