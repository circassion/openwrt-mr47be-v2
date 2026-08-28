MR47BE V2 OpenWrt v0.1.0-test4 (Hardware-Compatible Revision)
Build Status: ✅ COMPLETED (2026-08-29 01:47, clean tree /root/mr47be-clean, make -j4 EXIT 0)
Purpose: Correct the INCORRECT hardware assumptions in test1/2/3 
(separate QCA8386 chip, IPQ5332) and ensure compatibility with the actual hardware: 
   IPQ5322 (integrated QCA8084 4×2.5G) + QCN6274 (PCIe 6 GHz).
⚠️ EXPERIMENTAL — WRITING TO NAND. UART → U-Boot → TFTP → initramfs-uImage.itb (RAM only).

Why test4 (Why test1/2/3 were incorrect)
  
      Assumption (test1-3)
      Reality (photo + UART boot log)
        
      SoC = IPQ5332
      ❌ Physical SoC = IPQ5322 (photo IPQ5322 003 FK5134HJ)
        
      Ethernet = separate QCA8386 switch chip
      ❌ NO QCA8386. Boot log: eth0 PHY0 QCA8084-switch
        
      —
      Ethernet = QCA8084 switch-PHY — INTEGRATED into IPQ53xx SoC (LAN PORT1..3 + WAN PHY1, 4× 2.5G). Evidence: GPL U-Boot ipq_qca8084.c:1472 + internal MDIO + photos
        
      Secure boot status was unknown
      ✅ Secure Boot: Off (unsigned RAM boot possible)
    

ℹ️ PORT1 Up :100 in bootlog = Current auto-neg speed via TP-Link 740N (100 Mbps); ports are 2.5G capable (main evidence: QCA8084-switch).

Final DTS Used (Verified)
Source: openwrt/ git tree (commit cb2d2ab) → ipq5332-mercusys-mr47be-v2.dts
md5 90bdb804caf8de759cc33bbbc262afc — exact match with project root / tmp_build / build tree
Expected build name: ipq5332-mr47be-v2.dts (derived from DEVICE_DTS). setup_clean.sh permanently fixed: DTS + cmp guard for both names (FATAL_DTS_NAME).
DTS content: QCA8084 phy@1..4 + reset gpio16, PPE xgmac1=LAN (2500base-x fixed-link), xgmac2=WAN (phy3), NAND A/B partition (nand-partition.xml exact match, ART @0x900000 read-only), wifi0 q6 (board-id 18), PCIe QCN6274 pci17cb,1109 (board-id 0x1015).
Images (in this folder) — sha256
    
      File sha256
      Description
        
      openwrt-...-mercusys_mr47be-v2-initramfs-uImage.itb
      944038f9748b81d3b8ba14e24b6315eb25821b38969676ee0b867e01da658069
      RAM boot / test (recommended) · md5 c71c879e…
        
      openwrt-...-mercusys_mr47be-v2-uImage.itb
      90ea66713b799fabbdcc4aa8c69e021905d6db8dd2f6c27af89d68067a2a9cce
      FIT kernel
       
      openwrt-...-mercusys_mr47be-v2-squashfs-factory.bin
      a574f95b86f2da82f145c23f95f86dfd6587691ff5b9d7c7f2b582e939e388db
      UBI factory
        
      openwrt-...-mercusys_mr47be-v2-squashfs-factory.ubi
      a574f95b86f2da82f145c23f95f86dfd6587691ff5b9d7c7f2b582e939e388db
      UBI factory (raw)
        
      openwrt-...-mercusys_mr47be-v2-squashfs-sysupgrade.bin
      0bd575ff5a3d19160b4d22476971e42b73f25cda5f7f405fbc6aaffc3e601df2
      sysupgrade
    

sha256sums + .manifest files are also in this folder.
Hardware Coverage Verified in Build (from rootfs)
lib/firmware/ath12k/IPQ5332/hw1.0/ → q6_fw0 (on-SoC 2.4/5), q6_fw1 + iu_fw, Data.msc, regdb.bin ✅
lib/firmware/ath12k/QCN9274/hw2.0/board-2.bin → QCN6274 BDF (ipq-wifi mercusys_mr47be-v2 package) ✅
lib/modules/6.18.39/ → ath12k.ko, ath12k_wifi7.ko, qrtr.ko, qrtr-smd.ko, qrtr-mhi.ko ✅
etc/board.d/02_network → mercusys,mr47be-v2: lan/wan + MAC 0:art ✅
FIT config@mi01.6 + DTB ipq5332-mr47be-v2.dtb (QCA8084 phy@1..4, 2500base-x, fixed-link, pci17cb,1109, 0:art, rootfs_1; qca8386: 0) ✅
Boot / Test (RAM only)

UART GPIO18/19 @115200 8N1 → U-Boot (IPQ5332# prompt)
setenv serverip 192.168.1.100
setenv ipaddr 192.168.1.1
tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
bootm 0x46000000

⛔ Do not use 0x44000000 (bootm conflict). RAM boot does not touch NAND.

Verification (Post-Boot)
cat /proc/device-tree/compatible + dmesg | grep -i socinfo → IPQ5322 confirmation.
dmesg | grep -i "mdio\|phy\|qca8084" → PHYs (PORT1-3=LAN, PHY1=WAN).
dmesg | grep -i ath12k\|board-2\|bdf → Wi-Fi BDF status.
ip link → Are MACs coming from ART?
iwinfo / iw dev → on-SoC 2.4/5 + QCN6274 6 GHz radios.
Known Limitations (Open Tasks)
⚠️ etc/hotplug.d/firmware/12-ath12k-caldata: No Mercusys record (only gl-be6500/9300).
QCN6274 BDF comes from ipq-wifi board-2.bin; on-SoC (Q6) BDF is read from ART via qcom,bdf-address-offset.
If BDF is not loaded in boot dmesg, this script needs to be extended to add mercusys,mr47be-v2 ART extraction (offsets: to be clarified via mii read/dmesg with ART dump).
No mainline DSA switch driver for QCA8084. Initial goal: UART + Wi-Fi + 4× PHY link up; LAN switch/bridge is a separate DSA task.
Wi-Fi BDF (board-id 0x16 / 0x1015) will be finalized after hardware validation.

