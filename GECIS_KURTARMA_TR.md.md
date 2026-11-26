# MR47BE v2 — Geçiş ve Kurtarma (v26)

Kapsam: Mercusys **MR47BE v2** (etikette `Ver: 2.x`) · stok **1.1.11** · imaj **v26 / kernel 6.18.62**
İndirme: https://github.com/circassion/openwrt-mr47be-v2/releases/tag/v26

> Resmi olmayan topluluk imajı. Riski siz üstlenirsiniz. UART erişiminiz varsa önce tam NAND yedeği alın (özellikle ART).
> **Note:** the published image assets were refreshed with the **v27** build (kernel 6.18.62).
> The file names are unchanged; the checksums below match the files in the release.

## 0. Kurallar
- Sadece **kablo**, asla Wi-Fi üzerinden yazmayın.
- Kabloyu **LAN2 veya LAN3**'e takın. WAN'a ve (geçiş sırasında) LAN1'e takmayın.
- Yazma sırasında güç kesmeyin; yeniden başlatmadan sonra **3–5 dakika** bekleyin.
- **Stok silinmez.** Flash iki bölümlü: `tp_boot_idx=0` stok, `=1` OpenWrt.
- Dahili ağ kartı veya **Intel i225** tercih edin; bazı Realtek 2.5G USB adaptörler aktarımı bozuyor.
- Ardışık denemeler arasında cihazı **soğutun**; ısınınca 2.4 GHz radyo uyanmayabilir.

## 1. Dosyalar
| Dosya | Ne için |
|---|---|
| `transition_1_1_11_to_openwrt_6_18_62_FINAL_v26.bin` | Stok 1.1.11 → OpenWrt v26 (tek adım) |
| `openwrt-...-transition-v26.bin` | Aynı dosya, repo adıyla |
| `openwrt-...-squashfs-sysupgrade.bin` | OpenWrt → v26 güncelleme |
| `MR47BE(EU)_V2_1.1.11 Build 20260302` | Kurtarma / stoka dönüş |
| `factory.ubi`, `uImage.itb`, `initramfs-uImage.itb` | Geliştirici / UART / TFTP |

SHA-256 (transition): `9d3d075f8638a13900dc4f4741cf947edc50cc1ef89363ee9a62e2c7225f65b9`
SHA-256 (sysupgrade): `9603b128cd300ec84045dffd3096fcfd2e1c53d652027898033fbd66b7378f5a`
Kontrol: `certutil -hashfile <dosya> SHA256`

## 2. Stoktan OpenWrt'ye (tek adım)
1. Kablo LAN2'ye, PC'de IP **otomatik (DHCP)**.
2. Tarayıcı: **http://192.168.1.1** → stok Mercusys arayüzü. Parola etikette; bilinmiyorsa reset 10 sn.
3. Sürümün **1.1.11** olduğunu doğrulayın.
4. **System → Firmware Upgrade → Yerel Yükseltme** → `transition_..._FINAL_v26.bin` → **Upgrade**.
5. Çubuk 1–2 dk ilerler, cihaz kendi yeniden başlar. Sonra 3–5 dk bekleyin.
6. **http://192.168.5.1** → kullanıcı `root`, parola **boş**.
7. OpenWrt açılıyor ama sonraki yeniden başlatmada stoka dönüyorsa kalıcı yapın:
   `fw_setenv tp_boot_idx 1` → `reboot`
8. İlk işler: root parolası koyun, `OpenWRT_2G/5G/6G` şifrelerini (`12345678`) değiştirin, ülke kodunu seçin.

## 3. OpenWrt güncelleme (v11…v25 → v26)
LuCI → **System → Backup / Flash Firmware → Flash new firmware image** → `...squashfs-sysupgrade.bin`.
"Ayarları koru" işaretli kalabilir. Çok eski sürümlerden (v10/v13) temiz kurulum önerilir.

    scp openwrt-...-squashfs-sysupgrade.bin root@192.168.5.1:/tmp/
    ssh root@192.168.5.1
    sysupgrade -v /tmp/openwrt-...-squashfs-sysupgrade.bin    # ayarları korur
    sysupgrade -n /tmp/openwrt-...-squashfs-sysupgrade.bin    # temiz kurulum

❌ `transition.bin` / `factory.ubi` / `factory.bin` sysupgrade ile **yazılmaz** — onlar sadece stok WebUI için.

## 4. Stoka dönüş (3 yol)
**A. SSH (en kolay):**
    fw_printenv tp_boot_idx     # 1 = OpenWrt, 0 = stok
    fw_setenv tp_boot_idx 0
    reboot
OpenWrt silinmez, sadece boot seçimi değişir.

**B. Reset tuşu (OpenWrt çalışırken):**
| Basılı tutma | Sonuç |
|---|---|
| < 1 sn | yeniden başlatma |
| 5–14 sn | OpenWrt ayarları sıfırlanır |
| **15–26 sn** | **stoka döner** |
LED ~15. saniyede yanıp sönmeye başlar; o anda bırakabilirsiniz, en fazla 26 sn.

**C. UART / U-Boot:**
    setenv tp_boot_idx 0
    saveenv
    reset

## 5. Acil kurtarma — U-Boot web (UART gerekmez)
İki bölüm de bozulsa çalışır. **Yalnızca imzalı stok dosya kabul edilir.**
1. Gücü çekin.
2. **RESET'e basılı tutarken** gücü takın, **~25–26 sn** tutun, bırakın.
3. PC'ye sabit IP: **192.168.1.100 / 255.255.255.0**, ağ geçidi 192.168.1.1. Kablo **LAN2/LAN3**.
4. **http://192.168.1.1** (veya http://mwlogin.net). `/bin/cgi`'ye atıyorsa önbellek temizleyin / gizli sekme.
5. **Dosya Seç** → stok **1.1.11** → **Yükle** → **Devam Et**. Güç kesmeyin.
6. Cihaz stokla açılır. PC'yi tekrar **DHCP**'ye alın.

## 6. UART (115200 8N1, 3.3 V)
J1: `NC – GND – RX – TX`. Adaptörün **VCC'sini bağlamayın**, RS-232 seviyesi kullanmayın.
U-Boot istemi: `IPQ5332#`

Web kurtarma:
    setenv serverip 192.168.1.2
    setenv ipaddr 192.168.1.1
    httpd
PC: 192.168.1.2 → tarayıcı 192.168.1.1

RAM'den test (kalıcı değil):
    tftpboot 0x46000000 openwrt-...-initramfs-uImage.itb
    bootm 0x46000000
RAM boot IP'si 192.168.5.1 → PC 192.168.5.100. `0x44000000` kullanmayın (çakışıyor).

## 7. Sorun giderme
| Belirti | Çözüm |
|---|---|
| Sayfa açılmıyor / IP yok | PC'ye sabit IP: stok için 192.168.1.10, OpenWrt için 192.168.5.10 / 255.255.255.0 |
| Dosya yüklenmiyor | Yanlış dosya veya bozuk indirme → SHA-256 karşılaştırın |
| Yine stok açılıyor | OpenWrt'de `fw_setenv tp_boot_idx 1` |
| SSH "host key changed" | `ssh-keygen -R 192.168.5.1` |
| LuCI "Sysupgrade is not supported" | `sysupgrade.bin` kullanın veya SSH'den `sysupgrade -n` |
| 2.4 GHz gelmiyor, link kararsız | Cihazı soğutun, 2–3 soğuk başlatma ile tekrar deneyin |
| Hiç açılmıyor | Bölüm 5 (reset + güç) → olmazsa Bölüm 6 (UART) |

## 8. Notlar
- LAN/WAN LED eşlemesi henüz yapılmadı; kozmetiktir, veri yolunu etkilemez.
- `wan` her zaman 2500 gösterir (SoC↔PHY sabit link); hat hızını PHY ayarlar. 100 Mbit görüyorsanız sağlayıcı tarafıdır.
- kmod paketleri yalnızca bu imajdan kurulabilir (özel kernel hash'i).
- Yardım isterken: etiketteki `Ver`, stok sürümü, hangi adımda kaldığınız, LED durumu, kullandığınız LAN portu.