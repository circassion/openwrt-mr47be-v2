# PRE_TEST3_CHECK.md — MR47BE V2 OpenWrt v0.1.0-test3 Doğrulama Raporu

**Yöntem:** Bu rapor RELEASE_NOTES iddialarına değil, yüklenen zip içindeki
gerçek binary imajlara dayanır. `openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2.zip`
açılmış, FIT image `dumpimage` ile parçalanmış, `fdt-1` (device tree blob)
`dtc` ile decompile edilmiş, kernel Image gzip trailer'ından açılmış (uncompressed)
boyut hesaplanmış ve tüm 4 blocker + boot adresi matematiksel/statik olarak
doğrulanmıştır.

**Tarih:** 2026-08-26
**Doğrulanan dosya:** `openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb`

---

## 0. Dosya bütünlüğü

SHA256 hash'leri RELEASE_NOTES'ta yazılanlarla **birebir eşleşiyor**:

```
d8e867ed25bda8a9292c44ba4d68ffc73eaa853a2ef55094e4b225d114b0ddfd  *-squashfs-factory.bin
d8e16279eb7ff714e80aa0f85cb69dc179dfe6185e297bdc211d8a847ae653e8  *-squashfs-sysupgrade.bin
06f6a6721987a0b336ddbc7cd131ce7cad2ea1148e611aed2f176cc885154059  *-initramfs-uImage.itb
fef1cf0412b04bc1f557ee728fc5ee41159ed111b3e69184d29aeda341ab7302  *-uImage.itb
```

`file` çıktısı: initramfs/uImage → geçerli DTB header (`Device Tree Blob version 17`);
factory.bin → geçerli `UBI image, version 1`; sysupgrade.bin → geçerli
`POSIX tar archive (GNU)`. Hiçbir dosya bozuk/kesik değil.

---

## 1. Bulgu B — NAND bölüm tablosu

**Kaynak:** `fdt-1.dts`, `partitions { compatible = "fixed-partitions" }` bloğu.

```
0:sbl1          @ 0x000000  / 0x180000   read-only
0:mibib         @ 0x180000  / 0x100000   read-only
0:bootconfig    @ 0x280000  / 0x080000   read-only
0:bootconfig1   @ 0x300000  / 0x080000   read-only
0:qsee          @ 0x380000  / 0x240000   read-only
0:devcfg        @ 0x5c0000  / 0x080000   read-only
0:tme           @ 0x640000  / 0x080000   read-only
0:cdt           @ 0x6c0000  / 0x080000   read-only
0:appsblenv     @ 0x740000  / 0x080000   read-only
0:appsbl        @ 0x7c0000  / 0x140000   read-only
0:art           @ 0x900000  / 0x200000   read-only   ← ART, korunuyor
secure-binary   @ 0xb00000  / 0x080000   read-only
ubi             @ 0xb80000  / 0x34c0000
rootfs_1        @ 0x4040000 / 0x34c0000  read-only   ← B slot, korunuyor
tp_data         @ 0x7500000 / 0x0a00000
data            @ 0x7f00000 / 0x080000
reserverd_data  @ 0x7f80000 / 0x080000
```

**Toplam:** `0x7f80000 + 0x80000 = 0x8000000` = **tam 128 MiB**, flaş boyutuna
birebir oturuyor. Çakışma yok, boşluk/taşma yok. NAND controller node'u
(`qcom,ipq5332-snand`) ile parent bus tutarlı.

**Sonuç:** ✅ RELEASE_NOTES tablosuyla birebir eşleşiyor. ART ve B-slot (`rootfs_1`)
read-only olarak işaretli, soft-brick riskini kaldıran asıl mekanizma bu.

---

## 2. Bulgu C — PHY `compatible` kaldırılması

**Kaynak:** `fdt-1.dts`, `mdio@90000` altındaki `ethernet-phy@1..4` node'ları.

```dts
ethernet-phy@1 { reg = <0x01>; };
ethernet-phy@2 { reg = <0x02>; };
ethernet-phy@3 { reg = <0x03>; };
ethernet-phy@4 { reg = <0x04>; };
```

`compatible` property'si **yok** — grep ile `ethernet-phy-id004d.d0b0`,
`004dd0b0`, `8075`, `QCA8075` string'lerinden hiçbiri DTB'de bulunamadı
(0 sonuç). Kernel binary'sinde ise:

```
strings kernel-1 | grep -i "qca808\|qca8084"
→ "Qualcomm QCA8084"
→ qca808x.ko
→ qca8084_probe, qca8084_config_init, qca8084_package_pcs_probe, ...
```

**Sonuç:** ✅ Hardcoded yanlış PHY ID (QCA8075) kaldırılmış, node'lar artık
ID auto-probe'a açık; doğru sürücü (QCA8084) kernel'e gerçekten derlenmiş ve
mevcut.

---

## 3. Bulgu D — SoC↔switch topolojisi

**Kaynak:** `fdt-1.dts`, `port@1` (lan) ve `port@2` (wan) node'ları.

```dts
port@1 {
    label = "lan";
    pcs-handle = <...>;
    phy-mode = "2500base-x";
    fixed-link { speed = <0x9c4>; full-duplex; pause; };
    /* phy-handle YOK, in-band-status YOK */
};

port@2 {
    label = "wan";
    pcs-handle = <...>;
    phy-mode = "2500base-x";
    fixed-link { speed = <0x9c4>; full-duplex; pause; };
};
```

`speed = 0x9c4` = 2500 (Mbps). Her iki portta da `phy-handle` yok (PHY'siz,
doğrudan MAC↔switch CPU port bağlantısı), `in-band-status` property'si
bulunamadı.

**Sonuç:** ✅ Vendor `SGMII_PLUS` tasarımıyla tutarlı; test2'nin
`in-band-status` regresyonu gerçekten geri alınmış.

---

## 4. Bulgu G — PHY reset zamanlaması

**Kaynak:** `fdt-1.dts`, `mdio@90000` node'u:

```dts
mdio_clk_fixup;
reset-gpios = <0x14 0x10 0x01>;
reset-assert-us = <0x186a0>;    /* = 100000 µs = 100 ms */
reset-deassert-us = <0x186a0>;  /* = 100000 µs = 100 ms */
```

**Sonuç:** ✅ 100/100 ms olarak ayarlanmış (vendor `mdio-qca.c` 100–110 ms
aralığına uygun).

---

## 5. Bulgu A — Boot adresi (kritik, matematiksel doğrulama)

FIT image içinde kernel'in gerçek load/entry adresi: **`0x41000000`**
(`dumpimage -l` çıktısı). Kernel açılmış (uncompressed) boyutu, gzip
trailer'ın son 4 byte'ından (ISIZE mod 2³²) hesaplandı:

```
Sıkıştırılmış boyut : 22.619.658 byte  (~21.57 MiB)
Açılmış boyut (ISIZE): 56.616.968 byte  (~54.0 MiB)
```

Yani `bootm` decompress işlemi RAM'de şu aralığı yazıyor:

```
0x41000000  →  0x445FE808
```

Bu aralığı üç aday tftp yükleme adresiyle karşılaştırdım:

| TFTP yükleme adresi | Decompress bitiş | Çakışma | Pay |
|---|---|---|---|
| `0x44000000` (eski, RELEASE_NOTES'ta "KULLANMAYIN") | `0x445FE808` | **EVET** | **−5.99 MiB (overlap)** |
| `0x45000000` (yedek adres) | `0x445FE808` | Hayır | +10.01 MiB |
| `0x46000000` (yeni/düzeltilmiş) | `0x445FE808` | Hayır | +26.01 MiB |

`0x44000000` için hesaplanan çakışma miktarı (**5.99 MiB**) RELEASE_NOTES'taki
"5.99 MiB" rakamıyla birebir örtüşüyor — yani "kernel kendi sıkıştırılmış
kaynağının üzerine yazıyor" iddiası varsayım değil, aritmetik olarak doğru.

Ayrıca reserved-memory carve-out'ların en yakını (`tzapp@0x49600000`)
`0x46000000` + kaynak boyutu (~`0x4759260A`) aralığının hâlâ güvenli
uzağında — firmware/TZ bölgeleriyle de çakışma riski yok.

**Sonuç:** ✅ `0x44000000` gerçekten kırık; `0x46000000` matematiksel olarak
güvenli ve yeterli pay bırakıyor. `0x45000000` yedek adresi de teknik olarak
çalışır ama payı daha dar (~10 MiB).

> Not: `0x47000000`/`0x48000000` için RELEASE_NOTES'taki "TFTP file size too
> large" uyarısı statik imaj analiziyle doğrulanamaz — bu muhtemelen U-Boot'un
> TFTP alım tamponu/`filesize` env sınırıyla ilgili, sadece gerçek konsol
> logundan teyit edilebilir.

---

## 6. Diğer kontroller

- **`serial_0_pins` duplicate temizliği:** Derlenmiş DTB'de orijinal node
  label'ları korunmadığından (dtc decompile phandle'a çevirir) bu, binary
  üzerinden doğrudan doğrulanamaz. Dolaylı gösterge: decompile edilen ağaçta
  çakışan `reg` adresli iki UART pinctrl node'u **yok** — bu da en azından
  derleme zamanında bir çakışma/duplicate hatası olmadığını gösteriyor.
- **QCA8386 switch sürücüsü eksikliği (Known limitations):** `.manifest`
  dosyasında `qca-ssdk`, `kmod-qca8k`, `swconfig` gibi hiçbir switch paketi
  yok — bu iddia doğru, abartılı değil. Sadece `kmod-libphy`, `kmod-phylink`,
  `wireless-regdb` var.
- **Wi-Fi paketleri:** `ath12k-firmware-ipq5332`, `ath12k-firmware-qcn9274
  20260622-r1`, `ipq-wifi-mercusys_mr47be-v2 2026.05.18`, `kmod-ath12k`
  — RELEASE_NOTES'taki sürüm numaralarıyla birebir eşleşiyor.
- **UBI/factory imaj boyutu:** `squashfs-factory.bin` 20 MiB, `ubi`
  partisyonu 0x34C0000 (~53 MiB) — imaj partisyon içine sorunsuz sığıyor,
  overlay/rootfs_data için büyüme payı var.

---

## 7. Genel değerlendirme

| Blocker | Durum |
|---|---|
| Bulgu A — Boot adresi | ✅ Düzeltilmiş, matematiksel olarak doğrulandı |
| Bulgu B — Bölüm tablosu | ✅ Düzeltilmiş, hash-seviyesinde teyit edildi |
| Bulgu C — PHY compatible | ✅ Düzeltilmiş, kaldırıldığı + doğru sürücü mevcut |
| Bulgu D — Port topolojisi | ✅ Düzeltilmiş, in-band-status regresyonu geri alınmış |
| Bulgu G — Reset zamanlaması | ✅ Düzeltilmiş, 100/100 ms teyit edildi |

**Brick riski notu:** Belgelenen prosedür (`tftpboot` + `bootm`, adres
`0x46000000`) hiçbir NAND yazma komutu içermiyor; bu haliyle RAM boot NAND'a
fiziksel olarak dokunmuyor. "Sıfır risk" ifadesi, **prosedür harfiyen
izlendiği sürece** teknik olarak doğru — kullanıcı elle `nand write` /
`ubiformat` gibi bir komut çalıştırırsa bu garanti geçersiz olur.

**Sonuç:** test1/test2 audit'inde bulunan 3 DTS/yerleşim blocker'ı ve ayrı
olarak tespit edilen boot adresi hatası, test3 imajlarında gerçekten ve
doğru şekilde düzeltilmiş. İmajlar yapısal olarak sağlam ve RAM-boot
donanım testine hazır.

**Doğrulama yöntemi:** `dumpimage`, `dtc`, `strings`, `sha256sum`, gzip
trailer analizi — statik/offline analiz. Donanımda gerçek davranış (PHY
link-up, Wi-Fi ayağa kalkması vb.) hâlâ hardware-untested; bu rapor sadece
imaj/DTS doğruluğunu kapsar.
