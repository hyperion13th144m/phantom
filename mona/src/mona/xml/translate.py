from importlib import resources
from pathlib import Path
from typing import Union

import saxonche

from . import stylesheets


def xsl_resolver(xsl_name: str) -> Path:
    xsl = resources.files(stylesheets) / xsl_name
    return xsl


def translate_xml(src_xml: Union[str, Path], xsl_name: str) -> str:
    """translate xml by xsl using saxon

    Args:
        src_xml (Union[str, Path]): path to xml file or xml string
        xsl_name (str): name of xsl file
    """
    xsl_path = xsl_resolver(xsl_name)
    # Initialize the Saxon/C processor
    with saxonche.PySaxonProcessor(license=False) as proc:
        # Create an XSLT processor
        xslt_processor = proc.new_xslt30_processor()

        # Load the XML and XSLT files
        if isinstance(src_xml, Path):
            xml_file = proc.parse_xml(xml_file_name=str(src_xml))
        else:
            xml_file = proc.parse_xml(xml_text=src_xml)

        executable = xslt_processor.compile_stylesheet(stylesheet_file=str(xsl_path))

        # transformation
        output = executable.transform_to_string(xdm_node=xml_file)
    return output
