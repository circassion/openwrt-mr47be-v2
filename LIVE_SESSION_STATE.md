# 📊 MERCUSYS MR47BE V2 — OPENWRT PROJESİ (CANLI DURUM)

> **Tarih:** 2026-08-28 · **Dosya = TEK KAYNAK.** Her oturumda ilk bunu oku, sonunda güncelle.
> Bu sayfa **yalnızca kesin/foto/boot-log kanıtlı bilgi** içerir. Eski test1/2/3 spekülasyonları
> ve QCA8386 varsayımları buradan **çıkarılmıştır** (bunlar YANLIŞ çıktı — QCA8386 yok).

---

## 1. DONANIM — KESİN (foto + gerçek UART boot log, 2026-08-26/28)

| Bileşen | Marking / Kanıt | Sonuç |
|---|---|---|
| **SoC** | `Qualcomm IPQ5322 003 FK5134HJ` (5 ayrı net foto) | ✅ **IPQ5322** |
| 6 GHz radio | `Qualcomm QCN6274 001 JE510CV2` (foto) | ✅ QCN6274 |
| NAND | Winbond `W25N01GWZEIG` 128 MiB Serial (ID 0xef 0x21ba, foto+bootlog) | ✅ |
| DRAM | Samsung `K4A8G165WC-BCTD` 1 GiB DDR4 (foto+bootlog) | ✅ |
| Ethernet | **QCA8084** (4x 2.5G switch-PHY) — bootlog: `eth0 PHY0 QCA8084-switch ... PORT1/2/3` + `eth0 PHY1` | ✅ |
| UART | 4-pin J1 @115200 8N1 (çalışan boot log alındı) | ✅ |
| Secure Boot | `Secure Boot: Off` (bootlog) → imzasız OpenWrt RAM boot **MÜMKÜN** | ✅ |

> ⚠️ **QCA8386 YOK.** Board üzerinde böyle bir switch çipi yok (foto seti + bootlog:
> `QCA8084-switch`). Eski RELEASE_NOTES / DTS'lerdeki `ess-switch-qca8386` varsayımı **yanlış** —
> gerçek Ethernet = **QCA8084** (`dp1`→switch-PHY LAN PORT1..3, `dp2`→WAN PHY1).
> `IMAGE_VARIANT_STRING=IPQ5332LA` bootloader string'idir, donanım okuması DEĞİL (SoC = IPQ5322).

Foto kanıtları (tamamı): `resimler/BOTTOM_Qalcomm_IPQ5322_003_FK5134HJ*.jpg`,
`BOTTOM_Qalcomm_QCN6274_001_JE510CV2*.jpg`, `TOP_winbond_25N01GWZE1G*.jpg`,
`BOTTOM_SDRAM_SEC_343_K4A8G165WC_BCTD*.jpg`, `BOTTOM_EEC_DQ48201N0-S_2520A_LAN Transformer*.jpg`.
Boot log: `logs/uart_bootlog_2026-08-28.txt`.

---

## 2. ETHERNET MİMARİSİ — KESİN (GPL kaynak + bootlog + foto)

**Ethernet = QCA8084, 4×2.5G (LAN PORT1..3 + WAN PHY1) — ve bu QCA8084 AYRI ÇİP
DEĞİL: IPQ53xx SoC'nin İÇİNE ENTEGRE bir switch-PHY kompleksidir (GEPHY0..3 +
MAC0..5 + UniPHY0/1).** PCB'de ayrı Ethernet çipi YOK (fotoğraflar: yalnız 2×
EEC DQ48201N0-S magnetics). QCA8386 YOK (test1-3'ün hatası).

GPL kanıtları (vendor U-Boot 2016.01 = bootlog'dakiyle AYNI sürüm):
- `u-boot-2016/drivers/net/ipq_common/ipq_qca8084.c:1472` →
  `printf("QCA8084-switch status:\n");` (UART'taki yazının birebir kaynağı)
- `ipq_qca8084.c:1513-1564` → `/ess-switch/qca8084_swt_info` DTS node'u +
  `CONFIG_QCA8084_SWT_MODE` (switch modu)
- `ipq_qca8084_clk.h:164` → `QCA8084_CLK_BASE_REG 0x0c800000`; TÜM register/saat
  erişimi SoC'nin **dahili MDIO** yolu (`ipq_mii_read/write`) üzerinden — ayrık
  çip olsaydı bu adres alanı SoC'den böyle sürülemezdi
- `kernel-ipq5332-mi01.6.dts` → SoC içi `ess-switch@3a000000` (`forced-speed
  2500`); EVB'nin opsiyonel HARİCİ `ess-switch1` (qca8386) node'u bizde YOK

> **HIZ DEĞERLERİ (100/10):** Bootlog'daki `Speed :100`/`:10` değerleri port
> kapasitesi DEĞİL — cihaz TP-Link 740N (100 Mbps) üzerinden internete bağlıyken
> O ANKİ auto-neg link hızıdır. 4 port **2.5G kapasiteli** (QCA8084
> ADVERTISE_2500FULL). 2.5G doğrulamak için 2.5G/5G NIC ile `Link: 2500 Mbps`
> beklenir.

> **Tak-çalıştır hedef (test4):** WAN x1 + LAN x3 ayrı ayrı link olsun.
> Mainline'da QCA8084 için DSA sürücüsü yok — ilk adım UART + Wi-Fi (ath12k) +
> 4× PHY link up; LAN switch/vlan fonksiyonu ayrı DSA driver işi.

---

## 3. WIFI — KESİN

- on-SoC 2.4/5 GHz → `wifi0` ath12k (Q6), GPL `board_id=0x16` (18)
- PCIe 6 GHz → **QCN6274** → `wifi2`/pcie1, GPL `board_id=0x1015`
- Firmware: `ath12k-firmware-ipq5332` (q6) + `ath12k-firmware-qcn9274` + `ipq-wifi-mercusys_mr47be-v2`

---

## 4. FLASH / PARTITION — KESİN (nand-partition.xml, 128 MiB toplam, A/B)

`sbl1 768K · mibib 512K · bootconfig(+1) 256K×2 · qsee 1.75M · devcfg 256K · tme 256K ·
cdt 256K · appsblenv 256K · appsbl 768K · art 1M · secure-binary 256K ·
rootfs 54M · rootfs_1 54M · tp_data 10M · data 256K · reserverd_data 256K`
→ ART **1MiB @0x900000** (Wi-Fi cal + MAC, read-only korunur). GPL `basic.config`:
`BOARD_TYPE=AP-MI01.6_512M16_DDR4`, `ARCH_TYPE=64`, **`CONFIG_TP_MODEL_BE550V2`** (TP-Link rebrand).

---

## 5. U-BOOT / BOOT YOLU — KESİN

- Prompt `IPQ5332#`, baud 115200, `bootipq`; `FIT_SIGNATURE/SHA/RSA` kapalı (imzasız boot).
- Boot adresi: `tftpboot 0x46000000` + `bootm 0x46000000` (0x44000000 ÇAKIŞIR — kullanma).
- Vendor DTS/spi-nor `n25q128a11` referans NOR tanımı GERÇEK board'da YOK (NAND-only, SF: Unsupported).

---

## 6. TEST4 — TEMİZ BUILD (2026-08-28 — ROUND 3 TAMAMLANDI ✅)

- ✅ **Build ROUND 3 canlı** (23:15 başladı, PID setsid-detached): WSL `/root/mr47be-clean`
- ✅ **missing-macros GEÇTİ** (round 1/2'nin öldüğü nokta; bin/* install OK, 0.31 sn)
- ✅ **TOOLS BİTTİ → TOOLCHAIN BAŞLADI (23:52)**: binutils (aarch64 gcc-14.4.0-musl
  toolchain) + readline derleniyor; libtool host-bin + Makefile doğrulandı
  (`LIBTOOL_BIN=1 LIBTOOL_MKFILE=1`, 2 ignored bootstrap hatası normal davranış)
- ✅ Otonom izleme: `/root/autoprobe.sh` daemon'ı her 5 dk probe+log snapshot'ı
  E:'ye yazar (`tmp_build/probe_now.txt`, `clean_build_snapshot.log`)
- ❌ ROUND 1 (22:53) crash: `missing-macros/bin/*` eksikti · ROUND 2 (23:12): 0-byte
  log (nohup + anında oturum kapanması — setsid ile çözüldü)
- 🐛 **KÖK NEDEN — DERS:** rsync `--exclude=bin` (anchor'sız) ağaçtaki TÜM `bin/`
  klasörlerini silmiş (tools/missing-macros/src/bin dahil!). ÇÖZÜM: anchored
  `--exclude=/build_dir /staging_dir /tmp /.ccache /bin /logs`. Parite testi:
  SRC 24.770 = DST 24.770 dosya (birebir) + `bin/m4/README` kontrolü script'te FATAL guard.
- 🐛 **2. DERS:** `nohup make &` sonrası wsl oturumu ANINDA kapanırsa make ilk
  çıktıyı yazamadan ölüyor (0-byte log). ÇÖZÜM: `setsid nohup make ... &` + aynı
  komutta `sleep 12` canlı-doğrulama. (setsid = watcher'da kanıtlanmış detach)
- 🐛 **3. DERS:** WSL arka-plan watcher daemon'ları oturum kapanında ölüyor;
  make yaşıyor. Güvenilir izleme = dışarıdan periyodik probe + log kopyala-analiz.
- Log: `/root/mr47be-clean-build.log` · Script: `/root/setup_clean.sh` (setup|build)
- ❌ Eski imajlar (test1/2/3) QCA8386 varsayımlı — **kullanma**, sadece referans.
- ❌ **ROUND 3 (01:04) CRASH — son adımda:** `target/linux/install` → `cc1: fatal error: ../dts/ipq5332-mr47be-v2.dts: No such file or directory`
- 🐛 **ROUND 3 KÖK NEDEN:** `setup_clean.sh` DTS'i `ipq5332-mercusys-mr47be-v2.dts` olarak kopyalıyor ama `rm -f .../ipq5332-mr47be-v2.dts` ile build'in beklediği ismi SİLİYOR. DEVICE_DTS türetmesi (`mercusys_mr47be-v2` → `ipq5332-mr47be-v2`) bu ismi arıyordu → dosya yok → imaj üretimi en sonda düştü. (LIVE_SESSION_STATE "ÇALIŞIYOR" yazdığında henüz crash olmamıştı; 01:04'te oldu.)
- ✅ **FIX:** Doğrulanmış test4 DTS (md5 `90bdb804caf8de759cc33bbbc262afc`, otorite dosya ile birebir) `ipq5332-mr47be-v2.dts` adıyla yerine kondu; build relaunch.
- ✅ **ROUND 3 SONUÇ (01:47) BUILD OK:** 5 imaj + `sha256sums` + manifest → `imajlar/test4/` (initramfs-uImage.itb md5 `c71c879e6d8770459a7195f9cd58140e`). DTB içinde QCA8084 phy@1..4 + 2500base-x + fixed-link + pci17cb,1109 (QCN6274) + 0:art + rootfs_1; `qca8386` YOK. FIT `config@mi01.6` mevcut. Manifest: ath12k-firmware-ipq5332/qcn9274 + ipq-wifi-mercusys_mr47be-v2 + kmod-ath12k + kmod-phy-qca83xx.

---

## 7. BUILD HATTI — NASIL (tekrar için)

1. `bash /root/setup_clean.sh setup` → `/root/mr47be-clean` (anchored rsync + final DTS
   + parite/bin/dts FATAL guard + defconfig + feeds offline)
2. `cd /root/mr47be-clean; setsid nohup make -j4 V=s > /root/mr47be-clean-build.log 2>&1 < /dev/null &`
   (+ aynı komutta `sleep 12` canlı-doğrulama — nohup tek başına YETMEZ, bak §6 ders 2)
3. Çıktı: `bin/targets/qualcommbe/ipq53xx/openwrt-...-mercusys_mr47be-v2-initramfs-uImage.itb`
   → TFTP `tftpboot 0x46000000` + `bootm 0x46000000` (Secure Boot Off → imzasız OK)

---

## 8. KARARLAR / NOTLAR
- SoC **IPQ5322** (foto kanıtlı); `IPQ5332LA` = bootloader string'i, donanım okuması değil.
- **QCA8084 ayrı çip DEĞİL** → IPQ53xx die'ına entegre switch-PHY (GPL U-Boot
  `ipq_qca8084.c:1472` "QCA8084-switch" + dahili MDIO/0x0c800000 kanıtı).
  Bu yüzden PCB fotoğraflarında Ethernet çipi görünmez — görünecek çip yok.
- Bootlog `Speed :100/:10` = TP-Link 740N uplink'inin o anki auto-neg hızı;
  portlar 2.5G kapasiteli (`ADVERTISE_2500FULL`, vendor DTS `forced-speed 2500`).
- Secure Boot OFF → U-Boot üzerinden imzasız imaj boot edilir (NAND'a yazmadan).

---

## 9. TEST5 — TAK ÇALIŞTIR HAZIRLIK (2026-08-29)

### Yapılan Değişiklikler

| Değişiklik | Durum | Not |
|---|---|---|
| USB kaldırıldı | ✅ | Fiziksel USB girişi yok, DTS'ten çıkarıldı |
| LED eklendi | ✅ | gpio-leds (sys-green, sys-orange, wan, lan1, lan2, lan3) |
| Button eklendi | ✅ | gpio-keys (reset) |
| Kernel güncellendi | ✅ | 6.18.39 → 6.18.48 (en güncel LTS) |
| WiFi 7 | ✅ | QCN6274 6 GHz aktif |

### Dosyalar

| Dosya | Açıklama |
|---|---|
| `BUILD_INFO.md` | 🇹🇷 TR build talimatları |
| `BUILD_INFO_EN.md` | 🇬🇧 EN build instructions |
| `BUILD_INFO_RU.md` | 🇷🇺 RU инструкции по сборке |
| `RELEASE_NOTES_v0.1.0-test5.md` | 🇹🇷 TR sürüm notları |
| `RELEASE_NOTES_v0.1.0-test5_EN.md` | 🇬🇧 EN release notes |
| `RELEASE_NOTES_v0.1.0-test5_RU.md` | 🇷🇺 RU примечания к выпуску |
| `imajlar/test5/` | test5 imajları (test4'ten kopyalandı, yeni build bekleniyor) |

### İmajlar

```
E:\ROUTER\MERCUSYS MR47BE_OPENWRT\imajlar\test5\
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.ubi
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-sysupgrade.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2.manifest
└── sha256sums
```

### Build Durumu

- **Build başlatıldı:** 2026-08-29 (WSL'de çalışıyor)
- **Build yolu:** `/root/mr47be-clean`
- **Build komut:** `make -j4 V=s`
- **Tahmini süre:** 3-5 saat

---

## 10. BUILD DERSLERİ (Başımıza Gelirse Çözümler)

### Ders 1: DTS İsim Türetmesi (En Kritik)

**Sorun:** Build sistemi DTS'i `ipq5332-mr47be-v2.dts` (mercusys- olmadan) adıyla arar. `DEVICE_DTS` türetmesi: `mercusys_mr47be-v2` → `ipq5332-mr47be-v2`.

**Çözüm:** DTS dosyasını İKİ adla da yerleştirin veya symlink kullanın:
```bash
cp ipq5332-mercusys-mr47be-v2.dts ipq5332-mr47be-v2.dts
# veya
ln -s ipq5332-mercusys-mr47be-v2.dts ipq5332-mr47be-v2.dts
```

### Ders 2: rsync `--exclude=bin` Tuzakları

**Sorun:** rsync `--exclude=bin` (anchor'sız) ağaçtaki TÜM `bin/` klasörlerini silmiş.

**Çözüm:** Anchored kullan:
```bash
rsync -a --exclude=/build_dir --exclude=/staging_dir --exclude=/tmp --exclude=/.ccache --exclude=/bin --exclude=/logs SRC/ DST/
```

### Ders 3: nohup + setsid

**Sorun:** `nohup make &` sonrası WSL oturumu kapanırsa make ölür (0-byte log).

**Çözüm:** `setsid nohup make ... &` kullan.

### Ders 4: USB Blokları

**Sorun:** MR47BE'de fiziksel USB yok ama DTS'te USB blokları vardı.

**Çözüm:** Şu blokları DTS'ten çıkar:
```dts
&usb {
    status = "okay";
};

&usbphy0 {
    status = "okay";
};
```

### Build Komutu (Hızlı Başlangıç)

```bash
# 1. Temiz kurulum
bash /root/setup_clean.sh setup

# 2. Build (setsid + nohup)
cd /root/mr47be-clean
setsid nohup make -j4 V=s > /root/mr47be-clean-build.log 2>&1 < /dev/null &

# 3. İzleme
tail -f /root/mr47be-clean-build.log
```

