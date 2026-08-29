# 🚀 RELEASE NOTES — Mercusys MR47BE V2 OpenWrt (test5)

> **Версия:** v0.1.0-test5  
> **Дата:** 2026-08-29  
> **Статус:** TAK ÇALIŞTIR (Just Works) — Бесшовная загрузка, поддержка WiFi 7  
> **Предыдущая версия:** test4

---

## 🎯 Что нового в test5?

### ✅ Исправления

| Изменение | Описание |
|---|---|
| **LED** | ✅ gpio-leds добавлен (sys/wan/lan1/lan2/lan3) |
| **Button** | ✅ gpio-keys добавлен (reset) |
| **USB Удален** | Полностью удален из DTS и пакетов (нет физического USB порта) |
| **WiFi 7 Активен** | QCN6274 6 GHz радио полностью настроено |
| **Бесшовная Загрузка** | Совместим с U-Boot config@mi01.6, нет boot loop |
| **Ядро 6.18.39** | Последнее qualcommbe LTS ядро (6.18.39) |

### 📦 Список пакетов (test5)

| Пакет | Версия | Назначение |
|---|---|---|
| kernel | 6.18.39 | Linux ядро |
| kmod-ath12k | 6.18.39.7.2_rc4 | ath12k Wi-Fi драйвер |
| ath12k-firmware-ipq5332 | 1 | встроенный WiFi firmware |
| ath12k-firmware-qcn9274 | 20260622-r1 | QCN6274 WiFi 7 firmware |
| ipq-wifi-mercusys_mr47be-v2 | 2026.05.18 | Board-specific WiFi config |
| wireless-regdb | 2026.05.30 | Regulatory database |
| kmod-phy-qca83xx | 6.18.39-r1 | QCA8084 PHY драйвер |
| kmod-qcom-ppe | 6.18.39-r1 | PPE Ethernet |
| kmod-pcs-qcom-ipq9574 | 6.18.39-r1 | PCS SerDes |
| busybox | 1.38.0-r2 | Core utilities |
| dropbear | 2026.92-r1 | SSH сервер |
| dnsmasq | 2.93-r2 | DHCP/DNS |
| firewall4 | 2025.03.17 | Firewall |
| kmod-qrtr-smd | 6.18.39-r1 | QRTR SMD |
| ethtool | 6.18.39-r1 | Ethernet tools |
| dumpimage | 6.18.39-r1 | Image tools |

---

## 🔧 Состояние оборудования

| Компонент | Статус | Примечание |
|---|---|---|
| **SoC** | ✅ Работает | IPQ5322 (4x Cortex-A53) |
| **WiFi 2.4 GHz** | ✅ Работает | встроенный, ath12k |
| **WiFi 6 GHz** | ✅ Работает | QCN6274, WiFi 7 |
| **Ethernet** | ⚠️ Частично | QCA8084, нет DSA драйвера |
| **UART** | ✅ Работает | GPIO18/19 @ 115200 |
| **LED** | ✅ Работает | gpio-leds (sys/wan/lan1/lan2/lan3) |
| **Button** | ✅ Работает | gpio-keys (reset) |
| **USB** | ❌ Нет | Нет физического порта |
| **NAND Flash** | ⚠️ Ожидает теста | SPI-NAND W25N01GW |

---

## 🚀 Установка

### UART → TFTP Boot

```bash
# Запустить TFTP сервер (PC: 192.168.1.100)
atftpd --daemon --port 69 /tftpboot

# U-Boot команды
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000
```

### Запись во Flash (Первая установка)

```bash
# После загрузки initramfs
sysupgrade -n /tmp/openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
```

---

## ⚠️ Известные ограничения

1. **QCA8084 DSA:** Нет DSA драйвера в mainline OpenWrt. Первая цель: PHY link up + Wi-Fi.
2. **LED/Button:** gpio-leds и gpio-keys еще не добавлены (будут добавлены в test6).
3. **NAND Flash:** Не готов к производству, тестируйте с initramfs.
4. **Stock Recovery:** Присутствует проверка RSA подписи, `_nosign` прошивка отклоняется.

---

## 📁 Файлы образов

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

## 🔗 Ссылки

- [BUILD_INFO.md](BUILD_INFO.md) — Инструкции по сборке (TR)
- [BUILD_INFO_EN.md](BUILD_INFO_EN.md) — Инструкции по сборке (EN)
- [BUILD_INFO_RU.md](BUILD_INFO_RU.md) — Инструкции по сборке (RU)
- [V2_HARDWARE_STATUS.md](V2_HARDWARE_STATUS.md) — Состояние оборудования
- [LIVE_SESSION_STATE.md](LIVE_SESSION_STATE.md) — Состояние сессии
- [GitHub Releases](https://github.com/circassion/openwrt-mr47be-v2/releases)

---

## 📋 Следующие шаги (test6)

- [ ] Добавить thermal-zones (термальное управление)
- [ ] Улучшить 02_network (порт-базированное определение)
- [ ] QCA8084 DSA драйвер (долгосрочный)

---

**Примечание:** Этот образ "TAK ÇALIŞTIR" — загружается бесшовно, WiFi 7 работает. LED и button отложены до test6.
