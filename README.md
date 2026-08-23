# Mercusys MR47BE V2 — OpenWrt

**OpenWrt port for the Mercusys MR47BE V2 (IPQ5332 / Wi-Fi 7)**

This repository contains the OpenWrt device support, DTS, image definitions, firmware analysis and build configuration developed specifically for the **Mercusys MR47BE V2**.

> ⚠️ **Status: Experimental / Hardware flashing and full feature validation are still in progress.**
>
> The OpenWrt images have been successfully built and structurally verified. Do not flash them unless you understand UART/U-Boot recovery.

## Hardware

| Component     | Details                                                                                                               |
|---------------|-----------------------------------------------------------------------------------------------------------------------|
| SoC           | Qualcomm IPQ5332                                                                                                      |
| CPU           | 4× Cortex-A53 @ ~1.5 GHz                                                                                              |
| RAM           | 512 MB DDR4                                                                                                           |
| Wi-Fi         | Wi-Fi 7                                                                                                               |
| 2.4 GHz       | SoC-integrated radio                                                                                                  |
| 5 GHz / 6 GHz | QCN9224 via PCIe (QCN9274-compatible `ath12k` firmware)                                                               |
| Ethernet      | 2.5G WAN + 3× 2.5G LAN                                                                                                |
| Switch        | Qualcomm QCA8386 (present on board — **no driver/DTS support yet**, see [Current Limitations](#current-limitations))  |
| USB           | USB 3.0                                                                                                               |
| Flash         | 128 MB NAND + 16 MB SPI-NOR                                                                                           |
| UART          | GPIO18 TX / GPIO19 RX                                                                                                 |
| UART Speed    | 115200 8N1                                                                                                            |
| Bootloader    | U-Boot                                                                                                                |

Hardware information was cross-checked against the Mercusys GPL sources, teardown analysis, and the actual DTB embedded in the built FIT image (see [DTS Verification](#dts-verification) below).

## Current Build

**OpenWrt target:** `qualcommbe/ipq53xx`
**Board:**          `mercusys_mr47be-v2`
**Kernel:**          Linux 6.18.39
**Architecture:**    ARM64

The MR47BE V2-specific DTS and image definitions are included in the build tree.

### Built Images

| Image                       | Size     | Purpose                     |
|-----------------------------|----------|-----------------------------|
| `*-uImage.itb`              | ~6 MB    | FIT kernel image            |
| `*-initramfs-uImage.itb`    | ~22.6 MB | RAM boot / hardware testing |
| `*-squashfs-factory.bin`    | ~21 MB   | Factory/UBI image           |
| `*-squashfs-sysupgrade.bin` | ~20 MB   | OpenWrt sysupgrade          |

The FIT kernel was verified as **unsigned** and compatible with the device's U-Boot configuration.

## DTS Verification

The DTB embedded in the built FIT image was extracted and inspected directly. Confirmed present:

- `qcom,ipq5332-ppe`, `qcom,ipq5332-edma` (packet engine / ethernet DMA)
- `port@1` — label `lan`, `phy-mode = sgmii`, `fixed-link` 2500 Mbps
- `port@2` — label `wan`, `phy-mode = sgmii`
- `wifi@c000000` — `compatible = qcom,ipq5332-wifi`, `status = okay`, `board-id = 0x12`
- PCIe radio — `pci17cb,1109`, `board-id = 0x1015`
- `partition@b00000` → `art`, with `nvmem-layout` → `mac-address@0`
- NAND partition table: `sbl1`, `mibib`, `bootconfig`, `bootconfig1`, `qsee`, `devcfg`, `tme`, `cdt`, `appsblenv`, `appsbl`, `art` (0xB00000), `ubi` (0xD00000)

| Switch | Unconfirmed — a single forum comment claims QCA8386 present; not verified via GPL, teardown photos, or this build's DTS (no `qca8386` node found). No driver/DTS support regardless. |

## Package Versions (this build)

| Package                     | Version         |
|-----------------------------|-----------------|
| kernel                      | 6.18.39         |
| kmod-ath12k                 | 6.18.39.7.2_rc4 |
| ath12k-firmware-qcn9274     | 20260622-r1     |
| ipq-wifi-mercusys_mr47be-v2 | 2026.05.18      |
| wireless-regdb              | 2026.05.30      |
| busybox                     | 1.38.0          |
| dropbear                    | 2026.92         |
| dnsmasq                     | 2.93            |
| firewall4                   | 2025.03.17      |

## Boot / Installation

The MR47BE V2 accepts unsigned FIT images through its U-Boot console.

**UART:**

```text
MR47BE V2
GPIO18 = TX
GPIO19 = RX
GND    = GND
115200 8N1
```

The safest development path is currently:

```text
UART
  ↓
U-Boot
  ↓
TFTP
  ↓
initramfs-uImage.itb
  ↓
Hardware validation
  ↓
Flash strategy
```

The current recommended first-stage test is **initramfs boot**, rather than immediately overwriting NAND.

## Important: Stock Firmware Recovery

The vendor firmware uses a **Cloud firmware format with RSA verification and AES-CBC encrypted payloads**.

Unsigned `_nosign_` firmware files are rejected by the vendor recovery mechanism. Renaming the firmware version or filename does not bypass the verification.

Therefore:

- ❌ `_nosign_` firmware cannot be used through stock web recovery
- ❌ Renaming the firmware does not bypass verification
- ❌ Other TP-Link/Mercusys signed firmware should not be flashed
- ✅ U-Boot + UART + TFTP is the current development path
- ⚠️ Always preserve the original **ART/Wi-Fi calibration partition**

## Critical Partition

The device uses an A/B NAND layout:

```text
rootfs    → A
rootfs_1  → B
```

The **ART partition contains Wi-Fi calibration data and MAC information**.

> ⚠️ **BACK UP ART BEFORE FLASHING ANYTHING. DO NOT ERASE OR OVERWRITE IT.**

The A/B layout and ART partition were confirmed both from the device partition analysis and directly from the DTB in this build (`partition@b00000` → `art`, `nvmem-layout` → `mac-address@0`).

## Current Limitations

The following areas still require hardware validation or further development:

- [ ] Full Wi-Fi 7 validation
- [ ] Correct production BDF extraction/validation
- [ ] **QCA8386 external switch support — not implemented in the current DTS.** Mainline OpenWrt does not currently provide the required QCA8386 driver.
- [ ] WAN/LAN port validation
- [ ] LED/GPIO validation
- [ ] USB validation
- [ ] Full NAND flash/recovery procedure
- [ ] Stock firmware restoration test

## Project Structure

```text
.
├── target/
│   └── linux/
│       └── qualcommbe/
├── package/
│   └── firmware/
│       └── ipq-wifi/
├── README.md
└── LIVE_SESSION_STATE.md
```

## Credits / Sources

- OpenWrt
- Qualcomm IPQ53xx platform
- Mercusys MR47BE V2 GPL source
- Perceival's IPQ53xx / Flint 3 OpenWrt work
- Hardware teardown and reverse-engineering analysis

## Disclaimer

This is an **experimental community port**.

Flashing custom firmware can permanently damage the device if performed incorrectly. Always keep a complete backup of the original firmware, NAND partitions and especially the ART calibration data.

**Use UART recovery whenever possible.**

---

**Project:** `circassion/openwrt-mr47be-v2`
**Device:** Mercusys MR47BE V2
**Target:** `qualcommbe/ipq53xx`
**Status:** 🟡 Experimental / Build complete, structurally verified / Hardware validation ongoing
