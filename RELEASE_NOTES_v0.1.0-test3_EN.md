# MR47BE V2 OpenWrt v0.1.0-test3

**Mercusys MR47BE V2 (IPQ5332 / Wi-Fi 7) — experimental OpenWrt build**

> ⚠️ **EXPERIMENTAL. Do NOT flash to NAND yet.**
> Boot via UART → U-Boot → TFTP → `initramfs-uImage.itb` (RAM only, zero flash risk).

---

## Why test3 exists

In the deep audit (2026-08-25) of the test1/test2 `PRE_TEST_CHECK.md`, all 70
technical claims were verified and the images were confirmed to be
**structurally sound**. However, 3 blockers were found, and all of them were
**DTS/layout** errors — not kernel/config issues. test3 was produced to fix
these blockers:

| # | Fix | Blocker |
|---|---|---|
| 1 | **Partition table pinned to the real NAND layout** — `0:art` → `0x900000` `0x200000`, `ubi` → `0xB80000` `0x34C0000`, + `rootfs_1`/`tp_data`/`data`/`reserverd_data` (A/B backup preserved as read-only) | Finding B (soft-brick risk) |
| 2 | **PHY `compatible` removed** — `ethernet-phy-id004d.d0b0` (=QCA8075, wrong chip) was hard-coded and blocking auto-probe; now ID probing can find the real QCA8084 (`0x004dd180`) driver | Finding C |
| 3 | **Topology aligned with vendor** — `port@1`+`port@2` (lan+wan) SoC MACs to the QCA8386 CPU port **without a PHY**, `fixed-link 2500/full`; `phy-mode = "2500base-x"` (vendor `SGMII_PLUS`). test2's `in-band-status` regression was reverted | Finding D |
| 4 | **PHY reset timing** `10/50 ms` → `100/100 ms` (vendor `mdio-qca.c` 100–110 ms) | Finding G |

**Critical note (Finding A):** The `tftpboot 0x44000000` + `bootm 0x44000000`
commands written in RELEASE_NOTES/test1 and test2 **do not work on the actual
hardware** — the FIT kernel unpacks to 0x41000000 and overwrites its own
compressed source (`ERROR: new format image overwritten - must RESET the
board`). The correct address is: **`0x46000000`**.

---

## What's new (vs test2)

- Partition table, PHY ID, topology, and reset timing fixed (see table above)
- Kernel/config/driver set is **identical** to test2 (6.18.39, `CONFIG_QCA83XX_PHY` already built-in; `kmod-phy-qca83xx` package present)
- Duplicate `serial_0_pins` block removed from the DTS (already present in the dtsi)

## Included

- Linux **6.18.39** (ARM64, `qualcommbe/ipq53xx`)
- MR47BE V2 device tree + `mercusys_mr47be-v2` board definition
- Wi-Fi firmware/BDF: `ath12k-firmware-qcn9274` 20260622-r1,
  `ipq-wifi-mercusys_mr47be-v2` 2026.05.18
- FIT kernel, initramfs, factory UBI, sysupgrade images
- USB (DWC3/xHCI/storage), block-mount, dropbear SSH, firewall4

## Images

| Image | Size | Purpose |
|---|---|---:|
| `*-initramfs-uImage.itb` | ~21.6 MB | **RAM boot / hardware test (recommended)** |
| `*-uImage.itb` | ~5.7 MB | FIT kernel |
| `*-squashfs-factory.bin` | 20 MB | Factory UBI image |
| `*-squashfs-sysupgrade.bin` | ~19 MB | OpenWrt sysupgrade |

## SHA256 (calculated after build)

```
d8e867ed25bda8a9292c44ba4d68ffc73eaa853a2ef55094e4b225d114b0ddfd  openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-factory.bin
d8e16279eb7ff714e80aa0f85cb69dc179dfe6185e297bdc211d8a847ae653e8  openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-squashfs-sysupgrade.bin
06f6a6721987a0b336ddbc7cd131ce7cad2ea1148e611aed2f176cc885154059  openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
fef1cf0412b04bc1f557ee728fc5ee41159ed111b3e69184d29aeda341ab7302  openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-uImage.itb
```

> uImage.itb (kernel FIT) is deterministic across builds; the initramfs/factory/sysupgrade
> rootfs changes by a few hundred bytes each build due to the timestamp — the hashes above
> belong to the files in `images/test3/`.

## Boot / test (CORRECTED address)

```text
UART (GPIO18 TX / GPIO19 RX, 115200 8N1)
  → U-Boot console
  → setenv serverip 192.168.1.100
  → setenv ipaddr 192.168.1.1
  → tftpboot 0x46000000 openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-initramfs-uImage.itb
  → bootm 0x46000000
```

> ⛔ **DO NOT use** `0x44000000` — bootm conflict, 5.99 MiB (Finding A)
> ⛔ **DO NOT use** `0x47000000` / `0x48000000` — TFTP "file size too large"
> ⚠️ `0x50000000` only if `bdinfo` confirms 512 MiB
> ✅ Fallback address: `0x45000000`

RAM boot only. NAND is untouched.

## Post-boot checklist (zero risk)

1. Check the console banner for a kernel panic
2. `ip link` → does it match the MAC label (Finding J test — if it doesn't match, the partition table needs to be re-verified)
3. `dmesg | grep -i "mdio\|phy"` → were the PHYs found (Finding C)
4. `dmesg | grep -i "ath12k\|bdf\|board-2"` → was the BDF loaded (Finding I)
5. `cat /proc/mtd` → are the partitions in the real layout (Finding B)
6. Plug in the LAN cable → does the link come up (Finding D — may be dead due to missing driver, see §3)

## Known limitations

- **The QCA8386 switch driver is missing from both images** (`ess-switch` string = 0).
  The four ports are not switched by Linux; traffic depends on whatever state
  U-Boot left the switch in. Ethernet will not work on this board with a few DTS
  fixes alone — **this is driver work** (qca-ssdk / mainline DSA). Realistic
  expectation for the first test: **get Wi-Fi (ath12k) up + get a shell over UART.**
- `mdio_clk_fixup`/`phyaddr_fixup` have no counterpart in the kernel and are
  silently ignored (Finding H) — the QCA8386's internal PHYs may not respond on
  MDIO 1–4.
- Wi-Fi BDF is temporary — pending hardware validation (board-id 0x12 vs vendor 0x16).
- Do not write to NAND without confirming the partition table on real hardware
  via `smeminfo` (Finding B). If the `smeminfo` output doesn't match this table,
  do not write until the DTS is fixed.

## Important

- **Never flash unrelated TP-Link/Mercusys firmware** — stock recovery verifies RSA
  signatures; `_nosign_` files are rejected; renaming does not bypass it.
- **Preserve the ART partition** (Wi-Fi calibration + MAC). Real ART is at NAND offset
  `0x900000` (0x200000 = 1 MiB); this DTS marks it read-only.
- A/B layout: `rootfs` (A) + `rootfs_1` (B) — stock firmware can live in B.

## Status

- 🟡 Build: complete
- 🟢 Image analysis: PRE_TEST_CHECK fixes verified (partition table, PHY, topology, reset)
- 🟠 QCA8386: wired as MDIO PHY (auto-probe), **hardware-untested**, no driver
- 🟠 Wi-Fi / Ethernet / USB: hardware validation pending
- 🟢 Brick risk for RAM boot: none (with address 0x46000000)

**Experimental release. Use at your own risk.**
