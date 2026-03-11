"""Test for parse module."""

import json
import tempfile
from pathlib import Path

import pytest

from mona.parse import parse


def find_test_data_dirs():
    """Find all test data directories that contain manifest.json."""
    test_data_root = Path('/src-dir')

    if not test_data_root.exists():
        return []

    # Find all directories containing manifest.json
    manifest_files = list(test_data_root.glob('**/manifest.json'))

    # Return the parent directories (where manifest.json is located)
    test_dirs = [m.parent for m in manifest_files]

    # Filter only directories that have a json/ subdirectory with expected outputs
    test_dirs_with_json = [
        d
        for d in test_dirs
        if (d / 'json').exists() and list((d / 'json').glob('*.json'))
    ]

    return sorted(test_dirs_with_json)


def load_json_file(file_path: Path):
    """Load JSON file and return parsed content."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def compare_json_files(actual_path: Path, expected_path: Path):
    """Compare two JSON files.

    Returns:
        tuple: (is_equal, difference_message)
    """
    if not actual_path.exists():
        return False, f'Actual file not found: {actual_path.name}'

    if not expected_path.exists():
        return False, f'Expected file not found: {expected_path.name}'

    actual_data = load_json_file(actual_path)
    expected_data = load_json_file(expected_path)

    if actual_data == expected_data:
        return True, ''
    else:
        # Provide more detailed comparison info
        return False, f'JSON content mismatch in {actual_path.name}'


# Generate test parameters from test data directories
test_data_dirs = find_test_data_dirs()
test_ids = [f'{d.parent.name}/{d.name}' for d in test_data_dirs]


@pytest.mark.parametrize('test_dir', test_data_dirs, ids=test_ids)
def test_parse(test_dir: Path):
    """Test parse function with test data.

    Args:
        test_dir: Directory containing manifest.json and expected json/ outputs
    """
    # Create temporary directory for output
    with tempfile.TemporaryDirectory() as temp_dir:
        dst_dir = Path(temp_dir)

        # Run parse function
        parse(src_dir=test_dir, dst_dir=dst_dir)

        # Get expected output directory
        expected_dir = test_dir / 'json'

        # Get all expected JSON files
        expected_files = list(expected_dir.glob('*.json'))
        assert len(expected_files) > 0, (
            f'No expected JSON files found in {expected_dir}'
        )

        # Compare each expected file with generated file
        for expected_file in expected_files:
            actual_file = dst_dir / expected_file.name

            is_equal, message = compare_json_files(actual_file, expected_file)

            assert is_equal, (
                f'Mismatch in {expected_file.name} for test case {test_dir.name}\n'
                f'{message}'
            )


@pytest.mark.parametrize('test_dir', test_data_dirs, ids=test_ids)
def test_parse_output_files_exist(test_dir: Path):
    """Test that parse function generates all expected output files.

    Args:
        test_dir: Directory containing manifest.json and expected json/ outputs
    """
    with tempfile.TemporaryDirectory() as temp_dir:
        dst_dir = Path(temp_dir)

        # Run parse function
        parse(src_dir=test_dir, dst_dir=dst_dir)

        # Get expected output files
        expected_dir = test_dir / 'json'
        expected_files = {f.name for f in expected_dir.glob('*.json')}

        # Get actual output files
        actual_files = {f.name for f in dst_dir.glob('*.json')}

        # Check all expected files are generated
        missing_files = expected_files - actual_files
        assert not missing_files, (
            f'Missing output files for test case {test_dir.name}: {missing_files}'
        )

        # Check no unexpected files are generated
        extra_files = actual_files - expected_files
        assert not extra_files, (
            f'Unexpected output files for test case {test_dir.name}: {extra_files}'
        )
