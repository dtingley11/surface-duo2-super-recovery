#!/usr/bin/env python3
import struct
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} payload.bin manifest.pb", file=sys.stderr)
        return 2

    payload_path = Path(sys.argv[1])
    manifest_path = Path(sys.argv[2])

    with payload_path.open("rb") as payload:
        if payload.read(4) != b"CrAU":
            print("error: not an Android OTA payload.bin", file=sys.stderr)
            return 1

        version = struct.unpack(">Q", payload.read(8))[0]
        manifest_size = struct.unpack(">Q", payload.read(8))[0]
        signature_size = struct.unpack(">I", payload.read(4))[0] if version > 1 else 0
        manifest = payload.read(manifest_size)

    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    manifest_path.write_bytes(manifest)

    print(f"payload version: {version}")
    print(f"manifest size: {manifest_size}")
    print(f"metadata signature size: {signature_size}")
    print(f"wrote: {manifest_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

