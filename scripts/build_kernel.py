#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
import argparse
import subprocess
import sys


def main():
    p = argparse.ArgumentParser(description="Pack FdLoader and target binary into a boot image")
    p.add_argument("--loader", required=True)
    p.add_argument("--target", required=True)
    p.add_argument("--dtb", required=True)
    p.add_argument("--mkbootimg", required=True)
    p.add_argument("--payload", required=True)
    p.add_argument("--base", required=True)
    p.add_argument("--kernel-offset", required=True)
    p.add_argument("--ramdisk-offset", required=True)
    p.add_argument("--tags-offset", required=True)
    p.add_argument("--header-version", required=True)
    p.add_argument("--output", required=True)
    args = p.parse_args()

    with open(args.loader, "rb") as f:
        loader = f.read()
    with open(args.target, "rb") as f:
        target = f.read()

    if len(loader) % 16:
        sys.exit(f"loader size is not a multiple of 16: {len(loader)}")
    if len(target) % 8:
        sys.exit(f"target size is not a multiple of 8: {len(target)}")

    with open(args.payload, "wb") as f:
        f.write(loader + target)
    print(f"loader {len(loader)} + target {len(target)} = {len(loader) + len(target)} bytes")

    subprocess.run([
        sys.executable, args.mkbootimg,
        "--kernel", args.payload,
        "--ramdisk", "/dev/null",
        "--dtb", args.dtb,
        "--base", args.base,
        "--kernel_offset", args.kernel_offset,
        "--ramdisk_offset", args.ramdisk_offset,
        "--tags_offset", args.tags_offset,
        "--header_version", args.header_version,
        "-o", args.output,
    ], check=True)
    print(f"{args.output} generated")


if __name__ == "__main__":
    main()
