from typing import List, TypedDict


class TranslatorConfig(TypedDict):
    xsl_path: str
    force_list: List[str] | None
    namespace: str
    doctype: str

