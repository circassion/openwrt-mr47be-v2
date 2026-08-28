# Mercusys MR47BE V2 — OpenWrt

**OpenWrt port for the Mercusys MR47BE V2 (IPQ5332 / Wi-Fi 7)**

This repository contains the OpenWrt device support, DTS, image definitions, firmware analysis and build configuration developed specifically for the **Mercusys MR47BE V2**.

> ⚠️ **Status: Experimental / Hardware flashing and full feature validation are still in progress.**
>
> The OpenWrt images have been successfully built and structurally verified. Do not flash them unless you understand UART/U-Boot recovery.

# V2_HARDWARE_STATUS.md — MR47BE V2 Physical Hardware Audit

**Date:** 2026-08-26/27
**Method:** Direct optical identification of chip-top markings from 39 user-supplied
macro photographs of a physical `MR47BE(EU) Ver:2.0` unit (serial `2CF60F2000345`),
cross-referenced against manufacturer/distributor part listings and independent
chip-codename databases, then cross-validated against a real UART PBL/SBL boot
log captured from the *same physical unit*. This supersedes the chip-identity
sections of the earlier `V1_urun_analizi.pdf`, which was based on five third-party
V1 photos (ioiotimes.com) and could not see the main SoC, DRAM, or flash at all.

**Companion documents:** `PRE_TEST3_CHECK_ENG.md`, `RELEASE_NOTES_v0.1.0-test3_EN.md`,
`Release.md`, full report PDFs: `MR47BE_V2_Hardware_Analysis_{EN,TR,RU}.pdf`.

Every line below is graded: ✅ **CONFIRMED** = directly read from a photo and/or
independently matched against the boot log. 🟡 **OPEN** = visually inspected,
not yet matched to a public datasheet, or needs one more piece of evidence to
close. 🔴 **DISCREPANCY** = a real conflict between sources; resolution status
is stated explicitly so nothing is left ambiguous.

---

## 1. Unit identity — ✅ CONFIRMED

- Factory label: `MR47BE(EU) Ver:2.0`, barcode `2CF60F2000345`, module code `3FC-4`
  (photographed directly on the LAN-transformer bracket).
- PCB silkscreen code `2050502553` present on the TOP side.
- This is a genuine, labeled EU-region V2 board — not inferred from firmware or
  forum claims.

## 2. Bill of materials confirmed from chip markings

| Component | Marking (photographed) | Identification | Status |
|---|---|---|---|
| Main SoC | `Qualcomm IPQ5322 003 FK5134HJ` | Qualcomm **IPQ5322** — "Immersive Home 326" (Miami family). Quad Cortex-A53 @1.5GHz + 1x NPU@1.5GHz, 6-stream, MRQFN251 package | ✅ CONFIRMED — 5 separate legible photos |
| 6GHz radio | `Qualcomm QCN6274 001 JE510CV2` | Qualcomm **QCN6274**, 2×2 6GHz 802.11be companion radio for IPQ53xx SoCs | ✅ CONFIRMED |
| NAND flash | `winbond 25N01GWZE1G 2520 M51708600` | Winbond **W25N01GWZEIG**, 1Gbit (128MB) SPI NAND, WSON-8 | ✅ CONFIRMED — exact match to boot log |
| DRAM | `SEC 343 K4A8G165WC BCTD 62F89501C` | Samsung **K4A8G165WC-BCTD**, 8Gb (1GB) DDR4, ×16, 3200Mbps, 96-ball FBGA | ✅ CONFIRMED — exact match to boot log ("1 GiB") |
| LAN magnetics (×2, for 4× 2.5GbE) | `EEC DQ48201N0-S 2520-A` | Integrated RJ45 transformer/magnetics modules | ✅ CONFIRMED |
| Small RF ICs near radio (×3 visible) | `8570N 574909` (×2), `8770N 591305` (×2), `8270HT' 006589`(×2)| Likely RF front-end (PA/FEM or switch) support devices; position/package consistent with this role | 🟡 OPEN — no public datasheet matched to these exact markings |
| Front-end module | `FE51427S` | Likely front-end/PA module for one Wi-Fi band, based on placement under the RF shield | 🟡 OPEN — same as above |
| UART header | 4-pin, silkscreen `J1` | Unpopulated 4-pin header next to the main SoC shield — **this is the header the boot log below was actually captured through** | ✅ CONFIRMED — working, real boot log obtained |
| Antenna feeds (×6) | U.FL/IPEX click-on, `J21/J22/J51/J52/J61/J62`| All 6 feeds are click-on U.FL on this sample (V1 sample used a mix of soldered pigtails + click-on) | ✅ CONFIRMED |
| QCA8386 switch IC | — | Not visually located in either the V1 or V2 photo sets | 🟡 OPEN — position on PCB still unknown; RELEASE_NOTES independently confirms its Linux driver is absent from the current build regardless of exact physical location |

## 3. Cross-validation against the real UART boot log — ✅ CONFIRMED (2 of 2 checkable facts)

| Boot-log evidence | Photographed component | Result |
|---|---|---|
| `Serial NAND device Manufacturer:W25N01GWZEIG ... Device Size:128 MiB` | Winbond W25N01GWZEIG | ✅ EXACT MATCH |
| `DRAM: ... 1 GiB` | Samsung K4A8G165WC-BCTD (8Gb = 1GB) | ✅ EXACT MATCH |
| `JTAG ID @ 0x000a607c = 0x1023d0e1` | Main SoC package | See §4 — confirms genuine Qualcomm silicon, does not by itself resolve exact part number |

**JTAG ID decode:** a standard IEEE-1149.1 JTAG ID splits as bit0=1 (fixed),
bits[11:1]=11-bit manufacturer code, bits[27:12]=16-bit part number,
bits[31:28]=4-bit version. `0x1023d0e1` → manufacturer field = `0x070`, which is
Qualcomm's own registered JEP106 vendor code (independently confirmed by a
Qualcomm engineer's public LKML post: *"for MSM8996, the ID is of QCOM(0x70)"*).
This proves the die is genuine Qualcomm silicon. Qualcomm has not published a
per-SKU JTAG part-number table for IPQ53xx, so the part-number sub-field
(`0x23d`) alone cannot distinguish IPQ5322 from IPQ5332 — see §4 for how that
question is actually resolved.

## 4. 🔴 DISCREPANCY, now resolved for this unit: IPQ5322 (photo) vs "IPQ5332" (boot string / community assumption)

**The conflict:** The boot log prints `S - IMAGE_VARIANT_STRING=IPQ5332LA`.
Community discussion (OpenWrt forum, 4PDA, Romanian forums) has generally
assumed **IPQ5332**, reportedly based on strings in Mercusys's published GPL
source for V2 — but no photo evidence had ever been published to back this up
before now.

**The direct evidence:** Five separate, sharp macro photos of the main SoC on
this specific unit all read, unambiguously: **`Qualcomm IPQ5322 003 FK5134HJ`**.

**Are IPQ5322 and IPQ5332 actually different chips?** Yes — both real, both in
Qualcomm's "Miami"/"Immersive Home" Wi-Fi 7 family, same MRQFN251 package, same
marking format (which is exactly why they're easy to confuse):

| Chip | Platform | CPU | Wi-Fi streams | Aggregate class |
|---|---|---|---|---|
| IPQ5332 | Immersive Home 3210 | Quad Cortex-A53 @1.5GHz + 1x NPU@1.5GHz | 10-stream | ~20.7 Gbps |
| **IPQ5322** (this unit) | Immersive Home 326 | Quad Cortex-A53 @1.5GHz + 1x NPU@1.5GHz | 6-stream | ~10.6 Gbps |

Sources cross-checked independently: BoxMatrix chip-codename database, WikiDevi
Qualcomm parts table, Wallys Communications' own published platform comparison
— all three agree. (One low-quality blog claims a Cortex-A73+A53 big.LITTLE
design for IPQ5332; this is contradicted by every more authoritative source and
is treated as unreliable.)

**Why would the boot log say IPQ5332 then?** `IMAGE_VARIANT_STRING` is **not** a
live hardware read — it's a string compiled into the SBL/XBL bootloader binary
by whoever built that firmware (Mercusys's Qualcomm BSP build config). Since
IPQ5332 and IPQ5322 share die family, package, CPU cluster, and low-level
PBL/boot-ROM code path, it is a known pattern for one BSP/SBL build target to
serve multiple same-family SKUs, with SKU-specific behavior only differentiated
later (device tree / QMI-fuse reads after the kernel is up) — not at the
PBL/SBL stage. The early boot string most likely reflects *which BSP config
Mercusys reused*, not a verified silicon read.

**Resolution for this unit:** direct chip-top photographic evidence outranks
both the software variant string and unverified forum claims. **This unit's SoC
is Qualcomm IPQ5322.**

**Still open:** whether *every* MR47BE V2 unit uses IPQ5322, or whether
Mercusys dual-sourced IPQ5332 in some production batches under the same "Ver
2.0" label. 🟡 **To close permanently:** once RAM-boot succeeds, run —

```sh
cat /proc/device-tree/compatible
dmesg | grep -iE "ipq53|socinfo|soc:"
cat /sys/devices/soc0/*   # if present
```

Linux's `socinfo` driver reads the SoC ID from hardware fuses at runtime and
prints the true part number — that's the one piece of evidence that would
settle this beyond doubt. **Until that log exists, treat "IPQ5332" anywhere in
existing RELEASE_NOTES/DTS assumptions as unverified**, and this photograph as
the best evidence currently available.

**Practical impact on the test3 build:** CPU core count/clock/package are
identical between the two SKUs, so a kernel/DTS written for "IPQ5332" should
still boot on real IPQ5322 silicon (same boot ROM, same cluster). The risk is
narrower than "won't boot" — Wi-Fi stream-count/interface nodes in the DTS
could be provisioned for the wrong SKU's radio capability; worth checking once
wireless is testable.

## 5. RF / antenna system — ✅ CONFIRMED

Six external antennas feed the board through six click-on U.FL connectors on
a small daughter-board along the chassis edge (no soldered pigtails on this
sample, unlike V1). Radio split: IPQ5322 integrates 2.4GHz radio + iPA on-die;
6GHz is handled by the separate QCN6274 companion (§2); 5GHz is handled
on-SoC, consistent with the IPQ53xx family design. The small RF ICs (§2,
`FE51427S`, `8570N`×2, `8770N`x2, `8270HT`x2,) sit in the signal path near these radios and
are most likely front-end support devices (🟡 exact vendor open, see §2).

## 6. Thermal management — ✅ CONFIRMED

BOTTOM-side overview shows the same design language as the V1 unit: one large
pink silicone thermal gap-filler pad over the main SoC region, plus two metal
heat-spreader plates over secondary hot spots, all contacting the chassis top
cover as the primary heatsink. No fan or heatpipe — passive, chassis-as-heatsink
design.

## 7. Summary status matrix

| # | Item | Status |
|---|---|---|
| 1 | Genuine V2 EU hardware, Ver 2.0, serial 2CF60F2000345 | ✅ CONFIRMED |
| 2 | NAND = Winbond W25N01GWZEIG 128MB | ✅ CONFIRMED (photo + boot log) |
| 3 | DRAM = Samsung K4A8G165WC-BCTD 1GB DDR4 | ✅ CONFIRMED (photo + boot log) |
| 4 | Main SoC is genuine Qualcomm silicon (JTAG mfg ID 0x70) | ✅ CONFIRMED |
| 5 | Main SoC top marking = IPQ5322 (not IPQ5332) on this unit | ✅ CONFIRMED (this unit) |
| 6 | All V2 units = IPQ5322 (vs. possible dual-sourced IPQ5332) | 🟡 OPEN — needs Linux socinfo log or more owner photos |
| 7 | 6GHz radio = Qualcomm QCN6274 | ✅ CONFIRMED |
| 8 | 4-pin UART header present & functional | ✅ CONFIRMED (this report's own boot log proves it) |
| 9 | All 6 antenna feeds are click-on U.FL (no soldered pigtails) | ✅ CONFIRMED |
| 10 | Exact vendor of small RF ICs (FE51427S, 8570N, 8770N, 8270HT) | 🟡 OPEN — no public datasheet match |
| 11 | QCA8386 switch IC physical location on PCB | 🟡 OPEN — not visually located; driver absence independently confirmed in RELEASE_NOTES regardless |

## 8. Recommended next actions for this repo

1. The `soc_ipq5322.jpg` file (the clearest macro photograph of the chip) is stored as primary
   evidence — this is the strongest piece of standalone evidence
   produced to date for this card.
2. In the RELEASE_NOTES / PRE_TEST3_CHECK file, the statement *"The SoC is IPQ5332"* has been changed to 
*"It has been verified that the SoC is physically IPQ5322 in at least one production unit;
   IPQ5332, however, was an unverified community assumption."*
   `socinfo` log exists.
3. After the RAM-boot test, capture and publish `dmesg | grep -iE
   "ipq53|socinfo"`, `cat /proc/cpuinfo`, and `cat /sys/devices/soc0/*` (if
   present) — this closes item #6 above definitively.
4. Ask other MR47BE V2 owners to open their units and photograph the main SoC
   top marking the same way, to check whether IPQ5322 is universal across V2
   batches.

---

*This is a visual + boot-log-based hardware audit, not an official
Mercusys/TP-Link/Qualcomm document, and not a substitute for a runtime
kernel-side SoC ID read. All findings above are traceable to a specific photo
and/or a specific boot-log line quoted in this repository.*



## Current Build

**OpenWrt target:** `qualcommbe/ipq53xx`
**Board:**          `mercusys_mr47be-v2`
**Kernel:**          Linux 6.18.39
**Architecture:**    ARM64

The MR47BE V2-specific DTS and image definitions are included in the build tree.

### Built Images

| Image                       | Size     | Purpose                     |
|-----------------------------|----------|-----------------------------|
| `*-uImage.itb`              | ~6 MB    | FIT kernel image            |
| `*-initramfs-uImage.itb`    | ~22.6 MB | RAM boot / hardware testing |
| `*-squashfs-factory.bin`    | ~21 MB   | Factory/UBI image           |
| `*-squashfs-sysupgrade.bin` | ~20 MB   | OpenWrt sysupgrade          |

The FIT kernel was verified as **unsigned** and compatible with the device's U-Boot configuration.

## DTS Verification

The DTB embedded in the built FIT image was extracted and inspected directly. Confirmed present:

- `qcom,ipq5322-ppe`, `qcom,ipq5322-edma` (packet engine / ethernet DMA)
- `port@1` — label `lan`, `phy-mode = sgmii`, `fixed-link` 2500 Mbps
- `port@2` — label `wan`, `phy-mode = sgmii`
- `wifi@c000000` — `compatible = qcom,ipq5322-wifi`, `status = okay`, `board-id = 0x12`
- PCIe radio — `pci17cb,1109`, `board-id = 0x1015`
- `partition@b00000` → `art`, with `nvmem-layout` → `mac-address@0`
- NAND partition table: `sbl1`, `mibib`, `bootconfig`, `bootconfig1`, `qsee`, `devcfg`, `tme`, `cdt`, `appsblenv`, `appsbl`, `art` (0xB00000), `ubi` (0xD00000)


The vendor's own kernel DTS (`kernel-ipq5322-mi01.6.dts`, from Mercusys' published GPL source) confirms the switch directly:

```dts
qcom,is_switch_connected = <1>;
ess-switch@3a000000 {
    switch_cpu_bmp  = <0x1>;   /* cpu port bitmap */
    switch_lan_bmp  = <0x2>;   /* lan port bitmap */
    switch_wan_bmp  = <0x4>;   /* wan port bitmap */
    switch_mac_mode  = <0xc>;  /* mac mode for uniphy instance0 */
    switch_mac_mode1 = <0xc>;  /* mac mode for uniphy instance1 */
    switch_mac_mode2 = <0xff>; /* mac mode for uniphy instance2 */

    ess-switch1@1 {
        compatible = "qcom,ess-switch-qca8386";
        switch_access_mode = "mdio";
        switch_mac_mode  = <0xc>;
        switch_mac_mode1 = <0xc>;
        switch_cpu_bmp = <0x21>;  /* cpu port bitmap */
        switch_lan_bmp = <0x1c>;  /* lan port bitmap — 3 ports */
        switch_wan_bmp = <0x2>;   /* wan port bitmap — 1 port */
    };
};
```


## Package Versions (this build)

| Package                     | Version         |
|-----------------------------|-----------------|
| kernel                      | 6.18.39         |
| kmod-ath12k                 | 6.18.39.7.2_rc4 |
| ath12k-firmware-qcn9274     | 20260622-r1     |
| ipq-wifi-mercusys_mr47be-v2 | 2026.05.18      |
| wireless-regdb              | 2026.05.30      |
| busybox                     | 1.38.0          |
| dropbear                    | 2026.92         |
| dnsmasq                     | 2.93            |
| firewall4                   | 2025.03.17      |

## Boot / Installation

The MR47BE V2 accepts unsigned FIT images through its U-Boot console.

**UART:**

```text
MR47BE V2
GPIO18 = TX
GPIO19 = RX
GND    = GND
115200 8N1
```
      
|          J1   | V |
|  O  |  O | O  | O |
| VCC | GND| RX | TX|

The safest development path is currently:

```text
UART
  ↓
U-Boot
  ↓
TFTP
  ↓
initramfs-uImage.itb
  ↓
Hardware validation
  ↓
Flash strategy
```

The current recommended first-stage test is **initramfs boot**, rather than immediately overwriting NAND.

## Important: Stock Firmware Recovery

The vendor firmware uses a **Cloud firmware format with RSA verification and AES-CBC encrypted payloads**.

Unsigned `_nosign_` firmware files are rejected by the vendor recovery mechanism. Renaming the firmware version or filename does not bypass the verification.

Therefore:

- ❌ `_nosign_` firmware cannot be used through stock web recovery
- ❌ Renaming the firmware does not bypass verification
- ❌ Other TP-Link/Mercusys signed firmware should not be flashed
- ✅ U-Boot + UART + TFTP is the current development path
- ⚠️ Always preserve the original **ART/Wi-Fi calibration partition**

## Critical Partition

The device uses an A/B NAND layout:

```text
rootfs    → A
rootfs_1  → B
```

The **ART partition contains Wi-Fi calibration data and MAC information**.

> ⚠️ **BACK UP ART BEFORE FLASHING ANYTHING. DO NOT ERASE OR OVERWRITE IT.**

The A/B layout and ART partition were confirmed both from the device partition analysis and directly from the DTB in this build (`partition@b00000` → `art`, `nvmem-layout` → `mac-address@0`).

## Current Limitations

The following areas still require hardware validation or further development:

- [ ] Full Wi-Fi 7 validation
- [ ] Correct production BDF extraction/validation
- [ ] **QCA8386 external switch support.** Chip confirmed present and active in vendor firmware (`ess-switch@3a000000`, `compatible = "qcom,ess-switch-qca8386"`, MDIO-managed, port bitmaps cpu=0x21/lan=0x1c/wan=0x2 — see [DTS Verification](#dts-verification)). Not yet implemented in this OpenWrt port's DTS; mainline OpenWrt does not currently provide a QCA8386 driver.
- [ ] WAN/LAN port validation
- [ ] LED/GPIO validation
- [ ] USB validation
- [ ] Full NAND flash/recovery procedure
- [ ] Stock firmware restoration test
## Project Structure

```text
.
├── target/
│   └── linux/
│       └── qualcommbe/
├── package/
│   └── firmware/
│       └── ipq-wifi/
├── README.md
└── LIVE_SESSION_STATE.md
```

## Credits / Sources

- OpenWrt
- Qualcomm IPQ53xx platform
- Mercusys MR47BE V2 GPL source
- Perceival's IPQ53xx / Flint 3 OpenWrt work
- Hardware teardown and reverse-engineering analysis

## Disclaimer

This is an **experimental community port**.

Flashing custom firmware can permanently damage the device if performed incorrectly. Always keep a complete backup of the original firmware, NAND partitions and especially the ART calibration data.

**Use UART recovery whenever possible.**

---

**Project:** `circassion/openwrt-mr47be-v2`
**Device:** Mercusys MR47BE V2
**Target:** `qualcommbe/ipq53xx`
**Status:** 🟡 Experimental / Build complete, structurally verified / Hardware validation ongoing
