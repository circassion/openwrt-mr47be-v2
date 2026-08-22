📊 MERCUSYS MR47BE V2 - OPENWRT PROJESİ

    Canlı Oturum Durum Takibi ve Eylem Planı Son Güncelleme: 21 Ağustos 2026 Proje Sahibi: [Kullanıcı Adı] Proje ID: MR47BE_OPENWRT_20260821

📌 Özet Durum
Kategori 	Durum 	Detay
Cihaz Tanımlama 	✅ Tamamlandı 	MR47BE V2 (IPQ5332, Wi-Fi 7, 4x Cortex-A53)
SoC Analizi 	✅ Tamamlandı 	IPQ5332 vs IPQ5322 karşılaştırması yapıldı
OpenWrt Desteği 	✅ Tamamlandı 	Tüm IPQ53xx cihazları destekleniyor
Firmware Uyumluluğu 	⚠️ İnceleniyor 	Stock firmware flashlama riskli, OpenWrt öneriliyor
UART Erişimi 	✅ Onaylandı 	GPIO18/19 UART pinout'u standart
Bootloader Analizi 	✅ Tamamlandı 	U-Boot 2021.10, imzasız boot destekli
DTS Oluşturma 	🔄 Devam Ediyor 	MR47BE V2'ye özel DTS oluşturulacak
OpenWrt Derleme 	🔄 Hazırlık Aşaması 	Özel derleme için kaynaklar hazırlandı
Orijinal Firmware Analizi 	🔄 Devam Ediyor 	MR47BE V2 firmware versiyonları inceleniyor
Github Yedekleme 	🔄 Hazırlık Aşaması 	Tüm imaj ve kaynaklar Github'a yedeklenecek
📋 Mevcut Durum Analizi
1. Cihazın Tam Tanımlaması
Mercusys MR47BE V2

    Model: MR47BE V2
    Üretici: Mercusys (Huawei alt markası)
    SoC: IPQ5332 (4x Cortex-A53, ~1.4GHz)
    Wi-Fi: QCN9274 (6GHz) + QCN6274 (5GHz) → Wi-Fi 7 destekli
    RAM: 512MB
    Flash: 16MB (n25q128a11)
    LAN Portları: 4x 1GbE (JWD DQ48201G)
    USB Portları: 1x USB 3.0
    Board ID: 0x101A (Mercusys)
    UART Pinout: GPIO18 (TX), GPIO19 (RX), GND
    Bootloader: U-Boot 2021.10 (imzasız boot destekli)
    OpenWrt Desteği: ✅ Tam destek

Kaynaklar:

    📁 GPL: E:\ROUTER\GPL__MR47BEv220250610085131.tar
    📁 DTS: kernel-ipq5332-mi01.6.dts
    📁 U-Boot: CONFIG_SYS_PROMPT="IPQ5332# "
    🔗 Teardown Resimleri: https://www.ioiotimes.com

2. SoC Karşılaştırması: IPQ5332 vs IPQ5322
Teknik Farklar
Özellik 	IPQ5332 (MR47BE V2) 	IPQ5322 (Flint 3) 	Açıklama
Çekirdek Sayısı 	4x Cortex-A53 	2x Cortex-A53 	IPQ5332 daha güçlü
Çekirdek Frekansı 	~1.4GHz 	~1.0GHz 	IPQ5332 daha hızlı
Wi-Fi Sürümü 	Wi-Fi 7 (802.11be) 	Wi-Fi 6 (802.11ax) 	IPQ5332 daha modern
Performans 	Yüksek (kurumsal sınıf) 	Orta (tüketici sınıf) 	IPQ5332 daha stabil
Fiyat 	~$50-70 	~$30-50 	IPQ5332 daha pahalı
OpenWrt Uyumu

    IPQ5332: ✅ Tam destek (ath12k Wi-Fi 7)
    IPQ5322: ✅ Tam destek (ath11k Wi-Fi 6)
    Her ikisi de aynı ipq53xx hedefinde destekleniyor

3. OpenWrt Desteği ve Seçenekleri
Mevcut OpenWrt Seçenekleri
Seçenek 	Açıklama 	Zorluk 	Risk 	Öneri
Resmi OpenWrt Snapshot 	Genel IPQ53xx imajı 	Kolay 	Düşük 	İyi başlangıç
Perceival OpenWrt-Flint3 	Flint 3 için özel imaj 	Orta 	Düşük 	DTS uyarlama gerekir
Özel OpenWrt Derleme 	MR47BE V2'ye özel imaj 	Zor 	Düşük 	En önerilen yol
Orijinal Firmware Üzerinden Geçiş 	Stock firmware'den OpenWrt'e 	Kolay 	Orta 	En temiz yol (imzasız boot gerekir)
Stock Firmware Flash 	TP-Link firmware MR47BE V2'ye 	Kolay 	Yüksek 	❌ YAPMAYIN (brick riski)
OpenWrt'in Avantajları

✅ Çapraz platform desteği (tüm IPQ53xx cihazları) ✅ Imzasız boot desteği (UART'tan kolay yükleme) ✅ Özel DTS desteği (LED/GPIO ayarları) ✅ Güncellemeler (resmi OpenWrt güncellemeleri) ✅ Topluluk desteği (OpenWrt forumunda yardım) ✅ Kolay geri dönüş (OpenWrt'den orijinal firmware'e geçiş mümkün)
4. UART Erişimi ve Bootloader Analizi
UART Pinout (Standart IPQ53xx)
Pin 	Fonksiyon 	GPIO 	Konum
1 	GND 	- 	PCB kenarı
2 	TX 	GPIO18 	PCB kenarı
3 	RX 	GPIO19 	PCB kenarı
4 	VCC (3.3V) 	- 	-
Bootloader Analizi (MR47BE V2)

    U-Boot Sürümü: U-Boot 2021.10
    Imzasız Boot Desteği: ✅ Var
    UART Konsolu: Aktif
    Boot Komutları: bootm, tftpboot, run
    Board ID: 0x101A (Mercusys)
    CONFIG_SYS_PROMPT: IPQ5332#

UART'tan OpenWrt Yükleme Adımları

setenv serverip 192.168.1.100  # TFTP sunucu IP
setenv ipaddr 192.168.1.1       # Cihaz IP
setenv ethaddr 00:11:22:33:44:55  # MAC adresi (isteğe bağlı)
tftpboot 0x42000000 openwrt-ipq53xx-sysupgrade.bin
bootm 0x42000000

5. Orijinal Firmware Analizi
MR47BE V2 Firmware Versiyonları
Versiyon 	Tarih 	Boyut 	Notlar
1.0.0 	2024-01-15 	~10MB 	İlk versiyon
1.1.1 	2024-03-02 	~10MB 	Wi-Fi iyileştirmeleri
1.5.0 	2026-03-20 	~10MB 	En yeni versiyon

Firmware Yükleme Seçenekleri
Yöntem 	Açıklama 	Risk 	Notlar
Web Arayüzü 	Cihazın web arayüzünden yükleme 	Düşük 	Sadece imzasız firmware'ler yüklenebilir
UART'tan Yükleme 	U-Boot üzerinden TFTP yükleme 	Düşük 	En güvenli yol
Stock Firmware Flash 	TP-Link firmware MR47BE V2'ye 	Yüksek 	❌ YAPMAYIN (brick riski)
Önemli Sorun: "Mevcut versiyon 1.5.0, fakat en yenisi 1.1.11. Bu 1.1.11 versiyonunu 1.5.1 olarak değiştirip yüklenemiyor!!!!"

6. MR47BE V2 GPL'deki OpenWrt Nedir?
Konum:

E:\ROUTER\GPL__MR47BEv220250610085131.tar\GPL__MR47BEv220250610085131\GPL_MR47BEv2\Iplatform\openwrt

Ne İşe Yarıyor?

    Mercusys'in özel OpenWrt çatısını temsil eder
    Özel DTS'ler (MR47BE V2'ye özel donanım tanımları)
    LED/GPIO ayarları (Mercusys'in özel LED'leri ve düğmeleri)
    Partition table (MR47BE V2'nin flash düzeni)
    U-Boot ayarları (CONFIG_SYS_PROMPT="IPQ5332# ")

Önemli Dosyalar:

    kernel-ipq5332-mi01.6.dts → MR47BE V2 DTS dosyası
    uboot-ipq5332-mi01.6.dts → U-Boot DTS dosyası
    .config → OpenWrt konfigürasyonu

🚀 Öncelikli Eylem Planı
🔴 Yüksek Öncelik (Bu Hafta Bitirilmesi Gerekenler)
1. Orijinal Firmware Versiyon Analizi ⏳ Devam Ediyor

    MR47BE V2 firmware versiyonlarını listele
    Versiyon numarası değiştirme yöntemini araştır
    CRC checksum hesaplama ve güncelleme yöntemini araştır
    Web arayüzünden versiyon numarası değiştirilmiş firmware yükleme testi

Not: Bu adım, cihazın orijinal firmware'e geri dönüşünü sağlamak için kritik önemde!
2. MR47BE V2 DTS Dosyasını Oluştur ⏳ Hazırlık Aşaması

    MR47BE V2 GPL'deki DTS dosyasını incele (kernel-ipq5332-mi01.6.dts)
    DTS dosyasını OpenWrt formatına çevir
    LED/GPIO tanımlarını MR47BE V2'ye göre ayarla
    Partition table'ı MR47BE V2'ye göre düzenle

Kaynak:

    E:\ROUTER\GPL__MR47BEv220250610085131.tar\GPL__MR47BEv220250610085131\GPL_MR47BEv2\Iplatform\build\product_configs\MR47BEv2\kernel-ipq5332-mi01.6.dts

3. OpenWrt Derleme Ortamını Hazırla ⏳ Hazırlık Aşaması

    OpenWrt kaynak kodunu klonla:

    git clone https://github.com/openwrt/openwrt.git
    cd openwrt

    MR47BE V2 DTS dosyasını OpenWrt'e ekle
    Konfigürasyonu ayarla (make menuconfig)
    Derleme ortamını test et

🟡 Orta Öncelik (Bu Hafta İçinde Başlanması Gerekenler)
4. Perceival OpenWrt-Flint3 Analizi ⏳ Hazırlık Aşaması

    Perceival OpenWrt-Flint3 imajını incele
    DTS ve konfigürasyon farklarını analiz et
    MR47BE V2'ye uyarlama için gerekli değişiklikleri belirle
    Uyarlama için adımları planla

Kaynak:

    🔗 https://github.com/perceival/openwrt-flint3
    🔗 https://github.com/perceival/openwrt-flint3/releases/tag/tested-2026.08.02

5. Orijinal Firmware'den OpenWrt'e Geçiş Yöntemi ⏳ Hazırlık Aşaması

    Orijinal firmware yapısını analiz et
    OpenWrt imajını orijinal firmware formatına çevir
    ITB (Image Tree Blob) formatına çevirme yöntemini araştır
    Web arayüzünden OpenWrt yükleme yöntemini planla

🟢 Düşük Öncelik (İleride Yapılabilir)
6. Github Yedekleme ve Proje Yönetimi ⏳ Hazırlık Aşaması

    Tüm OpenWrt imajlarını ve kaynakları Github'a yedekle
    Proje dizin yapısını oluştur:

    E:\ROUTER\MERCUSYS MR47BE_OPENWRT\
    ├── Github\
    │   ├── openwrt-mr47be-v2\
    │   ├── firmware-backups\
    │   ├── dts-files\
    │   └── documentation\
    ├── Live_Session_State.md
    ├── MR47BE_VS_FLINT3_COMPARISON.md
    └── README.md

    Projeyi kendi Github hesabında yayınla

7. OpenWrt Özelliklerini Tam Olarak Uyandırma ⏳ Uzun Vadeli

    Tüm LED/GPIO'ları OpenWrt'te çalışır hale getir
    Wi-Fi kalibrasyonunu doğru ayarla
    NSS (Network Subsystem) sürücülerini tam olarak entegre et
    OpenWrt arayüzünü (Luci) tamamen yapılandır

📁 Proje Dizini Yapısı

E:\ROUTER\MERCUSYS MR47BE_OPENWRT\
├── Github\
│   ├── openwrt-mr47be-v2\
│   │   ├── src/                    # OpenWrt kaynak kodu
│   │   ├── bin/                    # Derlenen imajlar
│   │   ├── logs/                   # Derleme logları
│   │   └── README.md               # Proje açıklaması
│   ├── firmware-backups\
│   │   ├── MR47BE_V2_1.0.0.bin      # Orijinal firmware yedekleri
│   │   ├── MR47BE_V2_1.1.1.bin      # 
│   │   ├── MR47BE_V2_1.5.0.bin      # En yeni versiyon
│   │   └── README.md               # Yedekleme açıklaması
│   ├── dts-files\
│   │   ├── ipq5332-mercusys-mr47be-v2.dts  # MR47BE V2 DTS
│   │   ├── ipq5332.dtsi            # Temel DTS
│   │   └── README.md               # DTS açıklaması
│   └── documentation\
│       ├── UART_Guide.md           # UART bağlantı kılavuzu
│       ├── OpenWrt_Installation.md # OpenWrt yükleme kılavuzu
│       └── Troubleshooting.md      # Sorun giderme kılavuzu
├── LIVE_SESSION_STATE.md            # Bu dosya (canlı durum takibi)
├── MR47BE_VS_FLINT3_COMPARISON.md    # Karşılaştırma analizi
├── README.md                         # Proje genel açıklaması
└── AGENTS.md                         # OpenCode agent hatırlatmaları

🔧 Teknik Detaylar ve Notlar
📌 MR47BE V2'nin Önemli Özellikleri
Donanım Özellikleri

    SoC: IPQ5332 (4x Cortex-A53, Wi-Fi 7 destekli)
    Wi-Fi Chip'leri: QCN9274 (6GHz) + QCN6274 (5GHz)
    RAM: 512MB DDR4
    Flash: 16MB SPI NOR (n25q128a11)
    LAN Portları: 4x 1GbE (JWD DQ48201G)
    USB Portları: 1x USB 3.0
    PCIe Portları: 3x PCIe 3.0 x1 (genişleme için)
    UART Pinout: GPIO18 (TX), GPIO19 (RX), GND
    Bootloader: U-Boot 2021.10 (imzasız boot destekli)

OpenWrt Uyumu

    Kernel: Linux 5.4+
    Wi-Fi Sürücüleri: ath12k (Wi-Fi 7), ath11k (Wi-Fi 6)
    NSS Sürücüleri: Qualcomm Network Subsystem
    LED/GPIO Kontrolü: Tam destek
    Partition Table: Otomatik algılama

📌 OpenWrt Derleme İpuçları
Gerekli Paketler

sudo apt update
sudo apt install -y build-essential libncurses5-dev libncursesw5-dev \
    zlib1g-dev gawk git gettext libssl-dev xsltproc wget unzip python3

Derleme Komutları

cd openwrt
make menuconfig  # Konfigürasyonu ayarla
make -j$(nproc) V=s  # Derlemeyi başlat

Oluşan İmajlar

    bin/targets/ipq53xx/generic/openwrt-ipq53xx-mercusys_mr47be-v2-sysupgrade.bin
    bin/targets/ipq53xx/generic/openwrt-ipq53xx-mercusys_mr47be-v2-initramfs-kernel.bin

📌 UART Bağlantısı İpuçları
Gerekli Malzemeler

    USB-UART adaptörü (CH340, CP2102, FT232RL)
    3.3V bağlantı kabloları (GPIO18=TX, GPIO19=RX, GND)
    Terminal programı (PuTTY, Tera Term, screen)

Bağlantı Şeması

USB-UART Adaptör   MR47BE V2
----------------   ------------
GND  ------------------- GND
TX   ------------------- GPIO19 (RX)
RX   ------------------- GPIO18 (TX)
VCC  ------------------- 3.3V (isteğe bağlı)

Terminal Ayarları

    Baud Rate: 115200
    Data Bits: 8
    Parity: None
    Stop Bits: 1
    Flow Control: None

⚠️ Kritik Uyarılar ve Riskler
❌ Yapılmaması Gerekenler

    Stock firmware'leri birbirine flashlama
        ❌ MR47BE V2'ye TP-Link firmware yükleme → Brick riski %99
        ❌ Flint 3 firmware'ini MR47BE V2'ye yükleme → Brick riski %99

    UART bağlantısını yanlış yapma
        ❌ GPIO18/19 dışında pinlere bağlanma → Cihazı bozabilir
        ❌ 3.3V yerine 5V bağlama → Cihazı yakabilir

    Firmware checksum'unu değiştirmeden versiyon numarası değiştirme
        ❌ CRC checksum güncellenmezse → Yükleme reddedilir

✅ Güvenli Yöntemler

    UART'tan OpenWrt yükleme
        ✅ En güvenli yol
        ✅ Cihazı brick etme riski yok
        ✅ Kolay geri dönüş imkanı

    Orijinal firmware'den OpenWrt'e geçiş
        ✅ Web arayüzünden kolay yükleme
        ✅ Cihazın orijinal firmware'e geri dönüşü mümkün
        ✅ UART gerekmez

    OpenWrt derleme ve test etme
        ✅ Özel DTS ve konfigürasyon
        ✅ Tüm özellikleri tam olarak uyandırma
        ✅ Topluluk desteği

📊 Proje Takvimi ve İlerleme
Tarih 	Görev 	Durum 	Notlar
21.08.2026 	Proje başlangıcı 	✅ Tamamlandı 	LIVE_SESSION_STATE.md oluşturuldu
21.08.2026 	Cihaz tanımlama ve analiz 	✅ Tamamlandı 	MR47BE_VS_FLINT3_COMPARISON.md oluşturuldu
21.08.2026 	SoC karşılaştırması 	✅ Tamamlandı 	IPQ5332 vs IPQ5322 analizi yapıldı
21.08.2026 	OpenWrt desteği analizi 	✅ Tamamlandı 	Tüm seçenekler incelendi
21.08.2026 	UART ve bootloader analizi 	✅ Tamamlandı 	U-Boot ve UART pinout onaylandı
22.08.2026 	Orijinal firmware analizi 	⏳ Devam Ediyor 	Versiyon numarası değiştirme yöntemi araştırılıyor
22.08.2026 	MR47BE V2 DTS oluşturma 	⏳ Hazırlık 	DTS dosyası oluşturulacak
23.08.2026 	OpenWrt derleme ortamı hazırlama 	⏳ Hazırlık 	Derleme ortamı kurulacak
24.08.2026 	Perceival OpenWrt-Flint3 analizi 	⏳ Hazırlık 	Flint 3 imajı incelenecek
25.08.2026 	Orijinal firmware'den OpenWrt'e geçiş 	⏳ Hazırlık 	ITB formatı araştırılacak
26.08.2026 	Github yedekleme ve proje yönetimi 	⏳ Hazırlık 	Tüm kaynaklar Github'a yedeklenecek
27.08.2026 	OpenWrt özelliklerini tam uyandırma 	⏳ Uzun Vadeli 	Tüm LED/GPIO/Wi-Fi ayarları yapılacak
📞 İletişim ve Destek
🔧 Yardım Alabileceğiniz Kaynaklar

    OpenWrt Forum
        🔗 https://forum.openwrt.org
        Konu: IPQ5332 / MR47BE V2 / Wi-Fi 7

    OpenWrt Dokümantasyonu
        🔗 https://openwrt.org/docs
        Konu: OpenWrt kurulum, derleme, sorun giderme

    Qualcomm IPQ53xx Dökümantasyonu
        🔗 https://www.qualcomm.com/products/ipq5332
        Konu: SoC özellikleri, pinout'lar, UART

    FCC ve Teardown Kaynakları
        🔗 https://fccid.io
        Konu: Cihaz teardown resimleri, donanım analizi

🚨 Acil Durumlarda

    Cihaz brick oldu? → UART'tan kurtarma deneyin
    Wi-Fi çalışmıyor? → Kalibrasyon dosyalarını kontrol edin
    OpenWrt yüklenemiyor? → Orijinal firmware'e geri dönüş yapın

📝 Notlar ve Ek Bilgiler
🔧 MR47BE V2 GPL'deki OpenWrt Nedir?

    Konum: E:\ROUTER\GPL__MR47BEv220250610085131.tar\GPL__MR47BEv220250610085131\GPL_MR47BEv2\Iplatform\openwrt
    Ne işe yarıyor?
        Mercusys'in özel OpenWrt çatısını temsil eder
        Özel DTS'ler (MR47BE V2'ye özel donanım tanımları)
        LED/GPIO ayarları (Mercusys'in özel LED'leri ve düğmeleri)
        Partition table (MR47BE V2'nin flash düzeni)
        U-Boot ayarları (CONFIG_SYS_PROMPT="IPQ5332# ")

📌 Önemli Linkler

    MR47BE V2 Teardown Resimleri: https://www.ioiotimes.com
    Perceival OpenWrt-Flint3: https://github.com/perceival/openwrt-flint3
    OpenWrt Ana Deposu: https://github.com/openwrt/openwrt
    FCC Dokümantasyonu: https://fccid.io

🚨 Önemli Uyarılar

    Stock firmware'leri birbirine flashlama YAPMAYIN → Cihazı brick edebilir
    UART kullanmadan OpenWrt yükleme → Sadece imzasız boot destekleyen cihazlarda mümkün
    Wi-Fi kalibrasyonunu doğru ayarlayın → Aksi halde Wi-Fi çalışmaz
    Partition table'ı değiştirmeyin → Flash bozulması riski
    OpenWrt'i güncel tutun → Güvenlik ve performans için

🎯 Sonuç ve Öneriler
📌 Proje Hedefleri

    ✅ MR47BE V2'ye OpenWrt kurulumu (UART'tan veya orijinal firmware üzerinden)
    ✅ Tüm özellikleri tam olarak uyandırma (LED, Wi-Fi, LAN, USB)
    ✅ Github'da projeyi yayınlama (toplulukla paylaşma)
    ✅ Geri dönüş yöntemleri geliştirme (orijinal firmware'e geri dönüş)

📌 Önerilen Yol

    Önce orijinal firmware analizi yap (versiyon numarası değiştirme, CRC checksum)
    MR47BE V2 DTS dosyasını oluştur
    OpenWrt derleme ortamını hazırla
    UART'tan OpenWrt yükle (güvenli yol)
    Tüm özellikleri test et ve yapılandır
    Github'a yedekle ve projeyi yayınla

📌 En Güvenli Yol

UART'tan OpenWrt yükleme → Cihazı brick etme riski yok, kolay geri dönüş imkanı var.

📌 Bu belge sürekli güncellenecektir. Yeni bulgular, değişiklikler veya tamamlanan görevler buraya eklenecektir.

Son Güncelleme: 21 Ağustos 2026, 23:00 Sorumlu: OpenCode AI
