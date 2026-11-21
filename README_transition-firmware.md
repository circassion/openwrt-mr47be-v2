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
7. **Stoka dönüş:** OpenWrt çalışırken **reset'e 26 saniye bas** → `192.168.1.1`.

### 🇬🇧 English

1. Device must be **v2** running **stock 1.1.11**.
2. Connect by **cable to LAN2**. Flashing over Wi-Fi is **forbidden**.
3. `http://192.168.1.1` → **System → Firmware Upgrade** → `...transition.bin` → upload.
4. The router reboots itself → **wait 3–5 minutes**.
5. `http://192.168.5.1` → user `root`, **empty** password → set one immediately.
6. Wi-Fi password is `12345678` → **change it too**.
7. **Back to stock:** while OpenWrt runs, **hold reset for 26 seconds** → `192.168.1.1`.

### 🇷🇺 Русский

1. Роутер **v2**, на нём **сток 1.1.11**.
2. **Кабель в LAN2**. Прошивка по Wi-Fi **запрещена**.
3. `http://192.168.1.1` → **System → Firmware Upgrade** → `...transition.bin` → загрузить.
4. Роутер сам перезагрузится → **подождите 3–5 минут**.
5. `http://192.168.5.1` → логин `root`, пароль **пустой** → сразу задайте пароль.
6. Пароль Wi-Fi `12345678` → **смените и его**.
7. **Возврат на сток:** при работе OpenWrt **держите reset 26 секунд** → `192.168.1.1`.

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
| Reset **26 sn** → stok | ⬜ TEST_ONAYI_BEKLENIYOR |
| U-Boot `httpd` kurtarma (`192.168.0.1`) | ⬜ TEST_ONAYI_BEKLENIYOR |

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

## 📄 License / Lisans

| İçerik | Lisans |
|---|---|
| Özgün betikler, yamalar, hedef dosyalar | **GPL-2.0-or-later** |
| Device tree kaynakları (`*.dts`) | **GPL-2.0-or-later OR BSD-3-Clause** |
| Belgeler (`*.md`) | **CC BY-SA 4.0** |
| Qualcomm Wi-Fi firmware | **Repo'da yok** (proprietary; [LICENSING.md](LICENSING.md)) |
| OpenWrt / Linux / LuCI | Kendi lisansları (build sırasında indirilir, repo'da tutulmaz) |

Tam metinler: [LICENSES](LICENSES) · Bileşen eşlemesi: [LICENSING.md](LICENSING.md)
