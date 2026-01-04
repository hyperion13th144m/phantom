from typing import List

from .translation.translators import Translator


def translate_to_json(translators: List[Translator]) -> dict:
    result = {}
    for translator in translators:
        blocks = translator.translate()
        for key in blocks["root"]:
            if key in result:
                ### key が既に存在する場合は、リストに追加する
                if isinstance(result[key], list):
                    result[key].extend(blocks["root"][key])
                else:
                    result[key] = [result[key]] + blocks["root"][key]
            else:
                ### key が存在しない場合は、新規に追加する
                result[key] = blocks["root"][key]

    return result
