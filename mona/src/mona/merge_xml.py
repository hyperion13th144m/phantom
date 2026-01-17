import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List

ET.register_namespace("jp", "http://www.jpo.go.jp")


def merge_xml_to_string(src_xml_files: List[Path]) -> str:
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
    return byte_io.getvalue().decode("utf-8", "replace")


def merge_xml(src_xml_files: List[Path], dst_path):
    """merge specified xml files into a single xml file

    Args:
        src_xml_files (Iterator[Path]): iterator of source xml file paths
        dst_path (Path): destination file path

    Returns:
        None
    """
    root = ET.Element("root")
    for xml_file in src_xml_files:
        tree = ET.parse(xml_file)
        root_elem = tree.getroot()
        root.append(root_elem)
    tree = ET.ElementTree(root)
    # ET.indent(tree, space="  ")
    tree.write(dst_path, encoding="UTF-8", xml_declaration=False)
