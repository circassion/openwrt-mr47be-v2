# BUILD_INFO — Mercusys MR47BE V2 OpenWrt (test4)

> **Последнее обновление:** 2026-08-28  
> **Образ:** test4 (hardware-compatible revision)  
> **Статус:** Эксперимальный / Сборка завершена, структурная верификация проведена

Этот файл содержит всю информацию для воссоздания образа test4.

---

## ⚠️ ВАЖНО: Аппаратные реалии (отличается от test1/2/3)

| Компонент | Старое предположение (test1-3) | **Реальность (test4)** |
|---|---|---|
| **SoC** | IPQ5332 ❌ | **IPQ5322** ✅ (фотодоказательство: "IPQ5322 003 FK5134HJ") |
| **Ethernet** | QCA8386 внешний свитч ❌ | **QCA8084** (встроен в SoC, отдельного чипа НЕТ) ✅ |
| **6 GHz радио** | QCN9224 ❌ | **QCN6274** ✅ (фотодоказательство) |
| **Строка загрузчика** | IPQ5332LA = SoC ❌ | IPQ5332LA = строка компилятора BSP, НЕ чтение оборудования |

> **Примечание:** Имя DTS файла по-прежнему использует `ipq5332-*`, потому что IPQ5322 и IPQ5332 относятся к одной семье Miami и DTS совместим. Необходимо использовать `compatible = "qcom,ipq5332"`.

---

## Окружение сборки

- **ОС:** WSL2 Ubuntu-24.04
- **Путь сборки:** `/root/mr47be-clean`
- **Ветка OpenWrt:** main (qualcommbe target)
- **Ядро:** 6.18.39 (KERNEL_PATCHVER:=6.18)

---

## Критические файлы

### 1. Device Tree Source (DTS)

**Файл:** `target/linux/qualcommbe/dts/ipq5332-mercusys-mr47be-v2.dts`

> ⚠️ **ЗАМЕЧАНИЕ ОБ ОШИБКЕ СБОРКИ:** Система сборки ищет DTS как `ipq5332-mr47be-v2.dts` (без mercusys-).  
> Производное `DEVICE_DTS`: `mercusys_mr47be-v2` → `ipq5332-mr47be-v2`  
> Разместите файл под ОБЕИМИ именами или используйте symlink.

**MD5:** `90bdb8049caf8de759cc33bbbc262afc` (для верификации)

**Содержание DTS (кратко):**
```
SoC: Qualcomm IPQ5322 (4x Cortex-A53, 1 GiB DDR4)
WiFi: 
  - wifi0: встроенный 2.4GHz, qcom,board-id = 18 (0x12)
  - wifi2: QCN6274 через PCIe1, qcom,board-id = 0x1015, pci17cb,1109
Ethernet: QCA8084 (встроенный switch-PHY, 4x 2.5G)
Flash: SPI-NAND Winbond W25N01GW 128MiB
UART: GPIO18/19 @ 115200 8N1
```

**Include:** `#include <arm64/qcom/ipq5332.dtsi>`

**Compatible:** `"mercusys,mr47be-v2", "qcom,ipq5332-ap-mi01.6", "qcom,ipq5332"`

---

### 2. Image Makefile (ipq53xx.mk)

**Файл:** `target/linux/qualcommbe/image/ipq53xx.mk`

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

**Ключевые моменты:**
- `DEVICE_DTS_CONFIG := config@mi01.6` — Стоковый U-Boot ищет эту конфигурацию
- `kmod-phy-qca83xx` — Требуется для QCA8084 (драйвер семейства QCA83xx)
- `ath12k-firmware-qcn9274` — Прошивка радио QCN6274

---

### 3. Конфигурация сети (02_network)

**Файл:** `target/linux/qualcommbe/ipq53xx/base-files/etc/board.d/02_network`

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

> **Примечание:** MAC-адрес читается из раздела ART (nvmem-layout).

---

### 4. Конфигурация ядра (config-default)

**Файл:** `target/linux/qualcommbe/ipq53xx/config-default`

Критические опции:
```

---

### 6. Патчи ядра (patches-6.18/)

**Всего:** 113 патчей

Критические патчи:
- `0301-0308` — Поддержка QCA8084 PHY (SerDes, init, probe)
- `0313-0324` — Поддержка PCS/IPQ9574 (USXGMII, 2500BASEX)
- `0325-0336` — Планировщик Ethernet PPE/EDMA и поддержка DMA
- `0343-0351` — Узлы DTS IPQ9574 PPE/EDMA
- `0352-0355` — Исправления тактовой частоты NSS

---

## Этапы сборки

### Подготовка

```bash
# 1. Чистый клон OpenWrt
git clone https://git.openwrt.org/openwrt/openwrt.git mr47be-clean
cd mr47be-clean

# 2. Разместите файлы MR47BE V2
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

### Компиляция

```bash
# Полная сборка включая тулчейн (4 ядра ~3-5 часов)
make -j4 V=s 2>&1 | tee build.log
```

### Выходные файлы

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

## Загрузка (UART → TFTP)

```
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000
```

**UART:** GPIO18(TX)/GPIO19(RX) @ 115200 8N1  
**Адрес загрузки:** `0x46000000` (0x44000000 конфликтует, НЕ использовать)  
**Secure Boot:** Отключен → неподписанный образ может загрузиться

---

## Список пакетов (test4 manifest)

| Пакет | Версия |
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

## Известные ограничения

- **QCA8084:** Нет DSA драйвера в mainline OpenWrt. Первая цель: UART + Wi-Fi + PHY link up.
- **Wi-Fi BDF:** Временный, требуется аппаратная верификация.
- **LED/GPIO/USB:** Ожидает тестирования.
- **NAND flash:** Не готов к производству.
- **Stock recovery:** Присутствует проверка RSA подписи, `_nosign` прошивка отклоняется.

---

## Ссылки

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

### 5. Прошивка WiFi (ipq-wifi)

**Источник:** `package/firmware/ipq-wifi/src/`

| Файл | Размер | Описание |
|---|---|---|
| `board-mercusys_mr47be-v2.ipq5332` | 89,292 bytes | BDF встроенного WiFi |
| `board-mercusys_mr47be-v2.qcn9274` | 126,156 bytes | BDF QCN6274 |

**Makefile:** `package/firmware/ipq-wifi/Makefile`
```makefile
$(eval $(call generate-ipq-wifi-package,mercusys_mr47be-v2,Mercusys MR47BE V2))
```
