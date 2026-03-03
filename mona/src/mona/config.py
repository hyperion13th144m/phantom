from libefiling.image.params import ImageAttribute, ImageConvertParam

TARGET_DOCUMENT_CODES = [
    "A101",  # 特許査定
    "A102",  # 拒絶査定
    "A1131",  # 拒絶理由通知書
    "A1191",  # 補正却下の決定
    "A1192",  # 補正却下の決定
    "A130",  # 引用非特許文献
    "A163",  # 特許願
    "A263",  # 実用新案登録願
    "A1631",  # 翻訳文提出書
    "A1632",  # 国内書面
    # "A2633",    # 図面の提出書（実案）は対象外(データないので確認できない)
    "A1634",  # 国際出願翻訳文提出書
    # "A1635",    # 国際出願翻訳文提出書（職権）は対象外(データないので確認できない)
    "A151",  # 手続補正書（方式）| 手続補正書
    "A1523",  # 手続補正書 特許
    "A2523",  # 手続補正書 実案
    "A1524",  # 誤訳訂正書
    "A1525",  # 特許協力条約第１９条補正の翻訳文提出書
    "A1529",  # 特許協力条約第３４条補正の翻訳文提出書
    "A1526",  # 特許協力条約第１９条補正の翻訳文提出書（職権）
    "A15210",  # 特許協力条約第３４条補正の翻訳文提出書（職権）
    "A1527",  # 特許協力条約第１９条補正の写し提出書
    "A15211",  # 特許協力条約第３４条補正の写し提出書
    "A1528",  # 特許協力条約第１９条補正の写し提出書（職権）
    "A15212",  # 特許協力条約第３４条補正の写し提出書（職権）
    "A153",  # 意見書
    "A159",  # 弁明書
    "A1781",  # 上申書
    "A1871",  # 早期審査に関する事情説明書
    "A1872",  # 早期審査に関する事情説明補充書
    # 実用新案
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
