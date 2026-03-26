import argparse
import os


def main() -> None:
    import uvicorn

    parser = argparse.ArgumentParser(description="Start crow API server")
    parser.add_argument(
        "--src-dir", default="/src-dir", help="Source directory (SRC_DIR)"
    )
    parser.add_argument(
        "--dst-dir", default="/dst-dir", help="Destination directory (DST_DIR)"
    )
    parser.add_argument(
        "--log-dir", default="/var/log/crow", help="Log directory (LOG_DIR)"
    )
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

    # crow.server がモジュールレベルで環境変数を読むため、
    # crow.server を import 前にセットする
    os.environ["SRC_DIR"] = args.src_dir
    os.environ["DST_DIR"] = args.dst_dir
    os.environ["LOG_DIR"] = args.log_dir
    os.environ["LOG_LEVEL"] = args.log_level

    uvicorn.run(
        "crow.server:app",
        host=args.host,
        port=args.port,
        reload=args.reload,
    )


if __name__ == "__main__":
    main()
