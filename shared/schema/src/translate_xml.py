import json
from lxml import etree


def transform_xml_with_xslt(xml_path: str, xslt_path: str, output_path: str):
    """
    Transforms an XML file using an XSLT stylesheet and saves the result.

    Args:
        xml_path (str): Path to the XML file.
        xslt_path (str): Path to the XSLT file.
        output_path (str): Path to save the transformed output.
    """
    try:
        # Parse XML and XSLT files
        xml_tree = etree.parse(xml_path)
        xslt_tree = etree.parse(xslt_path)

        # Create an XSLT transformer
        transform = etree.XSLT(xslt_tree)

        # Apply transformation to json string
        result_tree = transform(xml_tree)

        # Save the result to file
        with open(output_path, "wb") as f:
            j = json.loads(str(result_tree))
            f.write(json.dumps(j, indent=4).encode("UTF-8"))

        print(f"Transformation successful! Output saved to: {output_path}")

    except (etree.XMLSyntaxError, etree.XSLTParseError) as e:
        print(f"XML/XSLT parsing error: {e}")
    except etree.XSLTApplyError as e:
        print(f"Error applying XSLT: {e}")
    except FileNotFoundError as e:
        print(f"File not found: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")


if __name__ == "__main__":
    import sys

    xml_path, xslt_path, output_path = sys.argv[1:4]
    transform_xml_with_xslt(xml_path, xslt_path, output_path)
