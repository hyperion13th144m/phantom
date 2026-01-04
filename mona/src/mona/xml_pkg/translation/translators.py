import json
import re
from abc import ABC, abstractmethod
from xml.etree import ElementTree as ET

import xmltodict

from .subr import translate_xml


class Translator(ABC):
    @abstractmethod
    def translate():
        pass

    @classmethod
    def create(cls, src_path: str, **kwargs):
        pass


class TranslatorUsingXSL(Translator):
    def __init__(self, xsl_path: str, xml_string: str):
        self._xsl_path = xsl_path
        self._xml_string = xml_string

    def translate(self) -> dict:
        output = self.process()
        output = self.post_process(output)
        return output

    @abstractmethod
    def process(self) -> str:
        pass

    @abstractmethod
    def post_process(self, translated_string: str) -> dict:
        pass

    @classmethod
    def create(cls, src_path: str, namespace: str, doctype: str, **kwargs):
        src_xml_string = open(src_path, "r").read()
        root = ET.fromstring(src_xml_string)

        ### namespace, doctype に合致する要素があれば Translator を生成
        if len(namespace) > 0:
            search_tag = f"{{{namespace}}}{doctype}"
        else:
            search_tag = doctype

        if root.find(search_tag) is not None:
            ### Translator インスタンスの生成
            return cls(xml_string=src_xml_string, **kwargs)
        else:
            return None


class JSONTranslator(TranslatorUsingXSL):
    def __init__(self, xsl_path: str, xml_string: str, force_list=None):
        super().__init__(xsl_path, xml_string)
        self._force_list = force_list

    def process(self) -> str:
        # Currently, params are not used.
        output = translate_xml(
            src_xml=self._xml_string,
            xsl_name=self._xsl_path,
        )
        return output

    def post_process(self, translated_string: str) -> str | dict:
        args = {}
        if self._force_list:
            args["force_list"] = self._force_list
        translated = xmltodict.parse(
            translated_string,
            strip_whitespace=False,
            **args,
        )
        return translated


class JSONLoader(Translator):
    def __init__(self, src_json_path: str):
        self._src_json_path = src_json_path

    def translate(self) -> str:
        with open(self._src_json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data

    @classmethod
    def create(cls, src_path: str, **kwargs):
        return cls(src_json_path=src_path)


class OCRJSONLoader(Translator):
    def __init__(self, src_json_path: str):
        self._src_json_path = src_json_path

    def translate(self) -> str:
        with open(self._src_json_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        all_text = "".join(map(lambda x: x["text"], data["root"]["ocrText"]))
        all_text = re.sub(r"[ \t\n]+", " ", all_text)
        return {"root": {"ocrText": all_text}}

    @classmethod
    def create(cls, src_path: str, **kwargs):
        return cls(src_json_path=src_path)
