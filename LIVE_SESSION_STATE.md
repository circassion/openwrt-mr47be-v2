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

## 2. ETHERNET MİMARİSİ — KESİN (GPL mi01.6 DTS + bootlog)

Bootlog'un anahtar kanıtı: **`eth0 PHY0 QCA8084-switch`** — Ethernet çözümü **QCA8084
switch'tir** (eksik olduğu düşünülen QCA8386'nın YERİNE UART bunu söylüyor). Topoloji:
**LAN PORT1..3 + WAN PHY1** (4× 2.5G). GPL vendor DTS'i (`kernel-ipq5332-mi01.6.dts`)
doğruluyor: `dp1` (`qcom,id=2`, `is_switch_connected=1`) + `dp2` (`qcom,id=1`), mdio phy0..3.

> **HIZ DEĞERLERİ HAKKINDA (100/10):** Bootlog'daki `Speed :100`/`:10` değerleri
> MR47'nin port kapasitesi DEĞİL — log, cihaz TP-Link 740N (100 Mbps) üzerinden
> internete bağlıyken alındığı için O ANKİ müzakere edilen (auto-neg) link hızıdır.
> 4 port da **2.5G kapasiteli** (EEC DQ48201N0-S ×2). 2.5G doğrulamak için 2.5G/5G
> NIC bağlanıp `Link: 2500 Mbps` okunmalı. Tek kesin donanım gerçeği: **`QCA8084-switch`**.

> **Tak-çalıştır hedef (test4):** WAN x1 + LAN x3 ayrı ayrı link olsun.
> Mainline'da QCA8084'ün *switch* olarak DSA sürücüsü yok (QCA8386 gibi) — ilk adım
> UART + Wi-Fi (ath12k) + 4× PHY link up; switch/vlan ayrı DSA driver işi.

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

## 6. TEST DURUMU (2026-08-28)

- ❌ **test4 imajı ÜRETİLMEDİ.** Mevcut imajlar yalnızca test1/2/3 — sırasıyla QCA8386 varsayımı
  içeriyor ve bu donanıma **uygun değil**.
- test3 hâlâ RAM-boot ile **donanımda hiç test edilmedi** (boot log stok firmware'e ait).
- İmajlar (eski/test3, referans saklamak için duruyor): `imajlar/test3/`.

---

## 7. TEST4 — PLAN (sonraki adım)

Donanımın kesin haline göre **yeni temiz DTS** (`dts/ipq5332-mercusys-mr47be-v2.dts` revize):
- QCA8386 referanslarını kaldır → **QCA8084** (mdio phy0..3 + dp1/dp2) yapısına göre.
- `secure-boot off` olduğundan RAM boot (TFTP) güvenli; NAND'a YAZMA (önce smeminfo doğrulama).
- Hedef ilk boot: UART shell + Wi-Fi (ath12k) + Ethernet link; sonra switch/vlan.

Build ortamı (WSL, Ubuntu-24.04) şu an **Stopped**. İmaj üretmek için WSL başlatılıp
`openwrt` ağacında `qualcommbe/ipq53xx` target build edilmeli (saatler sürer, kullanıcı ile netleştirilir).

---

## 8. KARARLAR / NOTLAR
- SoC IPQ5322 (foto) — forumdaki IPQ5332 varsayımı aksi ispatlanana kadar doğrulanmamış.
- QCA8386 yok; eski test1/2/3 dokümanlarındaki o varsayım geçersiz.
- Secure Boot OFF → firmware dosyasına gömme gerekmeden U-Boot üzerinden imzasız imaj boot edilir.
