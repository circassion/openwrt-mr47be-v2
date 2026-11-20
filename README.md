# MERCUSYS MR47BE V2 BE9300  Wi-Fi 7 Router. OpenWrt (Snapshots) 

**OpenWrt port for the Mercusys MR47BE V2 (Qualcomm IPQ5322 · Wi-Fi 7)**

> **Status:** 🟡 Snapshots works — images build cleanly. Hardware validation
> (RAM-boot, Wi-Fi, Ethernet link-up) is in progress.
> Do not flash unless you understand UART/U-Boot recovery.

---
        MERCUSYS MR47BE V2 (2.4 GHz - 5GHz - 6GHz Wi-Fi 7). OpenWrt (snapshots)

<img width="1902" height="861" alt="resim" src="https://github.com/user-attachments/assets/c1f8f0a2-b4aa-4d5d-9541-32a22f21b0e1" />


🎯  Current Status 

| □ | Current | Status |
|---|---|---|
| ✅ | WAN (DHCP + Internet |  2.5G/1G Working (QCA8084) |
| ✅ | LAN1 (Ethernet) | 2.5G/1G Working (QCA8084) |
| ✅ | LuCI (Web UI ) |  Working |
| ✅ | Wi-Fi 5/6GHz (QCN6274)| QCN6274 WiFi 7 firmware |
| ✅ | PCIe: | QCN6274 | detected (17cb:1109) |
| ✅ | LAN2/3 (Ethernet) | 2.5/1G Working  |
| ✅ | Wi-Fi 2.4GHz (Q6) | WiFi 7 firmware |


---

| 📌 ROADMAP | - | □ |
|---|---|---|
| ☑ | WAN (DHCP + Internet | ✅ |
| ☑  | LuCI  | ✅ |
| ☑  | Wi-Fi 2.4GHz | ✅ |
| ☑  | Wi-Fi 5/6GHz — MHI/QMI firmware loading | ✅ |
| ☑  | LED support | ✅ |
| ☑  | LAN1 & LAN2 & LAN3 — ess-switch driver | 2.5 G QCA8386 DSA Working |



---

MERCUSYS MR47BE V2 (5GHz - 6GHz Wi-Fi 7). OpenWrt (snapshots)

| | |
|---|---|
| **Kernel** | 6.18.39/44/52/54/55/60/62 (OpenWrt qualcommbe LTS) |
| **Target / Board** | `qualcommbe/ipq53xx` / `mercusys_mr47be-v2` |
| **Boot** | Unsigned FIT, `config@mi01.6` → U-Boot RAM-boot OK |
| **LED / Button** | gpio-leds + gpio-keys (reset) |
| **USB** | Disabled (no physical port) |

---

### Other docs
— full hardware audit (photo + boot-log + GPL)

Do not touch:(gpio)
8–13: NAND. Writing here will cause the system to crash.
18/19: UART.
25–28: MDIO.
29, 35: Button.
30, 39, 43, 45: PHY reset lines.
16: Used as an MDIO reset in the DTS.
38, 44, 46–51: PCIe/BT

---

## 🛠️ Hardware (confirmed, evidence-based)

| Component | Detail | Evidence |
|---|---|---|
| **SoC** | Qualcomm **IPQ5322** (Miami, 4× A53, 6-stream) | Chip-top photo, JTAG mfg 0x70 |
| **5/6 GHz radio** | **QCN6274** over PCIe (`board-id 0x1015`) | Chip-top photo + boot log |
| **2.4 GHz** | on-SoC (`wifi0`, ath12k, `board-id 0x12`) | Vendor DTS / boot log |
| **Ethernet** | **QCA8386+QCA8084** switch-PHY | Boot log `QCA8084-switch` + GPL +Chip-top photo|
| **Flash** | Winbond W25N01GW 128 MiB SPI-NAND | Photo + boot log (exact) |
| **DRAM** | Samsung K4A8G165WC 1 GiB DDR4 | Photo + boot log (exact) |
| **UART** | 4-pin J1, 115200 8N1, `Secure Boot: Off` | Working capture |
| **Antennas** | 6× (2.4GHz×2, 5GHz×2, 6GHz×2) | Photos |

> Note: the boot log prints `IPQ5332` as a **BSP compiler string**, not a hardware read.
> The physical die is **IPQ5322**. The DTS uses `qcom,ipq5332` compatible
> (same Miami family/package — boots fine); confirm with `socinfo` after RAM-boot.


### 🔧 Hardware Architecture & Known Limitations

**Chipset Configuration:**
- **CPU:** Qualcomm IPQ5332 (2x 2.5G MAC only)
- **Switch:** QCA8386 (4-port 2.5G switch with 2 HSGMII interfaces) (Kernel 6.18.55/60/62)
- **PHY:** QCA8084 (2.5G multi-gig PHY)

**⚠️ Critical Bandwidth Limitation:** (Only 6.18.39 Kernel)
The QCA8386 switch chip has only **2 HSGMII interfaces**, limiting total switch-to-CPU bandwidth to **5 Gbps**. While all 4 ports support 2.5G physically, they share this 5 Gbps aggregate bandwidth

**Port Behavior:**
- ✅ All 4 ports negotiate at 2.5G link speed
- ️ Total throughput capped at 5 Gbps (hardware limitation)

**Why QCA8386 instead of QCA8084?**  (Only 6.18.39 Kernel)
The IPQ5332 CPU lacks 4x 2.5G MACs required for QCA8084 (which would provide 10 Gbps via USXGMII). QCA8386 is a cost-effective solution but sacrifices total bandwidth [[1]].

**Reference:** Detailed analysis at [ACWIFI.NET - TP-LINK 7DR6560 teardown](https://www.acwifi.net/26503.html) (Chinese, technical deep-dive)

#### 🔌 Physical Port Map & Link Requirements

```
[ BACK PANEL VIEW (Left to Right) ]
|  LAN 1  |  LAN 2  |  LAN 3  |   WAN   |
|  2.5G   |   2.5G    |   2.5G    |  2.5G   |

```

#### 🛠️ Strict Port Negotiation Rules (Current Build)
*   **WAN Port:** **MUST** be connected to a 2.5G upstream source. Connecting to a 2.5/1G modem/router 
*   **LAN 1:** **MUST** be connected to a 2.5G client device. 
*   **LAN 2 & LAN 3:** **MUST** be connected to 2.5/1G client devices. Multi-gig (2.5G/5G/10G) 

```

#### 🌐 RAM Boot / UART Initial IP Warning
When booting the image via RAM (TFTP/UART), the default IP is `192.168.1.1`. To prevent subnet conflicts with your existing local network, **the initial boot IP has been remapped to `192.168.5.1/24`**.
1.  **During Boot:** You must manually assign the static IP `192.168.5.2/24` to your PC's NIC to access the router's web interface/SSH.
2.  **Post-Boot Cleanup:** Once the router fully boots and you configure your normal WAN/LAN settings, **you MUST remove the static IP assignment from your PC's network adapter** and revert to DHCP. Failing to do so will result in false "no IP / no internet" symptoms on your PC.

```

✅ Working Features
**Wi-Fi 5/6GHz (QCN6274)| QCN6274 WiFi 7 firmware
WAN (DHCP + Internet) —  successful
LAN1 (Ethernet) — SSH + ping accessible
LAN2 (Ethernet) — SSH + ping accessible
LAN3 (Ethernet) — SSH + ping accessible
LuCI (Web UI) — http://192.168.5.1
PCIe — QCN6274 Wi-Fi 7 chip detected (17cb:1109)
SOC - 2.4GHz 
LEDs POWER — ( Red/Orange/ Green)
LEDs(Ethernet) — LAN3

```
- **LuCI Port Status Visibility (QCA8386/QCA8084):** 
  LAN2 and LAN3 ports are fully functional at the hardware level (clients successfully obtain DHCP leases and pass traffic). However, they do not appear in the LuCI "Port Status" widget. 
  **Root Cause:** The current Device Tree (DTS) configuration aggregates the switch ports under a single `lan` interface without exposing them as individual labeled DSA slave ports (e.g., `lan1`, `lan2`). The QCA8386 switch handles Layer-2 traffic in hardware transparently. 
  **Impact:** UI display limitation only. No impact on actual routing, switching, or DHCP functionality. Future DTS updates will add proper `label` properties to restore per-port visibility in LuCI.
**LuCI Port Status Widget Shows No LAN Ports**

- **Hardware:** Qualcomm IPQ5332 + QCA8386 Switch + QCA8084 2.5G PHY
- **Issue:** LAN/WAN ports do not appear in LuCI Port Status widget
- **Root Cause:** QCA8386 DSA (Distributed Switch Architecture) slave interfaces are not properly defined in the Device Tree configuration. The switch operates in hardware bridging mode, exposing only a single `lan` interface to the kernel instead of individual port interfaces (lan1, lan2, lan3, wan).
- **Impact:** 
  - ✅ Ports are **fully functional** at hardware level (DHCP, routing, switching work)
  - ❌ LuCI cannot display per-port statistics or link status
  - ⚠️ Port-specific configurations (VLAN, speed limits) cannot be managed via LuCI

- **Workaround:** 
  - Verify port activity via SSH: `cat /sys/class/net/lan/statistics/rx_packets`
          'ubus call network.device status'

  - Check DHCP leases to confirm client connectivity
  - Physical port functionality is not affected

- **Fix Required:** Device Tree Source (DTS)

```
📥 Installation (TFTP RAM Boot)
⚠️ Warning: This method is temporary. The device will revert to stock firmware after reboot. Permanent flashing is not recommended yet.

Download this image: openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
Set your PC IP to 192.168.5.100 and start a TFTP server. Place the image in the TFTP root directory.
Connect to the device via UART (115200 8N1) and stop autoboot in U-Boot.
Run the following commands:
```

---

## 📥 Images

Uploaded to GitHub Releases 
(`MERCUSYS MR47BE V2.1.07 (2.4GHz - 5GHz - 6GHz Wi-Fi 7). OpenWrt ((snapshots))`):

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
📥 INSTALLATION
⚠️  WARNING :  / Temporary.  Permanent flashing not recommended 
## 🚀 Quick start (UART → TFTP → RAM boot)
```Download the Image /  → Releases
setenv serverip 192.168.5.100
setenv ipaddr 192.168.5.1
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000

```

**UART:** GPIO18=TX, GPIO19=RX, GND @ 115200 8N1. 
**Boot address:** `0x46000000` (`0x44000000` collides — do not use). 
`Secure Boot: Off` → unsigned image accepted.

```
UART pinout
uart
             V
o   o   o    o
Nc -Gnd -Rx -Tx

UART pinout

Viewed from above using the board's pin-1 triangle:

       pin-1 triangle
                         v
AP header:  [1] [2] [3] [4]
             NC  GND  RX  TX
                  |    |   |
USB-UART:        GND  TX  RX

AP pin 	Signal 	Connect to
1 	NC 	Leave unconnected
2 	GND 	Adapter GND
3 	RX 	Adapter TX
4 	TX 	Adapter RX

Warning

3.3 V means TTL logic level, not a power connection. Power the AP through PoE and connect only RX, TX, and GND. Never connect the adapter's VCC, 3V3, or 5V lead to pin 1 or any other AP header pin. Never use RS-232 voltage levels.

---

## ⚠️ Flash / recovery warnings

- **Back up the ART partition** (Wi-Fi calibration + MAC) before touching anything. Do **not** erase/overwrite it.
- Vendor firmware uses **RSA-signed, AES-CBC** cloud format → `_nosign_` and renamed files are **rejected** by stock web recovery.
- A/B layout: `rootfs` (A) / `rootfs_1` (B).

---

# 📡 Mercusys MR47BE v2 → OpenWrt

**Stok yazılımdan OpenWrt'ye geçiş imajı.** Stok yazılım **silinmez**: cihazda çift önyükleme oluşur ve **reset tuşuyla stoka dönülür**.

**Transition firmware** to move a Mercusys MR47BE v2 from stock to OpenWrt and back. Stock is **never erased**: dual boot + reset rollback.

**Переходная прошивка** для Mercusys MR47BE v2. Сток **не удаляется**: двойная загрузка + возврат кнопкой reset.

> [!WARNING]
> 🇹🇷 Resmi değildir, kullanım sana aittir, garanti etkilenebilir. Sadece **MR47BE v2**.
> 🇬🇧 Unofficial, use at your own risk, warranty may be affected. **MR47BE v2** only.
> 🇷🇺 Неофициальная, на ваш риск, гарантия может быть затронута. Только **MR47BE v2**.

---

## 📥 İndir / Download / Скачать

Dosyayı **[Releases](../../releases)** sayfasından indir.

| Dosya | Boyut |
|---|---|
| `openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-transition.bin` | 22.417.850 B |

**SHA-256:**

```
a273b2c7b21a932b4e636d81ecb518aabab94c3bf39ffb79fddb47d5f4cb142e
```

Doğrulama (Windows): `certutil -hashfile <dosya> SHA256`

---

## 📖 Belgeler / Guides / Инструкции

| Dil | Belge |
|---|---|
| 🇹🇷 **Türkçe** | [docs/KURULUM_TR.md](docs/KURULUM_TR.md) |
| 🇬🇧 **English** | [docs/INSTALL_EN.md](docs/INSTALL_EN.md) |
| 🇷🇺 **Русский** | [docs/INSTALL_RU.md](docs/INSTALL_RU.md) |
| 🔧 **Teknik / kurtarma** | [docs/TEKNIK_TR.md](docs/TEKNIK_TR.md) |
| 📝 **Sürüm notları** | [RELEASE_NOTES.md](RELEASE_NOTES.md) |

Belgeler **hiç bilmeyen** biri için yazıldı. Her adımda "ne yapacaksın" ve "ne göreceksin" ayrı yazılıdır.

---

## ⚡ Kısa özet

### 🇹🇷 Türkçe

1. Cihaz **v2** ve **stok 1.1.11** olsun.
2. Bilgisayarı **kablo ile LAN2**'ye bağla. Wi-Fi ile yükleme **yasak**.
3. `http://192.168.1.1` → **System → Firmware Upgrade** → `...transition.bin` → yükle.
4. Router kendi kendine yeniden başlar → **3–5 dakika bekle**.
5. `http://192.168.5.1` → kullanıcı `root`, şifre **boş** → hemen şifre koy.
6. Wi-Fi şifresi `12345678`'dir → **onu da değiştir**.
7. **Stoka dönüş:** OpenWrt çalışırken **reset'e (26) 20 saniye bas** → `192.168.1.1`.

### 🇬🇧 English

1. Device must be **v2** running **stock 1.1.11**.
2. Connect by **cable to LAN2**. Flashing over Wi-Fi is **forbidden**.
3. `http://192.168.1.1` → **System → Firmware Upgrade** → `...transition.bin` → upload.
4. The router reboots itself → **wait 3–5 minutes**.
5. `http://192.168.5.1` → user `root`, **empty** password → set one immediately.
6. Wi-Fi password is `12345678` → **change it too**.
7. **Back to stock:** while OpenWrt runs, **hold reset for (26) 20 seconds** → `192.168.1.1`.

### 🇷🇺 Русский

1. Роутер **v2**, на нём **сток 1.1.11**.
2. **Кабель в LAN2**. Прошивка по Wi-Fi **запрещена**.
3. `http://192.168.1.1` → **System → Firmware Upgrade** → `...transition.bin` → загрузить.
4. Роутер сам перезагрузится → **подождите 3–5 минут**.
5. `http://192.168.5.1` → логин `root`, пароль **пустой** → сразу задайте пароль.
6. Пароль Wi-Fi `12345678` → **смените и его**.
7. **Возврат на сток:** при работе OpenWrt **держите reset (26) 20 секунд** → `192.168.1.1`.

---

## 🔌 Hangi port? / Which port?

| Port | Durum | Not |
|---|---|---|
| **LAN1** | ⚠️ 2.5G | Her PC'de 2.5G yok, bazı açılışlarda geç gelir. **Önerilmez.** |
| **LAN2** | ✅ | **Önerilen / Recommended** |
| **LAN3** | ✅ | Kullanılabilir / OK |
| **WAN** | ✅ 1G | İnternet girişi / Internet input |

---

## ✅ Bu sürümde doğrulananlar

| Test | Sonuç |
|---|---|
| LAN2 / LAN3 | ✅ DHCP veriyor |
| LAN1 (2.5G) | ⚠️ çalışıyor, bazı açılışlarda geç geliyor |
| WAN (1G / 2.5G kablo) | ✅ DHCP + NAT + DNS |
| Wi-Fi 2.4G / 5G / 6G | ✅ 802.11be (Wi-Fi 7), internet geçiyor |
| overlay (ayarlar kalıcı) | ✅ |
| `fw_setenv` (mtd8'e yazma) | ✅ |
| Stok yazılım (mtd12) | ✅ dokunulmadı, bölüm bölüm doğrulandı |
| Reset **20  (26) sn** → stok | ✅
| U-Boot `httpd` kurtarma (`192.168.1.1`) | ✅

---

## ⚠️ Bilinen sınırlamalar

| Konu | Açıklama |
|---|---|
| **LuCI → Sysupgrade** | Bu kart için desteklenmiyor. "Force upgrade" **hiçbir şey yazmaz**. Kurulum bu transition imajıyla yapılır. |
| **Wi-Fi ile flash** | Yasak. Kablo zorunlu. |
| **LAN portları** | Yüklemeden sonra 1–2 dakikada açılır. DHCP bu sürede gelmeyebilir. |
| **2.4G açılış uyarısı** | dmesg'de `ath12k ... firmware-2.bin: -12` görülür. **Zararsızdır**, radyo çalışır. Ayrıntı: [TEKNIK_TR.md](docs/TEKNIK_TR.md) |

---

## 🧯 Acil durum

Cihaz hiç açılmıyorsa sırayla:

| Sıra | Yol |
|---|---|
| 1️⃣ | **Reset'e 26 saniye** bas (OpenWrt açıksa) |
| 2️⃣ | **UART** → U-Boot → `setenv tp_boot_idx 0` → `saveenv` → `bootipq` |
| 3️⃣ | **UART** → U-Boot → `httpd` → PC'ye `192.168.0.10` ver → tarayıcıda `192.168.0.1` → stok `.bin` yükle |

Ayrıntılı adımlar: [docs/TEKNIK_TR.md](docs/TEKNIK_TR.md)

---

## 🔧 Teknik özet

| Öğe | Değer |
|---|---|
| SoC | IPQ5332 (IPQ5322 die), 1 GiB DDR4, 128 MiB SPI-NAND |
| Çift önyükleme | stok = `mtd12` (`ubi`), OpenWrt = `mtd13` (`rootfs_1`) |
| Seçim | U-Boot ortamı `tp_boot_idx` (mtd8): `1` OpenWrt, `0` stok |
| Reset | GPIO30 aktif-low: <1 sn reboot, 5–14 sn ayar sıfırla, ≥15 sn stok |
| Ethernet | `lan` = 2.5G (die-switch uplink), `gmac1` = 1G WAN |

---

## 🙋 Yardım / Help

Takıldıysan **Issues** bölümünden yaz. Şunları ekle:

- Cihaz etiketindeki **Ver** bilgisi
- Stok sürüm numarası
- Hangi **adımda** kaldığın
- Işıkların durumu
- Kullandığın LAN portu

---

## 🔗 Kaynaklar

- IPQ5332 Q6 firmware / `.mdt` verisi ve 2.4 GHz bulguları: [perceival/openwrt-flint3 — Issue #93](https://github.com/perceival/openwrt-flint3/issues/93) (aynı hatayı MR47BE v2'de inceleyen LycorisWave'e teşekkürler)
- OpenWrt IPQ5332 hedefi: [openwrt/openwrt](https://github.com/openwrt/openwrt)

---

## 📄 Lisans

Belgeler: CC BY-SA 4.0 · Betikler: GPL-2.0 (OpenWrt ile uyumlu). Kernel/OpenWrt ve Qualcomm firmware dosyaları kendi lisanslarına tabidir.


## 🙏 Credits

- [OpenWrt](https://openwrt.org) (qualcommbe/ipq53xx target)
- https://github.com/perceival/openwrt-flint3
- https://github.com/luckkyboy/SBE1V1K
- https://github.com/VIKINGYFY/OpenWRT-CI
- https://github.com/kwrum1/ebpf-honk-ImmortalWRT-CI
- https://github.com/anothaDev/luci-theme-vantage
- Mercusys MR47BE V2 GPL source
- D-Link M95A1 GPL source (Openwrt Kernel 5.4)(IPQ5332+QCA8386+QCA8081+QCA6274)
- Community IPQ53xx OpenWrt work (Perceival / GL iNet)
- Hardware teardown & reverse-engineering analysis
- https://github.com/morluto/rea reverse-engineering analysis
- ACWIFI.NET - TP-LINK 7DR6560 teardown https://www.acwifi.net/26503.html
---

📄 LICENSE
This project is subject to the same license terms as OpenWrt.

## ⚠️ Disclaimer

Experimental community port. Flashing custom firmware can permanently damage the device. 
Always keep a backup of the original firmware, NAND partitions, and especially the ART calibration data. 
**Use UART recovery whenever possible.**

🤝 CONTRIBUTING
Please open an Issue or submit a Pull Request for bug reports, test results, and contributions.

✍️ NOTE 
This port is still in development. Wi-Fi and all Ethernet ports are not yet fully functional. 
Your feedback is highly valuable.





