from libefiling.image.params import ImageAttribute, ImageConvertParam

TARGET_DOCUMENT_CODES = [
    "A101",
    "A102",
    "A1131",
    "A1191",
    "A1192",
    "A130",
    "A1523",
    "A163",
    "A1631",  # 翻訳文提出書
    "A1632",  # 国内書面
    # "A1633", # 図面の提出書（実案）は対象外(データないので確認できない)
    "A1634",  # 国際出願翻訳文提出書
    # "A1635", # 国際出願翻訳文提出書（職権）は対象外(データないので確認できない)
    "A153",
    "A159",
    "A1781",
    "A1871",
    "A1872",
    # 実用新案
    "A263",  # 実用新案登録願
    "A2523",  # 手続補正書
    "A2242623",  # 実用新案技術評価の通知
]

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
