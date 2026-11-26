# Reproducible build — MR47BE V2 (v27)

This directory contains the recipe and the device-specific changes needed to
rebuild the OpenWrt image for the **Mercusys MR47BE V2** (Qualcomm IPQ5332,
Wi-Fi 7).

The v27 image was built from:

| Item | Value |
|---|---|
| OpenWrt base commit | `83384b861ffbafe757c803e654e89b8e0ab2dbd0` |
| Kernel | 6.18.62 |
| Target / board | `qualcommbe/ipq53xx` / `mercusys,mr47be-v2` |
| Version stamp | `v27` / `mr47be-v27` |
| LuCI feed | `5599f42b0eb861cd0414391fb412b0947b1e4e13` |
| Packages feed | `0d5f51b58e878508ff2df6189b98c6511c33ae51` |

The image includes LuCI, `sysupgrade` support, the MR47BE boot selector, the
MR47BE port setup, Wi-Fi 2.4/5/6 GHz and SSH.

## What the image contains

- **LAN1 at 100M / 1G / 2.5G.** The SoC↔switch trunk is described with
  `qcom,fixed-trunk-speed = <2500>` plus a `fixed-link` node, and the die
  port-4 MAC clocks are programmed with the vendor sequence. Without this the
  port kept bouncing between 100M and 2.5G.
- **WAN that is not speed-pinned.** The SoC MAC↔PHY link stays a fixed
  `2500base-x`; the QCA8084 PHY negotiates the line side itself.
- **PPPoE.** `ppp-mod-pppoe`, `kmod-pppoe` and `luci-proto-ppp` are enabled.
- **Clean port list.** Only `wan` and `lan` are exposed. `mr47be-polish` now
  runs at `START=25` (after `wan-rename`, `START=19`) and rewrites the WAN
  device name to `wan` in `/etc/board-base.json` **and** in the runtime copy
  `/tmp/sysinfo/board.json`, so LuCI no longer draws a dead `gmac1` card.
- **Working `apk`.** The 404 target-feed line is dropped at boot from
  `/etc/apk/repositories.d/distfeeds.list` (the file `apk` actually reads —
  earlier revisions patched `/etc/apk/repositories`, which does not exist on
  this image, so the fix never had any effect).
- **Extra kernel modules, built in:** `kmod-nf-tproxy`, `kmod-nft-tproxy`,
  `kmod-amneziawg` (AmneziaWG 3.1), `amneziawg-tools`, `luci-proto-amneziawg`.
- **Extra LuCI apps:** `luci-app-mr47be-boot` (stock ⇄ OpenWrt boot
  selector), `luci-app-sqm`, `luci-app-upnp` + `miniupnpd-nftables`,
  `luci-app-wol`, `luci-app-vantage` and `luci-theme-vantage`.

## Changes in this revision (v26 → v27)

| Area | Change |
|---|---|
| AmneziaWG | `package/amneziawg/kmod-amneziawg/Makefile` gets a custom `Build/Prepare`: the upstream tarball keeps the module in `<root>/src`, and OpenWrt's default prepare step moves that directory up one level, which left `M=` without a Makefile ("Makefile: No such file or directory"). The tarball is now extracted with `--strip-components=2` straight into `$(PKG_BUILD_DIR)/src`. |
| Feed packages | `luci-app-sqm`, `luci-app-upnp`, `luci-app-wol`, `miniupnpd-nftables` and `etherwake` live in the packages feed but were never linked, so the v26 install stage failed with "no such package". `build.sh` now runs `./scripts/feeds install -a` (all feeds, not a subset) before `make defconfig`. |
| WAN device name | `mr47be-polish` moved from `START=19` to `START=25` so it runs after `wan-rename`, and it patches both `/etc/board-base.json` and `/tmp/sysinfo/board.json` instead of only the former. |
| `apk` feed | The 404 target-feed line is now removed from `/etc/apk/repositories.d/distfeeds.list`. |
| WAN LED | `01_leds` uses the netdev trigger `wan` instead of `gmac1`, matching the renamed interface. |
| `96-mr47be-wan-fix` | The v13 hack that rewrote `"device": "wan"` → `"device": "gmac1"` in `/etc/board-base.json` is gone; it was the reason the WAN port showed up as a dead `gmac1` tile in LuCI. |

## WAN / PPPoE notes

The WAN works, but it settles late: `mr47be-die-switch` flips the integrated
QCA8084 die from the vendor's factory bypass mode (`WORK_MODE 0x20`) into
switch mode (`0x10`) at `START=21`, and only after that does the WAN jack
(behind the die's fabric, port-1) come up and PPPoE can negotiate. A cold boot
therefore needs roughly a minute before the WAN is usable.

Verified on the router running v27:

| Item | Result |
|---|---|
| LAN1 (`lan`) | `Speed: 2500Mb/s`, link detected |
| LAN2 / LAN3 (die ports 3/4) | link up at 1000M |
| WAN | link up, PPPoE session established, default route in place |
| Internet | ping / DNS / HTTP all OK |

If PPPoE reports an error and then stays down, the router recovers with one of
these, in order of least effort:

1. **Toggle the WAN interface** — LuCI → Network → Interfaces → WAN → *Disable*,
   wait a few seconds, then *Enable* (or `ifdown wan && ifup wan`).
2. **Reboot** — a cold or warm reboot re-runs the flip and the WAN link comes
   back with a fresh PPPoE session. This is the reliable fallback.

Two details of the die-switch implementation are worth knowing when debugging
the WAN, because they are the reason the flip is not instant:

* the port lookup tables are programmed correctly (`LK0={p1}`, `LK1={p0}`,
  `LK2..LK5` = the LAN group), so the fabric VLAN split is in place;
* `PS1` (port-1 `PORT_STATUS`, `0x80`) is never written by the die-switch
  script — it only programs `PS0/PS2/PS3/PS4/PS5` — and the port-1
  RCG/CBCR block is not programmed either, unlike the port-4/port-5 blocks.
  On a unit that ended up with a stale port-1 status the die reported the WAN
  port as 10M/half duplex and nothing was passed through it. The script's own
  watchdog notices this (`WAN-DEAD MOD-A detected: ... p1_tx=0->0`) but only
  tries a PHY reset, which does not help.

Programming `PS1` together with the port-1 RCG/CBCR block is the open task for
the next revision.

## Requirements

- Ubuntu 24.04 (or a similar recent x86_64 Linux)
- ~35 GB free disk space
- 16 GB RAM recommended; use `JOBS=8` on smaller machines
- Build dependencies:

```sh
sudo apt update
sudo apt install build-essential clang flex bison g++ gawk gcc-multilib \
  g++-multilib gettext git libncurses-dev libssl-dev python3 \
  python3-setuptools rsync unzip zlib1g-dev file wget
```

The AmneziaWG kernel module is downloaded from GitHub during the build, so the
build machine needs network access to `github.com`.

## Quick start

```sh
git clone https://github.com/circassion/openwrt-mr47be-v2.git
cd openwrt-mr47be-v2
./build/build.sh
```

By default the OpenWrt tree is created in `./openwrt-mr47be-v27` and the
images end up there, under `bin/targets/qualcommbe/ipq53xx/`.

Useful overrides:

```sh
WORK=/srv/openwrt-mr47be JOBS=8 ./build/build.sh
OPENWRT_REPO=https://git.openwrt.org/openwrt/openwrt.git ./build/build.sh
```

## Vendor Wi-Fi firmware (not included)

The Qualcomm `ath12k` firmware is proprietary and is **not** part of this
repository. Without it the image still builds, but Wi-Fi will not work.

Extract the firmware from your own device or stock firmware dump and arrange it
like this:

```text
ath12k-firmware/
├── IPQ5332/
│   └── hw1.0/      # q6_fw1.mdt, iu_fw.mtd, ...
└── QCN9274/
    └── hw2.0/      # board-2.bin, firmware-2.bin, regdb.bin, ...
```

Then build with:

```sh
ATH12K_FW_DIR=/path/to/ath12k-firmware ./build/build.sh
```

The per-device calibration file `cal-ahb-c000000.wifi.bin` is also not
distributed. The hotplug script `12-ath12k-caldata` extracts the calibration
data from the router's ART partition at boot. If you have a local copy you can
place it in `package/firmware/mr47be-wifi-cal/files/` before building.

The `ipq-wifi` board file for this board is device specific as well and is not
distributed; drop it into `package/firmware/ipq-wifi/files/` if you have it.

See [../LICENSING.md](../LICENSING.md) for the firmware license terms.

## Output files

After a successful build:

```text
openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.ubi
openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-sysupgrade.bin
openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-uImage.itb
openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2.manifest
```

The `factory.ubi` image is also the payload used by the stock-WebUI transition
container. Building that container additionally requires a stock **1.1.11**
reference image and the local container tooling. Neither the stock image nor
the tooling is distributed here; use your own dump.

## Configuration notes

- `config.seed` is the exact `.config` (target, packages, LuCI apps).
- `feeds.conf` lists only the two feeds used by the build.
- `feeds.lock` pins both feeds to the exact commits.
- `patches/` contains the complete diff against the base commit:
  - `0001-openwrt-core.patch` — packages, LuCI apps, include files, tools
  - `0002-target-qualcommbe.patch` — DTS, drivers, target files, kernel patches
  - `0003-target-generic.patch` — generic kernel backports

The default wireless configuration uses the key `12345678`. Change it after the
first boot.

## Difference from the published v26 image

The published `v26` release was cut before the last package additions were
made, and two of its boot-time fixes never fired:

* `kmod-amneziawg`, `amneziawg-tools` and `luci-proto-amneziawg` are **not** in
  the v26 image — the module source download failed during that build;
* `luci-app-sqm`, `luci-app-upnp`, `luci-app-wol` and `miniupnpd-nftables` are
  **not** in the v26 image either — the packages feed was only partially
  linked, so the install stage aborted;
* v26's `mr47be-polish` ran before `wan-rename`, so `/etc/board.json` kept the
  stale `gmac1` device name, and its `apk` fix patched a file that does not
  exist on this image.

Building from this recipe gives you the v26 data path **plus** all of the
above, correctly wired.

## What is intentionally not in this repository

- OpenWrt, Linux and LuCI source trees (fetched during the build)
- Qualcomm `ath12k` firmware and the device calibration blobs
- Stock Mercusys firmware images and the stock-WebUI transition container
- Personal credentials, SSH keys, Wi-Fi passwords, MAC addresses or build logs

## License

The build recipe and patches are covered by the component map in
[../LICENSING.md](../LICENSING.md).
