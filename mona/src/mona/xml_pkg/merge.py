import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Iterator

ET.register_namespace("jp", "http://www.jpo.go.jp")


def merge_xml(src_xml_files: Iterator[Path], dst_xml_file: str):
    """merge specified xml files into a single all.xml

    Args:
        src_xml_files (Iterator[Path]): iterator of source xml file paths
        dst_xml_file (str): destination xml file path
    """
    root = ET.Element("root")
    for xml_file in src_xml_files:
        tree = ET.parse(xml_file)
        root_elem = tree.getroot()
        root.append(root_elem)
    tree = ET.ElementTree(root)
    ET.indent(tree, space="  ")
    tree.write(dst_xml_file, encoding="UTF-8", xml_declaration=True)

def merge_xml_to_string(src_xml_files: Iterator[Path]) -> str:
    """merge specified xml files into a single xml string

    Args:
        src_xml_files (Iterator[Path]): iterator of source xml file paths

    Returns:
        str: merged xml string
    """
    root = ET.Element("root")
    for xml_file in src_xml_files:
        tree = ET.parse(xml_file)
        root_elem = tree.getroot()
        root.append(root_elem)
    tree = ET.ElementTree(root)
    ET.indent(tree, space="  ")
    from io import BytesIO

    byte_io = BytesIO()
    tree.write(byte_io, encoding="UTF-8", xml_declaration=True)
    return byte_io.getvalue().decode("utf-8")
