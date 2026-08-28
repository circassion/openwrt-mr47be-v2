# MR47BE V2 OpenWrt v0.1.0-test3

**Mercusys MR47BE V2 (IPQ5332 / Wi-Fi 7) — experimental OpenWrt build**

> ⚠️ **EXPERIMENTAL. Do NOT flash to NAND yet.**
> Boot via UART → U-Boot → TFTP → `initramfs-uImage.itb` (RAM only, zero flash risk).

---

## Why test3 exists

test1/test2 `PRE_TEST_CHECK.md` derin denetiminde (2026-08-25) 70 teknik iddianın
tamamı doğrulandı ve imajların **yapısal olarak sağlam** olduğu teyit edildi. Ancak
3 blocker bulundu ve bunların hepsi **DTS/yerleşim** hatasıydı — kernel/config
değil. test3 bu blocker'ları düzeltmek için üretildi:

| # | Düzeltme | Blocker |
|---|---|---|
| 1 | **Bölüm tablosu gerçek NAND yerleşimine sabitlendi** — `0:art` → `0x900000` `0x200000`, `ubi` → `0xB80000` `0x34C0000`, + `rootfs_1`/`tp_data`/`data`/`reserverd_data` (A/B yedeği read-only korunuyor) | Bulgu B (soft-brick riski) |
| 2 | **PHY `compatible` kaldırıldı** — `ethernet-phy-id004d.d0b0` (=QCA8075, yanlış çip) hard-coded olduğu için otomatik probe'u engelliyordu; artık ID probe'u gerçek QCA8084 (`0x004dd180`) sürücüsünü bulabilir | Bulgu C |
| 3 | **Topoloji vendor'a çekildi** — `port@1`+`port@2` (lan+wan) SoC MAC'leri QCA8386 CPU portuna **PHY'siz** `fixed-link 2500/full`; `phy-mode = "2500base-x"` (vendor `SGMII_PLUS`). test2'nin `in-band-status` regresyonu geri alındı | Bulgu D |
| 4 | **PHY reset zamanlaması** `10/50 ms` → `100/100 ms` (vendor `mdio-qca.c` 100–110 ms) | Bulgu G |

**Kritik not (Bulgu A):** RELEASE_NOTES/test1 ve test2'de yazan
`tftpboot 0x44000000` + `bootm 0x44000000` **donanımda çalışmaz** — FIT kernel
0x41000000'e açılıp kendi sıkıştırılmış kaynağının üzerine yazar (`ERROR: new
format image overwritten - must RESET the board`). Doğru adres: **`0x46000000`**.

---

## What's new (vs test2)

- Bölüm tablosu, PHY ID, topoloji ve reset zamanlaması düzeltildi (yukarıdaki tablo)
- Kernel/config/driver seti test2 ile **aynı** (6.18.39, `CONFIG_QCA83XX_PHY` zaten built-in; `kmod-phy-qca83xx` paketi mevcut)
- `serial_0_pins` duplicate bloğu DTS'ten temizlendi (dtsi'de zaten var)

## Included

- Linux **6.18.39** (ARM64, `qualcommbe/ipq53xx`)
- MR47BE V2 device tree + `mercusys_mr47be-v2` board definition
- Wi-Fi firmware/BDF: `ath12k-firmware-qcn9274` 20260622-r1,
  `ipq-wifi-mercusys_mr47be-v2` 2026.05.18
- FIT kernel, initramfs, factory UBI, sysupgrade images
- USB (DWC3/xHCI/storage), block-mount, dropbear SSH, firewall4

## Images

| Image | Size | Purpose |
|---|---|---:|
| `*-initramfs-uImage.itb` | ~21.6 MB | **RAM boot / hardware test (recommended)** |
| `*-uImage.itb` | ~5.7 MB | FIT kernel |
| `*-squashfs-factory.bin` | 20 MB | Factory UBI image |
| `*-squashfs-sysupgrade.bin` | ~19 MB | OpenWrt sysupgrade |

## SHA256 (build sonrası hesaplandı)

```
d8e867ed25bda8a9292c44ba4d68ffc73eaa853a2ef55094e4b225d114b0ddfd  openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
d8e16279eb7ff714e80aa0f85cb69dc179dfe6185e297bdc211d8a847ae653e8  openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-sysupgrade.bin
06f6a6721987a0b336ddbc7cd131ce7cad2ea1148e611aed2f176cc885154059  openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
fef1cf0412b04bc1f557ee728fc5ee41159ed111b3e69184d29aeda341ab7302  openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-uImage.itb
```

> uImage.itb (kernel FIT) build'ler arası deterministik; initramfs/factory/sysupgrade
> rootfs zaman damgası yüzünden her build'de ~birkaç yüz bayt değişir — üstteki
> hash'ler `imajlar/test3/` içindeki dosyalara aittir.

## Boot / test (DÜZELTİLMİŞ adres)

```text
UART (GPIO18 TX / GPIO19 RX, 115200 8N1)
  → U-Boot console
  → setenv serverip 192.168.1.100
  → setenv ipaddr 192.168.1.1
  → tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
  → bootm 0x46000000
```

> ⛔ `0x44000000` **KULLANMAYIN** — bootm çakışması, 5.99 MiB (Bulgu A)
> ⛔ `0x47000000` / `0x48000000` **KULLANMAYIN** — TFTP "file size too large"
> ⚠️ `0x50000000` yalnızca `bdinfo` 512 MiB teyit ederse
> ✅ Yedek adres: `0x45000000`

RAM boot only. NAND is untouched.

## Boot sonrası kontrol listesi (sıfır risk)

1. Konsol banner'ı, kernel panic var mı
2. `ip link` → MAC etiketle uyuşuyor mu (Bulgu J testi — uyuşmuyorsa bölüm tablosu teyit edilir)
3. `dmesg | grep -i "mdio\|phy"` → PHY'ler bulundu mu (Bulgu C)
4. `dmesg | grep -i "ath12k\|bdf\|board-2"` → BDF yüklendi mi (Bulgu I)
5. `cat /proc/mtd` → bölümler gerçek yerleşimde mi (Bulgu B)
6. LAN kablosu tak → link geliyor mu (Bulgu D — sürücü eksikliği nedeniyle ölü olabilir, §3)

## Known limitations

- **QCA8386 switch sürücüsü her iki imajda da YOK** (`ess-switch` string = 0).
  Dört jak Linux tarafından anahtarlanmıyor; trafik U-Boot'un switch'i bıraktığı
  varsayılan duruma bağlı. Ethernet bu kartta birkaç DTS düzeltmesiyle çalışmaz —
  **sürücü işi** (qca-ssdk / mainline DSA). İlk testte gerçekçi beklenti:
  **Wi-Fi (ath12k) ayağa kalksın + UART'tan shell alınsın.**
- `mdio_clk_fixup`/`phyaddr_fixup` kernel'de karşılığı olmadığı için sessizce yok
  sayılıyor (Bulgu H) — QCA8386 iç PHY'leri MDIO 1–4'te yanıt vermeyebilir.
- Wi-Fi BDF temporary — hardware validation bekliyor (board-id 0x12 vs vendor 0x16).
- NAND bölüm tablosu **donanımda `smeminfo` ile teyit edilmeden** NAND'a yazma yapma
  (Bulgu B). `smeminfo` çıktısı bu tabloyla uyuşmuyorsa DTS düzeltilmeden yazma.

## Important

- **Never flash unrelated TP-Link/Mercusys firmware** — stock recovery verifies RSA
  signatures; `_nosign_` files are rejected; renaming does not bypass it.
- **Preserve the ART partition** (Wi-Fi calibration + MAC). Real ART at NAND offset
  `0x900000` (0x200000 = 1 MiB); this DTS marks it read-only.
- A/B layout: `rootfs` (A) + `rootfs_1` (B) — stock firmware can live in B.

## Status

- 🟡 Build: complete
- 🟢 Image analysis: PRE_TEST_CHECK fixes verified (bölüm tablosu, PHY, topoloji, reset)
- 🟠 QCA8386: wired as MDIO PHY (auto-probe), **hardware-untested**, driver yok
- 🟠 Wi-Fi / Ethernet / USB: hardware validation pending
- 🟢 Brick risk for RAM boot: none (adres 0x46000000 ile)

**Experimental release. Use at your own risk.**
