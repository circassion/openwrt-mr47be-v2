# Release v0.1.0-test3 — MR47BE V2 (IPQ5332) OpenWrt

⚠️ **EXPERIMENTAL – RAM BOOT ONLY. DO NOT FLASH TO NAND.**

This is the third experimental build for the Mercusys MR47BE V2. It addresses all 4 critical blockers identified in the [PRE_TEST_CHECK.md](PRE_TEST_CHECK.md) audit of test1/test2. The images are fully validated, structurally sound, and ready for safe RAM-based hardware testing.

---

## What's fixed vs test1/test2

| # |                  Fix                                | Impact                                                                                               |
|---|-----------------------------------------------------|------------------------------------------------------------------------------------------------------|
| 1 | **NAND partition table aligned to real hardware** – `0:art` at `0x900000` / `0x200000`, `ubi` at `0xB80000` / `0x34C0000`; A/B slots (`rootfs_1`, etc.) preserved read-only | Eliminates soft-brick risk (Bulgu B)                                                                                                       |
| 2 | **PHY `compatible` removed** – dropped the hard-coded `ethernet-phy-id004d.d0b0` (QCA8075) which was blocking auto-probe | Kernel now auto-detects QCA8084 (`0x004dd180`) (Bulgu C)                                                                                                                                         |
| 3 | **SoC–switch topology restored to vendor design** – `port@1`/`port@2` use PHY-less `fixed-link 2500/full` + `phy-mode = "2500base-x"`; reverted test2's broken `in-band-status` regression | Matches vendor `SGMII_PLUS` (Bulgu D)                                                                                       |
| 4 | **PHY reset timings** increased from `10/50 ms` to `100/100 ms` | Matches vendor `mdio-qca.c` (Bulgu G)                                                    |

> 🚨 **Critical boot address fix (Bulgu A):** The `0x44000000` address from previous release notes **will not work** – the kernel overwrites its own source. The **correct address is `0x46000000`**.

---

## Included images

| Image                       | Size      | Purpose                                      |
|-----------------------------|-----------|----------------------------------------------|
| `*-initramfs-uImage.itb`    | ~21.6 MiB | **Primary – RAM boot / hardware validation** |
| `*-uImage.itb`              | ~5.7 MiB  | FIT kernel (deterministic)                   |
| `*-squashfs-factory.bin`    | 20 MiB    | Factory UBI image                            |
| `*-squashfs-sysupgrade.bin` | ~19 MiB   | OpenWrt sysupgrade                           |

- Kernel: Linux **6.18.39** (ARM64, `qualcommbe/ipq53xx`)
- Wi-Fi firmware: `ath12k-firmware-qcn9274` 20260622-r1, `ipq-wifi-mercusys_mr47be-v2` 2026.05.18

---

## Boot procedure (corrected address)

Connect via UART (**GPIO18 TX / GPIO19 RX, 115200 8N1**) and interrupt boot to reach the `IPQ5332#` prompt:

```bash
setenv serverip 192.168.1.100
setenv ipaddr 192.168.1.1
tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
bootm 0x46000000