# 🔧 MR47BE v2 — Teknik notlar ve kurtarma

> [!IMPORTANT]
> Bu dosya **normal kullanıcı için değil**, ileri seviyedir. Kurulum için [KURULUM_TR.md](KURULUM_TR.md) kullan.

---

## 📑 İçindekiler

1. Donanım ve flash yerleşimi
2. Transition imajı nedir?
3. Doğrulananlar (v10)
4. Kurtarma yolları (kolaydan zora)
5. UART ile kurtarma
6. OpenWrt'yi UART/TFTP ile yeniden yazmak
7. Bilinen tuzaklar
8. Doğrulama komutları

---

## 1️⃣ Donanım ve flash yerleşimi

| Öğe | Değer |
|---|---|
| SoC | Qualcomm IPQ5332 (IPQ5322 die), 4× Cortex-A53 |
| RAM | 1 GiB DDR4 |
| Flash | 128 MiB SPI-NAND (W25N01GW), PEB 128 KiB |
| Wi-Fi | IPQ5332 AHB (2.4G) + QCN9274 PCIe (5G/6G), 802.11be |
| Ethernet | `lan` = 2.5G (die-switch yukarı bağlantısı), `gmac1` = 1G WAN |

**Bölümler (kernel görünümü):**

| mtd | Etiket | İçerik |
|---|---|---|
| mtd0–mtd1 | `0:sbl1`, `0:mibib` | bootloader zinciri |
| mtd8 | `0:appsblenv` | **U-Boot ortamı** (`tp_boot_idx` burada) |
| mtd9 | `0:appsbl` | U-Boot |
| mtd10 | `0:art` | kalibrasyon verisi (Wi-Fi cal) |
| **mtd12** | `ubi` | **stok yazılım** (dokunulmaz) |
| **mtd13** | `rootfs_1` | **OpenWrt** (kernel + squashfs + overlay) |
| mtd14 | `tp_data` | stok veri alanı (UBIFS, salt-okunur) |

**Önyükleme seçimi:** U-Boot `tp_boot_idx` değişkeni.

| Değer | Açılan sistem |
|---|---|
| `1` | OpenWrt (mtd13) |
| `0` | stok (mtd12) |

---

## 2️⃣ Transition imajı nedir?

Stok WebUI, yüklediği dosyayı **doğrudan mtd12'ye yazmaz**. `fmup.lua` dosyayı `/tmp/firmware.bin` yapar ve doğrular. Bu imaj:

- 0x11BA ofsetinde **UBI** taşır (stok kendi başlığını bekliyor)
- başlık v5 alanlarını korur, sadece **MD5** alanı yeniden hesaplanır
- UBI boyutu **131072'nin tam katı** olmalıdır: 171 PEB = **22.413.312 B**

**MD5 kuralı:**

```
MD5 alanı = md5( SABİT + dosya[0x14:] )
SABİT     = 7a2b15ed9b98596de504ab44ac2a9f4e
```

RSA imzası stok **WebUI** yolunda kontrol edilmez (U-Boot yolu kontrol eder).

---

## 3️⃣ Geçerli sürüm (v10) — doğrulananlar

| Test | Sonuç |
|---|---|
| overlay (`/overlay`) | ✅ mount ediliyor, `/etc/config/` üretiliyor |
| LAN2 / LAN3 | ✅ DHCP veriyor |
| LAN1 (2.5G) | ⚠️ çalışıyor, bazı açılışlarda geç geliyor |
| WAN (`gmac1`) | ✅ DHCP + NAT + DNS |
| Wi-Fi 2.4G / 5G / 6G | ✅ üçü de bağlanıyor, internet geçiyor |
| `fw_setenv` (mtd8) | ✅ `tp_boot_idx` yazılıyor |
| reset ≥15 sn → stok | ⬜ TEST_ONAYI_BEKLENIYOR (26 sn uçtan uca) |

### 📻 2.4G açılış uyarısı (zararsız)

```
caldata12: request 'ath12k/IPQ5332/hw1.0/ath12k/IPQ5332/hw1.0/q6_fw1.mdt/firmware-2.bin'
ath12k_wifi7_ahb: failed to load firmware-2.bin: -12
```

**Sebep:** DTS'te `firmware-name` tam yol olarak verilmiş. Sürücü bunun önüne kendi klasörünü ekleyip sonuna `/firmware-2.bin` koyuyor. `IPQ5332/hw1.0` klasöründe birleşik `firmware-2.bin` yok (parçalı `q6_fw0.bXX` + `q6_fw1.mdt` var).

**Etki: yok.** Sürücü yedek yola düşüyor ve 2.4G radyosu çalışıyor. Canlı ölçüm: istemci bağlandı, `phy0-ap0` üzerinden **19 MB** trafik geçti, `hostapd: AP-STA-CONNECTED` kaydı var.

> [!NOTE]
> `failed to flush transmit queue` satırları istemci ayrılırken oluşur, zararsızdır.

---

## 4️⃣ 🛟 Kurtarma yolları (kolaydan zora)

Cihaz bozulursa **sırayla** şunları dene. Her yol bir öncekinde işe yaramazsa denenir.

| Sıra | Yol | Ne gerekir | Zorluk |
|---|---|---|---|
| 1️⃣ | **Reset 26 sn** (OpenWrt açıkken) | toplu iğne | ⭐ kolay |
| 2️⃣ | **UART + `tp_boot_idx 0`** | USB-TTL adaptör | ⭐⭐ orta |
| 3️⃣ | **UART + `httpd` kurtarma modu** | USB-TTL + stok `.bin` + kablo | ⭐⭐⭐ ileri |

### 1️⃣ Reset ile kurtarma

OpenWrt çalışıyorsa **reset'e 26 saniye** bas. Aşağıdaki tablo davranışı özetler.

| Basma süresi | Sonuç |
|---|---|
| < 1 sn | yeniden başlar |
| 5–14 sn | OpenWrt ayarları sıfırlanır |
| **≥ 15 sn (26 sn önerilir)** | **stoka döner** (`tp_boot_idx=0`) |

26 saniye seçilmesinin sebebi, 15 saniye eşiğine karşı **geniş güvenlik payı** bırakmaktır. Reset GPIO30, aktif-low.

### 2️⃣ ve 3️⃣ için ortak hazırlık

Gerekli: USB-TTL (**3.3V!**) adaptör, 115200 8N1, GND + TX + RX.

> [!CAUTION]
> Adaptörün **VCC** ucunu bağlama, sadece GND, TX, RX. 5V'luk adaptör cihazı yakabilir.

**Adım 1.** Terminali aç (PuTTY → Serial → COMx → 115200).

**Adım 2.** Cihaza fiş tak. U-Boot mesajları akarken **bir tuşa bas** (boşluk/Enter) ve otomatik açılışı durdur.

**Adım 3.** `IPQ5332#` komut satırını gör.

---

## 5️⃣ UART ile kurtarma

### 🅰️ Yol 2: Stok yazılımı seç (en basit)

`IPQ5332#` satırında şunları yaz:

```
setenv tp_boot_idx 0
saveenv
bootipq
```

`saveenv` 4 × 0x20000 blok siler, sonra ortamı yazar. Bu, cihazı **stoka** alır. Stok açıldıktan sonra `192.168.1.1` adresine gir.

### 🅱️ Yol 3: `httpd` ile web kurtarma modu

Stok yazılım da bozulduysa, U-Boot içinden **web üzerinden yeniden yükleme** yapılabilir.

**Hazırlık:**

| Ne | Ayrıntı |
|---|---|
| Stok yazılım | Mercusys sitesinden **1.1.11 `.bin`** dosyasını önceden indir |
| Kablo | Bilgisayar ↔ router **LAN2** |
| PC IP'si | `192.168.0.10` · maske `255.255.255.0` (elle ver) |

**Adım 1.** UART'tan U-Boot'a gir (yukarıdaki ortak hazırlık).

**Adım 2.** U-Boot satırında web sunucusunu başlat:

```
httpd
```

**Adım 3.** Tarayıcıdan kurtarma sayfasını aç: **http://192.168.0.1**

**Adım 4.** Stok `.bin` dosyasını seç ve yükle.

**Adım 5.** Router yeniden başlayınca bilgisayarın IP'sini **otomatiğe (DHCP)** geri al.

> [!NOTE]
> TP-Link'in kendi kurtarma sayfası genelde **192.168.0.1** adresindedir ve bilgisayara **192.168.0.10** verilir; DHCP bu modda **kapalıdır**. Sayfa açılmazsa U-Boot satırında `printenv ipaddr` yaz, çıkan adresi kullan.

> [!WARNING]
> `httpd` kurtarma yolu bu cihazda kullanıcı tarafından denenmeli, sonucu Issues'a yazılmalıdır. Durum: ⬜ TEST_ONAYI_BEKLENIYOR

**Stoka dönüş hatırlatması:** `httpd` ile stok yüklediysen U-Boot'un stok bölümünü açtığından emin ol:

```
setenv tp_boot_idx 0
saveenv
bootipq
```

---

## 6️⃣ OpenWrt'yi UART/TFTP ile yeniden yazmak

```
setenv ipaddr 192.168.5.1
setenv serverip 192.168.5.100
setenv netmask 255.255.255.0
tftpboot 0x46000000 factory.ubi
nand erase 0x4040000 0x34c0000
nand write 0x46000000 0x4040000 0x1560000
setenv tp_boot_idx 1
saveenv
bootipq
```

> [!CAUTION]
> `nand erase` ve `nand write` adresleri **yanlış yazılırsa stok bölümü silinir**. Komutları kopyalarken adresleri tek tek kontrol et. Stok bölüm `0x4040000`'dan **önce** başlar, ona dokunma.

`factory.ubi` = 22.413.312 B, `UBI#` ile başlar. Bilgisayara statik `192.168.5.100/24` ver.

---

## 7️⃣ ⚠️ Bilinen tuzaklar

| Tuzak | Açıklama |
|---|---|
| **LuCI sysupgrade** | `/lib/upgrade/platform.sh` içinde `mercusys,mr47be-v2` yok. "Force upgrade" **hiçbir şey yazmaz**, sadece servisleri kapatır. |
| **DTS `read-only;`** | `rootfs_1` veya `appsblenv` üzerinde kalırsa overlay mount olmaz / `fw_setenv` EACCES verir. v10'da ikisi de kaldırıldı. |
| **Wi-Fi ile flash** | Yasak. Kopma = tuğla riski. |
| **Aynı PC'de çok arayüz** | Windows'ta aynı alt ağa 2+ arayüz bağlamak rota karmaşası yaratır. |
| **LAN portlarının açılması** | Die-switch bring-up sırası nedeniyle 1–2 dakika sürebilir; bu sırada DHCP gelmeyebilir. |
| **LAN1 (2.5G)** | Her PC'de 2.5G yoktur, bazı açılışlarda geç gelir. Kullanıcıya **LAN2** önerilir. |

---

## 8️⃣ 🧪 Doğrulama komutları (OpenWrt)

```sh
cat /proc/mtd                          # bölümler
ubinfo -a                              # UBI hacimleri
mount | grep overlay                   # overlay bağlı mı
fw_printenv tp_boot_idx                # 1 = OpenWrt, 0 = stok
mr47be-die-switch status               # die-switch durumu
ip -br a ; ip route                    # ağ
nft list ruleset | grep -A3 forward    # firewall/NAT
iw dev                                 # Wi-Fi arayüzleri
```
