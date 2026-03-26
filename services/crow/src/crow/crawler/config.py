from enum import Enum
from typing import Dict, List

from libefiling.image.params import ImageAttribute, ImageConvertParam
from pydantic import BaseModel


class Category(Enum):
    EXAM = "EXAM"
    APP = "APP"
    AMND = "AMND"
    RSPN = "RSPN"
    ETC = "ETC"
    EXAM_F = "EXAM_F"
    ALL = "ALL"


class DocCode(Enum):
    A101 = "A101"
    A102 = "A102"
    A1131 = "A1131"
    A1191 = "A1191"
    A130 = "A130"
    A163 = "A163"
    A263 = "A263"
    A1631 = "A1631"
    A1632 = "A1632"
    A1634 = "A1634"
    A151 = "A151"
    A1523 = "A1523"
    A2523 = "A2523"
    A1529 = "A1529"
    A1527 = "A1527"
    A15211 = "A15211"
    A153 = "A153"
    A1781 = "A1781"
    A1871 = "A1871"
    A1872 = "A1872"
    A2242623 = "A2242623"


class DocCodeCategory(BaseModel):
    category: Category
    description: str
    codes: Dict[DocCode, str]


_code_config: List[DocCodeCategory] = [
    # コメントした文書はたぶん取り込めるけど、実データが無く確認できないので非対応
    DocCodeCategory(
        category=Category.EXAM,
        description="審査系",
        codes={
            DocCode.A101: "特許査定",
            DocCode.A102: "拒絶査定",
            DocCode.A1131: "拒絶理由通知書",
            DocCode.A1191: "補正却下の決定",
            # DocCode.A1192: "補正却下の決定",
            DocCode.A130: "引用非特許文献",
        },
    ),
    DocCodeCategory(
        category=Category.APP,
        description="出願系",
        codes={
            DocCode.A163: "特許願",
            DocCode.A263: "実用新案登録願",
            DocCode.A1631: "翻訳文提出書",
            DocCode.A1632: "国内書面",
            # DocCode.A2633:    "図面の提出書（実案）"
            DocCode.A1634: "国際出願翻訳文提出書",
            # DocCode.A1635:  "国際出願翻訳文提出書（職権）"
        },
    ),
    DocCodeCategory(
        category=Category.AMND,
        description="補正系",
        codes={
            DocCode.A151: "手続補正書（方式）| 手続補正書",
            DocCode.A1523: "手続補正書 特許",
            DocCode.A2523: "手続補正書 実案",
            # * DocCode.A1524,  # 誤訳訂正書
            # * DocCode.A1525,  # 特許協力条約第１９条補正の翻訳文提出書
            DocCode.A1529: "特許協力条約第３４条補正の翻訳文提出書",
            # * DocCode.A1526,  # 特許協力条約第１９条補正の翻訳文提出書（職権）
            # * DocCode.A15210,  # 特許協力条約第３４条補正の翻訳文提出書（職権）
            DocCode.A1527: "特許協力条約第１９条補正の写し提出書",
            DocCode.A15211: "特許協力条約第３４条補正の写し提出書",
            # * DocCode.A1528,  # 特許協力条約第１９条補正の写し提出書（職権）
            # * DocCode.A15212,  # 特許協力条約第３４条補正の写し提出書（職権）
        },
    ),
    DocCodeCategory(
        category=Category.RSPN,
        description="応答系",
        codes={
            DocCode.A153: "意見書",
            # DocCode.A159:  "弁明書",
        },
    ),
    DocCodeCategory(
        category=Category.ETC,
        description="その他",
        codes={
            DocCode.A1781: "上申書",
            DocCode.A1871: "早期審査に関する事情説明書",
            DocCode.A1872: "早期審査に関する事情説明補充書",
        },
    ),
    DocCodeCategory(
        category=Category.EXAM_F,
        description="方式審査系",
        codes={
            DocCode.A2242623: "実用新案技術評価の通知",
        },
    ),
    # 実用新案
    # いつか取り込むかも
    # 実用新案
    # いつか取り込むかも
    # DocCode.A1621 #出願審査請求書
    # DocCode.A2623 #実用新案技術評価請求書
    # DocCode.A2624 #実用新案技術評価請求書（他人）
]


class DocCodeConfig:
    def __init__(self, config: List[DocCodeCategory]):
        self._config = config

    def get_all_codes(self) -> List[str]:
        codes = []
        for category in self._config:
            codes.extend(category.codes.keys())
        return [code.value for code in codes]

    def get_all_categories(self) -> List[str]:
        return [category.category.value for category in self._config]

    def get_available_codes(self) -> List[str]:
        return self.get_all_codes() + self.get_all_categories()

    def get_codes_by_category(self, category_name: str) -> List[str]:
        category = next(
            (c for c in self._config if c.category.value == category_name), None
        )
        if category:
            return [code.value for code in category.codes.keys()]
        if category_name == Category.ALL.value:
            return self.get_all_codes()
        return []

    def print(self):
        for conf in self._config:
            print(f"{conf.category.value} {conf.description}")
            for code, desc in conf.codes.items():
                print(f"\t{code.value}: {desc}")
        print()
        print("Available codes for -c/--doc-code option")
        print(", ".join(self.get_all_categories()))
        print(", ".join(self.get_all_codes()))

    def dump(self) -> List[Dict[str, str | Dict[str, str]]]:
        return [
            {
                "category": conf.category.value,
                "description": conf.description,
                "codes": {code.value: desc for code, desc in conf.codes.items()},
            }
            for conf in self._config
        ]

    def get_codes(self, codes: List[str]) -> List[str]:
        results = set()

        for c in codes:
            results.update(self.get_codes_by_category(c))
            if c in self.get_all_codes():
                results.add(c)
        return list(results)


doc_code_config = DocCodeConfig(config=_code_config)


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
    doc_code_config.print()
    codes = doc_code_config.get_codes(["EXAM", "A163", "A1523"])
    print(codes)
    print(doc_code_config.dump())
