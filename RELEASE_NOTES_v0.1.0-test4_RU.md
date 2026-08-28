MR47BE V2 OpenWrt v0.1.0-test4 (аппаратная совместимость, ревизия)
Статус сборки: ✅ ЗАВЕРШЕНО (2026-08-29 01:47, чистое дерево /root/mr47be-clean, make -j4 EXIT 0)
Цель: Исправить НЕПРАВИЛЬНЫЕ предположения об оборудовании в test1/2/3 (отдельный чип QCA8386, IPQ5332) и обеспечить совместимость с реальным оборудованием: IPQ5322 (встроенный QCA8084 4×2.5G) + QCN6274 (PCIe 6 GHz).
⚠️ ЭКСПЕРИМЕНТАЛЬНО — ЗАПИСЬ В NAND. UART → U-Boot → TFTP → initramfs-uImage.itb (только ОЗУ).

Почему test4 (Почему test1/2/3 были неверными)
    
      Предположение (test1-3)
      Реальность (фото + лог загрузки UART)
        
      SoC = IPQ5332
      ❌ Физический SoC = IPQ5322 (фото IPQ5322 003 FK5134HJ)
        
      Ethernet = отдельный чип коммутатора QCA8386
      ❌ НЕТ QCA8386. Лог загрузки: eth0 PHY0 QCA8084-switch
        
      —
      Ethernet = QCA8084 switch-PHY — ВСТРОЕН в SoC IPQ53xx (LAN PORT1..3 + WAN PHY1, 4× 2.5G). Доказательства: GPL U-Boot ipq_qca8084.c:1472 + внутренний MDIO + фото
        
      Неизвестно, что Secure Boot отключен
      ✅ Secure Boot: Off (возможна загрузка в ОЗУ без подписи)
  
ℹ️ PORT1 Up :100 в логе загрузки = Текущая скорость автосогласования через TP-Link 740N (100 Мбит/с); порты поддерживают 2.5G (основное доказательство: QCA8084-switch).

Финальный DTS (проверено)
Источник: дерево openwrt/ git (коммит cb2d2ab) → ipq5332-mercusys-mr47be-v2.dts
md5 90bdb804caf8de759cc33bbbc262afc — точное совпадение с корнем проекта / tmp_build / дерево сборки
Ожидаемое имя сборки: ipq5332-mr47be-v2.dts (производное от DEVICE_DTS). setup_clean.sh постоянно исправлен: DTS + cmp защита для обоих имен (FATAL_DTS_NAME).
Содержимое DTS: QCA8084 phy@1..4 + сброс gpio16, PPE xgmac1=LAN (2500base-x fixed-link), xgmac2=WAN (phy3), раздел NAND A/B (nand-partition.xml точное совпадение, ART @0x900000 только для чтения), wifi0 q6 (board-id 18), PCIe QCN6274 pci17cb,1109 (board-id 0x1015).
Образы (в этой папке) — sha256
   
      Файл
      sha256
      Описание
        
      openwrt-...-mercusys_mr47be-v2-initramfs-uImage.itb
      944038f9748b81d3b8ba14e24b6315eb25821b38969676ee0b867e01da658069
      Загрузка в ОЗУ / тест (рекомендуется) · md5 c71c879e…
        
      openwrt-...-mercusys_mr47be-v2-uImage.itb
      90ea66713b799fabbdcc4aa8c69e021905d6db8dd2f6c27af89d68067a2a9cce
      FIT ядро
        
      openwrt-...-mercusys_mr47be-v2-squashfs-factory.bin
      a574f95b86f2da82f145c23f95f86dfd6587691ff5b9d7c7f2b582e939e388db
      UBI factory
        
      openwrt-...-mercusys_mr47be-v2-squashfs-factory.ubi
      a574f95b86f2da82f145c23f95f86dfd6587691ff5b9d7c7f2b582e939e388db
      UBI factory (сырой)
        
      openwrt-...-mercusys_mr47be-v2-squashfs-sysupgrade.bin
      0bd575ff5a3d19160b4d22476971e42b73f25cda5f7f405fbc6aaffc3e601df2
      sysupgrade

Файлы sha256sums + .manifest также находятся в этой папке.
Покрытие оборудования, проверенное в сборке (из rootfs)
lib/firmware/ath12k/IPQ5332/hw1.0/ → q6_fw0 (on-SoC 2.4/5), q6_fw1 + iu_fw, Data.msc, regdb.bin ✅
lib/firmware/ath12k/QCN9274/hw2.0/board-2.bin → QCN6274 BDF (пакет ipq-wifi mercusys_mr47be-v2) ✅
lib/modules/6.18.39/ → ath12k.ko, ath12k_wifi7.ko, qrtr.ko, qrtr-smd.ko, qrtr-mhi.ko ✅
etc/board.d/02_network → mercusys,mr47be-v2: lan/wan + MAC 0:art ✅
FIT config@mi01.6 + DTB ipq5332-mr47be-v2.dtb (QCA8084 phy@1..4, 2500base-x, fixed-link, pci17cb,1109, 0:art, rootfs_1; qca8386: 0) ✅
Загрузка / Тест (только ОЗУ)

UART GPIO18/19 @115200 8N1 → U-Boot (приглашение IPQ5332#)
setenv serverip 192.168.1.100
setenv ipaddr 192.168.1.1
tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
bootm 0x46000000

⛔ Не используйте 0x44000000 (конфликт bootm). Загрузка в ОЗУ не затрагивает NAND.

Проверка (после загрузки)
cat /proc/device-tree/compatible + dmesg | grep -i socinfo → Подтверждение IPQ5322.
dmesg | grep -i "mdio\|phy\|qca8084" → PHY (PORT1-3=LAN, PHY1=WAN).
dmesg | grep -i ath12k\|board-2\|bdf → Статус Wi-Fi BDF.
ip link → MAC-адреса из ART?
iwinfo / iw dev → Радио на SoC 2.4/5 + QCN6274 6 GHz.
Известные ограничения (открытые задачи)
⚠️ etc/hotplug.d/firmware/12-ath12k-caldata: Нет записи Mercusys (только gl-be6500/9300).
BDF QCN6274 берется из пакета ipq-wifi board-2.bin; BDF на SoC (Q6) считывается из ART через qcom,bdf-address-offset.
Если BDF не загружается в логе загрузки, этот скрипт нужно дополнить, чтобы добавить извлечение ART для mercusys,mr47be-v2 (смещения: уточняются через mii read/dmesg с дампом ART).
Отсутствует основной драйвер коммутатора DSA для QCA8084. Первоначальная цель: UART + Wi-Fi + 4× подключение PHY; LAN коммутатор/мост — отдельная задача DSA.
BDF Wi-Fi (board-id 0x16 / 0x1015) будет окончательно определен после аппаратной проверки.
