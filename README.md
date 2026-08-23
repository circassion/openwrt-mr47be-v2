Mercusys MR47BE V2 — OpenWrt

OpenWrt port for the Mercusys MR47BE V2 (IPQ5332 / Wi-Fi 7)

This repository contains the OpenWrt device support, DTS, image definitions, firmware analysis and build configuration developed specifically for the Mercusys MR47BE V2.

⚠️ Status: Experimental / Hardware flashing and full feature validation are still in progress.

The OpenWrt images have been successfully built. Do not flash them unless you understand UART/U-Boot recovery.

Hardware
Component	Details
SoC	Qualcomm IPQ5332
CPU	4× Cortex-A53 @ ~1.5 GHz
RAM	512 MB DDR4
Wi-Fi	Wi-Fi 7, QCN9224
2.4 GHz	SoC integrated radio
5 GHz / 6 GHz	QCN9224 via PCIe
Ethernet	2.5G WAN + 3× 2.5G LAN
Switch	Qualcomm QCA8386
USB	USB 3.0
Flash	128 MB NAND + 16 MB SPI-NOR
UART	GPIO18 TX / GPIO19 RX
UART Speed	115200 8N1
Bootloader	U-Boot

Hardware information was cross-checked against the Mercusys GPL sources and teardown analysis.

Current Build

OpenWrt target: qualcommbe/ipq53xx
Board: mercusys_mr47be-v2
Kernel: Linux 6.18.39
Architecture: ARM64

The MR47BE V2-specific DTS and image definitions are included in the build tree.

Built Images
Image	Size	Purpose
*-uImage.itb	~6 MB	FIT kernel image
*-initramfs-uImage.itb	~22.6 MB	RAM boot / hardware testing
*-squashfs-factory.bin	~21 MB	Factory/UBI image
*-squashfs-sysupgrade.bin	~20 MB	OpenWrt sysupgrade

The FIT kernel was verified as unsigned and compatible with the device's U-Boot configuration.

Boot / Installation
The MR47BE V2 accepts unsigned FIT images through its U-Boot console.

UART:
MR47BE V2
GPIO18 = TX
GPIO19 = RX
GND    = GND
115200 8N1

The safest development path is currently:

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

The current recommended first-stage test is initramfs boot, rather than immediately overwriting NAND.

Important: Stock Firmware Recovery

The vendor firmware uses a Cloud firmware format with RSA verification and AES-CBC encrypted payloads.

Unsigned _nosign_ firmware files are rejected by the vendor recovery mechanism. Renaming the firmware version or filename does not bypass the verification.

Therefore:

   ❌ _nosign_ firmware cannot be used through stock web recovery
   ❌ Renaming the firmware does not bypass verification
   ❌ Other TP-Link/Mercusys signed firmware should not be flashed
   ✅ U-Boot + UART + TFTP is the current development path
   ⚠️ Always preserve the original ART/Wi-Fi calibration partition


Critical Partition

The device uses an A/B NAND layout:

rootfs    → A
rootfs_1  → B

The ART partition contains Wi-Fi calibration data and MAC information.

⚠️ BACK UP ART BEFORE FLASHING ANYTHING. DO NOT ERASE OR OVERWRITE IT.

The A/B layout and ART partition were confirmed from the device partition analysis.

Current Limitations

The following areas still require hardware validation or further development:

Full Wi-Fi 7 validation

> Correct production BDF extraction/validation
> QCA8386 Ethernet switch support
> WAN/LAN port validation
> LED/GPIO validation
> USB validation
> Full NAND flash/recovery procedure
> Stock firmware restoration test

The QCA8386 is currently the major Ethernet-side development item. Mainline OpenWrt does not currently provide the required QCA8386 support.

Project Structure
.
├── target/
│   └── linux/
│       └── qualcommbe/
├── package/
│   └── firmware/
│       └── ipq-wifi/
├── README.md
└── LIVE_SESSION_STATE.md

    Credits / Sources

    OpenWrt
    Qualcomm IPQ53xx platform
    Mercusys MR47BE V2 GPL source
    Perceival's IPQ53xx / Flint 3 OpenWrt work
    Hardware teardown and reverse-engineering analysis
    Disclaimer

This is an experimental community port.

Flashing custom firmware can permanently damage the device if performed incorrectly. Always keep a complete backup of the original firmware, NAND partitions and especially the ART calibration data.

Use UART recovery whenever possible.

Project: circassion/openwrt-mr47be-v2
Device: Mercusys MR47BE V2
Target: qualcommbe/ipq53xx
Status: 🟡 Experimental / Build complete / Hardware validation ongoing
