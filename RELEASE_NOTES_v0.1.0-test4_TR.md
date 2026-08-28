# MR47BE V2 OpenWrt v0.1.0-test4 (donanım-uyumlu revizyon)

**Build durumu:** ✅ **TAMAMLANDI** (2026-08-29 01:47, temiz ağaç `/root/mr47be-clean`, `make -j4` EXIT 0)
**Amaç:** test1/2/3'teki YANLIŞ donanım varsayımlarını (ayrı QCA8386 çipi, IPQ5332) düzeltip
kesin donanıma uyum sağlamak: **IPQ5322 (içine entegre QCA8084 4×2.5G) + QCN6274 (PCIe 6 GHz)**.

> ⚠️ **EXPERIMENTAL — NAND'a YAZMA.** UART → U-Boot → TFTP → `initramfs-uImage.itb` (RAM only).

---

## Neden test4 (test1/2/3 neden yanlıştı)

| Varsayım (test1-3) | Gerçek (foto + UART boot log) |
|---|---|
| SoC = IPQ5332 | ❌ Fiziksel SoC = **IPQ5322** (foto `IPQ5322 003 FK5134HJ`) |
| Ethernet = ayrı QCA8386 switch çipi | ❌ **QCA8386 YOK.** Boot log: `eth0 PHY0 QCA8084-switch` |
| — | Ethernet = **QCA8084 switch-PHY — IPQ53xx SoC'ya ENTEGRE** (LAN PORT1..3 + WAN PHY1, 4× 2.5G). Kanıt: GPL U-Boot `ipq_qca8084.c:1472` + dahili MDIO + fotoğraflar |
| Secure boot kapalı olduğu bilinmiyordu | ✅ `Secure Boot: Off` (imzasız RAM boot mümkün) |

> ℹ️ Bootlog'daki `PORT1 Up :100` = TP-Link 740N (100 Mbps) üzerinden alınan **o anki**
> auto-neg hızıdır; portlar 2.5G kapasiteli (ana kanıt `QCA8084-switch`).

## Kullanılan final DTS (doğrulandı)

- Kaynak: `openwrt/` git ağacı (commit `cb2d2ab`) → `ipq5332-mercusys-mr47be-v2.dts`
- **md5 `90bdb804caf8de759cc33bbbc262afc`** — proje kökü / tmp_build / build ağacı ile birebir
- Build'in beklediği isim: `ipq5332-mr47be-v2.dts` (DEVICE_DTS türetmesi). `setup_clean.sh`
  kalıcı düzeltildi: her iki isimde de DTS + `cmp` guard (FATAL_DTS_NAME).
- DTS içeriği: QCA8084 phy@1..4 + reset gpio16, PPE xgmac1=LAN (2500base-x fixed-link),
  xgmac2=WAN (phy3), NAND A/B partition (nand-partition.xml birebir, ART @0x900000 read-only),
  wifi0 q6 (board-id 18), PCIe QCN6274 `pci17cb,1109` (board-id 0x1015).

## İmajlar (bu klasörde) — sha256

| Dosya | sha256 | Açıklama |
|---|---|---|
| `openwrt-...-mercusys_mr47be-v2-initramfs-uImage.itb` | `944038f9748b81d3b8ba14e24b6315eb25821b38969676ee0b867e01da658069` | **RAM boot / test (önerilen)** · md5 `c71c879e…` |
| `openwrt-...-mercusys_mr47be-v2-uImage.itb` | `90ea66713b799fabbdcc4aa8c69e021905d6db8dd2f6c27af89d68067a2a9cce` | FIT kernel |
| `openwrt-...-mercusys_mr47be-v2-squashfs-factory.bin` | `a574f95b86f2da82f145c23f95f86dfd6587691ff5b9d7c7f2b582e939e388db` | UBI factory |
| `openwrt-...-mercusys_mr47be-v2-squashfs-factory.ubi` | `a574f95b86f2da82f145c23f95f86dfd6587691ff5b9d7c7f2b582e939e388db` | UBI factory (ham) |
| `openwrt-...-mercusys_mr47be-v2-squashfs-sysupgrade.bin` | `0bd575ff5a3d19160b4d22476971e42b73f25cda5f7f405fbc6aaffc3e601df2` | sysupgrade |

`sha256sums` + `.manifest` dosyaları da bu klasörde.

## Build'de doğrulanan donanım kapsamı (rootfs içinden)

- `lib/firmware/ath12k/IPQ5332/hw1.0/` → q6_fw0 (on-SoC 2.4/5), q6_fw1 + iu_fw, Data.msc, regdb.bin ✅
- `lib/firmware/ath12k/QCN9274/hw2.0/board-2.bin` → QCN6274 BDF (ipq-wifi `mercusys_mr47be-v2` paketi) ✅
- `lib/modules/6.18.39/` → `ath12k.ko`, `ath12k_wifi7.ko`, `qrtr.ko`, `qrtr-smd.ko`, `qrtr-mhi.ko` ✅
- `etc/board.d/02_network` → `mercusys,mr47be-v2`: lan/wan + MAC `0:art` ✅
- FIT `config@mi01.6` + DTB `ipq5332-mr47be-v2.dtb` (QCA8084 phy@1..4, 2500base-x, fixed-link, pci17cb,1109, 0:art, rootfs_1; **qca8386: 0**) ✅

## Boot / test (RAM only)

```
UART GPIO18/19 @115200 8N1 → U-Boot (IPQ5332# prompt)
setenv serverip 192.168.1.100
setenv ipaddr 192.168.1.1
tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
bootm 0x46000000
```
> ⛔ 0x44000000 kullanma (bootm çakışması). RAM boot NAND'a dokunmaz.

## Doğrulama (boot sonrası)

1. `cat /proc/device-tree/compatible` + `dmesg | grep -i socinfo` → **IPQ5322** teyidi.
2. `dmesg | grep -i "mdio\|phy\|qca8084"` → PHY'ler (PORT1-3=LAN, PHY1=WAN).
3. `dmesg | grep -i ath12k\|board-2\|bdf` → Wi-Fi BDF durumu.
4. `ip link` → MAC'ler ART'tan geliyor mu.
5. `iwinfo` / `iw dev` → on-SoC 2.4/5 + QCN6274 6 GHz radyolar.

## Bilinen sınırlar (açık işler)

- ⚠️ `etc/hotplug.d/firmware/12-ath12k-caldata`: **mercusys kaydı YOK** (yalnız gl-be6500/9300).
  QCN6274 BDF'i ipq-wifi `board-2.bin`'den gelir; on-SoC (Q6) BDF'i ART'tan `qcom,bdf-address-offset`
  ile okunur. Boot dmesg'te BDF yüklenmezse bu script'e `mercusys,mr47be-v2` ART çıkarma
  (offsetler: ART dump'a göre `mii read`/dmesg ile netleşir) eklenmesi gerekir.
- QCA8084'ün mainline DSA **switch** sürücüsü yok. İlk hedef: UART + Wi-Fi + 4× PHY link up;
  LAN switch/bridge ayrı DSA işi.
- Wi-Fi BDF (board-id 0x16 / 0x1015) donanım doğrulaması sonrası kesinleşir.

---
