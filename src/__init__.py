import argparse

import downloader
import log_handler


def main():
    parser = argparse.ArgumentParser(description="Download playlist as high-quality MP3 with Metadata.")
    parser.add_argument("url", help="The YouTube playlist URL")
    parser.add_argument("dir", nargs='?', default="downloads", help="Output directory")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
    parser.add_argument("--log-file", help="Optional log file path")

    args = parser.parse_args()

    try:
        with log_handler.use_log_file(args.log_file):
            downloader.download_playlist(args.url, args.dir, args.verbose)
    except Exception as exc:
        print(f"Error: {exc}")


if __name__ == "__main__":
    main()
