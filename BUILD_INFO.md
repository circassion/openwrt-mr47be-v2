# BUILD_INFO — Mercusys MR47BE V2 OpenWrt (test4)

> **Son güncelleme:** 2026-08-28  
> **İmaj:** test4 (hardware-compatible revision)  
> **Durum:** Deneysel / Build tamamlandı, yapısal doğrulama yapıldı

Bu dosya, test4 imajını yeniden oluşturmak isteyecek geliştiriciler için gerekli build bilgilerini içerir.

---

## ⚠️ ÖNEMLİ: Donanım Gerçekleri (test1/2/3'ten farklı)

| Bileşen | Eski Varsayım (test1-3) | **Gerçek (test4)** |
|---|---|---|
| **SoC** | IPQ5332 ❌ | **IPQ5322** ✅ (foto kanıtlı: "IPQ5322 003 FK5134HJ") |
| **Ethernet** | QCA8386 harici switch ❌ | **QCA8084** (SoC'ya entegre, ayrı çip YOK) ✅ |
| **6 GHz radio** | QCN9224 ❌ | **QCN6274** ✅ (foto kanıtlı) |
| **Bootloader string** | IPQ5332LA = SoC ❌ | IPQ5332LA = BSP compiler string'i, donanım okuması DEĞİL |

> **Not:** DTS dosya adı hala `ipq5332-*` olarak devam ediyor çünkü IPQ5322 ve IPQ5332 aynı Miami ailesidir ve DTS uyumludur. `compatible = "qcom,ipq5332"` kullanılması gerekiyor.

---

## Build Ortamı

- **İşletim Sistemi:** WSL2 Ubuntu-24.04
- **Build yolu:** `/root/mr47be-clean`
- **OpenWrt branch:** main (qualcommbe target)
- **Kernel:** 6.18.48 (KERNEL_PATCHVER:=6.18)

---

## Kritik Dosyalar

### 1. Device Tree Source (DTS)

**Dosya:** `target/linux/qualcommbe/dts/ipq5332-mercusys-mr47be-v2.dts`

> ⚠️ **BUILD HATASI NOTU:** Build sistemi DTS'i `ipq5332-mr47be-v2.dts` (mercusys- olmadan) adıyla arar.  
> `DEVICE_DTS` türetmesi: `mercusys_mr47be-v2` → `ipq5332-mr47be-v2`  
> Bu yüzden dosyayı bu İKİ adla da yerleştirin veya symlink kullanın.

**MD5:** `90bdb8049caf8de759cc33bbbc262afc` (doğrulama için)

**DTS İçeriği (özet):**
```
SoC: Qualcomm IPQ5322 (4x Cortex-A53, 1 GiB DDR4)
WiFi: 
  - wifi0: on-SoC 2.4GHz, qcom,board-id = 18 (0x12)
  - wifi2: QCN6274 PCIe1 üzerinden, qcom,board-id = 0x1015, pci17cb,1109
Ethernet: QCA8084 (SoC'ya entegre switch-PHY, 4x 2.5G)
Flash: SPI-NAND Winbond W25N01GW 128MiB
UART: GPIO18/19 @ 115200 8N1
LED: gpio-leds (sys-green, sys-orange, wan, lan1, lan2, lan3)
Button: gpio-keys (reset)
```

**Include:** `#include <arm64/qcom/ipq5332.dtsi>`

**Compatible:** `"mercusys,mr47be-v2", "qcom,ipq5332-ap-mi01.6", "qcom,ipq5332"`

---

### 2. Image Makefile (ipq53xx.mk)

**Dosya:** `target/linux/qualcommbe/image/ipq53xx.mk`

```makefile
define Device/mercusys_mr47be-v2
	$(call Device/FitImage)
	$(call Device/UbiFit)
	DEVICE_VENDOR := Mercusys
	DEVICE_MODEL := MR47BE V2
	DEVICE_ALT0_VENDOR := Mercusys
	DEVICE_ALT0_MODEL := MR47BE
	DEVICE_DTS_CONFIG := config@mi01.6
	SOC := ipq5332
	SUPPORTED_DEVICES += mercusys,mr47be-v2
	BLOCKSIZE := 128k
	PAGESIZE := 2048
	KERNEL_INSTALL := 1
	KERNEL_SIZE := 6096k
	IMAGE_SIZE := 54016k
	IMAGES += factory.bin
	IMAGE/factory.bin := append-ubi
	DEVICE_PACKAGES := kmod-ath12k ath12k-firmware-ipq5332 \
		ath12k-firmware-qcn9274 ipq-wifi-mercusys_mr47be-v2 \
		kmod-qrtr-smd ethtool dumpimage kmod-phy-qca83xx \
		kmod-usb-core kmod-usb2 kmod-usb3 kmod-usb-dwc3 \
		kmod-usb-dwc3-qcom kmod-usb-xhci-hcd kmod-scsi-core \
		kmod-usb-storage kmod-usb-storage-uas kmod-fs-ext4 \
		block-mount blockd usbutils
endef
TARGET_DEVICES += mercusys_mr47be-v2
```

**Anahtar Noktalar:**
- `DEVICE_DTS_CONFIG := config@mi01.6` — Stock U-Boot bu config'i arar
- `kmod-phy-qca83xx` — QCA8084 için gerekli (QCA83xx family driver)
- `ath12k-firmware-qcn9274` — QCN6274 radio firmware

---

### 3. Network Config (02_network)

**Dosya:** `target/linux/qualcommbe/ipq53xx/base-files/etc/board.d/02_network`

```bash
mercusys,mr47be-v2)
	ucidef_set_interfaces_lan_wan "lan" "wan"
	wan_mac=$(mtd_get_mac_binary "0:art" 0x0)
	if [ -n "$wan_mac" ]; then
		lan_mac=$(macaddr_add "$wan_mac" 1)
		ucidef_set_network_device_mac "wan" "$wan_mac"
		ucidef_set_network_device_mac "lan" "$lan_mac"
		ucidef_set_interface_macaddr "wan" "$wan_mac"
		ucidef_set_interface_macaddr "lan" "$lan_mac"
		ucidef_set_label_macaddr "$wan_mac"
	fi
	;;
```

> **Not:** MAC adresi ART partition'dan okunur (nvmem-layout).

---

### 4. Kernel Config (config-default)

**Dosya:** `target/linux/qualcommbe/ipq53xx/config-default`

Kritik seçenekler:
```
CONFIG_IPQ_GCC_5332=y
CONFIG_IPQ_NSSCC_5332=y
CONFIG_PINCTRL_IPQ5332=y
CONFIG_QCA83XX_PHY=y
CONFIG_NET_DSA_QCA8K=y
CONFIG_SPI_QPIC_SNAND=y
CONFIG_MTD_SPI_NAND=y
CONFIG_PHY_QCOM_UNIPHY_PCIE_28LP=y
CONFIG_PHY_QCOM_M31_USB=y
CONFIG_INTERCONNECT_QCOM_OSM_L3=y
CONFIG_REGULATOR_CPR4_APSS=y
```

---

### 5. Board WiFi Firmware (ipq-wifi)

**Kaynak:** `package/firmware/ipq-wifi/src/`

| Dosya | Boyut | Açıklama |
|---|---|---|
| `board-mercusys_mr47be-v2.ipq5332` | 89,292 bytes | on-SoC WiFi BDF |
| `board-mercusys_mr47be-v2.qcn9274` | 126,156 bytes | QCN6274 BDF |

**Makefile:** `package/firmware/ipq-wifi/Makefile`
```makefile
$(eval $(call generate-ipq-wifi-package,mercusys_mr47be-v2,Mercusys MR47BE V2))
```


### 6. Kernel Patches (patches-6.18/)

**Toplam:** 113 patch

Kritik patch'ler:
- `0301-0308` — QCA8084 PHY desteği (SerDes, init, probe)
- `0313-0324` — PCS/IPQ9574 desteği (USXGMII, 2500BASEX)
- `0325-0336` — PPE/EDMA Ethernet scheduler ve DMA desteği
- `0343-0351` — IPQ9574 PPE/EDMA DTS node'ları
- `0352-0355` — NSS clock düzeltmeleri

---

## Build Adımları

### Hazırlık

```bash
# 1. Temiz OpenWrt klonu
git clone https://git.openwrt.org/openwrt/openwrt.git mr47be-clean
cd mr47be-clean

# 2. MR47BE V2 dosyalarını yerleştir
#    - DTS: target/linux/qualcommbe/dts/ipq5332-mercusys-mr47be-v2.dts
#    - ipq53xx.mk: target/linux/qualcommbe/image/ipq53xx.mk
#    - config-default: target/linux/qualcommbe/ipq53xx/config-default
#    - 02_network: target/linux/qualcommbe/ipq53xx/base-files/etc/board.d/02_network
#    - board files: package/firmware/ipq-wifi/src/board-mercusys_mr47be-v2.*
#    - patches: target/linux/qualcommbe/patches-6.18/*

# 3. Feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 4. Config
make defconfig
```

### Derleme

```bash
# Toolchain dahil tam derleme (4 çekirdekte ~3-5 saat)
make -j4 V=s 2>&1 | tee build.log
```

### Çıktı

```
bin/targets/qualcommbe/ipq53xx/
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.ubi
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-sysupgrade.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2.manifest
└── sha256sums
```


---

## Boot (UART → TFTP)

```
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000
```

**UART:** GPIO18(TX)/GPIO19(RX) @ 115200 8N1  
**Boot adresi:** `0x46000000` (0x44000000 çakışır, kullanmayın)  
**Secure Boot:** Kapalı → imzasız imaj boot edilebilir

---

## Paket Listesi (test4 manifest)

| Paket | Sürüm |
|---|---|
| kernel | 6.18.39 |
| kmod-ath12k | 6.18.39.7.2_rc4 |
| ath12k-firmware-ipq5332 | 1 |
| ath12k-firmware-qcn9274 | 20260622-r1 |
| ipq-wifi-mercusys_mr47be-v2 | 2026.05.18 |
| wireless-regdb | 2026.05.30 |
| kmod-phy-qca83xx | 6.18.39-r1 |
| kmod-qcom-ppe | 6.18.39-r1 |
| kmod-pcs-qcom-ipq9574 | 6.18.39-r1 |
| busybox | 1.38.0-r2 |
| dropbear | 2026.92-r1 |
| dnsmasq | 2.93-r2 |
| firewall4 | 2025.03.17 |

---

## Bilinen Sınırlamalar

- **QCA8084:** Mainline OpenWrt'ta DSA sürücüsü yok. İlk hedef: UART + Wi-Fi + PHY link up.
- **Wi-Fi BDF:** Geçici, donanım doğrulaması gerekli.
- **LED/GPIO/USB:** Test bekliyor.
- **NAND flash:** Üretim hazır değil.
- **Stock recovery:** RSA imza doğrulaması var, `_nosign` firmware kabul etmez.

---

## Referanslar

- [RELEASE_NOTES_v0.1.0-test4.md](../RELEASE_NOTES_v0.1.0-test4.md)
- [V2_HARDWARE_STATUS.md](../V2_HARDWARE_STATUS.md)
- [LIVE_SESSION_STATE.md](../LIVE_SESSION_STATE.md)
- [OpenWrt qualcommbe target](https://openwrt.org/docs/techref/targets/qualcommbe)


---

## 📚 Test Geçmişi ve Dersler (Bilgi Amaçlı)

> Bu bölüm, test4 build sürecinde yaşanan hatalardan çıkan dersleri içerir. Biri yeniden build yapmak isterse bu bilgiler işe yarar.

### TEST4 — Temiz Build (2026-08-28 — ROUND 3 Tamamlandı)

- ✅ Build ROUND 3 canlı: WSL `/root/mr47be-clean`
- ✅ missing-macros geçti (round 1/2'nin öldüğü nokta)
- ✅ Toolchain bitti → imaj üretimi başladı
- ❌ ROUND 1 crash: `missing-macros/bin/*` eksikti
- ❌ ROUND 2: 0-byte log (nohup + anında oturum kapanması — setsid ile çözüldü)
- ❌ ROUND 3 crash: DTS ismi sorunu (aşağıda çözüldü)

### 🐛 Ders 1: rsync `--exclude=bin` Tuzakları

**Sorun:** rsync `--exclude=bin` (anchor'sız) ağaçtaki TÜM `bin/` klasörlerini silmiş (tools/missing-macros/src/bin dahil).

**Çözüm:** Anchored `--exclude=/build_dir /staging_dir /tmp /.ccache /bin /logs` kullan. Parite testi: SRC = DST dosya sayısı (birebir).

### 🐛 Ders 2: `nohup make &` Tek Başına Yeterli Değil

**Sorun:** `nohup make &` sonrası WSL oturumu ANINDA kapanırsa make ilk çıktıyı yazamadan ölür (0-byte log).

**Çözüm:** `setsid nohup make ... &` + aynı komutta `sleep 12` canlı-doğrulama.

### 🐛 Ders 3: WSL Arka-plan Daemonları

**Sorun:** WSL arka-plan watcher daemon'ları oturum kapanında ölür; make yaşar.

**Çözüm:** Güvenilir izleme = dışarıdan periyodik probe + log kopyala-analiz.

### 🐛 Ders 4: DTS İsim Türetmesi (En Kritik)

**Sorun:** Build sistemi DTS'i `ipq5332-mr47be-v2.dts` (mercusys- olmadan) adıyla arar. `DEVICE_DTS` türetmesi: `mercusys_mr47be-v2` → `ipq5332-mr47be-v2`.

**Çözüm:** DTS dosyasını İKİ adla da yerleştirin veya symlink kullanın:
```bash
# Yöntem 1: Kopyala
cp ipq5332-mercusys-mr47be-v2.dts ipq5332-mr47be-v2.dts

# Yöntem 2: Symlink
ln -s ipq5332-mercusys-mr47be-v2.dts ipq5332-mr47be-v2.dts
```

### Build Komutu (Tekrar İçin)

```bash
# 1. Temiz kurulum
bash /root/setup_clean.sh setup

# 2. Build (setsid + nohup + log)
cd /root/mr47be-clean
setsid nohup make -j4 V=s > /root/mr47be-clean-build.log 2>&1 < /dev/null &

# 3. İzleme (aynı komutta sleep 12 canlı-doğrulama)
```

### Çıktı

```
bin/targets/qualcommbe/ipq53xx/
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.ubi
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-sysupgrade.bin
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-uImage.itb
├── openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2.manifest
└── sha256sums
```

### Boot (UART → TFTP)

```bash
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000
```

**UART:** GPIO18(TX)/GPIO19(RX) @ 115200 8N1
**Boot adresi:** `0x46000000` (0x44000000 çakışır, kullanmayın)
**Secure Boot:** Kapalı → imzasız imaj boot edilebilir

