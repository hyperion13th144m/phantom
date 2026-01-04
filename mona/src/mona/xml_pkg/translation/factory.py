import os
from typing import Dict, List, TypedDict

from .translators import Translator


class TranslatorConfig(TypedDict):
    translator: type[Translator]
    src: str
    args: Dict
    factory_args: Dict | None


def get_translators(
    src_dir_path: str, translator_configs: List[TranslatorConfig]
) -> Dict[str, List[Translator]]:
    result = []

    for config in translator_configs:
        src = os.path.join(src_dir_path, config["src"])
        translator = config["translator"].create(
            src_path=src, **config.get("factory_args", {}), **config.get("args", {})
        )

        if translator is None:
            continue

        result.append(translator)

    return result
