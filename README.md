# MERCUSYS MR47BE V2 BE9300  Wi-Fi 7 Router. OpenWrt (Snapshots) 

**OpenWrt port for the Mercusys MR47BE V2 (Qualcomm IPQ5322 · Wi-Fi 7)**

> **Status:** 🟡 Snapshots works — images build cleanly. Hardware validation
> (RAM-boot, Wi-Fi, Ethernet link-up) is in progress.
> Do not flash unless you understand UART/U-Boot recovery.

---
        MERCUSYS MR47BE V2( 5GHz - 6GHz Wi-Fi 7). OpenWrt (snapshots)

🎯  Current Status 

| □ | Current | Status |
|---|---|---|
| ✅ | WAN (DHCP + Internet |  2.5G Working (QCA8084) |
| ✅ | LAN1 (Ethernet) | 2.5G Working (QCA8084) |
| ✅ | LuCI (Web UI ) |  Working |
| ✅ | Wi-Fi 5/6GHz (QCN6274)| QCN6274 WiFi 7 firmware |
| ✅ | PCIe: | QCN6274 | detected (17cb:1109) |
| ✅ | LAN2/3 (Ethernet) | 1G Working  |
| ⚠️ | Wi-Fi 2.4GHz (Q6) | WiFi 7 firmware |


---

| 📌 ROADMAP | - | □ |
|---|---|---|
| ☑ | WAN (DHCP + Internet | ✅ |
| ☑  | LuCI  | ✅ |
| ☑  | Wi-Fi 5/6GHz — MHI/QMI firmware loading | ✅ |
| ☑  | LED support | ✅ |
| ☑  | LAN2 & LAN3 — ess-switch driver | ⚠️ 1G Only QCA8386 DSA Working |
| ⚠️ | Wi-Fi 2.4GHz | ⚠️ |


---

MERCUSYS MR47BE V2 (5GHz - 6GHz Wi-Fi 7). OpenWrt (snapshots)

| | |
|---|---|
| **Kernel** | 6.18.39/44/52/54/55 (OpenWrt qualcommbe LTS) |
| **Target / Board** | `qualcommbe/ipq53xx` / `mercusys_mr47be-v2` |
| **Boot** | Unsigned FIT, `config@mi01.6` → U-Boot RAM-boot OK |
| **LED / Button** | gpio-leds + gpio-keys (reset) |
| **USB** | Disabled (no physical port) |

---

### Other docs
— full hardware audit (photo + boot-log + GPL)

Do not touch:(gpio)
8–13: NAND. Writing here will cause the system to crash.
18/19: UART.
25–28: MDIO.
29, 35: Button.
30, 39, 43, 45: PHY reset lines.
16: Used as an MDIO reset in the DTS.
38, 44, 46–51: PCIe/BT

---

## 🛠️ Hardware (confirmed, evidence-based)

| Component | Detail | Evidence |
|---|---|---|
| **SoC** | Qualcomm **IPQ5322** (Miami, 4× A53, 6-stream) | Chip-top photo, JTAG mfg 0x70 |
| **6 GHz radio** | **QCN6274** over PCIe (`board-id 0x1015`) | Chip-top photo + boot log |
| **2.4/5 GHz** | on-SoC (`wifi0`, ath12k, `board-id 0x12`) | Vendor DTS / boot log |
| **Ethernet** | **QCA8386+QCA8084** switch-PHY | Boot log `QCA8084-switch` + GPL +Chip-top photo|
| **Flash** | Winbond W25N01GW 128 MiB SPI-NAND | Photo + boot log (exact) |
| **DRAM** | Samsung K4A8G165WC 1 GiB DDR4 | Photo + boot log (exact) |
| **UART** | 4-pin J1, 115200 8N1, `Secure Boot: Off` | Working capture |
| **Antennas** | 6× (2.4GHz×2, 5GHz×2, 6GHz×2) | Photos |

> Note: the boot log prints `IPQ5332` as a **BSP compiler string**, not a hardware read.
> The physical die is **IPQ5322**. The DTS uses `qcom,ipq5332` compatible
> (same Miami family/package — boots fine); confirm with `socinfo` after RAM-boot.


### 🔧 Hardware Architecture & Known Limitations

**Chipset Configuration:**
- **CPU:** Qualcomm IPQ5332 (2x 2.5G MAC only)
- **Switch:** QCA8386 (4-port 2.5G switch with 2 HSGMII interfaces)
- **PHY:** QCA8084 (2.5G multi-gig PHY)

**⚠️ Critical Bandwidth Limitation:**
The QCA8386 switch chip has only **2 HSGMII interfaces**, limiting total switch-to-CPU bandwidth to **5 Gbps**. While all 4 ports support 2.5G physically, they share this 5 Gbps aggregate bandwidth

**Port Behavior:**
- ✅ All 4 ports negotiate at 2.5G link speed
- ️ Total throughput capped at 5 Gbps (hardware limitation)
- ⚠️ LAN2/LAN3 not visible in LuCI (DSA driver incomplete)

**Why QCA8386 instead of QCA8084?**
The IPQ5332 CPU lacks 4x 2.5G MACs required for QCA8084 (which would provide 10 Gbps via USXGMII). QCA8386 is a cost-effective solution but sacrifices total bandwidth [[1]].

**Reference:** Detailed analysis at [ACWIFI.NET - TP-LINK 7DR6560 teardown](https://www.acwifi.net/26503.html) (Chinese, technical deep-dive)

#### 🔌 Physical Port Map & Link Requirements

```
[ BACK PANEL VIEW (Left to Right) ]
|  LAN 1  |  LAN 2  |  LAN 3  |   WAN   |
|  2.5G   |   1G    |   1G    |  2.5G   |

```

#### 🛠️ Strict Port Negotiation Rules (Current Build)
*   **WAN Port:** **MUST** be connected to a 2.5G upstream source. Connecting to a 1G modem/router will fail to negotiate and pass no traffic/IP.
*   **LAN 1:** **MUST** be connected to a 2.5G client device. 1G clients will fail to get an IP.
*   **LAN 2 & LAN 3:** **MUST** be connected to 1G client devices. Multi-gig (2.5G/5G/10G) clients will fail to negotiate and get no IP.

```

#### 🌐 RAM Boot / UART Initial IP Warning
When booting the image via RAM (TFTP/UART), the default IP is `192.168.1.1`. To prevent subnet conflicts with your existing local network, **the initial boot IP has been remapped to `192.168.5.1/24`**.
1.  **During Boot:** You must manually assign the static IP `192.168.5.2/24` to your PC's NIC to access the router's web interface/SSH.
2.  **Post-Boot Cleanup:** Once the router fully boots and you configure your normal WAN/LAN settings, **you MUST remove the static IP assignment from your PC's network adapter** and revert to DHCP. Failing to do so will result in false "no IP / no internet" symptoms on your PC.

```

✅ Working Features
**Wi-Fi 5/6GHz (QCN6274)| QCN6274 WiFi 7 firmware
WAN (DHCP + Internet) —  successful
LAN1 (Ethernet) — SSH + ping accessible
LAN2 (Ethernet) — SSH + ping accessible
LAN3 (Ethernet) — SSH + ping accessible
LuCI (Web UI) — http://192.168.5.1
PCIe — QCN6274 Wi-Fi 7 chip detected (17cb:1109)
LEDs POWER — ( Red/Orange/ Green)
LEDs(Ethernet) — LAN3

```
- **LuCI Port Status Visibility (QCA8386/QCA8084):** 
  LAN2 and LAN3 ports are fully functional at the hardware level (clients successfully obtain DHCP leases and pass traffic). However, they do not appear in the LuCI "Port Status" widget. 
  **Root Cause:** The current Device Tree (DTS) configuration aggregates the switch ports under a single `lan` interface without exposing them as individual labeled DSA slave ports (e.g., `lan1`, `lan2`). The QCA8386 switch handles Layer-2 traffic in hardware transparently. 
  **Impact:** UI display limitation only. No impact on actual routing, switching, or DHCP functionality. Future DTS updates will add proper `label` properties to restore per-port visibility in LuCI.
**LuCI Port Status Widget Shows No LAN Ports**

- **Hardware:** Qualcomm IPQ5332 + QCA8386 Switch + QCA8084 2.5G PHY
- **Issue:** LAN/WAN ports do not appear in LuCI Port Status widget
- **Root Cause:** QCA8386 DSA (Distributed Switch Architecture) slave interfaces are not properly defined in the Device Tree configuration. The switch operates in hardware bridging mode, exposing only a single `lan` interface to the kernel instead of individual port interfaces (lan1, lan2, lan3, wan).
- **Impact:** 
  - ✅ Ports are **fully functional** at hardware level (DHCP, routing, switching work)
  - ❌ LuCI cannot display per-port statistics or link status
  - ⚠️ Port-specific configurations (VLAN, speed limits) cannot be managed via LuCI

- **Workaround:** 
  - Verify port activity via SSH: `cat /sys/class/net/lan/statistics/rx_packets`
          'ubus call network.device status'

  - Check DHCP leases to confirm client connectivity
  - Physical port functionality is not affected

- **Fix Required:** Device Tree Source (DTS)

```
📥 Installation (TFTP RAM Boot)
⚠️ Warning: This method is temporary. The device will revert to stock firmware after reboot. Permanent flashing is not recommended yet.

Download this image: openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
Set your PC IP to 192.168.5.100 and start a TFTP server. Place the image in the TFTP root directory.
Connect to the device via UART (115200 8N1) and stop autoboot in U-Boot.
Run the following commands:
```

---

## 📥 Images

Uploaded to GitHub Releases 
(`MERCUSYS MR47BE V2.1.07 (2.4GHz - 5GHz - 6GHz Wi-Fi 7). OpenWrt ((snapshots))`):

| File | Purpose |
|---|---|
| `*-initramfs-uImage.itb` | RAM-boot / hardware testing (TFTP) |
| `*-squashfs-factory.bin` | Factory / UBI write |
| `*-squashfs-factory.ubi` | UBI image |
| `*-squashfs-sysupgrade.bin` | OpenWrt sysupgrade |
| `*-uImage.itb` | FIT kernel image |
| `*-manifest`, `sha256sums` | Package list + checksums |

*(file prefix: `openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2`)*

---
📥 INSTALLATION
⚠️  WARNING :  / Temporary.  Permanent flashing not recommended 
## 🚀 Quick start (UART → TFTP → RAM boot)
```Download the Image /  → Releases
setenv serverip 192.168.5.100
setenv ipaddr 192.168.5.1
U-Boot> tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
U-Boot> bootm 0x46000000

```

**UART:** GPIO18=TX, GPIO19=RX, GND @ 115200 8N1. 
**Boot address:** `0x46000000` (`0x44000000` collides — do not use). 
`Secure Boot: Off` → unsigned image accepted.

```
UART pinout
uart
             V
o   o   o    o
Nc -Gnd -Rx -Tx

UART pinout

Viewed from above using the board's pin-1 triangle:

       pin-1 triangle
                         v
AP header:  [1] [2] [3] [4]
             NC  GND  RX  TX
                  |    |   |
USB-UART:        GND  TX  RX

AP pin 	Signal 	Connect to
1 	NC 	Leave unconnected
2 	GND 	Adapter GND
3 	RX 	Adapter TX
4 	TX 	Adapter RX

Warning

3.3 V means TTL logic level, not a power connection. Power the AP through PoE and connect only RX, TX, and GND. Never connect the adapter's VCC, 3V3, or 5V lead to pin 1 or any other AP header pin. Never use RS-232 voltage levels.

---

## ⚠️ Flash / recovery warnings

- **Back up the ART partition** (Wi-Fi calibration + MAC) before touching anything. Do **not** erase/overwrite it.
- Vendor firmware uses **RSA-signed, AES-CBC** cloud format → `_nosign_` and renamed files are **rejected** by stock web recovery.
- A/B layout: `rootfs` (A) / `rootfs_1` (B).

---

## 🙏 Credits

- [OpenWrt](https://openwrt.org) (qualcommbe/ipq53xx target)
- https://github.com/perceival/openwrt-flint3
- https://github.com/luckkyboy/SBE1V1K
- Mercusys MR47BE V2 GPL source
- D-Link M95A1 GPL source (Openwrt Kernel 5.4)(IPQ5332+QCA8386+QCA8081+QCA6274)
- Community IPQ53xx OpenWrt work (Perceival / GL iNet)
- Hardware teardown & reverse-engineering analysis
- https://github.com/morluto/rea reverse-engineering analysis
- ACWIFI.NET - TP-LINK 7DR6560 teardown https://www.acwifi.net/26503.html
---

📄 LICENSE
This project is subject to the same license terms as OpenWrt.

## ⚠️ Disclaimer

Experimental community port. Flashing custom firmware can permanently damage the device. 
Always keep a backup of the original firmware, NAND partitions, and especially the ART calibration data. 
**Use UART recovery whenever possible.**

🤝 CONTRIBUTING
Please open an Issue or submit a Pull Request for bug reports, test results, and contributions.

✍️ NOTE 
This port is still in development. Wi-Fi and all Ethernet ports are not yet fully functional. 
Your feedback is highly valuable.





