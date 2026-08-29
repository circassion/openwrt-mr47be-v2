# MERCUSYS MR47BE V2 (BE9300) — Donanım Analizi ve Test4 Durum Raporu (v2 — DÜZELTİLMİŞ)

**Revizyon:** v2.0 — 2026-08-29 · **Önceki sürüm:** `MR47BE_V2_Hardware_Analysis_{EN,TR,RU}.pdf` (2026-08-27)
**Ünite:** MR47BE(EU) Ver:2.0 · Seri No **2CF60F2000345**
**Kanıt:** 39 makro fotoğraf + kullanıcının elle işaretlediği düzeltmeler (aynı fotoğraf seti üzerinde) +
gerçek UART PBL/SBL/U-Boot boot log + vendor GPL kaynağı (`ipq_qca8084.c`, `kernel-ipq5332-mi01.6.dts`,
`nand-partition.xml`, `basic.config`) + **test4 temiz build sonucu (2026-08-28, Round 3 — BAŞARILI)**.

---

## 0. Bu revizyonda ne değişti — DEĞİŞİKLİK GÜNLÜĞÜ

27 Ağustos raporu üzerinde kullanıcı elle 3 düzeltme işaretledi; bu düzeltmeler ve yeni test4 verileri
bu revizyonda işlenmiştir:

| # | Önceki rapor (v1, 27 Ağustos) | Düzeltme / yeni bilgi | Kaynak |
|---|---|---|---|
| 1 | Anten sayısı **6** (`21/J22/J51/J52/J61/J62) | **6 anten**, tam liste: `J21/J22/J51/J52/J61/J62`. Kablo renk kodlaması: 2,4GHz = gri ×2, 6GHz = turuncu ×2, 5GHz = siyah ×2 | Kullanıcının elle işaretlediği Şekil 6 + orijinal etiket fotoğrafı |
| 2 | `8770N 591305` **×2** adet görülmüş | **×2** adet — - | ** |
| 3 | `8270HT 006589` analizde **hiç geçmiyordu** | **Yeni bileşen eklendi: `8270HT 006589 FH2447` ×2 adet.** J21/J22 anten yolunda konumlanıyor (2,4GHz beslemesiyle aynı hat) | Kullanıcı notu: *"8270HT 006589 FH2447 x2 adet daha var bahsedilmemiş analizde!!! j21 ve j22 olarak yolunda"* |
| 4 | Ethernet mimarisi **açık madde** idi (QCA8386 aranıyor, bulunamadı) | **KAPANDI:** Ethernet = **QCA8084**, ayrı bir çip değil — IPQ53xx SoC'nin içine entegre switch-PHY kompleksi (GEPHY0-3 + MAC0-5 + UniPHY0/1). GPL kaynak koduyla (`ipq_qca8084.c`) doğrulandı. QCA8386 board'da **yok**. | GPL kaynak analizi + gerçek boot log (`QCA8084-switch status:`) |
| 5 | test4 build durumu raporda yoktu | **test4 Round 3 build BAŞARILI (2026-08-28, 01:47)** — 5 imaj + sha256sums + manifest üretildi, DTB içinde QCA8084/QCN6274/rootfs_1 doğrulandı | `LIVE_SESSION_STATE.md` §6 |

Aşağıdaki tüm bölümler bu düzeltmeler işlenmiş haliyle güncellenmiştir. Önceki raporda "DOĞRULANDI" olan
hiçbir madde bu revizyonda geri alınmamıştır — yalnızca eksik/sayım hataları giderilmiş ve yeni kanıtlar
eklenmiştir.

---

## 1. Ünite kimliği — ✅ DOĞRULANDI (değişmedi)

- Fabrika etiketi: `MR47BE(EU) Ver:2.0`, barkod `2CF60F2000345`, modül kodu `3FC-4`
  (LAN transformatör braketi üzerinde fotoğraflandı).
- PCB baskı kodu `2050502553`, TOP yüzde.
- Gerçek, etiketli bir EU-bölge V2 kartı — firmware veya forum iddiasından çıkarım değil.

## 2. Yonga baskılarından malzeme listesi (BOM) — GÜNCELLENDİ

| Bileşen | Baskı (fotoğraf) | Tanımlama | Durum |
|---|---|---|---|
| Ana SoC | `Qualcomm IPQ5322 003 FK5134HJ` | Qualcomm **IPQ5322** — "Immersive Home 326" (Miami ailesi). 4× Cortex-A53 @1.5GHz + 1× NPU@1.5GHz, 6-stream, MRQFN251 gövde | ✅ DOĞRULANDI — 5 ayrı net fotoğraf |
| 6GHz radyo | `Qualcomm QCN6274 001 JE510CV2` | Qualcomm **QCN6274**, 2×2 6GHz 802.11be yardımcı radyo | ✅ DOĞRULANDI |
| NAND flash | `winbond 25N01GWZE1G 2520 M51708600` | Winbond **W25N01GWZEIG**, 1Gbit (128MB) SPI NAND, WSON-8 | ✅ DOĞRULANDI — boot log ile birebir |
| DRAM | `SEC 343 K4A8G165WC BCTD 62F89501C` | Samsung **K4A8G165WC-BCTD**, 8Gb (1GB) DDR4, ×16, 3200Mbps | ✅ DOĞRULANDI — boot log ile birebir ("1 GiB") |
| LAN manyetikleri (×2, 4×2.5GbE) | `EEC DQ48201N0-S 2520-A` | Entegre RJ45 transformatör/manyetik modülleri | ✅ DOĞRULANDI |
| RF ön-uç yongaları | `8570N 574909` **×2**, `8770N 591305` **×2** *(düzeltildi: önceki raporda ×1 yazılmıştı)*, `8270HT 006589 FH2447` **×2** *(YENİ — önceki raporda hiç yoktu)* | RF kalkanına bitişik küçük QFN parçalar; PA/FEM/anahtar aile üyeleri olması muhtemel. `8270HT` çifti J21/J22 (2,4GHz) yolunda konumlanıyor | 🟡 AÇIK — üretici/parça numarası kamuya açık kaynaklarla eşleşmedi, ancak sayım ve konum artık tam |
| Ön-uç modülü | `FE51427S` | Ana SoC yanında RF kalkanı altında; muhtemel PA/ön-uç modülü | 🟡 AÇIK |
| UART header | 4-pin, silkscreen `J1` | Ana SoC kalkanı yanında lehimlenmemiş 4-pin header — bu raporun tüm boot logları bu header'dan alındı | ✅ DOĞRULANDI |
| Anten beslemeleri | **6× U.FL/IPEX click-on**, `J21/J22/J51/J52/J61/J62` | Tamamı click-on (V1'deki lehimli pigtail + click-on karışımından farklı) | ✅ DOĞRULANDI |
| Ethernet | **QCA8084** switch-PHY (ayrı çip DEĞİL) | IPQ53xx SoC içine entegre GEPHY0-3 + MAC0-5 + UniPHY0/1 kompleksi | ✅ DOĞRULANDI — bkz. §5 |
| QCA8386 switch IC | — | **Board'da fiziksel olarak yok** | ❌ ÇÜRÜTÜLDÜ |

## 3. UART boot log çapraz doğrulaması — ✅ DOĞRULANDI

| Boot-log kanıtı | Fotoğraflanan bileşen | Sonuç |
|---|---|---|
| `Serial NAND device Manufacturer:W25N01GWZEIG ... Device Size:128 MiB` | Winbond W25N01GWZEIG | ✅ BİREBİR EŞLEŞME |
| `DRAM: ... 1 GiB` | Samsung K4A8G165WC-BCTD (8Gb=1GB) | ✅ BİREBİR EŞLEŞME |
| `JTAG ID @ 0x000a607c = 0x1023d0e1` | Ana SoC gövdesi | Üretici alanı 0x070 = Qualcomm JEP106 kodu → gerçek Qualcomm silikonu doğrulanır (bkz. §4) |
| `eth0 PHY0 QCA8084-switch status:` | — (ayrı çip yok, SoC içi) | ✅ GPL kaynağıyla birebir eşleşme (bkz. §5) |

## 4. SoC kimliği: IPQ5322 (fiziksel) vs "IPQ5332" (boot string) — ✅ ÇÖZÜLDÜ (bu ünite için)

Boot log `IMAGE_VARIANT_STRING=IPQ5332LA` yazdırıyor; topluluk bunu SoC'nin IPQ5332 olduğu şeklinde
yorumlamıştı. Ancak beş ayrı net makro fotoğraf, ana SoC üzerinde açıkça **`Qualcomm IPQ5322 003
FK5134HJ`** baskısını gösteriyor.

IPQ5322 ve IPQ5332 aynı "Miami"/Immersive Home Wi-Fi 7 ailesinde, aynı MRQFN251 gövdede, gerçek ve
farklı iki SKU'dur:

| Yonga | Platform | CPU | Stream | Sınıf |
|---|---|---|---|---|
| IPQ5332 | Immersive Home 3210 | 4× A53@1.5GHz + NPU | 10-stream | ~20.7 Gbps |
| **IPQ5322 (bu ünite)** | Immersive Home 326 | 4× A53@1.5GHz + NPU | 6-stream | ~10.6 Gbps |

`IMAGE_VARIANT_STRING`, canlı bir donanım okuması değil, derleme zamanında BSP tarafından gömülen bir
string'dir — aynı BSP hedefi aynı aileden birden fazla SKU'ya hizmet edebilir. **Bu ünite için sonuç:**
fotoğraf kanıtı yazılım string'inin önüne geçer → SoC = **IPQ5322**.

**Hâlâ açık:** tüm V2 partilerinin IPQ5322 mi yoksa bazı partilerin çift-kaynaklı IPQ5332 mi olduğu —
kesin çözüm, çekirdek (kernel) tarafında `socinfo` okumasıdır:
```sh
cat /proc/device-tree/compatible
dmesg | grep -iE "ipq53|socinfo|soc:"
cat /sys/devices/soc0/*
```

## 5. Ethernet mimarisi — ✅ KAPANDI: QCA8084 (SoC-içi), QCA8386 YOK

Önceki rapordaki en büyük açık madde buydu; test4 hazırlığı sırasında vendor GPL kaynağı incelenerek
kesin olarak kapatıldı.

**Sonuç:** Ethernet = **QCA8084**, 4×2.5G (LAN PORT1-3 + WAN PHY1) — ve bu **ayrı bir çip değildir**:
IPQ53xx SoC'nin içine entegre bir switch-PHY kompleksidir (GEPHY0-3 + MAC0-5 + UniPHY0/1). Bu yüzden
hiçbir PCB fotoğrafında ayrı bir Ethernet/switch çipi görünmüyor — board'da yalnızca 2× `EEC
DQ48201N0-S` LAN manyetik modülü var, başka hiçbir şey yok. Görünmemesinin sebebi kayıp değil, entegre
olması.

**GPL kanıtları** (vendor U-Boot 2016.01 — bootlog'daki sürümle aynı):
- `u-boot-2016/drivers/net/ipq_common/ipq_qca8084.c:1472` → `printf("QCA8084-switch status:\n");`
  (boot log'daki satırın birebir kaynağı); `:1485` → `PORT%d %s Speed :%d %s duplex` (PORT satırlarının
  kaynağı)
- `ipq_qca8084.c:1513-1564` → `ipq_qca8084_hw_init()`, DTS düğümü `/ess-switch/qca8084_swt_info`
  (`switch_mac_mode0/1`, `switch_lan_bmp`, `switch_cpu_bmp`) okuyor; `CONFIG_QCA8084_SWT_MODE`
- `ipq_qca8084_clk.h:164` → `QCA8084_CLK_BASE_REG 0x0c800000`; tüm register/saat erişimi SoC'nin
  **dahili MDIO** yolundan (`ipq_mii_read/write`) geçiyor — ayrık bir çip bu şekilde sürülemezdi
- `kernel-ipq5332-mi01.6.dts` → SoC-içi `ess-switch@3a000000` (`forced-speed 2500`); EVB'nin opsiyonel
  HARİCİ `ess-switch1` (`qcom,ess-switch-qca8386`) düğümü bu board'da **yok**

**Hız değerleri:** Boot log'daki `Speed :100`/`:10` port kapasitesi değil — cihaz TP-Link 740N (100 Mbps)
üzerinden bağlıyken o anki auto-neg link hızı. Portlar `ADVERTISE_2500FULL` ile 2.5G kapasiteli;
doğrulamak için 2.5G/5G NIC ile `Link: 2500 Mbps` beklenmeli.

**Kablolama (bootlog + vendor DTS):** `dp1` (`qcom,id=2`) ↔ LAN PORT1-3; `dp2` (`qcom,id=1`) ↔ WAN PHY1.

**test4 hedefi:** Mainline'da QCA8084 için DSA sürücüsü yok; ilk hedef UART + Wi-Fi (ath12k) + 4× PHY
link-up. LAN switch/VLAN fonksiyonu ayrı bir DSA sürücü işi.

## 6. Wi-Fi — ✅ DOĞRULANDI

- On-SoC 2.4/5 GHz → `wifi0`, ath12k (Q6), GPL `board_id=0x16` (18)
- PCIe 6 GHz → **QCN6274** → `wifi2`/pcie1, GPL `board_id=0x1015`
- Firmware: `ath12k-firmware-ipq5332` (q6) + `ath12k-firmware-qcn9274` + `ipq-wifi-mercusys_mr47be-v2`

## 7. RF / anten sistemi — ✅ DÜZELTİLDİ: 6 anten (5 değil)

Altı harici anten, kasa kenarındaki küçük bir alt kart üzerinden **6× click-on U.FL** konnektörle karta
bağlanıyor (lehimli pigtail yok — V1'den farklı). Konnektör/bant eşleşmesi (kullanıcının elle işaretlediği
foto notlarından):

| Bant | Anten sayısı | Konnektör | Kablo rengi |
|---|---|---|---|
| 2,4 GHz | 2 | J21 / J22 | Gri |
| 6 GHz | 2 | J61 / J62 | Turuncu |
| 5 GHz | 2 | J51 / J52 | Siyah |

Radyo dağılımı: IPQ5322 SoC 2,4GHz radyo + iPA'yı entegre barındırıyor; 6GHz ayrı QCN6274 yardımcı
çipi tarafından yönetiliyor; 5GHz de SoC üzerinde entegre (IPQ53xx ailesi standardı). §2'deki küçük RF
ön-uç yongaları (`FE51427S`, `8570N`×2, `8770N`×2, `8270HT`×2) bu radyoların sinyal yolunda; `8270HT`
çifti spesifik olarak J21/J22 (2,4GHz) hattında konumlanıyor.

## 8. Isıl yönetim — ✅ DOĞRULANDI (değişmedi)

BOTTOM yüzde V1 ile aynı tasarım dili: ana SoC üzerinde büyük pembe silikon termal ped (gap-filler) +
ikincil sıcak noktalarda iki metal ısı yayıcı plaka, hepsi kasa üst kapağına temas ediyor. Fan/heatpipe
yok — pasif, kasa-ısı-emici tasarım.

## 9. Flash / Partition tablosu — ✅ DOĞRULANDI (`nand-partition.xml`)

Toplam 128 MiB, A/B düzeni:
`sbl1 768K · mibib 512K · bootconfig(+1) 256K×2 · qsee 1.75M · devcfg 256K · tme 256K · cdt 256K ·
appsblenv 256K · appsbl 768K · art 1M @0x900000 · secure-binary 256K · rootfs 54M · rootfs_1 54M ·
tp_data 10M · data 256K · reserverd_data 256K`

ART (1MiB, Wi-Fi kalibrasyon + MAC) salt-okunur korunmalı. GPL `basic.config`: `BOARD_TYPE=AP-MI01.6_512M16_DDR4`,
`ARCH_TYPE=64`, `CONFIG_TP_MODEL_BE550V2` (TP-Link rebrand).

## 10. U-Boot / Güvenlik — ✅ DOĞRULANDI

- Prompt `IPQ5332#`, 115200 baud, `bootipq`; FIT SIGNATURE/SHA/RSA **kapalı** → imzasız boot mümkün
- `Secure Boot: Off` → imzasız OpenWrt RAM-boot **mümkün**
- Boot adresi `0x46000000` (`0x44000000` çakışır — kullanılmamalı)
- Vendor spi-nor `n25q128a11` referansı gerçek board'da yok (NAND-only, `SF: Unsupported`)

## 11. test4 — Temiz build sonucu (2026-08-28, Round 3 — ✅ BAŞARILI)

Bu, önceki rapordan sonra elde edilen en önemli yeni gelişme: **test4 imajı başarıyla derlendi.**

**Build geçmişi:**
- ❌ Round 1 (22:53): `missing-macros/bin/*` eksikti → crash
- ❌ Round 2 (23:12): 0-byte log (nohup sonrası oturum anında kapandı) → setsid ile çözüldü
- ❌ Round 3 ilk deneme (01:04): son adımda `target/linux/install` → `cc1: fatal error:
  ../dts/ipq5332-mr47be-v2.dts: No such file or directory`
- ✅ **Round 3 düzeltme + relaunch (01:47) — BUILD OK**

**Kök nedenler ve dersler:**
1. **rsync `--exclude=bin` (anchor'sız)** ağaçtaki TÜM `bin/` klasörlerini sildi (tools/missing-macros/src/bin
   dahil). **Çözüm:** anchored `--exclude=/build_dir /staging_dir /tmp /.ccache /bin /logs` + parite testi
   (kaynak dosya sayısı = hedef dosya sayısı, `bin/m4/README` kontrolü FATAL guard olarak script'e eklendi).
2. **`nohup make &` sonrası oturum anında kapanırsa** make ilk çıktıyı yazamadan ölüyor (0-byte log).
   **Çözüm:** `setsid nohup make ... &` + aynı komutta `sleep 12` ile canlı doğrulama.
3. **WSL arka-plan watcher daemon'ları** oturum kapanışında ölüyor, make canlı kalıyor. Güvenilir izleme
   yöntemi: dışarıdan periyodik probe + log kopyala-analiz (`/root/autoprobe.sh`, 5 dakikada bir).
4. **DTS isimlendirme çakışması:** `setup_clean.sh`, DTS dosyasını `ipq5332-mercusys-mr47be-v2.dts` olarak
   kopyalıyor ama ardından `rm -f .../ipq5332-mr47be-v2.dts` ile build'in gerçekte aradığı ismi siliyordu
   (`DEVICE_DTS` türetmesi `mercusys_mr47be-v2` → `ipq5332-mr47be-v2` bekliyor). **Çözüm:** doğrulanmış DTS
   (md5 `90bdb804caf8de759cc33bbbc262afc`) doğru isimle yerine kondu.

**Build çıktısı (Round 3 sonucu, 01:47):**
- 5 imaj + `sha256sums` + manifest → `imajlar/test4/`
- `initramfs-uImage.itb` md5: `c71c879e6d8770459a7195f9cd58140e`
- DTB doğrulaması: `phy@1..4` + `2500base-x` + `fixed-link` + `pci17cb,1109` (QCN6274) + `0:art` +
  `rootfs_1` mevcut; **`qca8386` yok** (beklenen — §5 ile tutarlı)
- FIT `config@mi01.6` mevcut
- Manifest içeriği: `ath12k-firmware-ipq5332`, `ath12k-firmware-qcn9274`, `ipq-wifi-mercusys_mr47be-v2`,
  `kmod-ath12k`, `kmod-phy-qca83xx`

**Build hattı (tekrarlanabilirlik için):**
```sh
# 1) Kurulum (anchored rsync + final DTS + parite/bin/dts FATAL guard + defconfig + offline feeds)
bash /root/setup_clean.sh setup      # -> /root/mr47be-clean

# 2) Build (setsid ZORUNLU — bkz. ders #2)
cd /root/mr47be-clean
setsid nohup make -j4 V=s > /root/mr47be-clean-build.log 2>&1 < /dev/null &
sleep 12   # canlı doğrulama

# 3) Çıktı → TFTP boot (Secure Boot Off → imzasız OK, NAND'a yazmadan test)
# bin/targets/qualcommbe/ipq53xx/openwrt-...-mercusys_mr47be-v2-initramfs-uImage.itb
tftpboot 0x46000000 openwrt-...-initramfs-uImage.itb
bootm 0x46000000
```

**Sonraki adım (test5 hedefi):** WAN×1 + LAN×3 ayrı ayrı link-up doğrulaması; UART + Wi-Fi (ath12k) +
4× PHY link-up sonrası, LAN switch/VLAN fonksiyonu için ayrı DSA sürücü çalışması.

## 12. Özet durum matrisi

| # | Madde | Durum |
|---|---|---|
| 1 | Gerçek V2 donanımı, EU bölgesi, seri 2CF60F2000345 | ✅ DOĞRULANDI |
| 2 | NAND = Winbond W25N01GWZEIG 128MB | ✅ DOĞRULANDI |
| 3 | DRAM = Samsung K4A8G165WC-BCTD 1GB DDR4 | ✅ DOĞRULANDI |
| 4 | Ana SoC gerçek Qualcomm silikonu (JTAG mfg ID 0x70) | ✅ DOĞRULANDI |
| 5 | Bu ünitede SoC üst baskısı = IPQ5322 (IPQ5332 değil) | ✅ DOĞRULANDI (bu ünite) |
| 6 | Tüm V2 üniteleri IPQ5322 mi (çift-kaynak IPQ5332 riski) | 🟡 AÇIK — socinfo veya daha fazla foto gerekli |
| 7 | 6GHz radyo = QCN6274 | ✅ DOĞRULANDI |
| 8 | Ethernet = QCA8084 (SoC-içi entegre) | ✅ DOĞRULANDI — GPL + boot log |
| 9 | QCA8386 board'da var mı | ❌ YOK — çürütüldü |
| 10 | UART J1 çalışıyor, Secure Boot Off | ✅ DOĞRULANDI |
| 11 | Anten sayısı ve konnektörleri | ✅ DÜZELTİLDİ — 6 adet, J21/J22/J51/J52/J61/J62 |
| 12 | `8770N` adedi | ✅ DÜZELTİLDİ — ×2  |
| 13 | `8270HT 006589 FH2447` bileşeni | ✅ EKLENDİ — ×2, J21/J22 yolunda |
| 14 | Küçük RF ön-uç yongalarının tam üreticisi | 🟡 AÇIK — kamuya açık datasheet eşleşmesi yok |
| 15 | test4 temiz build | ✅ BAŞARILI — Round 3, 2026-08-28 01:47, 5 imaj üretildi |

## 13. Sonraki adımlar

1. `soc_ipq5322.jpg` (en net SoC makro fotoğrafı) birincil kanıt olarak repo'da saklanmalı.
2. RAM-boot testi sonrası şu çıktılar alınıp yayınlanmalı: `dmesg | grep -iE "ipq53|socinfo"`,
   `cat /proc/cpuinfo`, `cat /sys/devices/soc0/*` — madde #6'yı kesin kapatır.
3. Diğer MR47BE V2 sahiplerinden ana SoC üst baskısını fotoğraflamaları istenmeli — IPQ5322'nin tüm V2
   partilerinde evrensel olup olmadığını doğrulamak için.
4. test5 hedefi: WAN×1 + LAN×3 ayrı link-up + Wi-Fi (ath12k) canlı doğrulaması; ardından QCA8084 için
   LAN switch/VLAN DSA sürücüsü çalışması.

---

*Bu, görsel + GPL kaynak kodu + gerçek boot log tabanlı bir donanım denetimidir; resmi bir
Mercusys/TP-Link/Qualcomm belgesi değildir ve çalışma zamanı çekirdek tarafı SoC-ID okumasının (`socinfo`)
yerini tutmaz. Bu revizyon (v2), 27 Ağustos 2026 tarihli raporun kullanıcı tarafından elle işaretlenen
düzeltmelerini ve 28 Ağustos 2026 tarihli test4 build sonuçlarını içerir.*
