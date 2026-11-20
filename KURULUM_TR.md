# 🚀 MR47BE v2 — Stoktan OpenWrt'ye geçiş

**Hiç router yazılımı değiştirmemiş biri için yazıldı.** Sırayla ilerle, atlama yapma.

⏱️ Toplam süre: **~15 dakika** (+ router'ın kendine gelmesi için 5 dakika)

🌍 Diller: **Türkçe** · [English](INSTALL_EN.md) · [Русский](INSTALL_RU.md) · 🔧 [Teknik / kurtarma](TEKNIK_TR.md)

> [!WARNING]
> Bu yazılım **resmi değildir**. Kullanım senin sorumluluğundadır. Cihaz garantisi etkilenebilir. Sadece **Mercusys MR47BE v2** içindir.

---

## 1️⃣ Önce şunu bil

✅ **Stok yazılımın SİLİNMEZ.** Cihazın içinde iki ayrı bölüm var:

| Bölüm | İçinde ne var |
|---|---|
| Birinci bölüm | **Stok yazılım** (Mercusys arayüzü) — dokunulmaz |
| İkinci bölüm | **OpenWrt** — biz buraya yazacağız |

🔙 İstediğin zaman **reset tuşuna 20 saniye basarak** stoka dönebilirsin.

❌ **Wi-Fi ile yükleme YAPMA.** Kablo kullan.

❌ Yükleme sırasında **fişi çekme**, **reset'e basma**.

✅ Cihaz **stok 1.1.11** yazılımında olmalı.

✅ Cihazın **v2** olmalı. Router'ın altındaki etikette **Ver: 2.x** yazar.

---

## 2️⃣ Ne lazım?

- 🔌 1 adet **Ethernet kablosu** (bilgisayar ↔ router)
- 🌐 Bir **tarayıcı** (Chrome / Edge / Firefox)
- 📦 Şu dosya: **`openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-transition.bin`**
- 🔐 (İstersen) dosyanın doğruluğunu `SHA256SUMS.txt` ile kontrol et

> [!NOTE]
> Dosya adı önemli değil, istersen değiştirebilirsin.

---

## 3️⃣ Kabloyu nereye takacağım?

| Port | Durum | Ne yapmalı |
|---|---|---|
| **LAN1** | ⚠️ 2.5G port | Her bilgisayarda 2.5G yoktur; bazı açılışlarda geç gelebilir. **Önermiyoruz.** |
| **LAN2** | ✅ Çalışıyor | **Önerilen** |
| **LAN3** | ✅ Çalışıyor | Kullanabilirsin |
| **WAN** | 🌍 İnternet girişi | Şimdilik dokunma |

👉 Kabloyu **LAN2**'ye tak, diğer ucunu bilgisayarına.

⏳ Yükleme bittikten sonra LAN portlarının açılması **1–2 dakika** sürebilir. Bu normaldir.

---

## 4️⃣ Stok arayüze gir

**Adım 1.** Tarayıcıya yaz: **http://192.168.1.1**

**Adım 2.** Şifre sorarsa, fabrika ayarındaki cihazda şifre **router'ın altındaki etikette** yazar.

**Adım 3.** Şifreyi bilmiyorsan, router çalışırken **reset'e 10 saniye bas**. Cihaz sıfırlanır, sonra etiketteki şifreyle gir.

👀 **Ne göreceksin:** Mercusys'in kendi arayüzü.

**Sürüm kontrolü:** Arayüzde sürümün **1.1.11** yazdığından emin ol.

> [!TIP]
> Sürüm farklıysa önce Mercusys destek sitesinden **1.1.11**'i indirip yükle. Bulamazsan GitHub'da **Issues** bölümünden yaz.

---

## 5️⃣ Bilgisayar IP almıyorsa

Bazen bilgisayar router'dan otomatik IP alamaz ve sayfa açılmaz. Çözüm: IP'yi elle ver.

| Ne zaman | Bilgisayarın IP'si | Alt ağ maskesi |
|---|---|---|
| Stok arayüz (`192.168.1.1`) açılmıyorsa | `192.168.1.10` | `255.255.255.0` |
| OpenWrt (`192.168.5.1`) açılmıyorsa | `192.168.5.10` | `255.255.255.0` |

**Windows'ta:** Ayarlar → Ağ ve İnternet → Ethernet → IP atama → Düzenle → Elle → IPv4 açık → yukarıdaki değerleri yaz → Kaydet.

🔁 İşin bitince **"Otomatik (DHCP)"** seçeneğine geri dön.

---

## 6️⃣ Dosyayı yükle

**Adım 1.** Menüden **System → Firmware Upgrade** yolunu aç.

**Adım 2.** **Browse / Dosya Seç** düğmesine bas.

**Adım 3.** `...transition.bin` dosyasını seç.

**Adım 4.** **Upgrade / Yükle** düğmesine bas, onay penceresine **Evet** de.

⏳ **Ne olacak:** İlerleme çubuğu **1–2 dakika** dolar, router **kendi kendine yeniden başlar**, ışıklar tuhaf yanıp sönebilir. Hepsi normal.

🧘 Yeniden başladıktan sonra OpenWrt'nin açılması **3–5 dakika** sürebilir. Hiçbir şeyi sökme.

---

## 7️⃣ OpenWrt'ye gir

**Adım 1.** Tarayıcıya yaz: **http://192.168.5.1**

**Adım 2.** Kullanıcı adı: **`root`**

**Adım 3.** Şifre: **boş**. Hiçbir şey yazmadan Giriş'e bas.

👀 **Ne göreceksin:** OpenWrt (LuCI) arayüzü.

> [!TIP]
> Açılmazsa 3–5 dakika daha bekle. Sonra kabloyu LAN2'den LAN3'e al ve 1 dakika bekle. Hâlâ açılmazsa 5. bölümdeki IP ayarını yap.

---

## 8️⃣ 🔒 İlk iş: şifreleri değiştir

> [!CAUTION]
> OpenWrt'de **root şifresi baştan yoktur** ve Wi-Fi şifresi **`12345678`**'dir. Bu şifre herkese açıktır. İkisini de hemen değiştir.

| Ne | Nereden |
|---|---|
| 🔑 Router şifresi | **System → Administration → Router Password** |
| 📶 Wi-Fi şifresi | **Network → Wireless → Düzenle → Wireless Security → Key** |

Wi-Fi şifresini **3 ağ için de** (2G, 5G, 6G) değiştir.

---

## 9️⃣ Wi-Fi ağları

Cihaz açıldığında **3 Wi-Fi ağı** hazır gelir:

| Ağ adı (SSID) | Şifre | Ne için |
|---|---|---|
| `OpenWRT_2G` | `12345678` | Eski cihazlar / en uzak mesafe |
| `OpenWRT_5G` | `12345678` | **Günlük kullanım (önerilen)** |
| `OpenWRT_6G` | `12345678` | Yeni telefon ve bilgisayarlar, en hızlı |

> [!NOTE]
> Güvenlik **WPA3**'tür. Çok eski bir cihaz bağlanamazsa `OpenWRT_2G`'yi dene veya LuCI'den o ağı WPA2'ye çevir.

---

## 🔟 İnterneti bağla

**Adım 1.** Modemden gelen internet kablosunu router'ın **WAN** portuna tak.

**Adım 2.** OpenWrt kendi kendine IP alır (DHCP).

**Adım 3.** Kontrol: **Network → Interfaces** → `wan` satırında **up** ve bir IP görünmeli.

🎉 Artık hem kablodan hem Wi-Fi'den internet var.

---

## 1️⃣1️⃣ 🔙 Stoka geri dönmek

Router **OpenWrt çalışırken**:

**Adım 1.** Arkadaki **reset** dtuşunu basılı tut..

**Adım 2.** **20 saniye basılı tut.** Telefonun kronometresiyle say.

**Adım 3.** Bırak. Router kendi kendine yeniden başlar.

**Adım 4.** **~1 dakika sonra** stok arayüz açılır: **http://192.168.1.1**

| Ne kadar basarsan | Ne olur |
|---|---|
| 1 saniyeden az | Sadece yeniden başlar |
| **5–14 saniye** | OpenWrt ayarlarını sıfırlar, OpenWrt'te kalır |
| **15 saniye ve üstü (26 sn yap)** | 🔙 **Stok yazılıma döner** |

> [!TIP]
> Stok ayarların (Wi-Fi adı, şifresi) olduğu gibi durur. Stokta fabrika sıfırlaması yapmadıysan hiçbir şey kaybolmaz.

---

## 🆘 Bir şeyler ters giderse

| Belirti | Sebep | Ne yapmalı |
|---|---|---|
| Dosyayı yüklerken hata | Yanlış dosya | Doğru `...transition.bin` dosyasını seç, SHA-256'yı kontrol et |
| Yükleme bitti ama yine stok açıldı | Yükleme tamamlanmadı | Aynı işlemi tekrar yap |
| `192.168.5.1` açılmıyor | Ağ henüz hazır değil | 5 dk bekle, kabloyu LAN3'e al, 5. bölümdeki IP'yi ver |
| Kablo takılı ama IP gelmiyor | Port henüz açılmadı | 2 dk bekle, **LAN2** kullan |
| Wi-Fi'de internet yok | WAN kablosu takılı değil | İnternet kablosunu WAN'a tak |
| 2.4G Wi-Fi bağlanmıyor | Nadir / istemci sorunu | **5G veya 6G** kullan |
| LuCI "Sysupgrade is not supported" diyor | Bu kart için normal | **"Force upgrade" hiçbir şey yazmaz.** Bu imajı stok arayüzden yükle |
| Stoka dönmüyor | Kısa bastın | **20 veya 26 saniye** bas |
| Cihaz hiç açılmıyor | Nadir | Panik yok, UART ile kurtarılır: [TEKNIK_TR.md](TEKNIK_TR.md) |

### 🙋 Yardım isterken şunları yaz

Issues bölümünde şu bilgileri ver, çözüm çok hızlanır:

- Cihaz etiketindeki **Ver** bilgisi
- Stok sürüm numarası
- Hangi **adımda** kaldığın
- Işıkların durumu (yanıyor / yanıp sönüyor / sönük)
- Hangi LAN portunu kullandığın

---

## ❓ Sık sorulan sorular

**Stok yazılım gitti mi?**
Hayır. Ayrı bölümde duruyor, reset ile geri dönülüyor.

**Wi-Fi'den yükleyebilir miyim?**
Hayır. Kablo zorunlu.

**Yükleme yarıda kaldı, ne yapayım?**
Fişi çekme, 10 dakika bekle. Açılmazsa reset 20 sn → stok. O da olmazsa UART.

**Dosya bozuk mu indi?**
`SHA256SUMS.txt` ile karşılaştır. Windows'ta: `certutil -hashfile <dosya> SHA256`

**OpenWrt'yi güncelleyebilir miyim?**
LuCI'deki "Sysupgrade" bu kart için **desteklenmiyor**. Yeni sürüm çıkınca aynı yöntemle (stok → upgrade) yüklenir.

---

## ✅ Yapılacaklar listesi

- [ ] Cihaz **v2** ve stok **1.1.11**
- [ ] Kablo **LAN2**'de, Wi-Fi kapalı
- [ ] `192.168.1.1` açıldı, giriş yapıldı
- [ ] `...transition.bin` yüklendi
- [ ] Router yeniden başladı, 5 dakika beklendi
- [ ] `192.168.5.1` açıldı
- [ ] **root şifresi değiştirildi**
- [ ] **Wi-Fi şifreleri değiştirildi**
- [ ] WAN kablosu takıldı, internet geldi
- [ ] Wi-Fi'den telefonla test edildi
- [ ] (İstersen) reset 20 sn ile stoka dönüş denendi

🎉 **Bitti!**
