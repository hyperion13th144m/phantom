from importlib import resources
from pathlib import Path
from typing import Union

import saxonche

from . import stylesheets


def xsl_resolver(xsl_name: str) -> Path:
    xsl = resources.files(stylesheets) / xsl_name
    return xsl


def detect_encoding(file_path: Path) -> str:
    """Detect the encoding of a file by reading its BOM or first few bytes"""
    with open(file_path, "rb") as f:
        raw_data = f.read(4)

    # Check for BOM (order matters!)
    if raw_data.startswith(b"\xff\xfe\x00\x00"):
        return "utf-32-le"
    elif raw_data.startswith(b"\x00\x00\xfe\xff"):
        return "utf-32-be"
    elif raw_data.startswith(b"\xff\xfe"):
        return "utf-16-le"
    elif raw_data.startswith(b"\xfe\xff"):
        return "utf-16-be"
    elif raw_data.startswith(b"\xef\xbb\xbf"):
        return "utf-8-sig"

    # Try common encodings
    encodings = ["utf-8", "shift_jis", "cp932", "euc-jp", "iso-2022-jp"]
    for encoding in encodings:
        try:
            with open(file_path, "r", encoding=encoding) as f:
                f.read()
            return encoding
        except (UnicodeDecodeError, LookupError):
            continue

    # Default to utf-8
    return "utf-8"


def translate_xml(src_xml: Union[str, Path], xsl_name: str) -> str:
    """translate xml by xsl using saxon

    Args:
        src_xml (Union[str, Path]): path to xml file or xml string
        xsl_name (str): name of xsl file
    """
    import re

    xsl_path = xsl_resolver(xsl_name)
    # Initialize the Saxon/C processor
    with saxonche.PySaxonProcessor(license=False) as proc:
        # Create an XSLT processor
        xslt_processor = proc.new_xslt30_processor()

        # Load the XML and XSLT files
        if isinstance(src_xml, Path):
            # Detect encoding and read file content
            encoding = detect_encoding(src_xml)
            with open(src_xml, "r", encoding=encoding) as f:
                xml_text = f.read()

            # Normalize encoding declaration in XML to UTF-8
            # This ensures the XML declaration matches the actual encoding we're passing to Saxon
            xml_text = re.sub(
                r'<\?xml\s+version="[^"]*"\s+encoding="[^"]*"\s*\?>',
                '<?xml version="1.0" encoding="UTF-8"?>',
                xml_text,
                count=1,
            )

            # Ensure the text is properly encoded as UTF-8 for Saxon
            xml_bytes = xml_text.encode("utf-8", errors="replace")
            xml_text = xml_bytes.decode("utf-8")

            xml_file = proc.parse_xml(xml_text=xml_text)
        else:
            xml_file = proc.parse_xml(xml_text=src_xml)

        executable = xslt_processor.compile_stylesheet(stylesheet_file=str(xsl_path))

        # transformation
        # Use transform_to_file with a temporary file to avoid encoding issues
        # in saxonche's make_py_str function
        import tempfile

        with tempfile.NamedTemporaryFile(
            mode="w+", suffix=".xml", delete=False, encoding="utf-8"
        ) as tmp:
            tmp_path = tmp.name

        try:
            executable.transform_to_file(xdm_node=xml_file, output_file=tmp_path)
            # Read the result with proper encoding handling
            with open(tmp_path, "rb") as f:
                output_bytes = f.read()
            # Try to decode, handling potential encoding issues
            try:
                output = output_bytes.decode("utf-8")
            except UnicodeDecodeError:
                # If UTF-8 fails, try UTF-16
                try:
                    output = output_bytes.decode("utf-16")
                except UnicodeDecodeError:
                    # As last resort, decode with errors='replace'
                    output = output_bytes.decode("utf-8", errors="replace")
        finally:
            # Clean up temporary file
            import os

            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
    return output
