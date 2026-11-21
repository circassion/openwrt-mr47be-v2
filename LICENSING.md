# Licensing / Lisans

This repository contains the original work needed to reproduce the OpenWrt port
for the **Mercusys MR47BE V2** (Qualcomm IPQ5332). It does **not** contain the
OpenWrt source tree, the Linux kernel, LuCI, or Qualcomm firmware binaries.

## Component map

| Component / path | License | Notes |
|---|---|---|
| `patches/**` | **GPL-2.0-only** | Patches against Linux/OpenWrt, which are GPL-2.0. |
| `source/target/linux/qualcommbe/**` | **GPL-2.0-only** | Target files, base-files and image recipes derived from OpenWrt. |
| `source/target/linux/qualcommbe/dts/*.dts` | **GPL-2.0-or-later OR BSD-3-Clause** | SPDX header in each file. |
| `source/package/luci/luci-app-mr47be-boot/**` | **GPL-2.0-or-later** | `PKG_LICENSE` in the Makefile. |
| `source/package/network/mr47be-die-switch/**` | **GPL-2.0-or-later** | Original shell/C work. |
| `source/package/firmware/mr47be-wan-probe/**` | **GPL-2.0-or-later** | Original shell script. |
| `source/package/firmware/mr47be-wifi-cal/**` | **GPL-2.0-or-later** | Original shell script. |
| `scripts/**`, `tools/**` | **GPL-2.0-or-later** | Build, fetch and flash helpers. |
| `*.md` (documentation) | **CC BY-SA 4.0** | Attribution + share-alike. |
| `config.seed`, `feeds.lock`, `*.json` | no copyright | Configuration/data; provided as-is. |

Full license texts: [LICENSES](LICENSES). A short summary is also available
as [LICENSE](LICENSE).

## Qualcomm Wi-Fi firmware (not included)

The firmware needed by `ath12k` is **not** part of this repository. It is
proprietary Qualcomm Atheros software covered by
`LicenseRef-QualcommAtheros-ath10k` (full text in [LICENSES](LICENSES)).

That license permits redistribution **only in binary form and without
modification**, and only for use with a Qualcomm Atheros chipset. The firmware
used by this port comes from the vendor firmware and the QCN9274 board file is
modified for this device, so it cannot be redistributed here.

The build helpers therefore:

1. download the unmodified upstream files from `linux-firmware` at a pinned
   commit, and
2. ask you to copy the vendor-specific `IPQ5332/hw1.0` files from **your own**
   device or stock firmware dump.

If you publish a built image, remember that it contains Qualcomm firmware:
keep the copyright notice and disclaimer, do not reverse engineer the firmware,
and do not present it as your own work. This is your responsibility as the
distributor of the image.

## Third-party components (not bundled)

| Component | License | Where |
|---|---|---|
| OpenWrt | GPL-2.0 | https://github.com/openwrt/openwrt |
| Linux kernel | GPL-2.0-only | https://kernel.org |
| LuCI | Apache-2.0 | https://github.com/openwrt/luci |
| linux-firmware (ath12k) | Qualcomm Atheros firmware license | https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git |

The Apache-2.0 text is included in [LICENSES](LICENSES) for reference because
the LuCI application runs inside the LuCI framework; the framework itself is
fetched during the build and is not redistributed here.

## SPDX identifiers

Files that carry an explicit SPDX tag are governed by that tag. If a file has
no tag, the component map above applies.

## No warranty

The software is provided "as is", without warranty of any kind. Flashing
custom firmware can brick the device. See the disclaimer in [README.md](README.md).

## Türkçe özet

- Bu depo **OpenWrt ağacını ve Qualcomm firmware'ini içermez**; sadece bu cihaz
  için yazdığımız kaynak, yama ve belgeleri içerir.
- Betikler/yamalar **GPL-2.0**, DTS **GPL-2.0 veya BSD-3-Clause**, belgeler
  **CC BY-SA 4.0**.
- Qualcomm Wi-Fi firmware'i kendi lisansına tabidir ve **değiştirilmiş binary
  olarak dağıtılamaz**; bu yüzden repoda yok. Kendi cihazınızdan/stok
  yedeğinizden alıp yerel build'de kullanabilirsiniz.
- Bu metin hukuki tavsiye değildir.
