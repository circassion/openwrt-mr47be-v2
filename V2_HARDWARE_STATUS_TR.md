# MR47BE V2 — DONANIM DURUMU (FİNAL, kanıt tabanlı)

**Tarih:** 2026-08-28 · **Cihaz:** MR47BE(EU) Ver:2.0 · Seri **2CF60F2000345**
**Yöntem:** Çip üstü yazıların fotoğrafla okunması + gerçek UART PBL/SBL/U-Boot boot log'u
+ üretici GPL (`kernel-ipq5332-mi01.6.dts`, `nand-partition.xml`, `basic.config`).
Bu belge, daha önceki tüm varsayımları (IPQ5332 / QCA8386 tahminleri dahil) geçersiz kılar.

> ✅ = foto ve/veya boot log ile doğrulandı. 🟡 = açık. ❌ = çürütüldü.

---

## 1. Malzeme Listesi — DOĞRULANDI

| Bileşen | Foto kanıtı (resimler/) | Boot-log kanıtı | Durum |
|---|---|---|---|
| **Ana SoC** | `BOTTOM_Qalcomm_IPQ5322_003_FK5134HJ*.jpg` (5 foto — `IPQ5322`) | `JTAG ID=0x1023d0e1` (QCOM 0x70) | ✅ **IPQ5322** |
| **6 GHz radyo** | `BOTTOM_Qalcomm_QCN6274_001_JE510CV2*.jpg` | PCIe link açık (QCN9224/QCN6274 yolu) | ✅ QCN6274 |
| **NAND flash** | `TOP_winbond_25N01GWZE1G*.jpg` | `W25N01GWZEIG ... 128 MiB` (ID 0xef 0x21ba) | ✅ birebir |
| **DRAM** | `BOTTOM_SDRAM_SEC_343_K4A8G165WC_BCTD*.jpg` | `DRAM: ... 1 GiB` | ✅ birebir |
| **LAN transformatörü (4×2.5G)** | `BOTTOM_EEC_DQ48201N0-S_2520A_LAN Transformer*.jpg` | — | ✅ |
| **UART başlığı** | `TOP_UART_CONNECT*.jpg` (4-pin J1) | çalışan kayıt | ✅ |
| Anten beslemeleri (5× U.FL) | `TOP __.jpg` vb. | — | ✅ |

**SoC açıklaması:** Boot log'daki `IMAGE_VARIANT_STRING=IPQ5332LA` *BSP derleyici
string'idir*, donanım okuması DEĞİL. Fiziksel çip cinsi **IPQ5322** (Immersive Home 326,
6-stream) — IPQ5332 (10-stream) ile aynı Miami ailesinde farklı, gerçek bir SKU.

---

## 2. Ethernet — DOĞRULANDI: **QCA8084** (QCA8386 ❌ ÇÜRÜTÜLDÜ)

Boot log doğrudan şunu söylüyor:
```
eth0 PHY0 QCA8084-switch status:
PORT1 Up Speed :100 Full duplex     <- trafik olan port
PORT2 Down ...
PORT3 Down ...
eth0 PHY1 Down ...
```
**O hız değerleri hakkında:** `:100` / `:10` değerleri kayıt anındaki **müzakere
edilen (auto-neg) link hızıdır** — cihaz, internete bir **TP-Link 740N (100 Mbps
cihaz)** üzerinden bağlıyken okunmuştur, MR47'nin doğal port hızı DEĞİL. 4 Ethernet
portu da **2.5G kapasiteli** (LAN transformatörü `EEC DQ48201N0-S` ×2 = 4×2.5GbE);
2.5G'yi görmek için 2.5G/5G destekli bir NIC bağlanıp `Link: 2500 Mbps` okunmalı.

**Bu logdan çıkarılacak tek kesin donanım gerçeği `QCA8084-switch` ifadesidir** —
Ethernet çözümü bir **QCA8084 switch'tir** (eksik QCA8386'nın yerine UART bunu
söylüyor): **LAN PORT1..3 + WAN PHY1**.
Vendor DTS doğruluyor: `dp1` (`qcom,id=2`, `is_switch_connected`) + `dp2` (`qcom,id=1`),
mdio `phy0..3`.

> OpenWrt/mainline'ın QCA8084'ü *switch* olarak kullanan bir **DSA sürücüsü yoktur**
> (QCA8386 ile aynı durum). Gerçekçi ilk hedef: 4× PHY link + UART + Wi-Fi;
> switch/VLAN sürücü işidir.

---

## 3. Flash / Partition — DOĞRULANDI (nand-partition.xml)

Toplam 128 MiB A/B düzen: sbl1 768K · mibib 512K · bootconfig(+1) 256K×2 · qsee 1.75M ·
devcfg 256K · tme 256K · cdt 256K · appsblenv 256K · appsbl 768K · **art 1M @0x900000** ·
secure-binary 256K · **rootfs 54M** · **rootfs_1 54M** · tp_data 10M · data 256K · reserverd_data 256K.
ART, Wi-Fi kalibrasyonu + MAC tutar → salt-okunur kalmalı.

---

## 4. Güvenlik / Boot — DOĞRULANDI

- `Secure Boot: Off` → **imzasız OpenWrt RAM boot MÜMKÜN**.
- U-Boot `IPQ5332#`, 115200, FIT imza/SHA/RSA kapalı.
- Boot adresi `0x46000000` (0x44000000 çakışır → kullanma).

---

## 5. Özet

| # | Kalem | Durum |
|---|---|---|
| 1 | SoC **IPQ5322** (foto kanıtlı, bu cihaz) | ✅ |
| 2 | Ethernet **QCA8084** switch-PHY (boot log) | ✅ |
| 3 | QCA8386 var mı? | ❌ HAYIR |
| 4 | NAND W25N01GWZEIG 128M / 1 GiB DDR4 | ✅ |
| 5 | on-SoC 2.4/5 GHz + QCN6274 6 GHz (ath12k) | ✅ |
| 6 | UART J1 çalışıyor, Secure Boot Off | ✅ |

**Sonuç:** Donanım tamamen tanımlandı. test4 imajı **IPQ5322 + QCA8084**'e göre
üretilmeli — eski QCA8386/IPQ5332 varsayımlarına göre DEĞİL. Mevcut test1/2/3 imajları
bu donanıma uymuyor.
