# 🚀 MR47BE v2 — Stock to OpenWrt

**Written for people who have never changed router firmware.** Follow the steps in order, do not skip.

⏱️ Total time: **~15 minutes** (+ 5 minutes for the router to settle)

🌍 Languages: [Türkçe](KURULUM_TR.md) · **English** · [Русский](INSTALL_RU.md) · 🔧 [Technical / recovery](TEKNIK_TR.md)

> [!WARNING]
> This firmware is **unofficial**. Use it at your own risk. It may affect your warranty. For the **Mercusys MR47BE v2** only.

---

## 1️⃣ Read this first

✅ **Your stock firmware is NOT deleted.** The flash has two separate areas:

| Area | Contents |
|---|---|
| Area 1 | **Stock firmware** (Mercusys UI) — untouched |
| Area 2 | **OpenWrt** — we write here |

🔙 You can go back to stock at any time: **hold reset for 26 seconds**.

❌ **Never flash over Wi-Fi.** Use a cable.

❌ Do not unplug power and do not press reset while flashing.

✅ The device must run stock **1.1.11**.

✅ The device must be **v2**. The label under the router shows **Ver: 2.x**.

---

## 2️⃣ What you need

- 🔌 One **Ethernet cable** (computer ↔ router)
- 🌐 A **browser** (Chrome / Edge / Firefox)
- 📦 This file: **`openwrt-qualcommbe-ipq53xx-mercusys_mr47be-v2-transition.bin`**
- 🔐 (Optional) verify the file with `SHA256SUMS.txt`

> [!NOTE]
> The file name does not matter. You may rename it.

---

## 3️⃣ Which port?

| Port | Status | What to do |
|---|---|---|
| **LAN1** | ⚠️ 2.5G port | Not every PC has 2.5G, and it can come up late on some boots. **Not recommended.** |
| **LAN2** | ✅ Works | **Recommended** |
| **LAN3** | ✅ Works | You can use it |
| **WAN** | 🌍 Internet input | Leave alone for now |

👉 Plug the cable into **LAN2**, the other end into your computer.

⏳ After flashing, the LAN ports can take **1–2 minutes** to come up. That is normal.

---

## 4️⃣ Open the stock web UI

**Step 1.** In your browser go to **http://192.168.1.1**

**Step 2.** If it asks for a password on a factory-fresh device, it is on the **label** under the router.

**Step 3.** Unknown password? While the router runs, **hold reset for 10 seconds**. It resets, then use the label password.

👀 **You should see:** the Mercusys web interface.

**Version check:** make sure the firmware version is **1.1.11**.

> [!TIP]
> Different version? First download and install **1.1.11** from the Mercusys support site. If you cannot find it, open an **Issue** on GitHub.

---

## 5️⃣ If your computer gets no IP

Sometimes the PC does not get an IP automatically and the page will not open. Set the IP by hand.

| When | Your PC's IP | Subnet mask |
|---|---|---|
| Stock UI (`192.168.1.1`) does not open | `192.168.1.10` | `255.255.255.0` |
| OpenWrt (`192.168.5.1`) does not open | `192.168.5.10` | `255.255.255.0` |

**On Windows:** Settings → Network & Internet → Ethernet → IP assignment → Edit → Manual → IPv4 on → enter the values above → Save.

🔁 When finished, switch back to **Automatic (DHCP)**.

---

## 6️⃣ Upload the file

**Step 1.** Open **System → Firmware Upgrade**.

**Step 2.** Click **Browse / Choose File**.

**Step 3.** Select `...transition.bin`.

**Step 4.** Click **Upgrade** and confirm.

⏳ **What happens:** a progress bar runs for **1–2 minutes**, the router **reboots by itself**, LEDs may blink oddly. All normal.

🧘 After the reboot OpenWrt may take **3–5 minutes** to start. Do not unplug anything.

---

## 7️⃣ Log into OpenWrt

**Step 1.** Go to **http://192.168.5.1**

**Step 2.** Username: **`root`**

**Step 3.** Password: **empty**. Press Log in directly.

👀 **You should see:** the OpenWrt (LuCI) interface.

> [!TIP]
> Not loading? Wait 3–5 more minutes, move the cable from LAN2 to LAN3 and wait a minute. Still not? Do the IP setting in section 5.

---

## 8️⃣ 🔒 First thing: change the passwords

> [!CAUTION]
> OpenWrt has **no root password** at first and the Wi-Fi password is **`12345678`**. This password is public. Change both now.

| What | Where |
|---|---|
| 🔑 Router password | **System → Administration → Router Password** |
| 📶 Wi-Fi password | **Network → Wireless → Edit → Wireless Security → Key** |

Change the Wi-Fi password for **all 3 networks** (2G, 5G, 6G).

---

## 9️⃣ Wi-Fi networks

Three networks are ready out of the box:

| Network (SSID) | Password | Best for |
|---|---|---|
| `OpenWRT_2G` | `12345678` | Old devices / longest range |
| `OpenWRT_5G` | `12345678` | **Daily use (recommended)** |
| `OpenWRT_6G` | `12345678` | New phones and laptops, fastest |

> [!NOTE]
> Security is **WPA3**. If a very old device cannot connect, try `OpenWRT_2G` or switch that network to WPA2 in LuCI.

---

## 🔟 Connect the internet

**Step 1.** Plug the internet cable from the modem into the **WAN** port.

**Step 2.** OpenWrt gets an IP automatically (DHCP).

**Step 3.** Check: **Network → Interfaces** → the `wan` row should show **up** and an IP.

🎉 You now have internet on cable and Wi-Fi.

---

## 1️⃣1️⃣ 🔙 Going back to stock

While the router is **running OpenWrt**:

**Step 1.** Insert a paperclip into the **reset** hole.

**Step 2.** **Hold for 26 seconds.** Count with your phone's stopwatch.

**Step 3.** Release. The router reboots by itself.

**Step 4.** After **~1 minute** the stock UI opens: **http://192.168.1.1**

| Hold time | Result |
|---|---|
| less than 1 s | just reboots |
| **5–14 s** | wipes OpenWrt settings, stays in OpenWrt |
| **15 s and more (do 26 s)** | 🔙 **returns to stock firmware** |

> [!TIP]
> Your stock settings (Wi-Fi name and password) stay as they were, unless you factory-reset the stock firmware.

---

## 🆘 If something goes wrong

| Symptom | Cause | Fix |
|---|---|---|
| Upload fails | Wrong file | Use the correct `...transition.bin`, check SHA-256 |
| Still boots stock after upload | Upload incomplete | Repeat the upload |
| `192.168.5.1` does not open | Network still starting | Wait 5 min, move cable to LAN3, set the IP from section 5 |
| Cable plugged, no IP | Port not up yet | Wait 2 min, use **LAN2** |
| Wi-Fi has no internet | WAN cable not plugged | Plug the internet cable into WAN |
| 2.4G Wi-Fi does not connect | Rare / client issue | Use **5G or 6G** |
| LuCI says "Sysupgrade is not supported" | Normal for this board | **"Force upgrade" writes nothing.** Upload this image from the stock UI |
| Cannot return to stock | Too short a press | Hold **26 seconds** |
| Device does not boot at all | Rare | No panic, recover over UART: [TEKNIK_TR.md](TEKNIK_TR.md) |

### 🙋 When asking for help, include

Open an Issue with this information, it speeds things up a lot:

- The **Ver** on the device label
- Stock version number
- Which **step** you are stuck on
- LED status (on / blinking / off)
- Which LAN port you used

---

## ❓ FAQ

**Is the stock firmware gone?**
No. It lives in a separate flash area and reset boots it again.

**Can I flash over Wi-Fi?**
No. Cable only.

**The upload stopped halfway, what now?**
Do not unplug. Wait 10 minutes. If it does not boot: reset 26 s → stock. If that fails, use UART.

**How do I verify the download?**
Compare with `SHA256SUMS.txt`. On Windows: `certutil -hashfile <file> SHA256`

**Can I update OpenWrt?**
LuCI "Sysupgrade" is **not supported** on this board. For a new release, use the same method (stock → upgrade).

---

## ✅ Checklist

- [ ] Device is **v2** and runs stock **1.1.11**
- [ ] Cable in **LAN2**, Wi-Fi off
- [ ] `192.168.1.1` opened and logged in
- [ ] `...transition.bin` uploaded
- [ ] Router rebooted, waited 5 minutes
- [ ] `192.168.5.1` opened
- [ ] **root password changed**
- [ ] **Wi-Fi passwords changed**
- [ ] WAN cable plugged, internet works
- [ ] Tested from a phone over Wi-Fi
- [ ] (Optional) tested return to stock with a 26 s reset

🎉 **Done!**
