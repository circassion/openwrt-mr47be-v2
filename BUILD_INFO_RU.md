# BUILD_INFO — Mercusys MR47BE V2 OpenWrt (test5)

> **Последнее обновление:** 2026-08-29  
> **Образ:** test5 (тот же путь сборки, полная пересборка)  
> **Статус:** ✅ Сборка завершена — ядро 6.18.39, USB отключён, LED+Button присутствуют.  
> Этот файл — реальное, проверяемое техническое руководство для воссоздания образа test5 с нуля.

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
LED: gpio-leds (sys-green, sys-orange, wan, lan1, lan2, lan3)
Button: gpio-keys (reset)
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
		kmod-qrtr-smd ethtool dumpimage kmod-phy-qca83xx
endef
TARGET_DEVICES += mercusys_mr47be-v2
```

**Ключевые моменты (test5):**
- `DEVICE_DTS_CONFIG := config@mi01.6` — Стоковый U-Boot ищет эту конфигурацию
- `kmod-phy-qca83xx` — Драйвер PHY QCA808x/QCA83xx (kmod-phy-qca83xx)
- Драйвер Ethernet = **kmod-qcom-ppe** + kmod-pcs-qcom-ipq9574 (подтягивается из config/патчей;
  здесь не указан, генерируется из `CONFIG_QCOM_PPE=m`)
- USB-пакеты (kmod-usb-*, blockd, block-mount, usbutils) **намеренно удалены** — физического порта нет
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

- **Ethernet (QCA8084):** Нет **DSA-узла коммутатора**, разделяющего LAN1/2/3 на отдельные порты.
  Эта сборка управляет Ethernet через **открытый `kmod-qcom-ppe`** (Qualcomm PPE/EDMA, `CONFIG_QCOM_PPE=m`):
  `xgmac1` → **eth1 = LAN** (аплинк CPU коммутатора, fixed-link 2500) + `xgmac2` → **eth0 = WAN** (phy@4).
  Итог = **eth0 (WAN) + eth1 (LAN)** — как в моделе вендора (NSS). Разделение VLAN LAN1/2/3 — отдельная
  работа DSA/PPE-VLAN.
- **LED/Button:** Присутствуют — gpio-leds (wan/lan1/lan2/lan3/sys) + gpio-keys (reset @ tlmm30).
- **USB:** Отключён — `CONFIG_USB_SUPPORT=n` (`drivers/usb/*.ko` = 0), `&usb`/`&usbphy0` удалены из DTS,
  физического порта нет. (Метаданные OpenWrt оставляют пустые `kmod-usb-*` + `usbutils`; функций USB нет.)
- **Wi-Fi BDF:** Временный, требуется аппаратная верификация.
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

---

## 📚 История тестов и уроки (Информационный)

> Этот раздел содержит уроки, извлеченные из процесса сборки test4. Полезно для всех, кто пересобирает.

### TEST4 — Чистая сборка (2026-08-28 — ROUND 3 Завершена)

- ✅ Сборка ROUND 3 живая: WSL `/root/mr47be-clean`
- ✅ missing-macros прошел (где умер round 1/2)
- ✅ Toolchain закончен → генерация образов началась
- ❌ ROUND 1 crash: `missing-macros/bin/*` отсутствовал
- ❌ ROUND 2: 0-byte log (nohup + мгновенное закрытие сессии — исправлено setsid)
- ❌ ROUND 3 crash: проблема с именем DTS (исправлено ниже)

### 🐛 Урок 1: rsync `--exclude=bin` Ловушки

**Проблема:** rsync `--exclude=bin` (unanchored) удалил ВСЕ `bin/` директории в дереве (включая tools/missing-macros/src/bin).

**Исправление:** Используйте anchored `--exclude=/build_dir /staging_dir /tmp /.ccache /bin /logs`. Тест паритета: SRC = DST количество файлов (один-к-одному).

### 🐛 Урок 2: `nohup make &` Одного Недостаточно

**Проблема:** Если WSL сессия закрывается ПОСЛЕ `nohup make &`, make умирает до записи первого вывода (0-byte log).

**Исправление:** `setsid nohup make ... &` + `sleep 12` live-verification в той же команде.

### 🐛 Урок 3: WSL Фоновые Демоны

**Проблема:** WSL фоновые демоны-наблюдатели умирают при закрытии сессии; make выживает.

**Исправление:** Надежный мониторинг = внешний периодический проб + копировать-анализировать лог.

### 🐛 Урок 4: DTS Имя Производство (Самый Критичный)

**Проблема:** Система сборки ищет DTS как `ipq5332-mr47be-v2.dts` (без mercusys-). `DEVICE_DTS` производство: `mercusys_mr47be-v2` → `ipq5332-mr47be-v2`.

**Исправление:** Разместите файл DTS под ОБЕИМИ именами или используйте symlink:
```bash
# Метод 1: Копировать
cp ipq5332-mercusys-mr47be-v2.dts ipq5332-mr47be-v2.dts

# Метод 2: Symlink
ln -s ipq5332-mercusys-mr47be-v2.dts ipq5332-mr47be-v2.dts
```

### Команда Сборки (Для Повторного Использования)

```bash
# 1. Чистая установка
bash /root/setup_clean.sh setup

# 2. Сборка (setsid + nohup + log)
cd /root/mr47be-clean
setsid nohup make -j4 V=s > /root/mr47be-clean-build.log 2>&1 < /dev/null &

# 3. Мониторинг (та же команда с sleep 12 live-verification)
```

### Выходные Файлы

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

### Загрузка (UART → TFTP)

```bash
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000
```

**UART:** GPIO18(TX)/GPIO19(RX) @ 115200 8N1
**Адрес загрузки:** `0x46000000` (0x44000000 конфликтует, НЕ использовать)
**Secure Boot:** Отключен → неподписанный образ может загрузиться
---

## Аппаратная верификация (после RAM-boot)

### QCA8084 PHY ID — `mii read`

**Адреса PHY (DTS `&mdio`):** LAN `phy0@1`, `phy1@2`, `phy2@3`, `phy3@4` (WAN).

```sh
# Внутренний PHY ID QCA8084 = 0x004dd180
mii read 1 2   # -> 0x004d   (PHYID1 HIGH)
mii read 1 3   # -> 0xd180   (PHYID2 LOW)
# Все 4 PHY должны дать 0x004dd180; для WAN: mii read 4 2 / 4 3
```

> Если не `0x4d d1 80` — проверьте адрес/топологию switch-PHY.

### Идентификация SoC (окончательная)

```sh
cat /proc/device-tree/compatible   # -> qcom,ipq5332-ap-mi01.6, ...
dmesg | grep -iE "ipq53|socinfo|soc:"
```

> Физический SoC = **IPQ5322** (подтверждено фото); DTS использует `qcom,ipq5332` (то же семейство/корпус).
> `socinfo` решает это окончательно (подтверждает/опровергает предположение "IPQ5332").
