# MR47BE v2 — Flashing & Recovery (v26)

Scope: Mercusys **MR47BE v2** (label `Ver: 2.x`) · stock **1.1.11** · image **v26 / kernel 6.18.62**
Downloads: https://github.com/circassion/openwrt-mr47be-v2/releases/tag/v26

> Unofficial community build. Use at your own risk. If you have UART access, take a full NAND backup first (especially ART).
> **Note:** the published image assets were refreshed with the **v27** build (kernel 6.18.62).
> The file names are unchanged; the checksums below match the files in the release.

## 0. Rules
- **Wired only** — never flash over Wi-Fi.
- Plug into **LAN2 or LAN3**. Not WAN, and not LAN1 during the transition.
- Do not cut power while flashing; wait **3–5 minutes** after the reboot.
- **Stock is not erased.** Two flash slots: `tp_boot_idx=0` stock, `=1` OpenWrt.
- Prefer the built-in NIC or an **Intel i225**; some Realtek 2.5G USB adapters break the transfer.
- Let the router **cool down** between attempts; heat can stop the 2.4 GHz radio from coming up.

## 1. Files
| File | Purpose |
|---|---|
| `transition_1_1_11_to_openwrt_6_18_62_FINAL_v26.bin` | stock 1.1.11 → OpenWrt v26 (one step) |
| `openwrt-...-transition-v26.bin` | same bytes, repo name |
| `openwrt-...-squashfs-sysupgrade.bin` | OpenWrt → v26 update |
| `MR47BE(EU)_V2_1.1.11 Build 20260302` | recovery / back to stock |
| `factory.ubi`, `uImage.itb`, `initramfs-uImage.itb` | development / UART / TFTP |

SHA-256 (transition): `9d3d075f8638a13900dc4f4741cf947edc50cc1ef89363ee9a62e2c7225f65b9`
SHA-256 (sysupgrade): `9603b128cd300ec84045dffd3096fcfd2e1c53d652027898033fbd66b7378f5a`
Verify: `certutil -hashfile <file> SHA256`

## 2. Stock → OpenWrt (one step)
1. Cable into LAN2, PC set to **DHCP**.
2. Browser: **http://192.168.1.1** → stock Mercusys UI. Password is on the label; unknown → hold reset 10 s.
3. Confirm the stock version is **1.1.11**.
4. **System → Firmware Upgrade → Local Upgrade** → `transition_..._FINAL_v26.bin` → **Upgrade**.
5. The bar runs 1–2 min, the router reboots on its own. Then wait 3–5 min.
6. **http://192.168.5.1** → user `root`, **empty** password.
7. If OpenWrt boots but the next reboot returns to stock, make it permanent:
   `fw_setenv tp_boot_idx 1` → `reboot`
8. First actions: set a root password, change the `OpenWRT_2G/5G/6G` keys (`12345678`), set your country code.

## 3. Updating OpenWrt (v11…v25 → v26)
LuCI → **System → Backup / Flash Firmware → Flash new firmware image** → `...squashfs-sysupgrade.bin`.
"Keep settings" may stay checked. From very old builds (v10/v13) do a clean install.

    scp openwrt-...-squashfs-sysupgrade.bin root@192.168.5.1:/tmp/
    ssh root@192.168.5.1
    sysupgrade -v /tmp/openwrt-...-squashfs-sysupgrade.bin    # keep settings
    sysupgrade -n /tmp/openwrt-...-squashfs-sysupgrade.bin    # clean install

❌ Never sysupgrade `transition.bin` / `factory.ubi` / `factory.bin` — those are for the stock WebUI only.

## 4. Back to stock (3 ways)
**A. SSH (easiest):**
    fw_printenv tp_boot_idx     # 1 = OpenWrt, 0 = stock
    fw_setenv tp_boot_idx 0
    reboot
OpenWrt is not deleted; only the boot slot switches.

**B. Reset button (while OpenWrt runs):**
| Hold | Result |
|---|---|
| < 1 s | reboot |
| 5–14 s | reset OpenWrt settings |
| **15–26 s** | **back to stock** |
The LED starts blinking around 15 s — you may release then; 26 s maximum.

**C. UART / U-Boot:**
    setenv tp_boot_idx 0
    saveenv
    reset

## 5. Emergency recovery — U-Boot web (no UART needed)
Works even if both slots are broken. **Accepts signed stock files only.**
1. Unplug power.
2. **Hold RESET**, plug power in, keep holding **~25–26 s**, release.
3. Static IP on the PC: **192.168.1.100 / 255.255.255.0**, gateway 192.168.1.1. Cable in **LAN2/LAN3**.
4. **http://192.168.1.1** (or http://mwlogin.net). If it redirects to `/bin/cgi`, clear the cache or use a private window.
5. **Choose file** → stock **1.1.11** → **Upload** → **Continue**. Do not power off.
6. The router boots into stock. Set the PC back to **DHCP**.

## 6. UART (115200 8N1, 3.3 V)
J1: `NC – GND – RX – TX`. **Never connect the adapter's VCC**; never use RS-232 levels.
U-Boot prompt: `IPQ5332#`

Web recovery:
    setenv serverip 192.168.1.2
    setenv ipaddr 192.168.1.1
    httpd
PC: 192.168.1.2 → browse 192.168.1.1

RAM boot test (temporary):
    tftpboot 0x46000000 openwrt-...-initramfs-uImage.itb
    bootm 0x46000000
RAM-boot IP is 192.168.5.1 → PC 192.168.5.100. Do not use `0x44000000` (collision).

## 7. Troubleshooting
| Symptom | Fix |
|---|---|
| Page won't open / no IP | Static IP on PC: stock 192.168.1.10, OpenWrt 192.168.5.10 / 255.255.255.0 |
| Upload rejected | Wrong file or bad download → compare SHA-256 |
| Boots stock again | In OpenWrt: `fw_setenv tp_boot_idx 1` |
| SSH "host key changed" | `ssh-keygen -R 192.168.5.1` |
| LuCI "Sysupgrade is not supported" | Use `sysupgrade.bin`, or SSH `sysupgrade -n` |
| 2.4 GHz missing, unstable link | Cool the router down, retest 2–3 cold boots |
| Won't boot at all | Section 5 (reset + power) → then Section 6 (UART) |

## 8. Notes
- LED-to-port mapping is not done yet; cosmetic only, no effect on the data path.
- `wan` always reports 2500 (fixed SoC↔PHY link); the PHY negotiates the line rate. 100 Mbps means the ISP side.
- kmod packages can only come from this image (custom kernel hash).
- When asking for help, include: label `Ver`, stock version, the step you stopped at, LED state, which LAN port you used.