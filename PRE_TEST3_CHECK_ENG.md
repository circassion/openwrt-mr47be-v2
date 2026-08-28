# PRE_TEST3_CHECK.md — MR47BE V2 OpenWrt v0.1.0-test3 Verification Report

**Method:** This report is based on the actual binary images from the uploaded
zip, not on the claims in RELEASE_NOTES. The FIT image was unpacked with
`dumpimage`, the `fdt-1` (device tree blob) was decompiled with `dtc`, the
uncompressed kernel size was computed from the gzip trailer, and all 4
blockers plus the boot address were verified statically/mathematically.

**Date:** 2026-08-26
**File verified:** `openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb`

---

## 0. File integrity

SHA256 hashes **match RELEASE_NOTES exactly**:

```
d8e867ed25bda8a9292c44ba4d68ffc73eaa853a2ef55094e4b225d114b0ddfd  *-squashfs-factory.bin
d8e16279eb7ff714e80aa0f85cb69dc179dfe6185e297bdc211d8a847ae653e8  *-squashfs-sysupgrade.bin
06f6a6721987a0b336ddbc7cd131ce7cad2ea1148e611aed2f176cc885154059  *-initramfs-uImage.itb
fef1cf0412b04bc1f557ee728fc5ee41159ed111b3e69184d29aeda341ab7302  *-uImage.itb
```

`file` output: initramfs/uImage → valid DTB header (`Device Tree Blob version 17`);
factory.bin → valid `UBI image, version 1`; sysupgrade.bin → valid
`POSIX tar archive (GNU)`. No file is corrupted or truncated.

---

## 1. Finding B — NAND partition table

**Source:** `fdt-1.dts`, `partitions { compatible = "fixed-partitions" }` block.

```
0:sbl1          @ 0x000000  / 0x180000   read-only
0:mibib         @ 0x180000  / 0x100000   read-only
0:bootconfig    @ 0x280000  / 0x080000   read-only
0:bootconfig1   @ 0x300000  / 0x080000   read-only
0:qsee          @ 0x380000  / 0x240000   read-only
0:devcfg        @ 0x5c0000  / 0x080000   read-only
0:tme           @ 0x640000  / 0x080000   read-only
0:cdt           @ 0x6c0000  / 0x080000   read-only
0:appsblenv     @ 0x740000  / 0x080000   read-only
0:appsbl        @ 0x7c0000  / 0x140000   read-only
0:art           @ 0x900000  / 0x200000   read-only   ← ART, preserved
secure-binary   @ 0xb00000  / 0x080000   read-only
ubi             @ 0xb80000  / 0x34c0000
rootfs_1        @ 0x4040000 / 0x34c0000  read-only   ← B slot, preserved
tp_data         @ 0x7500000 / 0x0a00000
data            @ 0x7f00000 / 0x080000
reserverd_data  @ 0x7f80000 / 0x080000
```

**Total:** `0x7f80000 + 0x80000 = 0x8000000` = **exactly 128 MiB**, matching
the flash size precisely. No overlaps, no gaps, no overflow. The NAND
controller node (`qcom,ipq5332-snand`) and its parent bus are consistent.

**Result:** ✅ Matches the RELEASE_NOTES table exactly. ART and the B slot
(`rootfs_1`) are marked read-only — this is the actual mechanism that removes
the soft-brick risk.

---

## 2. Finding C — PHY `compatible` removal

**Source:** `fdt-1.dts`, `ethernet-phy@1..4` nodes under `mdio@90000`.

```dts
ethernet-phy@1 { reg = <0x01>; };
ethernet-phy@2 { reg = <0x02>; };
ethernet-phy@3 { reg = <0x03>; };
ethernet-phy@4 { reg = <0x04>; };
```

No `compatible` property present — grepping for `ethernet-phy-id004d.d0b0`,
`004dd0b0`, `8075`, `QCA8075` returns zero matches anywhere in the DTB. In the
kernel binary:

```
strings kernel-1 | grep -i "qca808\|qca8084"
→ "Qualcomm QCA8084"
→ qca808x.ko
→ qca8084_probe, qca8084_config_init, qca8084_package_pcs_probe, ...
```

**Result:** ✅ The hard-coded wrong PHY ID (QCA8075) has been removed; the
nodes are now open to ID auto-probing, and the correct driver (QCA8084) is
actually compiled into the kernel and present.

---

## 3. Finding D — SoC↔switch topology

**Source:** `fdt-1.dts`, `port@1` (lan) and `port@2` (wan) nodes.

```dts
port@1 {
    label = "lan";
    pcs-handle = <...>;
    phy-mode = "2500base-x";
    fixed-link { speed = <0x9c4>; full-duplex; pause; };
    /* no phy-handle, no in-band-status */
};

port@2 {
    label = "wan";
    pcs-handle = <...>;
    phy-mode = "2500base-x";
    fixed-link { speed = <0x9c4>; full-duplex; pause; };
};
```

`speed = 0x9c4` = 2500 (Mbps). Neither port has a `phy-handle` (PHY-less,
direct MAC↔switch CPU port link), and no `in-band-status` property was found.

**Result:** ✅ Consistent with the vendor `SGMII_PLUS` design; test2's
`in-band-status` regression has genuinely been reverted.

---

## 4. Finding G — PHY reset timing

**Source:** `fdt-1.dts`, `mdio@90000` node:

```dts
mdio_clk_fixup;
reset-gpios = <0x14 0x10 0x01>;
reset-assert-us = <0x186a0>;    /* = 100000 µs = 100 ms */
reset-deassert-us = <0x186a0>;  /* = 100000 µs = 100 ms */
```

**Result:** ✅ Set to 100/100 ms, matching the vendor `mdio-qca.c` range
(100–110 ms).

---

## 5. Finding A — Boot address (critical, mathematically verified)

The kernel's actual load/entry address in the FIT image is **`0x41000000`**
(from `dumpimage -l` output). The uncompressed kernel size was computed from
the last 4 bytes of the gzip stream (ISIZE mod 2³²):

```
Compressed size  : 22,619,658 bytes  (~21.57 MiB)
Uncompressed size : 56,616,968 bytes  (~54.0 MiB)
```

So the `bootm` decompression step writes to RAM across this range:

```
0x41000000  →  0x445FE808
```

I compared this range against the three candidate TFTP load addresses:

| TFTP load address | Decompression end | Overlap | Margin |
|---|---|---|---|
| `0x44000000` (old, RELEASE_NOTES says "DO NOT USE") | `0x445FE808` | **YES** | **−5.99 MiB (overlap)** |
| `0x45000000` (fallback address) | `0x445FE808` | No | +10.01 MiB |
| `0x46000000` (new/corrected) | `0x445FE808` | No | +26.01 MiB |

The computed overlap for `0x44000000` (**5.99 MiB**) matches the "5.99 MiB"
figure quoted in RELEASE_NOTES exactly — so the claim that "the kernel
overwrites its own compressed source" isn't an assumption, it's arithmetically
correct.

Additionally, the nearest reserved-memory carve-out (`tzapp@0x49600000`) is
still safely beyond the `0x46000000` + source-size range (~`0x4759260A`) — no
collision risk with firmware/TZ regions either.

**Result:** ✅ `0x44000000` is genuinely broken; `0x46000000` is mathematically
safe with a comfortable margin. The `0x45000000` fallback address also works
technically, but with a tighter margin (~10 MiB).

> Note: The RELEASE_NOTES warning about `0x47000000`/`0x48000000` causing
> "TFTP file size too large" cannot be confirmed through static image
> analysis — it's most likely related to U-Boot's TFTP receive buffer /
> `filesize` env limit, and can only be confirmed from an actual console log.

---

## 6. Other checks

- **`serial_0_pins` duplicate cleanup:** Because the compiled DTB doesn't
  preserve original source node labels (dtc decompile turns them into
  phandles), this can't be verified directly from the binary. Indirect
  evidence: the decompiled tree contains **no** two UART pinctrl nodes with
  conflicting `reg` addresses — at minimum showing no build-time conflict/duplicate error.
- **Missing QCA8386 switch driver (Known limitations):** The `.manifest` file
  contains no switch packages at all (`qca-ssdk`, `kmod-qca8k`, `swconfig`
  are absent) — this claim is accurate, not exaggerated. Only `kmod-libphy`,
  `kmod-phylink`, and `wireless-regdb` are present.
- **Wi-Fi packages:** `ath12k-firmware-ipq5332`, `ath12k-firmware-qcn9274
  20260622-r1`, `ipq-wifi-mercusys_mr47be-v2 2026.05.18`, `kmod-ath12k` —
  match the version numbers in RELEASE_NOTES exactly.
- **UBI/factory image size:** `squashfs-factory.bin` is 20 MiB, the `ubi`
  partition is 0x34C0000 (~53 MiB) — the image fits comfortably inside the
  partition, leaving room for overlay/rootfs_data growth.

---

## 7. Overall assessment

| Blocker | Status |
|---|---|
| Finding A — Boot address | ✅ Fixed, mathematically verified |
| Finding B — Partition table | ✅ Fixed, verified at hash level |
| Finding C — PHY compatible | ✅ Fixed, removal confirmed + correct driver present |
| Finding D — Port topology | ✅ Fixed, in-band-status regression reverted |
| Finding G — Reset timing | ✅ Fixed, 100/100 ms confirmed |

**Note on brick risk:** The documented procedure (`tftpboot` + `bootm`,
address `0x46000000`) contains no NAND write commands whatsoever; as written,
RAM boot never physically touches flash. The "zero risk" claim is technically
accurate **as long as the procedure is followed exactly as documented** — if
the user manually runs a command like `nand write` or `ubiformat`, that
guarantee no longer holds.

**Conclusion:** The 3 DTS/layout blockers found in the test1/test2 audit, plus
the separately identified boot-address bug, have genuinely and correctly been
fixed in the test3 images. The images are structurally sound and ready for
RAM-boot hardware testing.

**Verification method:** `dumpimage`, `dtc`, `strings`, `sha256sum`, gzip
trailer analysis — static/offline analysis only. Actual hardware behavior
(PHY link-up, Wi-Fi bring-up, etc.) remains hardware-untested; this report
covers image/DTS correctness only.
