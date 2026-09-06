# Mercusys MR47BE V2 — OpenWrt

**OpenWrt port for the Mercusys MR47BE V2 (Qualcomm IPQ5322 · Wi-Fi 7)**

> **Status:** 🟡 Test build pipeline works — images build cleanly. Hardware validation (RAM-boot, Wi-Fi, Ethernet link-up) is in progress. Do not flash unless you understand UART/U-Boot recovery.
---

🎯 Mevcut Durum / Current Status / Текущий статус

| Mevcut Durum | Current Status | Текущий статус |
|---|---|---|
| ✅ | WAN (DHCP + İnternet - Internet - Интернет) | Çalışıyor - Working - Работает |
| ✅ |LAN1 (Ethernet) | Çalışıyor - Working - Работает |
| ✅ | LuCI (Web Arayüzü - Web UI - Веб-интерфейс) | Çalışıyor - Working - Работаетe |
| ❌ | LAN2 / LAN3 | Geliştirmede / In Development / В разработкеe |
| ❌| Wi-Fi 2.4GHz (Q6) | Geliştirmede (PAS -22) - In Development - В разработке |
| ❌| Wi-Fi 5/6GHz (QCN6274)| QCN6274 WiFi 7 firmware |


🧪 TEST SONUÇLARI / TEST RESULTS / РЕЗУЛЬТАТЫ ТЕСТОВ (test30

🧪 [🇹🇷 RELEASE_NOTES_v2.0.30-BETA -test30_TR.md] (RELEASE_NOTES_v2.0.30-BETA -test30_TR.md)

---

| TEST SONUÇLARI | TEST RESULTS| Текущий статус |
|---|---|---|
| internet / Internet / Интернет | ping 8.8.8.8 | 0% kayıp / 0% loss / 0% потерь, ~45 ms |
| LAN1: |✅ DHCP → 192.168.0.104/24| gateway 192.168.0.1|
| LAN1: | ✅ping 192.168.1.1 | 0% loss / 0% потерь, ~0.12 ms |
| LuCI: | ✅LuCI (Web Arayüzü - Web UI - Веб-интерфейс) | Çalışıyor - Working - Работаетe |
| PCIe:| ✅ QCN6274 | tespit edildi / detected / обнаружен (17cb:1109) |

---

📌 YOL HARİTASI / ROADMAP / ПЛАН РАЗВИТИЯ

---

|---|---|---|
| ☑ | WAN (DHCP + İnternet / Internet / Интернет)  | ✅  |
| □  | LuCI  | ✅  |
| □  | Wi-Fi 2.4GHz — PAS 3-argüman yaması / PAS 3-argument patch / патч PAS с 3 аргументами  | ⚠️  |
| □  | Wi-Fi 5/6GHz — MHI/QMI firmware yüklemesi / MHI/QMI firmware loading / загрузка прошивки MHI/QMI  | ⚠️  |
| □  | LAN2 & LAN3 — ess-switch sürücüsü / driver / драйвер  | ⚠️  |
| □  | LED desteği / LED support / Поддержка светодиодов  | ⚠️  |

---

RELEASE_NOTES_v2.0.30-BETA -test30_TR.md
## 📦 Latest build: **test30** (v2.0.30- BETA)

| | |
|---|---|
| **Kernel** | 6.18.39 (OpenWrt qualcommbe LTS) |
| **Target / Board** | `qualcommbe/ipq53xx` / `mercusys_mr47be-v2` |
| **Boot** | Unsigned FIT, `config@mi01.6` → U-Boot RAM-boot OK |
| **USB** | Disabled (no physical port) |
| **LED / Button** | gpio-leds + gpio-keys (reset) |

### Build instructions (reproduce the image yourself)
- [🇹🇷 BUILD_INFO_TR.md](BUILD_INFO_TR.md)
- [🇬🇧 BUILD_INFO_EN.md](BUILD_INFO_EN.md)
- [🇷🇺 BUILD_INFO_RU.md](BUILD_INFO_RU.md)



### Other docs
- [MR47BE_V2_Hardware_Report_v2_EN.md](MR47BE_V2_Hardware_Report_v2_EN.md) — full hardware audit (photo + boot-log + GPL)

---

## 🛠️ Hardware (confirmed, evidence-based)

| Component | Detail | Evidence |
|---|---|---|
| **SoC** | Qualcomm **IPQ5322** (Miami, 4× A53, 6-stream) | Chip-top photo, JTAG mfg 0x70 |
| **6 GHz radio** | **QCN6274** over PCIe (`board-id 0x1015`) | Chip-top photo + boot log |
| **2.4/5 GHz** | on-SoC (`wifi0`, ath12k, `board-id 0x12`) | Vendor DTS / boot log |
| **Ethernet** | **QCA8084** switch-PHY (integrated, NO separate chip) | Boot log `QCA8084-switch` + GPL |
| **Flash** | Winbond W25N01GW 128 MiB SPI-NAND | Photo + boot log (exact) |
| **DRAM** | Samsung K4A8G165WC 1 GiB DDR4 | Photo + boot log (exact) |
| **UART** | 4-pin J1, 115200 8N1, `Secure Boot: Off` | Working capture |
| **Antennas** | 6× (2.4G×2, 5G×2, 6G×2) | Photos |

> Note: the boot log prints `IPQ5332LA` as a **BSP compiler string**, not a hardware read. The physical die is **IPQ5322**. The DTS uses `qcom,ipq5332` compatible (same Miami family/package — boots fine); confirm with `socinfo` after RAM-boot.

    **Ethernet reality (updated):** not "no driver" — Ethernet is driven by the open **`kmod-qcom-ppe`** (Qualcomm PPE/EDMA) driver. The DTS wires `xgmac1` → **eth1 = LAN** (fixed-link 2500 CPU uplink) and `xgmac2` → **eth0 = WAN** (phy@4). LAN1/2/3 as separate VLAN ports is a further DSA/PPE-VLAN task.

---

## 📥 Images

Uploaded to GitHub Releases (`v0.1.0-test5`):

| File | Purpose |
|---|---|
| `*-initramfs-uImage.itb` | RAM-boot / hardware testing (TFTP) |
| `*-squashfs-factory.bin` | Factory / UBI write |
| `*-squashfs-factory.ubi` | UBI image |
| `*-squashfs-sysupgrade.bin` | OpenWrt sysupgrade |
| `*-uImage.itb` | FIT kernel image |
| `*-manifest`, `sha256sums` | Package list + checksums |

*(file prefix: `openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2`)*

---
📥 KURULUM / INSTALLATION / УСТАНОВКА
⚠️ UYARI / WARNING / ПРЕДУПРЕЖДЕНИЕ: Geçicidir / Temporary / Временная. Kalıcı flashlama önerilmez / Permanent flashing not recommended / Постоянная прошивка не рекомендуется.
## 🚀 Quick start (UART → TFTP → RAM boot)
```İmajı İndir / Download the Image / Скачайте образ → Releases
setenv serverip 192.168.1.100
setenv ipaddr 192.168.1.1
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000

```

**UART:** GPIO18=TX, GPIO19=RX, GND @ 115200 8N1. 
**Boot address:** `0x46000000` (`0x44000000` collides — do not use). 
`Secure Boot: Off` → unsigned image accepted.

**Hardware verification (after boot):**
```sh
mii read 1 2 && mii read 1 3 && mii read 4 2   # QCA8084 PHY ID -> 0x004dd180
cat /proc/device-tree/compatible                # SoC compat
dmesg | grep -iE "ipq53|socinfo"
```

---

## ⚠️ Flash / recovery warnings

- **Back up the ART partition** (Wi-Fi calibration + MAC) before touching anything. Do **not** erase/overwrite it.
- Vendor firmware uses **RSA-signed, AES-CBC** cloud format → `_nosign_` and renamed files are **rejected** by stock web recovery.
- A/B layout: `rootfs` (A) / `rootfs_1` (B).

---

## 🧪 Current limitations

- [ ] RAM-boot + `socinfo` SoC confirm on real unit
- [ ] Wi-Fi 7 full validation (BDF / 6 GHz 320 MHz / MLO)
- [ ] WAN/LAN link-up validation (QCA8084 via `kmod-qcom-ppe`)
- [ ] LAN1/2/3 VLAN separation (DSA / PPE-VLAN driver work)
- [ ] NAND flash / stock-restore procedure test

---

## 📁 Project structure

```text
.
├── target/linux/qualcommbe/   # ipq53xx DTS, image defs, config
├── package/firmware/ipq-wifi/ # board BDF
├── imajlar/test5/             # built images + sha256sums
├── BUILD_INFO_{TR,EN,RU}.md
├── RELEASE_NOTES_v0.1.0-test5_{TR,EN,RU}.md
├── V2_HARDWARE_STATUS.md
└── LIVE_SESSION_STATE.md
```
---

## 🙏 Credits

- [OpenWrt](https://openwrt.org) (qualcommbe/ipq53xx target)
- https://github.com/perceival/openwrt-flint3
- https://github.com/luckkyboy/SBE1V1K
- Mercusys MR47BE V2 GPL source
- Community IPQ53xx OpenWrt work (Perceival / GL iNet)
- Hardware teardown & reverse-engineering analysis
---

📄 LİSANS / LICENSE / ЛИЦЕНЗИЯ
Bu proje, OpenWrt ile aynı lisans koşullarına tabidir.
This project is subject to the same license terms as OpenWrt.
Этот проект подчиняется тем же условиям лицензии, что и OpenWrt.

## ⚠️ Disclaimer

Experimental community port. Flashing custom firmware can permanently damage the device. Always keep a backup of the original firmware, NAND partitions, and especially the ART calibration data. **Use UART recovery whenever possible.**

🤝 KATKIDA BULUNMA / CONTRIBUTING / ВКЛАД
Hata raporları, test sonuçları ve katkılar için lütfen Issue açın veya Pull Request gönderin.
Please open an Issue or submit a Pull Request for bug reports, test results, and contributions.
Пожалуйста, открывайте Issue или отправляйте Pull Request для сообщений об ошибках, результатов тестов и вклада в проект.

✍️ NOT / NOTE / ПРИМЕЧАНИЕ
Bu port geliştirme aşamasındadır. Wi-Fi ve tüm Ethernet portları henüz tam çalışmıyor. Geri bildirimleriniz çok değerli.
This port is still in development. Wi-Fi and all Ethernet ports are not yet fully functional. Your feedback is highly valuable.
Этот порт все еще находится в разработке. Wi-Fi и все порты Ethernet пока не полностью функциональны. Ваши отзывы очень ценны.





