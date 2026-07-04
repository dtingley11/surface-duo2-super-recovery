#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 IMAGE_DIR" >&2
  exit 2
fi

IMAGE_DIR="$1"

require_image() {
  if [[ ! -f "$IMAGE_DIR/$1.img" ]]; then
    echo "missing required image: $IMAGE_DIR/$1.img" >&2
    exit 1
  fi
}

for img in boot vendor_boot dtbo vbmeta vbmeta_system aop tz hyp modem bluetooth abl dsp keymaster devcfg qupfw uefisecapp imagefv shrm vm-bootsys cpucp featenabler sfsecapp; do
  require_image "$img"
done

echo "About to flash Surface Duo 2 slot_a firmware from: $IMAGE_DIR"
echo "Press Ctrl-C now if this is not an official clean Duo 2 OTA extraction."
sleep 5

fastboot flash boot_a "$IMAGE_DIR/boot.img"
fastboot flash vendor_boot_a "$IMAGE_DIR/vendor_boot.img"
fastboot flash dtbo_a "$IMAGE_DIR/dtbo.img"
fastboot flash vbmeta_a "$IMAGE_DIR/vbmeta.img"
fastboot flash vbmeta_system_a "$IMAGE_DIR/vbmeta_system.img"

fastboot flash aop_a "$IMAGE_DIR/aop.img"
fastboot flash tz_a "$IMAGE_DIR/tz.img"
fastboot flash hyp_a "$IMAGE_DIR/hyp.img"
fastboot flash modem_a "$IMAGE_DIR/modem.img"
fastboot flash bluetooth_a "$IMAGE_DIR/bluetooth.img"
fastboot flash abl_a "$IMAGE_DIR/abl.img"
fastboot flash dsp_a "$IMAGE_DIR/dsp.img"
fastboot flash keymaster_a "$IMAGE_DIR/keymaster.img"
fastboot flash devcfg_a "$IMAGE_DIR/devcfg.img"
fastboot flash qupfw_a "$IMAGE_DIR/qupfw.img"
fastboot flash uefisecapp_a "$IMAGE_DIR/uefisecapp.img"
fastboot flash imagefv_a "$IMAGE_DIR/imagefv.img"
fastboot flash shrm_a "$IMAGE_DIR/shrm.img"
fastboot flash vm-bootsys_a "$IMAGE_DIR/vm-bootsys.img"
fastboot flash cpucp_a "$IMAGE_DIR/cpucp.img"
fastboot flash featenabler_a "$IMAGE_DIR/featenabler.img"
fastboot flash sfsecapp_a "$IMAGE_DIR/sfsecapp.img"

echo "slot_a firmware flash complete"

