#!/usr/bin/env bash
#
# Reproducible build for the Mercusys MR47BE V2 (IPQ5332) OpenWrt port.
# The v27 release was built from OpenWrt SNAPSHOT commit 83384b8
# (kernel 6.18.62) with the patches in ./patches.
#
# Usage:
#   ./build/build.sh
#   WORK=/path/to/work JOBS=8 ./build/build.sh
#   ATH12K_FW_DIR=/path/to/ath12k-firmware ./build/build.sh
#
set -euo pipefail

BASE_COMMIT="83384b861ffbafe757c803e654e89b8e0ab2dbd0"
OPENWRT_REPO="${OPENWRT_REPO:-https://github.com/openwrt/openwrt.git}"
WORK="${WORK:-$PWD/openwrt-mr47be-v27}"
JOBS="${JOBS:-$(nproc)}"
VERSION_NUMBER="${VERSION_NUMBER:-v27}"
VERSION_CODE="${VERSION_CODE:-mr47be-v27}"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '\n==> %s\n' "$*"; }

if [ ! -d "$WORK/.git" ]; then
	log "Cloning OpenWrt into $WORK"
	git clone --filter=blob:none "$OPENWRT_REPO" "$WORK"
fi

cd "$WORK"

log "Checking out base commit $BASE_COMMIT"
if ! git cat-file -e "${BASE_COMMIT}^{commit}" 2>/dev/null; then
	git fetch origin "$BASE_COMMIT"
fi
git checkout --detach "$BASE_COMMIT"

log "Applying MR47BE patches"
for p in "$HERE"/patches/*.patch; do
	[ -s "$p" ] || continue
	name="$(basename "$p")"
	if git apply --reverse --check "$p" 2>/dev/null; then
		echo "  - $name (already applied)"
	else
		echo "  - $name"
		git apply --check "$p"
		git apply "$p"
	fi
done

log "Updating feeds at the pinned revisions"
cp "$HERE/feeds.conf" feeds.conf
./scripts/feeds update -a
while read -r name url rev; do
	[ -n "${name:-}" ] || continue
	echo "  - $name @ $rev"
	if ! git -C "feeds/$name" cat-file -e "${rev}^{commit}" 2>/dev/null; then
		git -C "feeds/$name" fetch origin "$rev"
	fi
	git -C "feeds/$name" checkout --detach "$rev"
done < "$HERE/feeds.lock"
# "install -a" is required: without it the packages feed is only partially
# linked and luci-app-sqm / luci-app-upnp / luci-app-wol / etherwake /
# miniupnpd are not selectable at all ("no such package" during install).
./scripts/feeds install -a

log "Applying configuration seed"
cp "$HERE/config.seed" .config
make defconfig

log "Vendor Wi-Fi firmware"
if [ -n "${ATH12K_FW_DIR:-}" ]; then
	"$HERE/scripts/fetch-firmware.sh" "$ATH12K_FW_DIR" \
		"$WORK/package/firmware/ath12k-firmware/src"
else
	echo "  ATH12K_FW_DIR is not set."
	echo "  The image will build, but Wi-Fi will not work without the vendor"
	echo "  ath12k firmware. See build/README.md."
fi

log "Downloading package sources (jobs=$JOBS)"
make -j"$JOBS" download

log "Building (jobs=$JOBS, version $VERSION_NUMBER)"
make -j"$JOBS" VERSION_NUMBER="$VERSION_NUMBER" VERSION_CODE="$VERSION_CODE"

log "Done. Images:"
find bin/targets/qualcommbe/ipq53xx -maxdepth 1 -type f -printf '  %f\n' 2>/dev/null || true
