# Tools

These are the tools used by this recovery flow.

## Required Host Tools

### Android Platform Tools

Download official `adb` and `fastboot` from Google:

https://developer.android.com/tools/releases/platform-tools

Many Linux distributions also package these as `android-tools`.

### Dynamic Partition Tools

You need:

```bash
lpmake
lpdump
simg2img
```

These are Android image/dynamic partition utilities. On some Linux distributions they are included in `android-tools`; on others they may be packaged separately.

Background docs:

- https://source.android.com/docs/core/ota/dynamic_partitions
- https://source.android.com/docs/core/ota/dynamic_partitions/implement

### Payload Dumper

Use one of these to extract images from `payload.bin`:

- Python payload dumper: https://github.com/vm03/payload_dumper
- Go payload dumper alternative: https://github.com/ssut/payload-dumper-go

This repo's examples use the Python payload dumper.

### Protocol Buffers

`protoc` is used to inspect the OTA payload manifest:

https://github.com/protocolbuffers/protobuf

On many Linux distributions, install the `protobuf` package.

## Quick Package Hints

Arch Linux / CachyOS style:

```bash
sudo pacman -S android-tools protobuf python
```

Debian / Ubuntu style package names vary by release, but commonly include:

```bash
sudo apt install android-sdk-platform-tools protobuf-compiler python3 python3-venv
```

If your distribution does not provide `lpmake`, `lpdump`, or `simg2img`, install Android image tools from your distro or build them from AOSP.

