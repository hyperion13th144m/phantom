#!/bin/bash
set -e

# Usage function
usage() {
    cat <<EOF
Usage: $0 <command> [options]

Available commands:
  build-all          Build all components
  gen-test-data      Generate test data
  run-test           Run tests
  translate-all      Translate all documents
  translate          Translate single document
  help               Show this help message

Examples:
  $0 build-all
  $0 build-pkg
  $0 translate --help
  $0 run-test

For command-specific options, run:
  $0 <command> --help
EOF
}

# Check if no arguments provided
if [ $# -eq 0 ]; then
    echo "Error: No command specified"
    echo ""
    usage
    exit 1
fi

COMMAND=$1
shift

# Execute the appropriate script based on the command
case "$COMMAND" in
    build-all)
        exec ./scripts/build-all.sh "$@"
        ;;
    build-es-mapping)
        exec ./scripts/build-es-mapping.sh "$@"
        ;;
    run-test)
        exec ./scripts/run-test.sh "$@"
        ;;
    translate-all)
        exec ./scripts/translate-all.sh "$@"
        ;;
    translate)
        exec ./scripts/translate.sh "$@"
        ;;
    help|--help|-h)
        usage
        exit 0
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'"
        echo ""
        usage
        exit 1
        ;;
esac
