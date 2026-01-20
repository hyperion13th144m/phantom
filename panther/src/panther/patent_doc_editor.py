#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from datetime import datetime
from typing import Iterable, List, Optional
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
        agents1 = extract_text_list(
            self.src.textBlocksRoot,
            ["applicationForm", "jp:agents", "jp:agent"],
            "jp:name",
        )
        agents2 = extract_text_list(
            self.src.textBlocksRoot,
            ["applicationForm", "jp:attorney-change-article", "jp:agent"],
            "jp:name",
        )
        agents = agents1 + agents2
        specialMentionMatterArticle = extract_text_list(
            self.src.textBlocksRoot,
            [
                "applicationForm",
                "jp:special-mention-matter-article",
                "jp:article",
            ],
            "text",
        )
        inventionTitle = find_by_tag_path(
            self.src.textBlocksRoot,
            ["description", "inventionTitle"],
        )
        if inventionTitle:
            inventionTitle_text = inventionTitle[0].text or ""
        else:
            inventionTitle_text = None
        embodiments1 = extract_text(
            self.src.textBlocksRoot,
            ["description", "descriptionOfEmbodiments", "paragraph"],
            "text",
        )
        embodiments2 = extract_text(
            self.src.textBlocksRoot,
            ["description", "bestMode", "paragraph"],
            "text",
        )
        embodiments = embodiments1 or embodiments2
        independentClaims = filter(
            lambda block: block.isIndependent == True,
            find_by_tag_path(
                self.src.textBlocksRoot,
                ["claims", "claim"],
            ),
        )
        independentClaims_text = "".join(
            collect_descendants_text_by_tag(
                list(independentClaims),
                "text",
            )
        )
        dependentClaims = filter(
            lambda block: block.isIndependent == False,
            find_by_tag_path(
                self.src.textBlocksRoot,
                ["claims", "claim"],
            ),
        )
        dependentClaims_text = "".join(
            collect_descendants_text_by_tag(
                list(dependentClaims),
                "text",
            )
        )
        abstract = find_by_tag_path(
            self.src.textBlocksRoot,
            ["abstract"],
        )
        if abstract:
            abstract_text = abstract[0].text or ""
        else:
            abstract_text = None
        conclusionPartArticle1 = extract_text(
            self.src.textBlocksRoot,
            ["ntcPatExam", "jp:conclusion-part-article"],
            "text",
        )
        conclusionPartArticle2 = extract_text(
            self.src.textBlocksRoot,
            ["ntcPatExamRn", "jp:conclusion-part-article"],
            "text",
        )
        conclusionPartArticle = conclusionPartArticle1 or conclusionPartArticle2
        draftingBody1 = extract_text(
            self.src.textBlocksRoot,
            ["ntcPatExam", "jp:drafting-body"],
            "text",
        )
        draftingBody2 = extract_text(
            self.src.textBlocksRoot,
            ["ntcPatExamRn", "jp:drafting-body"],
            "text",
        )
        draftingBody = draftingBody1 or draftingBody2
        rejArticles1 = extract_text_list(
            self.src.textBlocksRoot,
            [
                "ntcPatExam",
                "jp:bibliog-in-ntc-pat-exam",
                "jp:article-group",
            ],
            "jp:article",
        )
        rejArticles2 = extract_text_list(
            self.src.textBlocksRoot,
            [
                "ntcPatExamRn",
                "jp:bibliog-in-ntc-pat-exam-rn",
                "jp:article-group",
            ],
            "jp:article",
        )
        rejectionReasonArticle = rejArticles1 + rejArticles2

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
            inventors=extract_text_list(
                self.src.textBlocksRoot,
                ["applicationForm", "jp:inventors", "jp:inventor"],
                "jp:name",
            ),
            applicants=extract_text_list(
                self.src.textBlocksRoot,
                ["applicationForm", "jp:applicants", "jp:applicant"],
                "jp:name",
            ),
            agents=agents,
            specialMentionMatterArticle=uniq_keep_order(specialMentionMatterArticle),
            lawOfIndustrialRegenerate=extract_text(
                self.src.textBlocksRoot,
                ["applicationForm", "jp:law-of-industrial-regenerate"],
                "text",
            ),
            inventionTitle=inventionTitle_text,
            technicalField=extract_text(
                self.src.textBlocksRoot,
                ["description", "technicalField", "paragraph"],
                "text",
            ),
            backgroundArt=extract_text(
                self.src.textBlocksRoot,
                ["description", "backgroundArt", "paragraph"],
                "text",
            ),
            techProblem=extract_text(
                self.src.textBlocksRoot,
                ["description", "summaryOfInvention", "techProblem", "paragraph"],
                "text",
            ),
            techSolution=extract_text(
                self.src.textBlocksRoot,
                ["description", "summaryOfInvention", "techSolution", "paragraph"],
                "text",
            ),
            advantageousEffects=extract_text(
                self.src.textBlocksRoot,
                [
                    "description",
                    "summaryOfInvention",
                    "advantageousEffects",
                    "paragraph",
                ],
                "text",
            ),
            embodiments=embodiments,
            industrialApplicability=extract_text(
                self.src.textBlocksRoot,
                ["description", "industrialApplicability", "paragraph"],
                "text",
            ),
            referenceToDepositedBiologicalMaterial=extract_text(
                self.src.textBlocksRoot,
                ["description", "referenceToDepositedBiologicalMaterial", "paragraph"],
                "text",
            ),
            independentClaims=self._none_if_blank(independentClaims_text),
            dependentClaims=self._none_if_blank(dependentClaims_text),
            abstract=self._none_if_blank(abstract_text),
            conclusionPartArticle=self._none_if_blank(conclusionPartArticle),
            draftingBody=self._none_if_blank(draftingBody),
            rejectionReasonArticle=uniq_keep_order(rejectionReasonArticle),
        )

    @staticmethod
    def _norm(s: Optional[str]) -> str:
        return (s or "").strip()

    @staticmethod
    def _none_if_blank(s: Optional[str]) -> Optional[str]:
        if s is None:
            return None
        s2 = s.strip()
        return s2 if s2 else None

    @staticmethod
    def _uniq_nonempty(items: List[str]) -> List[str]:
        seen = set()
        out: List[str] = []
        for x in items:
            if not x:
                continue
            if x in seen:
                continue
            seen.add(x)
            out.append(x)
        return out


def walk(nodes: list[TextBlock]) -> Iterable[TextBlock]:
    stack = list(reversed(nodes))
    while stack:
        n = stack.pop()
        yield n
        if n.blocks:
            stack.extend(reversed(n.blocks))


def find_by_tag_path(roots: list[TextBlock], path: list[str]) -> list[TextBlock]:
    """
    例: path=["jp:inventors"] を渡すと、該当ノード(複数ありうる)を返す
        path=["applicationForm","jp:inventors"] のように上位から縛ることも可能
    """
    cur = roots
    for want in path:
        next_nodes: list[TextBlock] = []
        for n in cur:
            if n.tag == want:
                next_nodes.append(n)
                continue
            # cur の各ノードの直下 blocks を見て、tag一致を拾う
            for c in n.blocks:
                if c.tag == want:
                    next_nodes.append(c)
        cur = next_nodes
        if not cur:
            return []
    return cur


def collect_descendants_text_by_tag(roots: list[TextBlock], tag: str) -> list[str]:
    out: list[str] = []
    for n in walk(roots):
        if n.tag != tag:
            continue
        t = (n.text or "").strip()
        if t:
            out.append(t)
    return out


def uniq_keep_order(items: list[str]) -> list[str]:
    seen = set()
    out: list[str] = []
    for x in items:
        if x in seen:
            continue
        seen.add(x)
        out.append(x)
    return out


def extract_text_list(
    text_blocks_root: list[TextBlock], path: list[str], tag: str
) -> list[str]:
    nodes = find_by_tag_path(
        roots=text_blocks_root,
        path=path,
    )
    # nodes の部分木から tag を全部集める
    blocks = collect_descendants_text_by_tag(nodes, tag)

    return blocks


def extract_text(
    text_blocks_root: list[TextBlock], path: list[str], tag: str
) -> list[str]:
    blocks = extract_text_list(text_blocks_root, path, tag)
    names = [b.strip() for b in blocks if b.strip()]
    return "".join(names)


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
