import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Callable, List

import xmltodict
from pydantic import BaseModel

from ..merge_xml import merge_xml, merge_xml_to_string
from ..translate_xml import translate_xml
from .base import ManifestProcessor


class TranslatorConfig(BaseModel):
    xsl_path: str
    namespace: str
    doctype: str
    force_list: List[str]
    postprocessor: Callable[[List[str], str, str], None] | None = None
    strip_whitespace: bool = False


class XSLTProcessor(ManifestProcessor):
    def __init__(
        self,
        manifest_path: Path,
        translator_config: List[TranslatorConfig],
    ):
        super().__init__(manifest_path)
        self.translator_config = translator_config

    def translate(self) -> list[dict]:
        data = []
        xml_files = [
            self.manifest_dir / xml_file.path for xml_file in self.manifest.xml_files
        ]
        merged_xml_path = self.manifest_dir / "document.xml"
        merge_xml(xml_files, merged_xml_path)
        # merged_xml_string = merge_xml_to_string(xml_files)

        for config in self.translator_config:
            if (
                self.has_doctype(
                    xml_path=merged_xml_path,
                    namespace=config.namespace,
                    doctype=config.doctype,
                )
                is False
            ):
                continue

            translated_xml = translate_xml(
                src_xml=merged_xml_path, xsl_name=config.xsl_path
            )
            debug_path = self.manifest_dir / f"translated_{config.doctype}.xml"
            with open(debug_path, "w", encoding="utf-8") as f:
                xml = ET.fromstring(translated_xml)  # validate XML
                ET.indent(xml, space="  ")
                f.write(ET.tostring(xml, encoding="unicode"))

            translated_data = xmltodict.parse(
                translated_xml,
                strip_whitespace=config.strip_whitespace,
                force_list=config.force_list,
                postprocessor=config.postprocessor,
            )
            data.append(translated_data)

        return data

    def has_doctype(self, xml_path: Path, namespace: str, doctype: str) -> bool:

        root = ET.parse(xml_path)
        if namespace:
            search_tag = f"{{{namespace}}}{doctype}"
        else:
            search_tag = doctype

        return root.find(search_tag) is not None
