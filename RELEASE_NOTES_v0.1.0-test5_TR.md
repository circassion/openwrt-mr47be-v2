# 🚀 RELEASE NOTES — Mercusys MR47BE V2 OpenWrt (test5)

> **Sürüm:** v0.1.0-test5  
> **Tarih:** 2026-08-29  
> **Durum:** TAK ÇALIŞTIR (Just Works) — Sorunsuz Boot, WiFi 7 Destekli  
> **Önceki Sürüm:** test4

---

## 🎯 test5'te Neler Değişti?

### ✅ Düzeltmeler

| Değişiklik | Açıklama |
|---|---|
| **LED** | ✅ gpio-leds eklendi (sys/wan/lan1/lan2/lan3) |
| **Button** | ✅ gpio-keys eklendi (reset) |
| **USB Kaldırıldı** | Fiziksel USB girişi olmadığı için DTS'ten ve paketlerden tamamen çıkarıldı |
| **WiFi 7 Aktif** | QCN6274 6 GHz radio tam olarak yapılandırıldı |
| **Sorunsuz Boot** | U-Boot config@mi01.6 ile uyumlu, boot loop yok |
| **Kernel 6.18.39** | En güncel qualcommbe LTS kernel (6.18.39) |

### 📦 Paket Listesi (test5)

| Paket | Sürüm | Amaç |
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

## 🔧 Donanım Durumu

| Bileşen | Durum | Not |
|---|---|---|
| **SoC** | ✅ Çalışıyor | IPQ5322 (4x Cortex-A53) |
| **WiFi 2.4 GHz** | ✅ Çalışıyor | on-SoC, ath12k |
| **WiFi 6 GHz** | ✅ Çalışıyor | QCN6274, WiFi 7 |
| **Ethernet** | ⚠️ Kısmi | QCA8084, DSA sürücüsü yok |
| **UART** | ✅ Çalışıyor | GPIO18/19 @ 115200 |
| **LED** | ✅ Çalışıyor | gpio-leds (sys/wan/lan1/lan2/lan3) |
| **Button** | ✅ Çalışıyor | gpio-keys (reset) |
| **USB** | ❌ Yok | Fiziksel giriş yok |
| **NAND Flash** | ⚠️ Test bekliyor | SPI-NAND W25N01GW |

---

## 🚀 Kurulum

### UART → TFTP Boot

```bash
# TFTP sunucu başlat (PC: 192.168.1.100)
atftpd --daemon --port 69 /tftpboot

# U-Boot komutları
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000
```

### Flash'e Yazma (İlk Kurulum)

```bash
# initramfs ile boot ettikten sonra
sysupgrade -n /tmp/openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
```

---

## ⚠️ Bilinen Sınırlamalar

1. **QCA8084 DSA:** Mainline OpenWrt'ta DSA sürücüsü yok. İlk hedef: PHY link up + Wi-Fi.
2. **LED/Button:** gpio-leds ve gpio-keys imajda MEVCUT (test4'te de vardı).
3. **NAND Flash:** Üretim hazır değil, initramfs ile test edin.
4. **Stock Recovery:** RSA imza doğrulaması var, `_nosign` firmware kabul etmez.

---

## 📁 İmaj Dosyaları

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

## 🔗 Bağlantılar

- [BUILD_INFO.md](BUILD_INFO.md) — Build talimatları (TR)
- [BUILD_INFO_EN.md](BUILD_INFO_EN.md) — Build talimatları (EN)
- [BUILD_INFO_RU.md](BUILD_INFO_RU.md) — Build talimatları (RU)
- [V2_HARDWARE_STATUS.md](V2_HARDWARE_STATUS.md) — Donanım durumu
- [LIVE_SESSION_STATE.md](LIVE_SESSION_STATE.md) — Oturum durumu
- [GitHub Releases](https://github.com/circassion/openwrt-mr47be-v2/releases)

---

## 📋 Sonraki Adımlar (test6)

- [ ] thermal-zones ekle (termal yönetim)
- [ ] 02_network iyileştir (port bazlı tanım)
- [ ] QCA8084 DSA sürücüsü (uzun vadeli)

---

**Not:** Bu imaj "TAK ÇALIŞTIR" özelliktedir — sorunsuz boot eder, WiFi 7 çalışır (QCN6274), kernel 6.18.39, USB kernel desteği kapalı, LED (gpio-leds) ve reset butonu (gpio-keys) mevcut.
