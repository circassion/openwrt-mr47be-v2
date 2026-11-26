#!/usr/bin/env bash
#
# Copy the vendor ath12k firmware trees into the build tree.
#
# The firmware is proprietary and is not distributed in this repository.
# Extract it from your own device / stock firmware dump and point this script
# at the directory that contains:
#
#   IPQ5332/hw1.0/     (on-SoC 2.4 GHz firmware, q6_fw1.mdt, iu_fw.mdt, ...)
#   QCN9274/hw2.0/     (PCIe 5/6 GHz firmware, board-2.bin, firmware-2.bin, ...)
#
set -euo pipefail

SRC="${1:?usage: fetch-firmware.sh /path/to/ath12k-firmware [dest]}"
DEST="${2:-$PWD/package/firmware/ath12k-firmware/src}"

if [ ! -d "$SRC" ]; then
	echo "error: source directory not found: $SRC" >&2
	exit 1
fi

found=0
for d in IPQ5332/hw1.0 QCN9274/hw2.0; do
	if [ -d "$SRC/$d" ]; then
		mkdir -p "$DEST/$d"
		cp -a "$SRC/$d/." "$DEST/$d/"
		echo "copied $d"
		found=1
	else
		echo "warning: $SRC/$d not found" >&2
	fi
done

if [ "$found" -eq 0 ]; then
	echo "error: no firmware directories found under $SRC" >&2
	exit 1
fi
