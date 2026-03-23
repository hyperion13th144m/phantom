import xml.etree.ElementTree as ET
from pathlib import Path
from typing import List

ET.register_namespace("jp", "http://www.jpo.go.jp")


def merge_xml(src_xml: List[str], dst_path: str) -> None:
    """merge specified xml files into a single xml file

    Args:
        src_xml (List[str]): list of source xml file paths
        dst_path (str): destination file path

    Returns:
        None
    """
    root = ET.Element("root")
    for xml_file in src_xml:
        tree = ET.parse(xml_file)
        root_elem = tree.getroot()
        root.append(root_elem)
    tree = ET.ElementTree(root)
    tree.write(dst_path, encoding="UTF-8", xml_declaration=False)
