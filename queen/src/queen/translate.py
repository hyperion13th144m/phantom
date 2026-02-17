import json
import os
import tempfile
from pathlib import Path

import saxonche


def translate(
    src_xml: str, xsl_path: str, output_path: str, prettify: bool = False
) -> None:
    """translate xml by xsl using saxon

    Args:
        src_xml (str): path to xml file
        xsl_path (str): path to xsl file
        output_path (str): path to output json file
        prettify (bool, optional): whether to prettify the output XML. Defaults to False.
    """
    if prettify:
        with tempfile.NamedTemporaryFile() as tmp_file:
            tmp_output_path = tmp_file.name
            _translate(src_xml, xsl_path, tmp_output_path)
            with open(tmp_output_path, "rb") as f:
                json.dump(
                    json.load(f),
                    open(output_path, "w", encoding="utf-8"),
                    ensure_ascii=False,
                    indent=4,
                )

    else:
        _translate(src_xml, xsl_path, output_path)


def _translate(src_xml: str, xsl_path: str, output_path: str) -> None:
    """translate xml by xsl using saxon to json.

    Args:
        src_xml (str): path to xml file
        xsl_path (str): path to xsl file
        output_path (str): path to output file
    """
    if not os.path.isfile(src_xml):
        raise FileNotFoundError(f"Source XML file not found: {src_xml}")
    if not os.path.isfile(xsl_path):
        raise FileNotFoundError(f"XSLT file not found: {xsl_path}")

    # Initialize the Saxon/C processor
    with saxonche.PySaxonProcessor(license=False) as proc:
        # Create an XSLT processor
        xslt_processor = proc.new_xslt30_processor()

        xml_file = proc.parse_xml(xml_file_name=src_xml)

        executable = xslt_processor.compile_stylesheet(stylesheet_file=str(xsl_path))
        executable.transform_to_file(
            source_file=src_xml, xdm_node=xml_file, output_file=output_path
        )


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Translate XML using XSLT")
    parser.add_argument("src_xml", type=str, help="Path to the source XML file")
    parser.add_argument("xsl_path", type=str, help="Path to the XSLT file")
    parser.add_argument("output_path", type=str, help="Path to the output JSON file")
    parser.add_argument(
        "-p",
        "--prettify",
        action="store_true",
        help="Whether to prettify the output JSON (default: False)",
    )
    args = parser.parse_args()

    translate(args.src_xml, args.xsl_path, args.output_path, prettify=args.prettify)
