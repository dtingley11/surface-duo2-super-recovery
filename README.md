# Surface Duo 2 Super Partition Recovery

Steps to rebuild and flash a Microsoft Surface Duo 2 `super.img` from an official OTA package.

This is for the case where the physical `super` partition still exists, but the logical partitions inside it are broken or from the wrong device.

## What This Fixes

Use this guide if:

- Your Surface Duo 2 still enters bootloader or recovery.
- `fastboot getvar product` reports `surfaceduo2`.
- `/dev/block/by-name/super` exists.
- Android will not boot because `super` contains bad dynamic partition metadata or wrong logical images.

Do **not** use this to create GPT partitions from scratch. `system`, `vendor`, `product`, `system_ext`, and `odm` are logical partitions inside `super`.

## Requirements

Linux host with:

```bash
adb
fastboot
lpmake
lpdump
simg2img
protoc
python3
```

You also need:

- An unlocked bootloader.
- The Microsoft Surface Duo 2 OTA `.zip`.
- A payload dumper, such as `payload_dumper.py` or `payload-dumper-go`.

Tool links:

- Android SDK Platform Tools, for `adb` and `fastboot`: https://developer.android.com/tools/releases/platform-tools
- AOSP dynamic partition docs, for `lpmake`/`lpdump` concepts: https://source.android.com/docs/core/ota/dynamic_partitions
- Python payload dumper used during my recovery: https://github.com/vm03/payload_dumper
- Go payload dumper alternative: https://github.com/ssut/payload-dumper-go
- Protocol Buffers / `protoc`: https://github.com/protocolbuffers/protobuf

See [docs/tools.md](docs/tools.md) for package hints.

## 1. Confirm The Device

Boot to bootloader:

```bash
adb reboot bootloader
```

Check:

```bash
fastboot getvar product
fastboot getvar unlocked
fastboot getvar current-slot
fastboot getvar partition-size:super
```

Expected:

```text
product: surfaceduo2
unlocked: yes
current-slot: a
partition-size:super: 0x380000000
```

`0x380000000` is `15032385536` bytes.

## 2. Extract The OTA Cleanly

Do not reuse an old payload output folder.

```bash
mkdir -p work
python3 -m venv work/venv
work/venv/bin/pip install -r /path/to/payload_dumper/requirements.txt

rm -rf work/images
mkdir -p work/images

PYTHONPATH=/path/to/payload_dumper \
work/venv/bin/python /path/to/payload_dumper/payload_dumper.py \
  /path/to/payload.bin \
  --out work/images
```

If your OTA is still zipped:

```bash
unzip SurfaceDuo2-OTA.zip payload.bin -d work
```

## 3. Read The OTA Dynamic Partition Manifest

```bash
python3 scripts/extract-payload-manifest.py work/payload.bin work/manifest.pb
protoc --decode_raw < work/manifest.pb | tail -120
```

For the known working Duo 2 OTA, the dynamic group is:

```text
surface_dynamic_partitions
size: 7511998464
partitions:
  odm
  product
  system
  system_ext
  vendor
```

## 4. Build `super.img`

For slot `a`, run:

```bash
scripts/build-super-slot-a.sh work/images work/super-duo2-slot-a.img
```

The script uses:

```text
super size: 15032385536
group size: 7511998464
metadata size: 65536
metadata slots: 3
group names:
  surface_dynamic_partitions_a
  surface_dynamic_partitions_b
```

It creates populated `_a` partitions and empty `_b` partitions:

```text
odm_a
product_a
system_a
system_ext_a
vendor_a

odm_b
product_b
system_b
system_ext_b
vendor_b
```

## 5. Validate The Image

```bash
simg2img work/super-duo2-slot-a.img work/super.raw
lpdump work/super.raw
```

Expected group names:

```text
surface_dynamic_partitions_a
surface_dynamic_partitions_b
```

Expected logical partitions:

```text
odm_a
product_a
system_a
system_ext_a
vendor_a
```

## 6. Flash

Bootloader fastboot worked for my recovery:

```bash
fastboot flash super work/super-duo2-slot-a.img
```

Then flash matching active slot images from the same clean OTA:

```bash
scripts/flash-slot-a-firmware.sh work/images
```

Finally:

```bash
fastboot reboot
```

First boot can take several minutes.

## Safety Notes

- Do not relock the bootloader until the phone boots reliably and all flashed images are stock and from the same build.
- Do not flash images from mixed payload extraction folders.
- Do not manually create physical `system`, `vendor`, `product`, `system_ext`, or `odm` partitions.
- Back up `persist`, `modemst1`, `modemst2`, `fsg`, `fsc`, and GPT data after recovery.

## Docs

- Android dynamic partitions: https://source.android.com/docs/core/ota/dynamic_partitions
- Implement dynamic partitions: https://source.android.com/docs/core/ota/dynamic_partitions/implement
- Userspace fastboot / fastbootd: https://source.android.com/docs/core/architecture/bootloader/fastbootd
- Android SDK Platform Tools: https://developer.android.com/tools/releases/platform-tools
