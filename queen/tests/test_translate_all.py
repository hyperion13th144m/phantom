"""Test cases for translate_all function."""

import json
import tempfile
from pathlib import Path

import pytest

from queen.translate_all import translate_all


def get_test_cases():
    """Get all test cases from test-data directory.
    
    Returns:
        list[tuple]: List of (test_name, xml_files, expected_json_dir) tuples
    """
    test_data_root = Path(__file__).parent.parent.parent / "test-data"
    
    if not test_data_root.exists():
        return []
    
    test_cases = []
    
    # Find all xml directories and their corresponding xml-to-json directories
    xml_dirs = sorted(test_data_root.glob("*/*/xml"))
    
    for xml_dir in xml_dirs:
        xml_files = sorted(xml_dir.glob("*.xml"))
        json_dir = xml_dir.parent / "xml-to-json"
        
        if xml_files and json_dir.exists():
            # Create test case name from directory path
            relative_path = xml_dir.parent.relative_to(test_data_root)
            test_name = str(relative_path).replace("/", "-")
            
            test_cases.append((test_name, xml_files, json_dir))
    
    return test_cases


@pytest.mark.parametrize("test_name,xml_files,expected_json_dir", get_test_cases(), 
                         ids=lambda x: x[0] if isinstance(x, tuple) else x)
def test_translate_all(test_name, xml_files, expected_json_dir):
    """Test translate_all with actual test data.
    
    Args:
        test_name: Name of the test case
        xml_files: List of source XML file paths
        expected_json_dir: Directory containing expected output JSON files
    """
    xml_file_paths = [str(f) for f in xml_files]
    
    with tempfile.TemporaryDirectory() as output_dir:
        # Run translate_all
        translate_all(
            src_xml=xml_file_paths,
            output_dir=output_dir,
            prettify=True,
            debug=False,
        )
        
        # Compare generated JSON files with expected ones
        output_path = Path(output_dir)
        generated_json_files = sorted(output_path.glob("*.json"))
        
        assert len(generated_json_files) > 0, \
            f"No JSON files generated in {output_dir}"
        
        for generated_file in generated_json_files:
            expected_file = expected_json_dir / generated_file.name
            
            assert expected_file.exists(), \
                f"Expected JSON file not found: {expected_file}"
            
            # Load and compare JSON
            with open(generated_file, "r", encoding="utf-8") as f:
                generated_json = json.load(f)
            
            with open(expected_file, "r", encoding="utf-8") as f:
                expected_json = json.load(f)
            
            assert generated_json == expected_json, \
                f"JSON mismatch in {generated_file.name}:\n" \
                f"Generated: {json.dumps(generated_json, ensure_ascii=False, indent=2)}\n" \
                f"Expected: {json.dumps(expected_json, ensure_ascii=False, indent=2)}"


if __name__ == "__main__":
    # Run tests with pytest
    pytest.main([__file__, "-v"])
