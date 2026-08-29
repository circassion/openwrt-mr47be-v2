# 🚀 RELEASE NOTES — Mercusys MR47BE V2 OpenWrt (test5)

> **Version:** v0.1.0-test5  
> **Date:** 2026-08-29  
> **Status:** TAK ÇALIŞTIR (Just Works) — Seamless Boot, WiFi 7 Support  
> **Previous Version:** test4

---

## 🎯 What's New in test5?

### ✅ Fixes

| Change | Description |
|---|---|
| **LED** | ✅ gpio-leds added (sys/wan/lan1/lan2/lan3) |
| **Button** | ✅ gpio-keys added (reset) |
| **USB Removed** | Completely removed from DTS and packages (no physical USB port) |
| **WiFi 7 Active** | QCN6274 6 GHz radio fully configured |
| **Seamless Boot** | Compatible with U-Boot config@mi01.6, no boot loop |
| **Kernel 6.18.39** | Latest qualcommbe LTS kernel (6.18.39) |

### 📦 Package List (test5)

| Package | Version | Purpose |
|---|---|---|
| kernel | 6.18.39 | Linux kernel |
| kmod-ath12k | 6.18.39.7.2_rc4 | ath12k Wi-Fi driver |
| ath12k-firmware-ipq5332 | 1 | on-SoC WiFi firmware |
| ath12k-firmware-qcn9274 | 20260622-r1 | QCN6274 WiFi 7 firmware |
| ipq-wifi-mercusys_mr47be-v2 | 2026.05.18 | Board-specific WiFi config |
| wireless-regdb | 2026.05.30 | Regulatory database |
| kmod-phy-qca83xx | 6.18.39-r1 | QCA8084 PHY driver |
| kmod-qcom-ppe | 6.18.39-r1 | PPE Ethernet |
| kmod-pcs-qcom-ipq9574 | 6.18.39-r1 | PCS SerDes |
| busybox | 1.38.0-r2 | Core utilities |
| dropbear | 2026.92-r1 | SSH server |
| dnsmasq | 2.93-r2 | DHCP/DNS |
| firewall4 | 2025.03.17 | Firewall |
| kmod-qrtr-smd | 6.18.39-r1 | QRTR SMD |
| ethtool | 6.18.39-r1 | Ethernet tools |
| dumpimage | 6.18.39-r1 | Image tools |

---

## 🔧 Hardware Status

| Component | Status | Note |
|---|---|---|
| **SoC** | ✅ Working | IPQ5322 (4x Cortex-A53) |
| **WiFi 2.4 GHz** | ✅ Working | on-SoC, ath12k |
| **WiFi 6 GHz** | ✅ Working | QCN6274, WiFi 7 |
| **Ethernet** | ⚠️ Partial | QCA8084, no DSA driver |
| **UART** | ✅ Working | GPIO18/19 @ 115200 |
| **LED** | ✅ Working | gpio-leds (sys/wan/lan1/lan2/lan3) |
| **Button** | ✅ Working | gpio-keys (reset) |
| **USB** | ❌ None | No physical port |
| **NAND Flash** | ⚠️ Pending test | SPI-NAND W25N01GW |

---

## 🚀 Installation

### UART → TFTP Boot

```bash
# Start TFTP server (PC: 192.168.1.100)
atftpd --daemon --port 69 /tftpboot

# U-Boot commands
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000
```

### Flash Write (First Install)

```bash
# After booting initramfs
sysupgrade -n /tmp/openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
```

---

## ⚠️ Known Limitations

1. **QCA8084 DSA:** No DSA driver in mainline OpenWrt. First goal: PHY link up + Wi-Fi.
2. **USB residual packages:** Kernel USB support is fully disabled (no USB modules); the
   devicetree has no `&usb`. OpenWrt's package metadata may still list empty `kmod-usb-*`
   entries plus the `usbutils` CLI tool — these contain no USB drivers and the device has no USB port.
3. **NAND Flash:** Not production ready, test with initramfs.
4. **Stock Recovery:** RSA signature verification present, `_nosign` firmware rejected.

---

## 📁 Image Files

```
E:\ROUTER\MERCUSYS MR47BE_OPENWRT\imajlar\test5\
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.ubi
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-sysupgrade.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2.manifest
└── sha256sums
```

---

## 🔗 Links

- [BUILD_INFO.md](BUILD_INFO.md) — Build instructions (TR)
- [BUILD_INFO_EN.md](BUILD_INFO_EN.md) — Build instructions (EN)
- [BUILD_INFO_RU.md](BUILD_INFO_RU.md) — Build instructions (RU)
- [V2_HARDWARE_STATUS.md](V2_HARDWARE_STATUS.md) — Hardware status
- [LIVE_SESSION_STATE.md](LIVE_SESSION_STATE.md) — Session status
- [GitHub Releases](https://github.com/circassion/openwrt-mr47be-v2/releases)

---

## 📋 Next Steps (test6)

- [ ] Add thermal-zones (thermal management)
- [ ] Improve 02_network (port-based definition)
- [ ] QCA8084 DSA driver (long-term)

---

**Note:** TAK ÇALIŞTIR — boots seamlessly, WiFi 7 works (QCN6274), kernel 6.18.39,
USB kernel support disabled, LED (gpio-leds) + reset button (gpio-keys) present.
