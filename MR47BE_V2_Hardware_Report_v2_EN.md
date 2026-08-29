# MERCUSYS MR47BE V2 (BE9300) — Hardware Analysis & Test4 Status Report (v2 — CORRECTED)

**Revision:** v2.0 — 2026-08-29 · **Previous version:** `MR47BE_V2_Hardware_Analysis_{EN,TR,RU}.pdf` (2026-08-27)
**Unit:** MR47BE(EU) Ver:2.0 · Serial **2CF60F2000345**
**Evidence:** 39 macro photographs + the owner's handwritten corrections on that same photo set +
a real UART PBL/SBL/U-Boot boot log + vendor GPL source (`ipq_qca8084.c`, `kernel-ipq5332-mi01.6.dts`,
`nand-partition.xml`, `basic.config`) + **a successful test4 clean-build result (2026-08-28, Round 3).**

---

## 0. What changed in this revision — CHANGE LOG

The owner hand-annotated three corrections on the August 27 report, and new test4 data has become
available since. Both are folded into this revision:

| # | Previous report (v1, Aug 27) | Correction / new information | Source |
|---|---|---|---|
| 1 | Antenna count **6** (`J21/J22/J51/J52/J61/J62`) | **6 antennas**, full list: `J21/J22/J51/J52/J61/J62`. Cable color coding: 2.4 GHz = gray ×2, 6 GHz = orange ×2, 5 GHz = black ×2 | Owner's handwritten markup on Figure 6 + the original label photo |
| 2 | `8770N 591305` counted as **×2** | **×2**  | - |
| 3 | `8270HT 006589` **not mentioned at all** in the analysis | **New component added: `8270HT 006589 FH2447` ×2.** Sits on the J21/J22 antenna path (same line as the 2.4 GHz feed) | Owner's note: *"8270HT 006589 FH2447, two more of these exist, not mentioned in the analysis!! routed as j21 and j22"* |
| 4 | Ethernet architecture was an **open item** (QCA8386 searched for, not found) | **CLOSED:** Ethernet = **QCA8084**, not a discrete chip — a switch-PHY complex integrated inside the IPQ53xx SoC (GEPHY0-3 + MAC0-5 + UniPHY0/1). Confirmed via GPL source (`ipq_qca8084.c`). QCA8386 is **not present** on the board. | GPL source analysis + real boot log (`QCA8084-switch status:`) |
| 5 | test4 build status was not in the report | **test4 Round 3 build SUCCEEDED (2026-08-28, 01:47)** — 5 images + sha256sums + manifest produced; DTB verified to contain QCA8084/QCN6274/rootfs_1 | `LIVE_SESSION_STATE.md` §6 |

Every section below reflects these corrections. Nothing previously marked CONFIRMED in the prior report
has been walked back — only counting gaps have been fixed and new evidence has been added.

---

## 1. Unit identity — ✅ CONFIRMED (unchanged)

- Factory label: `MR47BE(EU) Ver:2.0`, barcode `2CF60F2000345`, module code `3FC-4`
  (photographed on the LAN transformer bracket).
- PCB silkscreen code `2050502553`, TOP side.
- A genuine, labeled EU-region V2 board — not inferred from firmware or forum claims.

## 2. Bill of Materials from chip-top markings — UPDATED

| Component | Marking (photo) | Identification | Status |
|---|---|---|---|
| Main SoC | `Qualcomm IPQ5322 003 FK5134HJ` | Qualcomm **IPQ5322** — "Immersive Home 326" (Miami family). 4× Cortex-A53 @1.5GHz + 1× NPU@1.5GHz, 6-stream, MRQFN251 package | ✅ CONFIRMED — 5 separate legible photos |
| 6 GHz radio | `Qualcomm QCN6274 001 JE510CV2` | Qualcomm **QCN6274**, 2×2 6GHz 802.11be companion radio | ✅ CONFIRMED |
| NAND flash | `winbond 25N01GWZE1G 2520 M51708600` | Winbond **W25N01GWZEIG**, 1Gbit (128MB) SPI NAND, WSON-8 | ✅ CONFIRMED — exact match to boot log |
| DRAM | `SEC 343 K4A8G165WC BCTD 62F89501C` | Samsung **K4A8G165WC-BCTD**, 8Gb (1GB) DDR4, ×16, 3200Mbps | ✅ CONFIRMED — exact match to boot log ("1 GiB") |
| LAN magnetics (×2, for 4× 2.5GbE) | `EEC DQ48201N0-S 2520-A` | Integrated RJ45 transformer/magnetics modules | ✅ CONFIRMED |
| RF front-end ICs | `8570N 574909` **×2**, `8770N 591305` **×2** *(corrected — previous report said ×1)*, `8270HT 006589 FH2447` **×2** *(NEW — absent from the previous report)* | Small QFN parts adjacent to the RF shield; likely PA/FEM/switch family members. The `8270HT` pair sits on the J21/J22 (2.4 GHz) path | 🟡 OPEN — part markings not matched to a public datasheet, but the count and placement are now complete |
| Front-end module | `FE51427S` | Under the RF shield next to the main SoC; likely a PA/front-end module | 🟡 OPEN |
| UART header | 4-pin, silkscreen `J1` | Unpopulated 4-pin header next to the main SoC shield — every boot log in this report was captured through this header | ✅ CONFIRMED |
| Antenna feeds | **6× U.FL/IPEX click-on**, `J21/J22/J51/J52/J61/J62` *(corrected — previous report listed 5 antennas with an incomplete connector list)* | All click-on (unlike V1's mix of soldered pigtails + click-on) | ✅ CONFIRMED |
| Ethernet | **QCA8084** switch-PHY (NOT a discrete chip) | GEPHY0-3 + MAC0-5 + UniPHY0/1 complex integrated inside the IPQ53xx SoC | ✅ CONFIRMED — see §5 |
| QCA8386 switch IC | — | **Physically absent from the board** | ❌ DISPROVEN |

## 3. Cross-validation against the real UART boot log — ✅ CONFIRMED

| Boot-log evidence | Photographed component | Result |
|---|---|---|
| `Serial NAND device Manufacturer:W25N01GWZEIG ... Device Size:128 MiB` | Winbond W25N01GWZEIG | ✅ EXACT MATCH |
| `DRAM: ... 1 GiB` | Samsung K4A8G165WC-BCTD (8Gb=1GB) | ✅ EXACT MATCH |
| `JTAG ID @ 0x000a607c = 0x1023d0e1` | Main SoC package | Manufacturer field 0x070 = Qualcomm's JEP106 code → confirms genuine Qualcomm silicon (see §4) |
| `eth0 PHY0 QCA8084-switch status:` | — (no discrete chip, on-SoC) | ✅ Exact match to GPL source (see §5) |

## 4. SoC identity: IPQ5322 (physical) vs. "IPQ5332" (boot string) — ✅ RESOLVED (for this unit)

The boot log prints `IMAGE_VARIANT_STRING=IPQ5332LA`; the community had read this as meaning the SoC is
IPQ5332. However, five separate, sharp macro photos of the main SoC clearly show **`Qualcomm IPQ5322 003
FK5134HJ`**.

IPQ5322 and IPQ5332 are both real, distinct SKUs in the same "Miami"/Immersive Home Wi-Fi 7 family, in
the same MRQFN251 package:

| Chip | Platform | CPU | Streams | Class |
|---|---|---|---|---|
| IPQ5332 | Immersive Home 3210 | 4× A53@1.5GHz + NPU | 10-stream | ~20.7 Gbps |
| **IPQ5322 (this unit)** | Immersive Home 326 | 4× A53@1.5GHz + NPU | 6-stream | ~10.6 Gbps |

`IMAGE_VARIANT_STRING` is not a live hardware read — it's a string compiled into the bootloader by the
BSP build; the same BSP target can serve multiple SKUs from the same family. **Conclusion for this
unit:** photographic evidence outranks the software string → SoC = **IPQ5322**.

**Still open:** whether every V2 batch uses IPQ5322, or whether some batches are dual-sourced with
IPQ5332. The definitive resolution is a kernel-side `socinfo` read:
```sh
cat /proc/device-tree/compatible
dmesg | grep -iE "ipq53|socinfo|soc:"
cat /sys/devices/soc0/*
```

## 5. Ethernet architecture — ✅ CLOSED: QCA8084 (on-SoC), QCA8386 ABSENT

This was the biggest open item in the previous report; it was definitively closed during test4
preparation by reading the vendor GPL source.

**Conclusion:** Ethernet = **QCA8084**, 4×2.5G (LAN PORT1-3 + WAN PHY1) — and this is **not a discrete
chip**: it's a switch-PHY complex integrated inside the IPQ53xx SoC (GEPHY0-3 + MAC0-5 + UniPHY0/1).
That's why no PCB photo shows a separate Ethernet/switch chip — the board only has 2× `EEC
DQ48201N0-S` LAN magnetics modules and nothing else in that role. It isn't missing; it's integrated.

**GPL evidence** (vendor U-Boot 2016.01 — same version as in the boot log):
- `u-boot-2016/drivers/net/ipq_common/ipq_qca8084.c:1472` → `printf("QCA8084-switch status:\n");`
  (the exact source of the boot-log line); `:1485` → `PORT%d %s Speed :%d %s duplex` (source of the PORT
  lines)
- `ipq_qca8084.c:1513-1564` → `ipq_qca8084_hw_init()` reads the DTS node `/ess-switch/qca8084_swt_info`
  (`switch_mac_mode0/1`, `switch_lan_bmp`, `switch_cpu_bmp`); `CONFIG_QCA8084_SWT_MODE`
- `ipq_qca8084_clk.h:164` → `QCA8084_CLK_BASE_REG 0x0c800000`; all register/clock access goes through
  the SoC's **internal MDIO** path (`ipq_mii_read/write`) — a discrete chip could not be driven this way
- `kernel-ipq5332-mi01.6.dts` → on-SoC `ess-switch@3a000000` (`forced-speed 2500`); the EVB's optional
  EXTERNAL `ess-switch1` node (`qcom,ess-switch-qca8386`) does **not** exist on this board

**Speed values:** the boot log's `Speed :100`/`:10` are not port capacity — they're the auto-negotiated
link speed at capture time, while the unit was connected through a TP-Link 740N (100 Mbps). Ports are
2.5G-class (`ADVERTISE_2500FULL`); confirming this needs a 2.5G/5G-capable NIC showing `Link: 2500 Mbps`.

**Wiring (boot log + vendor DTS):** `dp1` (`qcom,id=2`) ↔ LAN PORT1-3; `dp2` (`qcom,id=1`) ↔ WAN PHY1.

**test4 target:** mainline has no DSA driver for QCA8084; the initial goal is UART + Wi-Fi (ath12k) +
4× PHY link-up. LAN switch/VLAN functionality is separate DSA-driver work.

## 6. Wi-Fi — ✅ CONFIRMED

- On-SoC 2.4/5 GHz → `wifi0`, ath12k (Q6), GPL `board_id=0x16` (18)
- PCIe 6 GHz → **QCN6274** → `wifi2`/pcie1, GPL `board_id=0x1015`
- Firmware: `ath12k-firmware-ipq5332` (q6) + `ath12k-firmware-qcn9274` + `ipq-wifi-mercusys_mr47be-v2`

## 7. RF / antenna system — ✅ CORRECTED: 6 antennas (not 5)

Six external antennas connect through **6× click-on U.FL** connectors on a small daughter-board along
the chassis edge (no soldered pigtails — unlike V1). Connector/band mapping (from the owner's
hand-annotated photo notes):

| Band | Antennas | Connector | Cable color |
|---|---|---|---|
| 2.4 GHz | 2 | J21 / J22 | Gray |
| 6 GHz | 2 | J61 / J62 | Orange |
| 5 GHz | 2 | J51 / J52 | Black |

Radio split: the IPQ5322 SoC integrates the 2.4 GHz radio + iPA on-die; 6 GHz is handled by the
separate QCN6274 companion; 5 GHz is also on-SoC (standard for the IPQ53xx family). The small RF
front-end ICs from §2 (`FE51427S`, `8570N`×2, `8770N`×2, `8270HT`×2) sit in these radios' signal path;
the `8270HT` pair specifically sits on the J21/J22 (2.4 GHz) line.

## 8. Thermal management — ✅ CONFIRMED (unchanged)

The BOTTOM side shows the same design language as V1: a large pink silicone thermal gap-filler pad over
the main SoC, plus two metal heat-spreader plates over secondary hot spots, all contacting the chassis
top cover. No fan or heatpipe — a passive, chassis-as-heatsink design.

## 9. Flash / partition layout — ✅ CONFIRMED (`nand-partition.xml`)

Total 128 MiB, A/B layout:
`sbl1 768K · mibib 512K · bootconfig(+1) 256K×2 · qsee 1.75M · devcfg 256K · tme 256K · cdt 256K ·
appsblenv 256K · appsbl 768K · art 1M @0x900000 · secure-binary 256K · rootfs 54M · rootfs_1 54M ·
tp_data 10M · data 256K · reserverd_data 256K`

ART (1MiB, Wi-Fi calibration + MAC) must stay read-only. GPL `basic.config`:
`BOARD_TYPE=AP-MI01.6_512M16_DDR4`, `ARCH_TYPE=64`, `CONFIG_TP_MODEL_BE550V2` (TP-Link rebrand).

## 10. U-Boot / Security — ✅ CONFIRMED

- Prompt `IPQ5332#`, 115200 baud, `bootipq`; FIT SIGNATURE/SHA/RSA **disabled** → unsigned boot possible
- `Secure Boot: Off` → unsigned OpenWrt RAM-boot **is possible**
- Boot address `0x46000000` (`0x44000000` collides — do not use)
- The vendor's `n25q128a11` spi-nor reference is not present on the real board (NAND-only, `SF: Unsupported`)

## 11. test4 — Clean build result (2026-08-28, Round 3 — ✅ SUCCESS)

This is the most significant new development since the previous report: **the test4 image built
successfully.**

**Build history:**
- ❌ Round 1 (22:53): `missing-macros/bin/*` was missing → crash
- ❌ Round 2 (23:12): 0-byte log (the shell session closed immediately after `nohup`) → fixed with `setsid`
- ❌ Round 3, first attempt (01:04): crashed at the last step —
  `target/linux/install` → `cc1: fatal error: ../dts/ipq5332-mr47be-v2.dts: No such file or directory`
- ✅ **Round 3, fix + relaunch (01:47) — BUILD OK**

**Root causes and lessons:**
1. **`rsync --exclude=bin` (unanchored)** deleted every `bin/` folder in the tree, including
   `tools/missing-macros/src/bin`. **Fix:** anchored exclude,
   `--exclude=/build_dir /staging_dir /tmp /.ccache /bin /logs`, plus a parity check (source file count =
   destination file count, and a `bin/m4/README` check) added to the script as a FATAL guard.
2. **If the shell session closes immediately after `nohup make &`**, make dies before writing its first
   output (0-byte log). **Fix:** `setsid nohup make ... &` plus `sleep 12` in the same command for a
   live-verification check.
3. **WSL background watcher daemons** die when the session closes, but `make` keeps running. Reliable
   monitoring = an external periodic probe that copies and analyzes the log (`/root/autoprobe.sh`, every
   5 minutes).
4. **DTS naming collision:** `setup_clean.sh` copied the DTS file as `ipq5332-mercusys-mr47be-v2.dts` but
   then deleted the name the build actually looks for with `rm -f .../ipq5332-mr47be-v2.dts` (the
   `DEVICE_DTS` derivation expects `mercusys_mr47be-v2` → `ipq5332-mr47be-v2`). **Fix:** the verified DTS
   (md5 `90bdb804caf8de759cc33bbbc262afc`) was put back under the correct name.

**Build output (Round 3 result, 01:47):**
- 5 images + `sha256sums` + manifest → `imajlar/test4/`
- `initramfs-uImage.itb` md5: `c71c879e6d8770459a7195f9cd58140e`
- DTB verified to contain `phy@1..4` + `2500base-x` + `fixed-link` + `pci17cb,1109` (QCN6274) + `0:art`
  + `rootfs_1`; **`qca8386` absent** (expected — consistent with §5)
- FIT `config@mi01.6` present
- Manifest contents: `ath12k-firmware-ipq5332`, `ath12k-firmware-qcn9274`,
  `ipq-wifi-mercusys_mr47be-v2`, `kmod-ath12k`, `kmod-phy-qca83xx`

**Build pipeline (for reproducibility):**
```sh
# 1) Setup (anchored rsync + final DTS + parity/bin/dts FATAL guard + defconfig + offline feeds)
bash /root/setup_clean.sh setup      # -> /root/mr47be-clean

# 2) Build (setsid is MANDATORY — see lesson #2)
cd /root/mr47be-clean
setsid nohup make -j4 V=s > /root/mr47be-clean-build.log 2>&1 < /dev/null &
sleep 12   # live verification

# 3) Output -> TFTP boot (Secure Boot Off -> unsigned OK, test without flashing NAND)
# bin/targets/qualcommbe/ipq53xx/openwrt-...-mercusys_mr47be-v2-initramfs-uImage.itb
tftpboot 0x46000000 openwrt-...-initramfs-uImage.itb
bootm 0x46000000
```

**Next step (test5 target):** verify WAN×1 + LAN×3 as independent links; after UART + Wi-Fi (ath12k) +
4× PHY link-up are confirmed, a separate DSA driver effort is needed for LAN switch/VLAN functionality.

## 12. Summary status matrix

| # | Item | Status |
|---|---|---|
| 1 | Genuine V2 hardware, EU region, serial 2CF60F2000345 | ✅ CONFIRMED |
| 2 | NAND = Winbond W25N01GWZEIG 128MB | ✅ CONFIRMED |
| 3 | DRAM = Samsung K4A8G165WC-BCTD 1GB DDR4 | ✅ CONFIRMED |
| 4 | Main SoC is genuine Qualcomm silicon (JTAG mfg ID 0x70) | ✅ CONFIRMED |
| 5 | This unit's SoC top marking = IPQ5322 (not IPQ5332) | ✅ CONFIRMED (this unit) |
| 6 | All V2 units = IPQ5322 (dual-source IPQ5332 risk) | 🟡 OPEN — needs socinfo or more owner photos |
| 7 | 6 GHz radio = QCN6274 | ✅ CONFIRMED |
| 8 | Ethernet = QCA8084 (integrated on-SoC) | ✅ CONFIRMED — GPL + boot log |
| 9 | Is QCA8386 present on the board | ❌ ABSENT — disproven |
| 10 | UART J1 working, Secure Boot Off | ✅ CONFIRMED |
| 11 | Antenna count and connectors | ✅ CORRECTED — 6 total, J21/J22/J51/J52/J61/J62 |
| 12 | `8770N` quantity | ✅ CORRECTED — ×2 |
| 13 | `8270HT 006589 FH2447` component | ✅ ADDED — ×2, on the J21/J22 path |
| 14 | Exact manufacturer of the small RF front-end ICs | 🟡 OPEN — no public datasheet match |
| 15 | test4 clean build | ✅ SUCCEEDED — Round 3, 2026-08-28 01:47, 5 images produced |

## 13. Next steps

1. `soc_ipq5322.jpg` (the clearest SoC macro photo) should be kept as primary evidence in the repo.
2. After the RAM-boot test, capture and publish: `dmesg | grep -iE "ipq53|socinfo"`,
   `cat /proc/cpuinfo`, `cat /sys/devices/soc0/*` — this definitively closes item #6.
3. Other MR47BE V2 owners should be asked to photograph the main SoC top marking the same way, to check
   whether IPQ5322 is universal across V2 batches.
4. test5 target: verify WAN×1 + LAN×3 independent link-up and live Wi-Fi (ath12k); then take on a LAN
   switch/VLAN DSA driver for QCA8084.

---

*This is a visual + GPL-source + real-boot-log-based hardware audit, not an official
Mercusys/TP-Link/Qualcomm document, and not a substitute for a runtime kernel-side SoC-ID read
(`socinfo`). This revision (v2) incorporates the owner's handwritten corrections to the August 27, 2026
report and the test4 build results from August 28, 2026.*
