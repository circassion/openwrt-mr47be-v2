# PRE_TEST_CHECK — Mercusys MR47BE V2 / OpenWrt imaj ön denetimi

**Denetim tarihi:** 2026-08-25
**Kapsam:** `imajlar/test1` + `imajlar/test2` karşılaştırmalı, derin teknik denetim
**Hedef:** IPQ5332 (Qualcomm), 512 MB DDR4, 128 MB SPI-NAND (2048 B sayfa, 0x20000 silme bloğu)
**Yöntem:** Tüm iddialar imaj dosyaları üzerinden programatik olarak yeniden hesaplandı; U-Boot davranışı vendor GPL kaynağından (`u-boot-2016`) satır satır doğrulandı. Hiçbir sayı elle yazılmadı.

> **TEK CÜMLELİK SONUÇ:** İmajlar yapısal olarak sağlam ve bozuk değil, **ama RELEASE_NOTES'taki boot komutu donanımda çalışmaz** — `bootm` kendi kaynağının üzerine yazar ve kart resetlenir. Adresi değiştirmeden test etmeyin.

# Memory Index !!!!! çok önemli 

- [MR47BE OpenWrt imaj denetimi](mr47be-openwrt-audit.md) — Dogrulanmis sayilar: TFTP 0x46000000, bolum tablosu uyusmazligi, PHY/Ethernet blocker'lari. Yeniden hesaplama.
- [MR47BE guvenlik kurallari](mr47be-safety-rules.md) — ART'a asla yazma, imzali stok yol kapali, sadece UART+TFTP RAM boot.
- [Once karar, sonra kanit](feedback-verdict-first.md) — Kritik bulguyu bulur bulmaz soyle; raporu sona birakma.



E:\ROUTER\MERCUSYS MR47BE_OPENWRT\imajlar\fdtlib.py
E:\ROUTER\MERCUSYS MR47BE_OPENWRT\imajlar\fitinfo.py
E:\ROUTER\MERCUSYS MR47BE_OPENWRT\imajlar\fitextract.py
E:\ROUTER\MERCUSYS MR47BE_OPENWRT\imajlar\ubiscan.py
E:\ROUTER\MERCUSYS MR47BE_OPENWRT\imajlar\PRE_TEST_CHECK.md yani okuduğun şuanki by açık rapor md..
Doğrulama bitti: raporun 70 teknik iddiasının tamamı imaj üzerinden teyit edildi. Düşen 3 kontrol benim doğrulama betiğimin hatasıydı (UBI VID header offset'i ve ters kurulmuş bir assert), raporda hata yok. Konsol yolu da temiz: stdout-path = "serial0:115200n8" → serial@78af000 (okay), yani Ethernet ölse bile UART'tan görüntü alacaksın.

1. En kritik ve en ucuz: TFTP adresi. RELEASE_NOTES'ta yazan tftpboot 0x44000000 + bootm 0x44000000 çalışmayacak. Sebep boyut değil, yerleşim: FIT kernel'i 0x41000000'e açıyor ve açılım 0x445FE808'e kadar uzanıyor, yani TFTP blob'unun üstüne biniyor. U-Boot bunu yakalıyor ve ERROR: new format image overwritten - must RESET the board verip duruyor. 0x46000000 kullan (yedek 0x45000000). 0x47000000 ve 0x48000000 da olmaz, 0x50000000 sadece DRAM 512 MiB'se. Bu bulgunun değeri şu: o hatayı görüp "imajım bozuk" diye 3 gün boşa harcamanı engelliyor. İmaj sağlam — 70 teknik iddianın hepsi doğrulandı, hash'ler, UBI, squashfs, FIT, hepsi temiz.

2. NAND'a yazmadan önce smeminfo. DTB'deki bölüm tablosu düzgün 1 MiB blok varsayıyor, gerçek tablo öyle değil. DTB'nin ubi bölgesi gerçek rootfs'in 1536 KB içinde başlıyor ve sonunu 768 KB aşıyor — yazarsan A/B iki stok slotu da bozarsın. İyi haber: gerçek ART ile yazılabilir hiçbir DTB bölümü kesişmiyor (%0), onu kapsayan iki bölüm de read-only, yani kalibrasyon ve MAC kazara güvende. Ama bu şans, tasarım değil. RAM boot sıfır risk, oraya kadar rahat gidebilirsin.

3. Dürüst büyük resim — asıl eksik bir satır DTS değil, bir sürücü. İki imajın hiçbirinde QCA8386 switch sürücüsü yok (ess-switch string sayısı sıfır). Yani PHY'leri düzeltsen bile 4 jack Linux tarafından yönetilmiyor. test2'deki compatible = "ethernet-phy-id004d.d0b0" satırı da yanlış çip (o QCA8075, sende QCA8084 = 0x004DD180) ve hard-coded olduğu için otomatik probe'u da engelliyor — o satır silinmeliydi, keşke hiç eklenmemiş olsa. Ayrıca test2 port@1'in vendor'la uyumlu fixed-link 2500 tanımını bozmuş; Ethernet açısından test1 daha iyi aday. Ama net söylüyorum: bu kartta Ethernet birkaç DTS düzeltmesiyle çalışmaz, sürücü işi. İlk testte gerçekçi beklenti Wi-Fi'nin (ath12k) ayağa kalkması ve UART'tan shell almak.

Bunun dışındaki her şey (reset darbesi 10 ms yerine 100 ms olsun, phy-mode 2500base-x olsun, mdio_clk_fixup sessizce yok sayılıyor, board-id 0x12 vs 0x16) doğru ama önce yukarıdaki üçü olmadan hiçbirinin sırası gelmiyor.

Bir tek açık nokta bıraktım: chosen/bootargs-append satırını vendor U-Boot 2016'nın işlediğini doğrulayamadım. RAM boot için önemsiz, NAND aşamasından önce promptta printenv bootargs ile bakman yeter.


---

## 1. Özet tablo

| # | Kontrol | Sonuç | Etki |
|---|---|---|---|
| A | RELEASE_NOTES boot komutu (`tftpboot 0x44000000` + `bootm`) | **BAŞARISIZ** | Boot etmez, "must RESET the board" |
| B | DTB bölüm tablosu ↔ gerçek NAND yerleşimi | **BAŞARISIZ** | NAND'a yazılırsa soft-brick |
| C | QCA8386 PHY ID'si (`ethernet-phy-id004d.d0b0`) | **BAŞARISIZ** | Yanlış çip; Ethernet çalışmaz |
| D | SoC ↔ switch bağlantı topolojisi | **BAŞARISIZ** (test2 regresyon) | LAN/WAN ölü veya ters |
| E | RELEASE_NOTES "QCA83XX_PHY test2'de eklendi" iddiası | **YANLIŞ** | Belge hatası |
| F | U-Boot'ta gzip desteği | **UYARI** | "tiny" derlemede bootm gzip açamaz |
| G | PHY reset zamanlaması (test2) | **UYARI** | Vendor 100 ms, imaj 10 ms |
| H | `mdio_clk_fixup` / `phyaddr_fixup` | **UYARI** | Kernel'de karşılığı yok, sessizce yok sayılır |
| I | ath12k board-id 0x12 ↔ vendor 0x16 | **UYARI** | BDF bulunamayabilir |
| J | MAC adresi okuma yolu (`0:art`) | **UYARI** | Yanlış bölümden okur |
| K | FIT bütünlüğü (crc32 + sha1, imza yok) | **GEÇTİ** | — |
| L | RELEASE_NOTES SHA256 değerleri (9/9) | **GEÇTİ** | — |
| M | UBI yapısı (160 PEB, tüm CRC'ler) | **GEÇTİ** | — |
| N | squashfs (v4.0, xz) ↔ kernel xz_dec | **GEÇTİ** | — |
| O | sysupgrade metadata + FWx0 trailer | **GEÇTİ** | — |
| P | Boyut uyumluluğu (UBI ↔ NAND bölümü) | **GEÇTİ** | — |
| Q | ART bölümüne yazma yolu | **GEÇTİ** (kazara korunuyor) | — |
| R | pinctrl / SPI0 GPIO16 çakışması | **GEÇTİ** (vendor'da var, OpenWrt'de yok) | — |

---

## 2. Dosya envanteri ve SHA256

### test1
| Dosya | Boyut | SHA256 |
|---|---:|---|
| `...-initramfs-uImage.itb` | 22 649 356 | `132301f4c6d1df9d078a119bedec99d1ab48982dabf6264e52ad67eb7544a824` |
| `...-uImage.itb` | 6 013 248 | `ef47dbd7c79b094a27a1fd8f49082c26f474aefbe4d3d7acd16a3f98bcc22d8c` |
| `...-squashfs-factory.bin` | 20 971 520 | `4fad8477383011dc7839126e581eb878e0d1490c6c01a4d48c5ce005505a51a3` |
| `...-squashfs-sysupgrade.bin` | 19 958 043 | `940331dd72bc58c730378819109a518fb8c2a07defc60e71c2cff0820d01435a` |
| `...v2.manifest` | 4 586 | `198ef438877062eca4e6c6f0fc8c315aef28b7df57d7f7546963c257806ee451` |
| `...v2.zip` | 68 439 315 | `310f6e7cfda46833f447c2077257f9542c27b75ad3c460950144a6e15e847bda` |

### test2
| Dosya | Boyut | SHA256 |
|---|---:|---|
| `...-initramfs-uImage.itb` | 22 649 376 | `ba20a98d5f8859988e5f385a3381e83ce07e449cb2075be9a93ae72ec7380d38` |
| `...-uImage.itb` | 6 013 516 | `7f840cc2246c5833b184b9d08b220359b84ad066f0e4e1f604f0b167915725a8` |
| `...-squashfs-factory.bin` | 20 971 520 | `e74b47f1bcee70ac0fc43bb77ef2a66665335a2b128b6b0c66fd10ce44669e3b` |
| `...-squashfs-sysupgrade.bin` | 19 958 043 | `051b5cb3d18fdd9f03f9338222fdec96f57dbe0ab76f378865836b195d9ad547` |
| `...v2.rar` | 68 527 523 | `2390f2ac72d9c303b0790e051d0cddab2b5f0e20453b4f9b8faf3ee2ce00ef1b` |

**GEÇTİ (L):** `RELEASE_NOTES_v0.1.0-test1.md` içindeki 5 SHA256 ve `RELEASE_NOTES_v0.1.0-test2.md` içindeki 4 SHA256 — **toplam 9/9 değerin tamamı gerçek dosyalarla birebir uyuşuyor.** Dosyalar bozulmamış, karışmamış.

> Not: `test2/...v2.rar` bu ortamda açılamadı (`unrar`/`7z` yok). İçeriği denetlenmedi; ama `.itb`/`.bin` dosyaları zaten ayrı ayrı denetlendi.
> Not: `test1/` klasöründe hem test1 hem test2 RELEASE_NOTES var (test2 kopyası test2/ ile birebir aynı, sha `78f9ba65...`).

---

## 3. BULGU A — BLOCKER: Belgedeki boot komutu çalışmaz

### İddia (RELEASE_NOTES_v0.1.0-test2.md, her iki kopyada da)
```
→ tftpboot 0x44000000 openwrt-...-initramfs-uImage.itb
→ bootm 0x44000000
```

### Gerçek aritmetik (her iki imaj setinde de aynı)

| Değer | initramfs FIT |
|---|---|
| Dosya boyutu | 22 649 376 B (21.60 MiB) — FDT `totalsize` ile birebir eşit |
| `load` = `entry` | `0x41000000` |
| Sıkıştırma | gzip; gzip ISIZE **56 616 968** = gerçek açılan boyut (doğrulandı) |
| ARM64 `Image` magic (offset 56) | `ARMd` ✔ |
| `image_size` (offset 0x10, BSS dahil) | 57 016 320 B (54.38 MiB) |
| Açılma aralığı | `0x41000000 .. 0x445FE808` |
| Çalışma sonu (BSS ile) | `0x44660000` |
| `CONFIG_SYS_BOOTM_LEN` kontrolü | 56 616 968 ≤ 67 108 864 → **geçer**, 10.01 MiB boşluk |

`tftpboot 0x44000000` ile FIT bloğu RAM'de `[0x44000000, 0x45599A20)` aralığında durur.

U-Boot `common/bootm.c:452` kontrolü:
```c
no_overlap = (os.comp == IH_COMP_NONE && load == image_start);
if (!no_overlap && (load < blob_end) && (*load_end > blob_start)) {
    ...
    puts("ERROR: new format image overwritten - must RESET the board to recover\n");
    return BOOTM_ERR_RESET;
}
```
- `load` (0x41000000) `<` `blob_end` (0x45599A20) → **doğru**
- `load_end` (0x445FE808) `>` `blob_start` (0x44000000) → **doğru**

→ **Çakışma = 6 285 320 bayt (5.99 MiB).** BSS dahil edilirse 6 684 672 bayt (6.38 MiB).

**Sonuç:** Kernel açılırken kendi sıkıştırılmış kaynağının üzerine yazar. U-Boot bunu tespit edip `BOOTM_ERR_RESET` döndürür. Boot etmez.

Sorun **boyut değil, yerleşim.** `BOOTM_LEN` rahatça yetiyor.

### Doğru adres seçimi

Vendor `net/tftp.c` iki ayrı kapı koyuyor (`ipq5332.h`'den: `IPQ_TFTP_MIN_ADDR=0x41000000`, `CONFIG_IPQ_FDT_HIGH=0x48500000`, `CONFIG_TZ_END_ADDR=0x4AA00000`, `CONFIG_SYS_SDRAM_END = 0x40000000 + gd->ram_size`):

```c
/* net/tftp.c:840-843 — adres kapısı */
if ((load_addr < IPQ_TFTP_MIN_ADDR) ||
    (load_addr >= CONFIG_SYS_SDRAM_END) ||
    ((load_addr >= CONFIG_IPQ_FDT_HIGH) && (load_addr < CONFIG_TZ_END_ADDR)))
        puts("\nError specified load address not allowed\n");

/* net/tftp.c:201-203 — BİTİŞ kapısı (asıl tuzak) */
if (((load_addr + newsize) >= CONFIG_SYS_SDRAM_END) ||
    (((load_addr + newsize) >= CONFIG_IPQ_FDT_HIGH) &&
     ((load_addr + newsize) < CONFIG_TZ_END_ADDR)))
        puts("\nError file size too large\n");
```

Yani `[0x48500000, 0x4AA00000)` penceresine **ne başlangıç ne de bitiş** girebilir.

Her aday adres, hem `bootm` çakışması hem de her iki TFTP kapısı için test edildi:

| Adres | initramfs.itb (21.60 MiB) | uImage.itb (5.73 MiB) |
|---|---|---|
| `0x44000000` | ❌ bootm çakışması 6 285 320 B | ✅ geçer |
| **`0x45000000`** | ✅ **GEÇER** | ✅ geçer |
| **`0x46000000`** | ✅ **GEÇER** | ✅ geçer |
| `0x47000000` | ❌ bitiş yasak pencerede | ✅ geçer |
| `0x48000000` | ❌ bitiş yasak pencerede | ❌ bitiş yasak pencerede |
| **`0x4AA00000`** | ✅ **GEÇER** | ✅ geçer |
| `0x50000000` | ⚠️ sadece RAM 512 MiB ise geçer | ⚠️ aynı |
| `0x58000000` | ⚠️ sadece RAM 512 MiB ise geçer | ⚠️ aynı |

> `CONFIG_SYS_SDRAM_END` derleme sabiti değil — çalışma anında `gd->ram_size`'dan türetiliyor (`ipq5332.h:147`). Operatör `>=` olduğu için, SMEM 256 MiB raporlarsa `0x50000000` tam sınırda **reddedilir**. Bu yüzden `0x50000000` önerilmiyor.

**ÖNERİ: `0x46000000`.** 256 MiB ve 512 MiB senaryolarının ikisinde de, her iki imaj tipi için geçerli. Yedek: `0x45000000`.

---

## 4. BULGU B — BLOCKER: DTB bölüm tablosu gerçek NAND ile uyuşmuyor

Gerçek yerleşim, vendor `nand-partition.xml`'den `alloc = size_kb + pad_kb` kuralıyla kümülatif türetildi. İki bağımsız çapa doğruladı:
- `secure-binary` başlangıcı = `0xB00000` = U-Boot `CONFIG_NAND_SEC_BIN_ADDR` ✔
- Toplam = `0x8000000` = tam 128.00 MiB ✔

| Bölüm | Gerçek başl. | Gerçek uzunluk | Gerçek bitiş |
|---|---|---|---|
| 0:SBL1 | 0x000000 | 0x180000 | 0x180000 |
| 0:MIBIB | 0x180000 | 0x100000 | 0x280000 |
| 0:BOOTCONFIG | 0x280000 | 0x080000 | 0x300000 |
| 0:BOOTCONFIG1 | 0x300000 | 0x080000 | 0x380000 |
| 0:QSEE | 0x380000 | 0x240000 | 0x5C0000 |
| 0:DEVCFG | 0x5C0000 | 0x080000 | 0x640000 |
| 0:TME | 0x640000 | 0x080000 | 0x6C0000 |
| 0:CDT | 0x6C0000 | 0x080000 | 0x740000 |
| 0:APPSBLENV | 0x740000 | 0x080000 | 0x7C0000 |
| 0:APPSBL | 0x7C0000 | 0x140000 | 0x900000 |
| **0:ART** | **0x900000** | **0x200000** | **0xB00000** |
| secure-binary | 0xB00000 | 0x080000 | 0xB80000 |
| **rootfs** | **0xB80000** | 0x34C0000 | 0x4040000 |
| rootfs_1 | 0x4040000 | 0x34C0000 | 0x7500000 |
| tp_data | 0x7500000 | 0x0A00000 | 0x7F00000 |
| data | 0x7F00000 | 0x080000 | 0x7F80000 |
| reserverd_data | 0x7F80000 | 0x080000 | 0x8000000 |

İmajın DTB'sindeki `fixed-partitions` ise 1 MiB'lik düzgün bloklar varsayıyor — **hepsi kaymış**:

| DTB bölümü | DTB aralığı | ro? | Fiziksel olarak neyin üzerinde |
|---|---|---|---|
| 0:sbl1 | 0x000000–0x100000 | ro | 0:SBL1 (1024 KB) |
| 0:mibib | 0x100000–0x200000 | ro | 0:SBL1 512 KB + 0:MIBIB 512 KB |
| 0:qsee | 0x400000–0x600000 | ro | 0:QSEE 1792 KB + 0:DEVCFG 256 KB |
| 0:tme | 0x700000–0x800000 | ro | 0:CDT 256 KB + **0:APPSBLENV 512 KB** + 0:APPSBL 256 KB |
| 0:cdt | 0x800000–0x900000 | ro | 0:APPSBL (1024 KB) |
| **0:appsblenv** | 0x900000–0xA00000 | ro | **0:ART'ın ilk 1024 KB'ı** |
| **0:appsbl** | 0xA00000–0xB00000 | ro | **0:ART'ın son 1024 KB'ı** |
| **0:art** | 0xB00000–0xD00000 | ro | secure-binary 512 KB + **rootfs'in ilk 1536 KB'ı** |
| **ubi** | 0xD00000–0x4100000 | **YAZILABİLİR** | rootfs 52480 KB + **rootfs_1'in ilk 768 KB'ı** |

### Sonuçları

1. **Gerçek ART kazara korunuyor (BULGU Q — GEÇTİ).** Fiziksel ART'ı (0x900000–0xB00000) kapsayan iki DTB bölümü (`0:appsblenv`, `0:appsbl`) **ikisi de `read-only`.** Yazılabilir tek DTB bölümü `ubi` ve o ART'a hiç değmiyor. Ayrıca `uboot-envtools` yapılandırma dizini boş ve `/etc/fw_env.config` boş — yani ART'a yazacak hiçbir yol yok. Bu iyi haber ama **tesadüf**, tasarım değil.

2. **MAC adresi yanlış yerden okunacak (BULGU J — UYARI).** `/etc/board.d/02_network`:
   ```sh
   mercusys,mr47be-v2)
       wan_mac=$(mtd_get_mac_binary "0:art" 0x0)
   ```
   DTB'deki `0:art`, fiziksel olarak `secure-binary`'yi işaret ediyor. Yani WAN/LAN MAC etiketteki MAC olmayacak (ya da hiç olmayacak).
   **Bu, RAM boot sırasında sıfır riskle gözlemlenebilir tek doğrudan belirti.** `ip link` ile MAC'e bakın; etiketle uyuşmuyorsa bölüm tablosu teyit edilmiş olur.

3. **NAND'a yazılırsa ne olur:** `ubi` bölümü fiziksel `rootfs`'in 1.5 MiB içinden başlayıp `rootfs_1`'e 768 KB girer. Yani **hem A hem B stok slotu kısmen bozulur**, stok U-Boot 0xB80000'de geçerli UBI bulamaz → soft-brick. Kurtarma yalnızca UART + TFTP ile mümkün.

### Doğrulama (donanımda, sıfır risk)
`IPQ5332#` promptunda:
```
smeminfo
mtdparts
nand info
nand bad
```
`smeminfo` argümansız çalışır ve SMEM/MIBIB'den gerçek tabloyu basar — **bu tablo yukarıdaki "Gerçek" sütunuyla karşılaştırılmalı.** Uyuşmazsa DTS düzeltilmeden NAND'a hiçbir şey yazılmamalı.

---

## 5. BULGU C — BLOCKER: PHY ID yanlış çipi gösteriyor

test2, dört PHY'ye şunu ekliyor:
```dts
ethernet-phy@1 { reg = <0x1>; compatible = "ethernet-phy-id004d.d0b0"; };
ethernet-phy@2 { reg = <0x2>; compatible = "ethernet-phy-id004d.d0b0"; };
ethernet-phy@3 { reg = <0x3>; compatible = "ethernet-phy-id004d.d0b0"; };
ethernet-phy@4 { reg = <0x4>; compatible = "ethernet-phy-id004d.d0b0"; };
```

Vendor `u-boot-2016/drivers/net/ipq_common/ipq_phy.h`:
```c
47: #define QCA8075_PHY_V1_0_5P    0x004DD0B0   /* <- imajdaki ID budur */
54: #define QCA8084_PHY            0x004DD180   /* <- olması gereken */
```

`0x004DD0B0`, tüm GPL ağacında **yalnızca iki yerde** geçiyor ve ikisi de QCA8075 ("Malibu", 5 portlu ayrı PHY çipi). QCA8386/QCA8084 ile hiçbir ilgisi yok.

Kernel binary'sinde u32 taraması: `0x004dd0b0` için **0 eşleşme** (LE ve BE); buna karşılık `0x004dd033/034/036/074/0c0/101/180` her biri tam 2 LE eşleşme veriyor ve sürücü isim stringleri arasında `Qualcomm QCA8084` var.

**Yani:** hard-coded `compatible` donanım ID probe'unu **atlatıyor**, ID hiçbir sürücüyle eşleşmiyor, dördü de Generic PHY'ye düşüyor. `compatible` olmasaydı otomatik probe QCA8084 sürücüsünü bulacaktı.

Vendor DTS'i zaten `compatible` kullanmıyor:
```dts
phy0: ethernet-phy@0 { reg = <1>; fixup; };
```

### Düzeltme (iki seçenek)
- **Basit:** `compatible` satırlarını tamamen kaldır → otomatik probe QCA8084 sürücüsünü bulur.
- **Açık:** `compatible = "ethernet-phy-id004d.d180";`

### Önce donanımdan oku (sıfır risk)
U-Boot promptunda PHYIDR1/PHYIDR2 (MII reg 2 ve 3):
```
mii read 1 2
mii read 1 3
mii read 2 2
mii read 2 3
```
Birleştirilmiş `(reg2 << 16) | reg3` değerini `0x004DD180` ile karşılaştırın. `mii` komutu bu U-Boot'ta derlenmiş durumda (ancak "tiny" derlemede `CONFIG_CMD_MII` kapalı — bkz. Bulgu F).

---

## 6. BULGU D — BLOCKER: SoC ↔ switch topolojisi yanlış, test2 regresyon

### Vendor gerçeği (`kernel-ipq5332-mi01.6.dts`)
```dts
ess-switch@3a000000 {                       /* SoC tarafı */
    switch_mac_mode  = <0xc>;  switch_mac_mode1 = <0xc>;   /* 0xc = SGMII_PLUS = 2.5G */
    qcom,port_phyinfo {
        port@0 { port_id = <1>; forced-speed = <2500>; forced-duplex = <1>; };
        port@1 { port_id = <2>; forced-speed = <2500>; forced-duplex = <1>; };
    };                                       /* İKİSİNDE DE PHY YOK */
};
ess-switch1@1 {                              /* QCA8386, MDIO üzerinden */
    compatible = "qcom,ess-switch-qca8386";
    switch_cpu_bmp = <0x21>;                 /* port 0 ve 5 = SoC'ye uplink */
    switch_wan_bmp = <0x2>;                  /* port 1 = FİZİKSEL WAN JAKI */
    switch_lan_bmp = <0x1c>;                 /* port 2,3,4 = LAN jakları */
    qcom,port_phyinfo {
        port@0 { port_id = <0>; forced-speed = <2500>; forced-duplex = <1>; };
        port@1 { port_id = <1>; phy_address = <1>; };   /* WAN */
        port@2 { port_id = <2>; phy_address = <2>; };   /* LAN1 */
        port@3 { port_id = <3>; phy_address = <3>; };   /* LAN2 */
        port@4 { port_id = <4>; phy_address = <4>; };   /* LAN3 */
        port@5 { port_id = <5>; forced-speed = <2500>; forced-duplex = <1>; };
    };
};
```

Doğru okunuşu: **SoC'nin iki MAC'i, QCA8386'nın 0. ve 5. portlarına PHY'siz 2.5G sabit link ile bağlı.** Fiziksel WAN jakı switch'in 1. portu (PHY adresi 1). Dört jak da switch'in arkasında; SoC MAC'leri jaklara doğrudan bağlı değil.

### İmajların yaptığı

**test1** (`ppe/ethernet-ports`):
```dts
port@1 { label = "lan"; pcs-handle = <0x1d>; phy-mode = "sgmii";
         fixed-link { speed = <0x9c4>; full-duplex; pause; };   /* 0x9c4 = 2500 */
};
port@2 { label = "wan"; pcs-handle = <0x1e>; phy-handle = <0x1f>;  /* -> ethernet-phy@1 */
         phy-mode = "sgmii"; };
```

**test2** (değişen kısım):
```dts
port@1 { label = "lan"; ...
         phy-handle = <0x1e>;          /* -> ethernet-phy@1  (WAN jakının PHY'si!) */
         managed = "in-band-status";   /* fixed-link KALDIRILDI */
};
port@2 { label = "wan"; pcs-handle = <0x1f>; phy-handle = <0x20>;  /* -> ethernet-phy@2 (LAN1'in PHY'si) */
```

**İki sorun:**
1. Her iki imajda da SoC portlarına PHY bağlanmış — oysa vendor'da o taraf PHY'siz. `port@2`'nin `phy-handle`'ı en baştan yanlış.
2. **test2 regresyon:** test1'in `port@1 { fixed-link 2500/full }` tanımı vendor'un `forced-speed=2500, forced-duplex=1` ayarıyla **birebir örtüşüyordu.** test2 bunu silip yerine WAN jakının PHY'sini + `in-band-status` koydu. Yani test2 daha kötü.

→ **Ethernet açısından test1 daha iyi aday. test2'de LAN ölürse test1'i deneyin.**

**Ek:** her iki imaj da `phy-mode = "sgmii"` (1 Gb/s) kullanıyor; vendor `PORT_WRAPPER_SGMII_PLUS = 12` (2.5 Gb/s) kullanıyor. Kernel'de `2500base-x` stringi mevcut (3 eşleşme) — doğru değer büyük olasılıkla `phy-mode = "2500base-x"`.

**Ek 2:** Hiçbir imajda QCA8386 switch sürücüsü yok (kernel'de `ess-switch` string sayısı = 0). Yani dört jak Linux tarafından anahtarlanmıyor; trafik, U-Boot'un switch'i kullanılabilir bir varsayılanda bırakmasına bağlı.

---

## 7. BULGU E — Belge hatası: test2'nin "yeni" özelliği yok

RELEASE_NOTES_v0.1.0-test2.md şunu iddia ediyor:
> `CONFIG_QCA83XX_PHY=y` kernel'de etkinleştirildi ... ayrıca paket setine `kmod-phy-qca83xx` eklendi

**Doğrulama:** `qca83xx` string sayısı = 10 ve `QCA8084` = 1 — **hem t1 hem t2 kernel'inde aynı.** İki rootfs'te de `qca83xx.ko` yok (built-in). Yani test2 yalnızca DTS'i değiştirmiş, sürücü setine dokunmamış. İddia yanlış.

**DTB diff özeti (test1 → test2), phandle numaralandırma gürültüsü hariç gerçek değişiklikler:**
1. `mdio@90000`: `pinctrl-0 = <0x33>` → `<0x34 0x35>` (mdio1-state + mdio0-state)
2. `mdio@90000`: `reset-gpios = <&tlmm 16 GPIO_ACTIVE_LOW>` **eklendi**
3. `mdio@90000`: `reset-assert-us = <0x2710>` (10 ms), `reset-deassert-us = <0xc350>` (50 ms) **eklendi**
4. Dört PHY'ye `compatible = "ethernet-phy-id004d.d0b0"` **eklendi** (Bulgu C)
5. `port@1`: `fixed-link` **silindi**, yerine `phy-handle` + `managed="in-band-status"` (Bulgu D)

Başka hiçbir şey değişmemiş — toplam 138 diff satırının geri kalanı phandle kayması.

---

## 8. BULGU F — UYARI: U-Boot'ta gzip olmayabilir

Vendor `include/configs/ipq5332.h:217-222`:
```c
#ifdef CONFIG_IPQ_TINY
/* undef gzip lib */
#undef CONFIG_GZIP
#undef CONFIG_ZLIB
#else
#define CONFIG_CMD_MII
...
#endif
```

`configs/` altında üç ipq5332 defconfig var:

| defconfig | `CONFIG_IPQ_TINY` | gzip |
|---|---|---|
| `ipq5332_defconfig` | kapalı | **var** |
| `ipq5332_tiny_defconfig` | **açık** | **YOK** |
| `ipq5332_tiny_debug_defconfig` | **açık** | **YOK** |

"tiny" derlemede `bootm` gzip'li FIT kernel'de şunu basar (`common/bootm.c:408-410`):
```
Unimplemented compression type 1
```

Kartın hangi derlemeyle geldiği GPL paketinden anlaşılamıyor (U-Boot build recipe'i eksik, `package/feeds/bootloader/*` 0 baytlık kırık sembolik bağlar).

### Konsoldan ayırt etme (sıfır risk)
"tiny" derlemelerde şu komutlar **kapalı**: `bdinfo`, `editenv`, `mtest`, `setexpr`, `part`, `itest`, `loadb`, `mii`.

```
IPQ5332# bdinfo
```
Çalışıyorsa → tam derleme, gzip var, sorun yok.
"Unknown command" veriyorsa → tiny derleme; FIT'i **LZMA** ile yeniden paketlemek gerekir (LZMA üç defconfig'de de derli) veya sıkıştırmasız.

> `bdinfo` ayrıca `DRAM: 512 MiB` teyidini de verir — bu, `0x50000000` gibi yüksek adreslerin geçerliliği için gerekli bilgi.

---

## 9. Diğer uyarılar

**G — PHY reset süresi çok kısa (test2).** test2 `reset-assert-us = 10000` (10 ms) / `reset-deassert-us = 50000` (50 ms) veriyor. Vendor kernel sürücüsü (`mdio-qca.c:267-278`) 100–110 ms düşük + 100–110 ms bekleme uyguluyor; vendor U-Boot (`ipq5332.c` → `bring_phy_out_of_reset`) 500 ms tutuyor. Öneri: `reset-assert-us = <100000>; reset-deassert-us = <100000>;`. İyi haber: OpenWrt kernel bu üç property'yi de tanıyor (`reset-gpios`, `reset-assert-us`, `reset-deassert-us` — üçü de kernel'de mevcut).

**H — `mdio_clk_fixup` / `phyaddr_fixup` sessizce yok sayılıyor.** DTB'de `mdio_clk_fixup;` var ama kernel'de `mdio_clk_fixup` ve `qca_phy_addr_fixup` string sayısı **0**. Vendor'da bu fixup, QCA8386'nın dahili PHY MDIO adreslerini **yeniden programlıyor** (`mdio-qca.c:554`, `:622` — "For qca8386, the switch occupies the other 16 MDIO address"). Fixup çalışmazsa PHY'ler 1–4 adreslerinde **hiç cevap vermeyebilir.** Bu, Bulgu C ile birlikte Ethernet'in çalışmama olasılığını ciddi ölçüde artırıyor.

**I — ath12k board-id.** DTB `qcom,board-id = <0x12>` (18), gönderilen `board-2.bin` de `bus=ahb,qmi-chip-id=0,qmi-board-id=18` beyan ediyor → **kendi içinde tutarlı.** Ama vendor DTS `qcom,board_id = <0x16>` (22) kullanıyor. Donanım/CDT 22 raporlarsa BDF araması başarısız olur. `dmesg | grep -i "bdf\|board-2\|board_id"` ile izleyin. QCN9274 tarafı: DTB `0x1015`, board-2.bin `qmi-board-id=21` (= 0x15, alt bayt) → tutarlı.

**Küçük not — LED tetikleyicileri.** `/etc/board.d/01_leds` `lan1`/`lan2`/`lan3` için netdev tetikleyicisi kuruyor, ama `02_network` yalnızca `lan` ve `wan` arayüzlerini yaratıyor. O üç tetikleyici işlevsiz kalır. Zararsız, kozmetik.

---

## 10. Temiz çıkan denetimler (detay)

**K — FIT bütünlüğü.** Dört FIT'in de `crc32` ve `sha1` hash düğümleri **tamamı OK**. Hiçbirinde imza düğümü yok. `default = config@mi01.6`, kernel + fdt düğümleri doğru bağlı. FDT `totalsize` her dosyada dosya boyutuna birebir eşit (gizli ek veri yok). Derleme damgası: `2026-08-11 20:00:45 UTC`, `ARM64 OpenWrt Linux-6.18.39`.

**M — UBI yapısı.** 160 PEB × 0x20000, kalıntı 0 bayt. EC başlığı v1, `vid_hdr_offset = 0x800` (2048 B sayfa için doğru), `data_offset = 0x1000`, LEB = 0x1F000 (126 976 B), `image_seq = 0x6A7B7F6D`. **UBI# başlığı olmayan PEB: 0.** Tüm EC ve volume-table CRC'leri OK.

| Volume | Rezerve PEB | Boyut | Bayrak |
|---|---|---|---|
| kernel | 48 | 6.00 MiB | 0x0 |
| rootfs | 110 | 13.75 MiB | 0x0 |
| rootfs_data | 9 | 1.12 MiB | **0x1 (autoresize — doğru)** |

**N — squashfs.** v4.0 @ `0x641000`, 1069 inode, 256 KB blok, **xz**, `bytes_used` 13 931 688 (test1) / 13 931 660 (test2). Kernel'de `xz_dec` (19 eşleşme) ve `squashfs` (102 eşleşme) built-in. `ubiblock` da mevcut (38 eşleşme).

**O — sysupgrade metadata.** `sysupgrade.bin` sonunda `FWx0` fwtool trailer'ı mevcut (offset `0x1308808`, dosya sonu `0x130891b`):
```json
{"metadata_version": "1.1", "compat_version": "1.0",
 "supported_devices": ["mercusys,mr47be-v2", "mercusys,mr47be-v2"],
 "version": {"dist": "OpenWrt", "version": "SNAPSHOT", "revision": "",
             "target": "qualcommbe/ipq53xx", "board": "mercusys_mr47be-v2"}}
```
`CONTROL: BOARD=mercusys_mr47be-v2` ve DTB `compatible` ile uyumlu → sysupgrade bu imajı kabul eder, `-F` gerekmez.

**P — Boyut uyumluluğu.** factory.bin'de dolu 160 PEB (20.00 MiB); volume-table rezervasyonu 167 PEB (20.88 MiB). DTB `ubi` bölümü 416 PEB (52.00 MiB), gerçek `rootfs` 422 PEB (52.75 MiB) — **her ikisine de rahatça sığar.** (Sığması sorun değil; sorun yerin yanlış olması — Bulgu B.)

**İç tutarlılık.** `sysupgrade/kernel` == bağımsız `uImage.itb` bit-bit aynı. factory UBI'deki `kernel` volume'ü == aynı FIT + sıfır kuyruk. `rootfs` volume'ü == aynı squashfs. Yani üç dağıtım formatı aynı içerikten türetilmiş.

**R — GPIO16 çakışması yok.** Vendor DTS'te gpio16/17 aynı anda hem switch reset hem de **etkin** `blsp0_spi` (MISO/CS) tarafından talep ediliyor — gerçek bir vendor hatası. OpenWrt imajında `spi@78b5000 status = "disabled"` ve DTB'de hiç `"gpio16"`/`"gpio17"` pin referansı yok. **Bu çakışma OpenWrt tarafında yok — test2'nin `reset-gpios` eklemesi bu açıdan güvenli.**

**MDIO pin mux — düzeltme.** Vendor kaynağı hem `mdio0_pins` (gpio25/26) hem `mdio1_pins` (gpio27/28) tanımlıyor ama ikisi de aynı düğüm adını (`mdio_pinmux`) kullandığı için dtc bunları birleştiriyor; **derlenmiş vendor DTB'de yalnızca gpio27/28 (`mdc1`/`mdio1`) kalıyor.** U-Boot da bağımsız olarak gpio27/28 kullanıyor. test1 `pinctrl-0 = <mdio1-state>` (gpio27/28) → vendor DTB ile birebir. test2 ikisini de ekliyor (gpio25/26 fazladan muxlanıyor) → vendor *kaynak niyetiyle* uyumlu, muhtemelen zararsız. Bu kalem sorun değil.

---

## 11. Risk analizi ve kurtarma

### RAM boot neden güvenli
`tftpboot` + `bootm` **flash'a hiçbir şey yazmaz.** Tüm işlem DDR'de. Kart resetlenirse stok firmware'e döner. Bu yüzden ilk test kesinlikle `initramfs-uImage.itb` ile RAM'den yapılmalı.

### Değişmez güvenlik kuralları
1. **ART bölümüne asla yazma/silme yapma.** Wi-Fi kalibrasyonu + MAC, cihaza özel, geri getirilemez — vendor imajında da yok.
2. **Doğrulanmadan NAND'a yazma.** Bulgu B çözülmeden `ubiformat`/`sysupgrade` çalıştırmayın.
3. **A/B yedeğini bozma.** `rootfs` ve `rootfs_1` stok fallback'i; ikisi birden bozulursa kurtarma yalnızca UART.
4. **İlgisiz TP-Link/Mercusys firmware'i yüklemeyin.** Stok recovery RSA imza doğruluyor; `_nosign_` dosyalar her zaman reddediliyor, yeniden adlandırma bunu aşmıyor.

### Test öncesi alınacak yedekler (UART'tan, okuma — yazma yok)
```
nand read 0x46000000 0x900000 0x200000     # 0:ART        (EN KRİTİK)
nand read 0x46000000 0x180000 0x100000     # 0:MIBIB      (bölüm tablosu)
nand read 0x46000000 0x740000 0x080000     # 0:APPSBLENV  (U-Boot env)
nand read 0x46000000 0x7500000 0xa00000    # tp_data
```
Her okumadan sonra veriyi TFTP ile dışarı alın (`tftpput` varsa) veya `md.b` ile konsoldan dökün. **Yedek alınmadan hiçbir yazma işlemi yapılmamalı.**

> Adresler yukarıdaki "Gerçek" tablosundan; `smeminfo` çıktısı farklıysa **smeminfo kazanır**, bu komutları ona göre düzeltin.

### Brick senaryoları
| Senaryo | Sonuç | Kurtarma |
|---|---|---|
| RAM boot başarısız (Bulgu A) | Kart reset atar | Güç kes-aç, stok açılır. **Kalıcı hasar yok** |
| gzip yok (Bulgu F) | "Unimplemented compression type 1" | Aynı, hasar yok |
| Ethernet ölü (Bulgu C/D/H) | Konsol var, ağ yok | Aynı, hasar yok |
| Yanlış tabloyla NAND'a yazma (Bulgu B) | Her iki rootfs slotu bozulur | **UART + TFTP zorunlu** |
| ART silinmesi | Wi-Fi + MAC kalıcı kayıp | **Kurtarma yok** |

---

## 12. Düzeltilmiş test prosedürü

### Aşama 0 — keşif (yazma yok, risk yok)
```
IPQ5332# bdinfo                 # tam derleme mi? DRAM kaç MiB?
IPQ5332# printenv
IPQ5332# smeminfo               # argümansız — GERÇEK bölüm tablosu
IPQ5332# mtdparts
IPQ5332# nand info
IPQ5332# nand bad
IPQ5332# mii read 1 2
IPQ5332# mii read 1 3           # (reg2<<16)|reg3 == 0x004DD180 mi?
```
- `bdinfo` yoksa → tiny U-Boot → **durun**, FIT'i LZMA ile yeniden paketleyin.
- `smeminfo` çıktısı §4'teki tabloyla uyuşmuyorsa → DTS düzeltilmeden NAND'a yazmayın.

### Aşama 1 — yedek al
§11'deki dört `nand read` komutu.

### Aşama 2 — RAM boot (DÜZELTİLMİŞ)
```
IPQ5332# setenv serverip 192.168.1.100
IPQ5332# setenv ipaddr 192.168.1.1
IPQ5332# tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
IPQ5332# bootm 0x46000000
```

> ⛔ `0x44000000` **KULLANMAYIN** — bootm çakışması, 5.99 MiB (Bulgu A)
> ⛔ `0x47000000` / `0x48000000` **KULLANMAYIN** — TFTP "file size too large"
> ⚠️ `0x50000000` yalnızca `bdinfo` 512 MiB teyit ederse
> ✅ Yedek adres: `0x45000000`

### Aşama 3 — boot sonrası kontrol listesi
1. Konsol banner'ı, kernel panic var mı
2. `ip link` → MAC etiketle uyuşuyor mu (Bulgu J testi — uyuşmuyorsa Bulgu B doğrulanmış olur)
3. `dmesg | grep -i "mdio\|phy"` → PHY'ler bulundu mu, Generic PHY'ye mi düştü (Bulgu C)
4. `dmesg | grep -i "ath12k\|bdf\|board-2"` → BDF yüklendi mi (Bulgu I)
5. `cat /proc/mtd` → bölümler nasıl görünüyor (Bulgu B)
6. LAN kablosu tak → link geliyor mu (Bulgu D)
7. **test2'de LAN ölüyse → test1 initramfs'i aynı adresle deneyin** (test1'in `fixed-link 2500` tanımı vendor'la uyumlu)

### Aşama 4 — NAND'a yazma
**Şu üçü çözülmeden yapılmamalı:** Bulgu B (bölüm tablosu), Bulgu C (PHY ID), Bulgu D (topoloji). RAM boot'ta Ethernet çalışmıyorsa NAND'a yazmanın hiçbir faydası yok, sadece risk ekler.

---

## 13. Yapılacaklar (öncelik sırasıyla)

1. **Bölüm tablosunu düzelt.** DTS `fixed-partitions` bloğunu §4'teki gerçek yerleşime göre yeniden yaz — özellikle `0:art` → `0x900000` `0x200000`, `ubi` → `0xB80000` `0x34C0000`. Önce `smeminfo` ile teyit et.
2. **PHY ID'yi düzelt.** `compatible` satırlarını sil (otomatik probe) veya `ethernet-phy-id004d.d180` yap.
3. **Topolojiyi düzelt.** `port@1` ve `port@2`'yi vendor gibi PHY'siz `fixed-link` 2500/full yap; `phy-mode` için `2500base-x` dene. Dört jak switch'in arkasında.
4. **Reset zamanlamasını uzat.** `reset-assert-us = <100000>`, `reset-deassert-us = <100000>`.
5. **RELEASE_NOTES'u düzelt.** Boot adresini `0x46000000` yap; yanlış `CONFIG_QCA83XX_PHY` iddiasını kaldır.
6. **QCA8386 switch sürücüsü** (qca-ssdk veya mainline DSA) olmadan dört jak Linux tarafından anahtarlanmayacak — orta vadeli iş.

---

*Bu rapordaki tüm boyut, adres ve hash değerleri imaj dosyaları üzerinden programatik olarak hesaplandı; U-Boot davranış iddiaları vendor GPL kaynağından dosya:satır referansıyla doğrulandı.*
