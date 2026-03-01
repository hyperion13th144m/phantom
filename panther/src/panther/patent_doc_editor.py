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

from panther.es_patent_doc import EsPatentDoc, ImageInfo
from panther.models.generated.bibliographic_items import BibliographicItems
from panther.models.generated.full_text import FullText
from panther.models.generated.images_information import ImagesInformation


# -----------------------------
# 3) 編集（変換）用クラス
# -----------------------------
@dataclass(frozen=True)
class PatentDocEditor:
    bib: BibliographicItems
    full_text: FullText
    images_info: list[ImagesInformation]

    def to_es_model(self) -> EsPatentDoc:
        return EsPatentDoc(
            docId=self.bib.docId,
            task=self.full_text.task,
            kind=self.full_text.kind,
            law=self.bib.law.value,
            documentName=self.bib.documentName,
            documentCode=self.bib.documentCode,
            fileReferenceId=self.bib.fileReferenceId,
            applicationNumber=self.bib.applicationNumber,
            internationalApplicationNumber=self.bib.internationalApplicationNumber,
            registrationNumber=self.bib.registrationNumber,
            appealReferenceNumber=self.bib.appealReferenceNumber,
            submissionDate=get_date(self.bib.submissionDate, self.bib.submissionTime),
            dispatchDate=get_date(self.bib.dispatchDate, self.bib.dispatchTime),
            images=get_images(self.images_info),
            ocrText=get_image_text(self.images_info),
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
            embodiments=self.full_text.descriptionOfEmbodiments
            or self.full_text.bestMode,
            industrialApplicability=self.full_text.industrialApplicability,
            referenceToDepositedBiologicalMaterial=self.full_text.referenceToDepositedBiologicalMaterial,
            lawOfIndustrialRegenerate=self.full_text.lawOfIndustrialRegenerate,
            independentClaims=self.full_text.independentClaims,
            dependentClaims=self.full_text.dependentClaims,
            abstract=self.full_text.abstract,
            conclusionPartArticle=self.full_text.conclusionPartArticle,
            draftingBody=self.full_text.draftingBody,
            rejectionReasonArticle=self.full_text.rejectionReasonArticle,
            opinionContentsArticle=self.full_text.opinionContentsArticle,
            contentsOfAmendment=self.full_text.contentsOfAmendment,
            priorityClaims=self.full_text.priorityClaims,
        )

    @staticmethod
    def _none_if_blank(s: Optional[str]) -> Optional[str]:
        if s is None:
            return None
        s2 = s.strip()
        return s2 if s2 else None


def get_date(date_str: str | None, time_str: str | None) -> str | None:
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


def get_image_text(images: List[ImagesInformation]) -> Optional[str]:
    texts = []
    for img in images:
        if img.text:
            texts.append(img.text)
    if not texts:
        return None
    return "\n".join(texts)


def get_images(images_info: list[ImagesInformation]) -> list[ImageInfo]:
    images = []
    for img in images_info:
        for derived in img.derived:
            attrs = {
                attr.key: attr.value
                for attr in derived.attributes or []
                if attr.key == "sizeTag"
            }
            images.append(
                ImageInfo(
                    **attrs,
                    filename=derived.filename,
                    width=derived.width,
                    height=derived.height,
                    number=img.number or "",
                    kind=img.kind or "",
                    representative=img.representative or False,
                    description=img.description or None,
                )
            )
    return images


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
        bib = BibliographicItems(**bib)
        full_text = FullText(**full_text)
        images_info = [ImagesInformation(**img) for img in images_info]
        editor = PatentDocEditor(bib=bib, full_text=full_text, images_info=images_info)
        es_doc = editor.to_es_model()
        print(es_doc.model_dump_json(indent=2, ensure_ascii=False))
    except ValidationError as e:
        print("Validation error:", e)
        sys.exit(1)
