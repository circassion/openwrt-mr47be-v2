# MR47BE V2 OpenWrt v0.1.0-test4 (donanım-uyumlu revizyon)

**Tarih:** 2026-08-28 · **Amaç:** test1/2/3'teki YANLIŞ donanım varsayımlarını
(QCA8386, IPQ5332) düzeltip kesin donanıma (IPQ5322 + QCA8084 + QCN6274) uyum sağlamak.

> ⚠️ **EXPERIMENTAL — NAND'a YAZMA.** UART → U-Boot → TFTP → `initramfs-uImage.itb` (RAM only).

---

## Neden test4 (test1/2/3 neden yanlıştı)

| Varsayım (test1-3) | Gerçek (foto + UART boot log) |
|---|---|
| SoC = IPQ5332 | ❌ Fiziksel SoC = **IPQ5322** (foto `IPQ5322 003 FK5134HJ`) |
| Ethernet = QCA8386 switch | ❌ **QCA8386 YOK**. Boot log: `eth0 PHY0 QCA8084-switch` |
| — | Ethernet = **QCA8084** 4×2.5G switch-PHY (LAN PORT1..3 + WAN PHY1) |
| Secure boot kapalı olduğu bilinmiyordu | ✅ `Secure Boot: Off` (imzasız RAM boot mümkün) |

## test4'te yapılan DTS değişiklikleri (`ipq5332-mercusys-mr47be-v2.dts`)

1. **mdio**: QCA8386 yorumları çıkarıldı → **QCA8084** (4×2.5G switch-PHY), reset gpio16 (vendor GPL `phy-reset-gpio`).
2. **qcom_ppe**: xgmac1 = LAN → QCA8084 switch CPU portuna 2500base-x fixed-link uplink;
   xgmac2 = WAN → `phy-handle = <&phy3>` (QCA8084 PHY1).
3. Partition tablosu A/B (128 MiB) — nand-partition.xml ile birebir (değişmedi, doğruydu).
4. Secure Boot Off olduğundan boot adresi `0x46000000` (0x44000000 çakışmasına karşı).

## İmajlar (build sonrası bin/targets/qualcommbe/ipq53xx → buraya kopyalanır)
- `*-initramfs-uImage.itb` → **RAM boot / test (önerilen)**
- `*-uImage.itb` → FIT kernel
- `*-squashfs-factory.bin` → UBI factory (build sonrası hesaplanır)
- `*-squashfs-sysupgrade.bin`

## Boot / test (RAM only)
```
UART GPIO18/19 @115200 8N1 → U-Boot (IPQ5332# prompt)
setenv serverip 192.168.1.100
setenv ipaddr 192.168.1.1
tftpboot 0x46000000 openwrt-...-initramfs-uImage.itb
bootm 0x46000000
```
> ⛔ 0x44000000 kullanma (bootm çakışması). RAM boot NAND'a dokunmaz.

## Doğrulama (boot sonrası)
1. `cat /proc/device-tree/compatible` + `dmesg | grep -i socinfo` → **IPQ5322** teyidi.
2. `dmesg | grep -i "mdio\|phy\|qca8084"` → PHY'ler (PORT1-3=LAN, PHY1=WAN).
3. `dmesg | grep -i ath12k\|board-2\|bdf` → Wi-Fi BDF yüklendi mi.
4. `ip link` → MAC'ler ART'tan geliyor mu (ART read-only).
5. `iwinfo` / `iw dev` → on-SoC 2.4/5 + QCN6274 6 GHz radyolar.

## Bilinen sınırlar
- QCA8084'ün **switch** olarak mainline DSA sürücüsü yok (QCA8386 gibi). İlk hedef:
  UART + Wi-Fi + 4× PHY link up. LAN switch/bridge için ayrı DSA driver işi gerekir.
- Wi-Fi BDF (board-id 0x16 / 0x1015) donanım doğrulaması sonrası netleşir.
