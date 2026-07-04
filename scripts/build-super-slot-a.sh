#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 IMAGE_DIR OUTPUT_SUPER_IMG" >&2
  exit 2
fi

IMAGE_DIR="$1"
OUTPUT="$2"

for img in odm product system system_ext vendor; do
  if [[ ! -f "$IMAGE_DIR/$img.img" ]]; then
    echo "missing required image: $IMAGE_DIR/$img.img" >&2
    exit 1
  fi
done

size_of() {
  stat -c '%s' "$1"
}

ODM_SIZE="$(size_of "$IMAGE_DIR/odm.img")"
PRODUCT_SIZE="$(size_of "$IMAGE_DIR/product.img")"
SYSTEM_SIZE="$(size_of "$IMAGE_DIR/system.img")"
SYSTEM_EXT_SIZE="$(size_of "$IMAGE_DIR/system_ext.img")"
VENDOR_SIZE="$(size_of "$IMAGE_DIR/vendor.img")"

mkdir -p "$(dirname "$OUTPUT")"

lpmake \
  --metadata-size 65536 \
  --metadata-slots 3 \
  --super-name super \
  --device super:15032385536 \
  --group surface_dynamic_partitions_a:7511998464 \
  --group surface_dynamic_partitions_b:7511998464 \
  --partition "odm_a:readonly:${ODM_SIZE}:surface_dynamic_partitions_a" \
  --image "odm_a=$IMAGE_DIR/odm.img" \
  --partition odm_b:readonly:0:surface_dynamic_partitions_b \
  --partition "product_a:readonly:${PRODUCT_SIZE}:surface_dynamic_partitions_a" \
  --image "product_a=$IMAGE_DIR/product.img" \
  --partition product_b:readonly:0:surface_dynamic_partitions_b \
  --partition "system_a:readonly:${SYSTEM_SIZE}:surface_dynamic_partitions_a" \
  --image "system_a=$IMAGE_DIR/system.img" \
  --partition system_b:readonly:0:surface_dynamic_partitions_b \
  --partition "system_ext_a:readonly:${SYSTEM_EXT_SIZE}:surface_dynamic_partitions_a" \
  --image "system_ext_a=$IMAGE_DIR/system_ext.img" \
  --partition system_ext_b:readonly:0:surface_dynamic_partitions_b \
  --partition "vendor_a:readonly:${VENDOR_SIZE}:surface_dynamic_partitions_a" \
  --image "vendor_a=$IMAGE_DIR/vendor.img" \
  --partition vendor_b:readonly:0:surface_dynamic_partitions_b \
  --virtual-ab \
  --sparse \
  --output "$OUTPUT"

echo "built: $OUTPUT"

