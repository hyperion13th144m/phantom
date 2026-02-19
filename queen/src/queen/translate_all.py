import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path

from queen.config import TranslatorKey, translator_config
from queen.merge import merge_xml
from queen.translate import translate

DoctypePathMap = dict[TranslatorKey, str]


def translate_all(
    src_xml: list[str],
    doctype_path_map: DoctypePathMap | None = None,
    output_dir: str | None = None,
    prettify: bool = False,
    debug: bool = False,
) -> None:
    """Translate all XML files according to the provided configuration.

    Args:
        src_xml (list[str]): List of source XML file paths.
        doctype_path_map (DoctypePathMap | None): Mapping of doctype keys to output file paths.
        output_dir (str | None): Directory to save the translated XML files.
        prettify (bool): Whether to prettify the output XML files.
        debug (bool): Whether to enable debug mode.

        if doctype_path_map is None and output_dir is not None,
        the translated XML files will be saved in output_dir
        with default filenames defined in translator_config.

        if doctype_path_map is not None, the translated XML files will
        be saved according to the mapping, and output_dir will be ignored.
    Raises:
        ValueError: If neither output_dir nor doctype_path_map are specified.
    """
    if doctype_path_map is None and output_dir is None:
        raise ValueError("Either output_dir or doctype_path_map must be specified.")

    with tempfile.NamedTemporaryFile() as tmp_file:
        merge_xml(src_xml, tmp_file.name)

        for key, config in translator_config.items():
            if (
                has_doctype(
                    xml_path=tmp_file.name,
                    namespace=config.namespace,
                    doctype=config.doctype,
                )
                is False
            ):
                continue

            if doctype_path_map is not None:
                output_path = doctype_path_map.get(key)
                if output_path is None:
                    continue
            else:
                output_path = config.default_filename

            if output_dir is not None:
                output_path = str(Path(output_dir) / Path(output_path).name)

            translate(
                src_xml=tmp_file.name,
                xsl_path=config.xsl_path,
                output_path=output_path,
                prettify=prettify,
                debug=debug,
            )


def has_doctype(xml_path: str, namespace: str, doctype: str) -> bool:
    if doctype == "*":
        return True

    root = ET.parse(xml_path)
    if namespace:
        search_tag = f"{{{namespace}}}{doctype}"
    else:
        search_tag = doctype
    return root.find(search_tag) is not None


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Translate XML files according to the provided configuration."
    )
    parser.add_argument("src_xml", nargs="+", help="List of source XML file paths.")
    parser.add_argument(
        "--output-dir", help="Directory to save the translated XML files."
    )
    parser.add_argument(
        "--prettify", action="store_true", help="Prettify the output XML files."
    )
    parser.add_argument(
        "-d",
        "--debug",
        action="store_true",
        help="Whether to enable debug mode (default: False)",
    )
    args = parser.parse_args()
    translate_all(
        src_xml=args.src_xml,
        output_dir=args.output_dir,
        prettify=args.prettify,
        debug=args.debug,
    )
