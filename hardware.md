# OpenWrt port for the Mercusys MR47BE V2 (work in progress)

> **Status: experimental. Nothing here has been flashed. All tests were done by TFTP-booting an
> initramfs image (the LuCI banner shows "System running in recovery (initramfs) mode").**
> Do not flash anything from this repository to a device you care about.

Device: Mercusys MR47BE V2 ("BE9300 Tri-Band Wi-Fi 7 Router", product_ver 2.0.0).
Target: OpenWrt `qualcommbe/ipq53xx`, Linux 6.18.x (tests run on 6.18.39/44/52/53/54/55/56 build output).

## What works / what does not (test MR47BE_XXX)

| Area | State | Evidence |
|---|---|---|
| Boot via TFTP initramfs, UART console | works | UART logs |
| 5 GHz + 6 GHz (PCIe radio) | **works** (APs up, client associated at 6 GHz / 160 MHz / EHT-MCS 12) | LuCI screenshot, UART |
| 2.4 GHz (on-SoC Q6 / ath12k AHB) | **does not work** — Q6 userPD crashes right after BDF/cal download | UART  |


### 2.4 GHz progress
* Q6 rootPD / PAS `-22` is fixed by passing the whole `.mdt` as metadata (idea from
  [perceival/openwrt-flint3#93](https://github.com/perceival/openwrt-flint3/issues/93)); rootPD and userPD come up, QMI connects.
* The stock board data is `bdwlan.b12` (63488 B). Sending a 131080 B blob as "board data" crashed the Q6
  (that blob was calibration data, not board data). With the stock board file the board download completes.
* Current blocker: the calibration data (131072 B) is sent as a single 64-byte segment (`seg 0 len 64 end 1`),
  followed by a Q6 crash. Stock sends the full `caldata.bin` (131072 B).

### Ethernet
* The kernel reports a QCA8386-family (MHT) switch (`qca8386 ... detected QCA8386 (id 0x17)`), four QCA808x PHYs on MDIO 1-4.
* Stock firmware attaches **both** PPE MACs to the switch (`dp1: Switch attached to macid 2`, `dp2: ... macid 1`)
  and uses `switch_cpu_bmp=0x21, lan_bmp=0x1c, wan_bmp=0x2`. Our DTS currently wires WAN directly to a PHY. Under investigation.

## Hardware (verified from photos and UART logs)

| Component | Detail | Evidence |
|---|---|---|
| SoC | Qualcomm **IPQ5322** (4x Cortex-A53, up to 1.1 GHz) | die marking `IPQ5322 003 FK5134HJ`; stock kernel prints `CPU: IPQ5322, SoC Version: 1.1`. The string `IPQ5332LA` in the boot log is only the SBL image variant name. |
| DRAM | Samsung K4A8G165WC-BCTD, 1 GiB DDR4 | photo, kernel `Memory: ...1048576K` |
| Flash | Winbond W25N01GWZEIG, 128 MiB SPI-NAND (17 MTD partitions in stock) | photo, UART |
| 5/6 GHz radio | marking `Qualcomm QCN6274`, PCI ID 17cb:1109; ath12k binds it as `qcn9274 hw2.0` | photo, UART |
| 2.4 GHz radio | on-SoC Q6 (ath12k AHB, board-id 0x12); stock firmware `WLAN.WBE.1.1-03321` (build 2025-09-30) | UART |
| Ethernet | QCA8386-family (MHT) switch + 4x QCA8084 2.5G PHYs | UART (kernel + stock ssdk) |
| Secure boot | Off (`Secure Boot: Off`), unsigned RAM boot accepted | stock UART |
| UART | 4-pin J1, 115200 8N1 | photo, UART |

Note: LuCI / vendor drivers label the PCIe radio "QCN6224/9224/9274"; that is a generic driver string,
the chip marking is QCN6274.

## Boot (RAM only)

```
setenv serverip 192.168.1.100
setenv ipaddr 192.168.1.1
tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
bootm 0x46000000
```

## Not included
Vendor binaries (stock firmware, board data, calibration/ART dumps) and device identifiers are not published.
Hashes and sizes of the files used are listed in `docs/`.

## Credits
* perceival/openwrt-flint3 (issue #93 and the Flint 3 tree), JiaY-shi's IPQ5332 work.
