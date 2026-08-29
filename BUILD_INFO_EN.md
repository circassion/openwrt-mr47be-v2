# BUILD_INFO — Mercusys MR47BE V2 OpenWrt (test4)

> **Last updated:** 2026-08-28  
> **Image:** test4 (hardware-compatible revision)  
> **Status:** Experimental / Build complete, structurally verified

This file contains all build information needed to recreate the test4 image.

---

## ⚠️ IMPORTANT: Hardware Truths (different from test1/2/3)

| Component | Old Assumption (test1-3) | **Reality (test4)** |
|---|---|---|
| **SoC** | IPQ5332 ❌ | **IPQ5322** ✅ (photo proof: "IPQ5322 003 FK5134HJ") |
| **Ethernet** | QCA8386 external switch ❌ | **QCA8084** (integrated into SoC, NO separate chip) ✅ |
| **6 GHz radio** | QCN9224 ❌ | **QCN6274** ✅ (photo proof) |
| **Bootloader string** | IPQ5332LA = SoC ❌ | IPQ5332LA = BSP compiler string, NOT hardware read |

> **Note:** DTS filename still uses `ipq5332-*` because IPQ5322 and IPQ5332 are in the same Miami family and DTS is compatible. `compatible = "qcom,ipq5332"` must be used.

---

## Build Environment

- **OS:** WSL2 Ubuntu-24.04
- **Build path:** `/root/mr47be-clean`
- **OpenWrt branch:** main (qualcommbe target)
- **Kernel:** 6.18.39 (KERNEL_PATCHVER:=6.18)

---

## Critical Files

### 1. Device Tree Source (DTS)

**File:** `target/linux/qualcommbe/dts/ipq5332-mercusys-mr47be-v2.dts`

> ⚠️ **BUILD ERROR NOTE:** Build system looks for DTS as `ipq5332-mr47be-v2.dts` (without mercusys-).  
> `DEVICE_DTS` derivation: `mercusys_mr47be-v2` → `ipq5332-mr47be-v2`  
> Place the file under BOTH names or use symlink.

**MD5:** `90bdb8049caf8de759cc33bbbc262afc` (for verification)

**DTS Content (summary):**
```
SoC: Qualcomm IPQ5322 (4x Cortex-A53, 1 GiB DDR4)
WiFi: 
  - wifi0: on-SoC 2.4GHz, qcom,board-id = 18 (0x12)
  - wifi2: QCN6274 via PCIe1, qcom,board-id = 0x1015, pci17cb,1109
Ethernet: QCA8084 (on-SoC switch-PHY, 4x 2.5G)
Flash: SPI-NAND Winbond W25N01GW 128MiB
UART: GPIO18/19 @ 115200 8N1
```

**Include:** `#include <arm64/qcom/ipq5332.dtsi>`

**Compatible:** `"mercusys,mr47be-v2", "qcom,ipq5332-ap-mi01.6", "qcom,ipq5332"`

---

### 2. Image Makefile (ipq53xx.mk)

**File:** `target/linux/qualcommbe/image/ipq53xx.mk`

```makefile
define Device/mercusys_mr47be-v2
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Mercusys
	DEVICE_MODEL := MR47BE V2
	DEVICE_ALT0_VENDOR := Mercusys
	DEVICE_ALT0_MODEL := MR47BE
	DEVICE_DTS_CONFIG := config@mi01.6
	SOC := ipq5332
	SUPPORTED_DEVICES += mercusys,mr47be-v2
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	KERNEL_INSTALL := 1
	KERNEL_SIZE := 6096k
	IMAGE_SIZE := 54016k
	IMAGES += factory.bin
	IMAGE/factory.bin := append-ubi
	DEVICE_PACKAGES := kmod-ath12k ath12k-firmware-ipq5332 \
		ath12k-firmware-qcn9274 ipq-wifi-mercusys_mr47be-v2 \
		kmod-qrtr-smd ethtool dumpimage kmod-phy-qca83xx \
		kmod-usb-core kmod-usb2 kmod-usb3 kmod-usb-dwc3 \
		kmod-usb-dwc3-qcom kmod-usb-xhci-hcd kmod-scsi-core \
		kmod-usb-storage kmod-usb-storage-uas kmod-fs-ext4 \
		block-mount blockd usbutils
endef
TARGET_DEVICES += mercusys_mr47be-v2
```

**Key Points:**
- `DEVICE_DTS_CONFIG := config@mi01.6` — Stock U-Boot looks for this config
- `kmod-phy-qca83xx` — Required for QCA8084 (QCA83xx family driver)
- `ath12k-firmware-qcn9274` — QCN6274 radio firmware

---

### 3. Network Config (02_network)

**File:** `target/linux/qualcommbe/ipq53xx/base-files/etc/board.d/02_network`

```bash
mercusys,mr47be-v2)
	ucidef_set_interfaces_lan_wan "lan" "wan"
	wan_mac=$(mtd_get_mac_binary "0:art" 0x0)
	if [ -n "$wan_mac" ]; then
		lan_mac=$(macaddr_add "$wan_mac" 1)
		ucidef_set_network_device_mac "wan" "$wan_mac"
		ucidef_set_network_device_mac "lan" "$lan_mac"
		ucidef_set_interface_macaddr "wan" "$wan_mac"
		ucidef_set_interface_macaddr "lan" "$lan_mac"
		ucidef_set_label_macaddr "$wan_mac"
	fi
	;;
```

> **Note:** MAC address is read from ART partition (nvmem-layout).

---

### 4. Kernel Config (config-default)

**File:** `target/linux/qualcommbe/ipq53xx/config-default`

Critical options:
```

---

### 6. Kernel Patches (patches-6.18/)

**Total:** 113 patches

Critical patches:
- `0301-0308` — QCA8084 PHY support (SerDes, init, probe)
- `0313-0324` — PCS/IPQ9574 support (USXGMII, 2500BASEX)
- `0325-0336` — PPE/EDMA Ethernet scheduler and DMA support
- `0343-0351` — IPQ9574 PPE/EDMA DTS nodes
- `0352-0355` — NSS clock fixes

---

## Build Steps

### Preparation

```bash
# 1. Clean OpenWrt clone
git clone https://git.openwrt.org/openwrt/openwrt.git mr47be-clean
cd mr47be-clean

# 2. Place MR47BE V2 files
#    - DTS: target/linux/qualcommbe/dts/ipq5332-mercusys-mr47be-v2.dts
#    - ipq53xx.mk: target/linux/qualcommbe/image/ipq53xx.mk
#    - config-default: target/linux/qualcommbe/ipq53xx/config-default
#    - 02_network: target/linux/qualcommbe/ipq53xx/base-files/etc/board.d/02_network
#    - board files: package/firmware/ipq-wifi/src/board-mercusys_mr47be-v2.*
#    - patches: target/linux/qualcommbe/patches-6.18/*

# 3. Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 4. Config
make defconfig
```

### Compilation

```bash
# Full build including toolchain (4 cores ~3-5 hours)
make -j4 V=s 2>&1 | tee build.log
```

### Output

```
bin/targets/qualcommbe/ipq53xx/
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.ubi
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-sysupgrade.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2.manifest
└── sha256sums
```

---

## Boot (UART → TFTP)

```
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000
```

**UART:** GPIO18(TX)/GPIO19(RX) @ 115200 8N1  
**Boot address:** `0x46000000` (0x44000000 conflicts, do NOT use)  
**Secure Boot:** Disabled → unsigned image can boot

---

## Package List (test4 manifest)

| Package | Version |
|---|---|
| kernel | 6.18.39 |
| kmod-ath12k | 6.18.39.7.2_rc4 |
| ath12k-firmware-ipq5332 | 1 |
| ath12k-firmware-qcn9274 | 20260622-r1 |
| ipq-wifi-mercusys_mr47be-v2 | 2026.05.18 |
| wireless-regdb | 2026.05.30 |
| kmod-phy-qca83xx | 6.18.39-r1 |
| kmod-qcom-ppe | 6.18.39-r1 |
| kmod-pcs-qcom-ipq9574 | 6.18.39-r1 |
| busybox | 1.38.0-r2 |
| dropbear | 2026.92-r1 |
| dnsmasq | 2.93-r2 |
| firewall4 | 2025.03.17 |

---

## Known Limitations

- **QCA8084:** No DSA driver in mainline OpenWrt. First goal: UART + Wi-Fi + PHY link up.
- **Wi-Fi BDF:** Temporary, hardware validation required.
- **LED/GPIO/USB:** Awaiting testing.
- **NAND flash:** Not production ready.
- **Stock recovery:** RSA signature verification present, `_nosign` firmware rejected.

---

## References

- [RELEASE_NOTES_v0.1.0-test4.md](../RELEASE_NOTES_v0.1.0-test4.md)
- [V2_HARDWARE_STATUS.md](../V2_HARDWARE_STATUS.md)
- [LIVE_SESSION_STATE.md](../LIVE_SESSION_STATE.md)
- [OpenWrt qualcommbe target](https://openwrt.org/docs/techref/targets/qualcommbe)

CONFIG_IPQ_GCC_5332=y
CONFIG_IPQ_NSSCC_5332=y
CONFIG_PINCTRL_IPQ5332=y
CONFIG_QCA83XX_PHY=y
CONFIG_NET_DSA_QCA8K=y
CONFIG_SPI_QPIC_SNAND=y
CONFIG_MTD_SPI_NAND=y
CONFIG_PHY_QCOM_UNIPHY_PCIE_28LP=y
CONFIG_PHY_QCOM_M31_USB=y
CONFIG_INTERCONNECT_QCOM_OSM_L3=y
CONFIG_REGULATOR_CPR4_APSS=y
```

---

### 5. Board WiFi Firmware (ipq-wifi)

**Source:** `package/firmware/ipq-wifi/src/`

| File | Size | Description |
|---|---|---|
| `board-mercusys_mr47be-v2.ipq5332` | 89,292 bytes | on-SoC WiFi BDF |
| `board-mercusys_mr47be-v2.qcn9274` | 126,156 bytes | QCN6274 BDF |

**Makefile:** `package/firmware/ipq-wifi/Makefile`
```makefile
$(eval $(call generate-ipq-wifi-package,mercusys_mr47be-v2,Mercusys MR47BE V2))
```

