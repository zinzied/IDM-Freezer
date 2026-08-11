<img width="956" height="475" alt="image" src="https://github.com/user-attachments/assets/c0b6a1bc-9b5e-4eb5-a7b3-b25df1cf7e4b" />

# IDM Tool - Unified Activation Manager

**ZIEDEV 2026 | https://github.com/zinzied**

A single-file menu-driven tool to activate, freeze, reset, and manage Internet Download Manager (IDM) on Windows. Simply run the .exe as Administrator.

---

## Files

| File | Description |
|------|-------------|
| [IDM-Freezer-Activation-Tool.exe](https://github.com/zinzied/IDM-Freezer-Activation-Tool/releases/download/IDM-Freezer-Activation-Tool.exe) | Standalone executable — no Python or additional files needed |

---

## How to Run

1. Download `idm_tool.exe` from: https://github.com/zinzied/IDM-Freezer-Activation-Tool/releases/download/IDM-Freezer-Activation-Tool.exe

2. Double-click the downloaded `IDM-Freezer-Activation-Tool.exe`
3. Run it as Administrator
4. The menu appears

---

## Features

- **Lifetime Activation** - Activate IDM with a permanent serial
- **Freeze Trial** - Freeze the 30-day trial period forever
- **Freeze Activation** - Apply serial + block online verification (recommended)
- **Reset** - Clear all IDM registration and trial data
- **Status Check** - View current IDM registration state
- **Enable Updates** - Allow IDM updates (with warning that it breaks activation)
- **Crash logging** - Errors saved to `idm_tool_crash.log` for debugging
- **Automatic Hosts File Cleaning** - Before activation, freeze, reset, or quick activate, the tool removes any existing IDM server blocks from the hosts file to ensure a clean state for activation

---

## Menu Options

| Option | Action | Description |
|--------|--------|-------------|
| **1** | Activate IDM (Lifetime) | Full activation via embedded engine |
| **2** | Freeze 30-Day Trial | Freeze trial permanently without serial |
| **3** | Reset Activation / Trial | Clear all IDM registration data |
| **4** | Quick Activate (Direct) | Apply random serial directly to registry |
| **5** | Check IDM Status | View current registration state |
| **6** | Restart IDM | Kill and relaunch IDM |
| **7** | **Freeze Activation** | **Recommended** — Serial + block online verification |
| **8** | Enable IDM Updates | Allow updates (will break activation!) |
| **0** | Exit | Close the tool |

---

## Recommended Workflow

### First Time / Fresh Install

1. Close IDM completely (including system tray icon)
2. Run `idm_tool.exe` as Administrator
3. Choose **[7] Freeze Activation**
4. Let it restart IDM automatically when prompted
5. In IDM, go to **Help -> Register IDM** to verify:
   - Status: Registered
   - Type: Lifetime

### Why Option 7 is Best

**Option 7** does three things:
1. Applies a **randomly generated serial** to the registry
2. Blocks IDM's validation servers in your `hosts` file (after cleaning any existing blocks)
3. Disables IDM's update check

This prevents the "Fake Serial" popup forever because IDM can never phone home to verify the serial.

---

## Updating IDM (Not Recommended)

Updating IDM to a new version will **break your activation**. If you must update:

1. Run this tool and choose **[8] Enable IDM Updates**
2. Update IDM through its official updater
3. **Immediately re-run this tool and choose [7] Freeze Activation again**

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Window closes instantly | Check `idm_tool_crash.log` in the same folder, or run from CMD/PowerShell |
| "Fake Serial" popup appears | Use **Option 7** (Freeze Activation) instead of Option 1 |
| Activation lost after update | Re-run **Option 7** after each IDM update |
| IDM not found | Make sure IDM is installed in the default location |
| UAC prompt does not appear | Right-click `idm_tool.exe` and select **Run as administrator** |

---

## Disclaimer

This tool is for educational and research purposes only. Use at your own risk. The authors are not responsible for any misuse or damage caused by this software.
