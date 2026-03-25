from typing import Any, Dict, List, Literal, Union, get_args

from libefiling.image.params import ImageAttribute, ImageConvertParam
from pydantic import BaseModel


class CategoryConfig(BaseModel):
    description: str
    codes: Dict[str, str]


Category = Literal["EXAM", "APP", "AMND", "RSPN", "ETC", "EXAM_FORMALITY", "ALL"]
DocCode = Literal[
    "A101",
    "A102",
    "A1131",
    "A1191",
    "A130",
    "A163",
    "A263",
    "A1631",
    "A1632",
    "A1634",
    "A151",
    "A1523",
    "A2523",
    "A1529",
    "A1527",
    "A15211",
    "A153",
    "A1781",
    "A1871",
    "A1872",
    "A2242623",
]
all_categories: List[Category] = list(get_args(Category))
all_codes: List[DocCode] = list(get_args(DocCode))


class DocCodeConfig(BaseModel):
    category: Category
    description: str
    codes: Dict[DocCode, str]


code_config: List[DocCodeConfig] = [
    # コメントした文書はたぶん取り込めるけど、実データが無く確認できないので非対応
    DocCodeConfig(
        category="EXAM",
        description="審査系",
        codes={
            "A101": "特許査定",
            "A102": "拒絶査定",
            "A1131": "拒絶理由通知書",
            "A1191": "補正却下の決定",
            # "A1192": "補正却下の決定",
            "A130": "引用非特許文献",
        },
    ),
    DocCodeConfig(
        category="APP",
        description="出願系",
        codes={
            "A163": "特許願",
            "A263": "実用新案登録願",
            "A1631": "翻訳文提出書",
            "A1632": "国内書面",
            # "A2633":    "図面の提出書（実案）"
            "A1634": "国際出願翻訳文提出書",
            # "A1635":  "国際出願翻訳文提出書（職権）"
        },
    ),
    DocCodeConfig(
        category="AMND",
        description="補正系",
        codes={
            "A151": "手続補正書（方式）| 手続補正書",
            "A1523": "手続補正書 特許",
            "A2523": "手続補正書 実案",
            # * "A1524",  # 誤訳訂正書
            # * "A1525",  # 特許協力条約第１９条補正の翻訳文提出書
            "A1529": "特許協力条約第３４条補正の翻訳文提出書",
            # * "A1526",  # 特許協力条約第１９条補正の翻訳文提出書（職権）
            # * "A15210",  # 特許協力条約第３４条補正の翻訳文提出書（職権）
            "A1527": "特許協力条約第１９条補正の写し提出書",
            "A15211": "特許協力条約第３４条補正の写し提出書",
            # * "A1528",  # 特許協力条約第１９条補正の写し提出書（職権）
            # * "A15212",  # 特許協力条約第３４条補正の写し提出書（職権）
        },
    ),
    DocCodeConfig(
        category="RSPN",
        description="応答系",
        codes={
            "A153": "意見書",
            # "A159":  "弁明書",
        },
    ),
    DocCodeConfig(
        category="ETC",
        description="その他",
        codes={
            "A1781": "上申書",
            "A1871": "早期審査に関する事情説明書",
            "A1872": "早期審査に関する事情説明補充書",
        },
    ),
    DocCodeConfig(
        category="EXAM_FORMALITY",
        description="方式審査系",
        codes={
            "A2242623": "実用新案技術評価の通知",
        },
    ),
    # 実用新案
    # いつか取り込むかも
    # 実用新案
    # いつか取り込むかも
    # "A1621" #出願審査請求書
    # "A2623" #実用新案技術評価請求書
    # "A2624" #実用新案技術評価請求書（他人）
]


def get_all_document_codes() -> List[Union[Category, DocCode]]:
    return all_codes + all_categories


def is_valid_document_code(codes: List[Union[Category, DocCode]]) -> bool:
    # empty list is valid (means no filter)
    return all(c in all_codes or c in all_categories or c == "ALL" for c in codes)


def get_target_document_codes(
    codes: List[Union[Category, DocCode]],
) -> List[str]:
    results = set()

    for c in codes:
        if c == "ALL":
            results.update(all_codes)
        elif c in all_categories:
            conf = next(filter(lambda x: x.category == c, code_config), None)
            if conf:
                results.update(conf.codes.keys())
        elif c in all_codes:
            results.add(c)
        else:
            pass
    return list(results)


image_params: list[ImageConvertParam] = [
    ImageConvertParam(
        width=300,
        height=300,
        suffix="-thumbnail",
        format=".webp",
        attributes=[ImageAttribute(key="sizeTag", value="thumbnail")],
    ),
    ImageConvertParam(
        width=600,
        height=600,
        suffix="-middle",
        format=".webp",
        attributes=[ImageAttribute(key="sizeTag", value="middle")],
    ),
    ImageConvertParam(
        width=800,
        height=0,
        suffix="-large",
        format=".webp",
        attributes=[ImageAttribute(key="sizeTag", value="large")],
    ),
]

if __name__ == "__main__":
    import json

    print(json.dumps(get_target_document_codes(["EXAM", "A163"]), indent=2))
