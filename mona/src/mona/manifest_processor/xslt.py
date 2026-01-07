import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List

import xmltodict
from pydantic import BaseModel

from ..merge_xml import merge_xml_to_string
from ..translate_xml import translate_xml
from .base import ManifestProcessor


class TranslatorConfig(BaseModel):
    xsl_path: str
    force_list: List[str]
    namespace: str
    doctype: str


class XSLTProcessor(ManifestProcessor):
    def __init__(self, manifest_path: Path, translator_config: List[TranslatorConfig]):
        super().__init__(manifest_path)
        self.translator_config = translator_config

    def translate(self) -> list[dict]:
        data = []
        xml_files = [
            self.manifest_dir / xml_file.path for xml_file in self.manifest.xml_files
        ]
        merged_xml_string = merge_xml_to_string(xml_files)

        for config in self.translator_config:
            if (
                self.has_doctype(
                    xml_string=merged_xml_string,
                    namespace=config.namespace,
                    doctype=config.doctype,
                )
                is False
            ):
                continue

            translated_xml = translate_xml(
                src_xml=merged_xml_string, xsl_name=config.xsl_path
            )
            translated_data = xmltodict.parse(
                translated_xml,
                strip_whitespace=False,
                force_list=config.force_list,
            )
            data.append(translated_data)

        return data

    def has_doctype(self, xml_string: str, namespace: str, doctype: str) -> bool:

        root = ET.fromstring(xml_string)
        if namespace:
            search_tag = f"{{{namespace}}}{doctype}"
        else:
            search_tag = doctype

        return root.find(search_tag) is not None
