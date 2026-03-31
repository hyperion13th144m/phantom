import argparse
import os


def main() -> None:
    import uvicorn

    parser = argparse.ArgumentParser(description="Start mona API server")
    parser.add_argument(
        "--data-dir", default="/data-dir", help="Destination directory (DST_DIR)"
    )
    parser.add_argument("--log-dir", help="Log directory (LOG_DIR)")
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Log level (LOG_LEVEL)",
    )
    parser.add_argument("--host", default="0.0.0.0", help="Bind host")
    parser.add_argument("--port", type=int, default=8000, help="Bind port")
    parser.add_argument(
        "--reload", action="store_true", help="Enable auto-reload (dev only)"
    )
    args = parser.parse_args()

    # mona.server がモジュールレベルで環境変数を読むため、
    # mona.server を import 前にセットする
    os.environ["DATA_DIR"] = args.data_dir
    os.environ["LOG_DIR"] = (
        args.log_dir if args.log_dir else os.environ.get("LOG_DIR", "/var/log/mona")
    )
    os.environ["LOG_LEVEL"] = args.log_level

    uvicorn.run(
        "mona.server:app",
        host=args.host,
        port=args.port,
        reload=args.reload,
    )


if __name__ == "__main__":
    main()
