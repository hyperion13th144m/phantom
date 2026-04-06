import argparse
import importlib.metadata
import json
import tomllib
from pathlib import Path

from mona.server import app

PROJECT_ROOT = Path(__file__).resolve().parents[1]
PYPROJECT_PATH = PROJECT_ROOT / "pyproject.toml"
DISTRIBUTION_NAME = "mona"


def get_project_version() -> str:
    try:
        return importlib.metadata.version(DISTRIBUTION_NAME)
    except importlib.metadata.PackageNotFoundError:
        project = tomllib.loads(PYPROJECT_PATH.read_text(encoding="utf-8"))["project"]
        return str(project["version"])


version = get_project_version()
parser = argparse.ArgumentParser()
parser.add_argument("output_dir", help="output directory")
parser.add_argument(
    "-f",
    "--file-name",
    help="output file name",
    default=f"mona-{version}.json",
)

args = parser.parse_args()
filename = Path(args.output_dir) / args.file_name
schema = app.openapi()
filename.write_text(json.dumps(schema, indent=2), encoding="utf-8")
