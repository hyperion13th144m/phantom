import saxonche


def translate(src_xml: str, xsl_name: str, out_name: str) -> None:
    # Initialize the Saxon/C processor
    with saxonche.PySaxonProcessor(license=False) as proc:
        # Create an XSLT processor
        xslt_processor = proc.new_xslt30_processor()

        # load the XML files
        with open(src_xml, "r", encoding="UTF-8") as f:
            xml_raw = f.read()
            xml_text = proc.parse_xml(xml_text=xml_raw)

        # load the XSLT files
        executable = xslt_processor.compile_stylesheet(stylesheet_file=xsl_name)

        # transformation
        executable.transform_to_file(xdm_node=xml_text, output_file=out_name)


def prettify(json_path: str) -> None:
    import json

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)


if __name__ == "__main__":
    import sys

    xml = sys.argv[1]
    xsl = sys.argv[2]
    out = sys.argv[3]

    translate(xml, xsl, out)
    prettify(out)
