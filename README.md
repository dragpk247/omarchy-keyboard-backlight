# Omarchy Keyboard Backlight & Schedule Manager

A sleek status bar widget, interactive configuration menu, and automated schedule daemon for **[Omarchy](https://omarchy.org/) (Arch Linux + Hyprland)**.

Optimized for **ASUS ROG** laptops (Flow 13, Zephyrus, Strix) using `asusctl` as well as any Linux laptop with a standard `brightnessctl` keyboard backlight device.

---

## ✨ Features

- **Top Bar Widget**: Native Quickshell status bar icon (``) that dynamically illuminates when your keyboard backlight is active.
- **Interactive Laptop-Friendly Menu**: Single left-click opens an interactive Quickshell menu:
  - **Instant Toggle**: Quickly switch the backlight On or Off.
  - **Customizable Turn-OFF Hour**: Set daytime turn-off time (e.g. `09:00`).
  - **Customizable Turn-ON Hour**: Set evening turn-on time (e.g. `18:00`).
  - **Enable / Disable Automation**: Toggle automated scheduling on or off with a single click.
  - **Brightness Presets**: Choose between `low`, `med`, or `high`.
- **Sleep & Resume Watcher**: Automatically listens to systemd-logind D-Bus wake events (`PrepareForSleep`), ensuring the backlight state doesn't desync when waking from sleep or opening the laptop lid.
- **Dual Hardware Sync**: Simultaneously manages `asusctl` (ASUS Aura controller) and `brightnessctl` (kernel sysfs LED class) to eliminate state discrepancies.
- **Omarchy Menu Integration**: Also accessible from the main launcher menu (<kbd>Super</kbd>) under **Trigger ➔ Toggle** and **Setup ➔ Keyboard Backlight Schedule**.

---

## 📦 Requirements

- **Omarchy Linux** (Quickshell + Hyprland)
- `brightnessctl`
- `asusctl` *(optional, recommended for ASUS ROG hardware)*
- `jq`

Install dependencies on Arch/Omarchy:
```bash
sudo pacman -S brightnessctl jq
# For ASUS laptops:
sudo pacman -S asusctl
```

---

## 🚀 Installation

Clone and run the automated installer:

```bash
git clone https://github.com/dragpk247/omarchy-keyboard-backlight.git
cd omarchy-keyboard-backlight
./install.sh
```

The installer will:
1. Copy scripts to `~/.local/bin/`
2. Install the widget to `~/.config/omarchy/plugins/user.kbd-backlight/`
3. Enable the background sleep/resume sync service (`asus-sleep-watcher.service`)
4. Place the widget on your Omarchy top bar and refresh the shell.

---

## 🛠️ CLI Usage

You can control everything directly from your terminal:

```bash
# Check current schedule and hardware status
asus-kbd-sync status

# Toggle backlight on / off
asus-kbd-sync toggle

# Turn backlight on or off directly
asus-kbd-sync on
asus-kbd-sync off

# Open the interactive GUI menu
asus-kbd-menu
```

---

## ⏰ Enabling Automated Day/Night Scheduling (Optional)

By default, the keyboard backlight is set to **100% manual control**, meaning it will only turn on or off when you press your hotkeys or click the widget.

If you prefer your keyboard backlight to automatically turn off during the day (to save battery) and turn on at night, you can easily enable the automated schedule:

### Option 1: Via the GUI Menu (Recommended)
1. Left-click the **``** keyboard icon on your Omarchy top bar (or run `asus-kbd-menu`).
2. Click **`⏰ Auto Schedule: DISABLED`** to toggle it to **ENABLED**.
3. Use the menu items to set your preferred turn-off and turn-on hours (e.g., Off at 09:00, On at 18:00) and brightness level (`low`, `med`, or `high`).

### Option 2: Via Terminal Commands
```bash
# 1. Enable automated scheduling
asus-kbd-sync enable

# 2. Configure daytime turn-off hour (0-23, e.g. 9:00 AM)
asus-kbd-sync set-off 9

# 3. Configure evening turn-on hour (0-23, e.g. 6:00 PM)
asus-kbd-sync set-on 18

# 4. Set evening brightness preset (low, med, or high)
asus-kbd-sync set-brightness med

# 5. Check status
asus-kbd-sync status
```

### Automatic Hourly Sync (Optional)
The included `asus-sleep-watcher` service automatically enforces the schedule whenever your laptop wakes from sleep or you open the lid. If you also want the schedule to automatically enforce on boot or hourly, you can enable the systemd service:

```bash
systemctl --user enable --now asus-kbd-sync.service
```

### To Switch Back to Manual Control Anytime:
```bash
asus-kbd-sync disable
```

---

## ⚙️ Configuration File

Configuration is saved in JSON format at:
```text
~/.local/state/omarchy/settings/kbd-schedule.json
```

Example:
```json
{
  "enabled": false,
  "off_hour": 9,
  "on_hour": 18,
  "brightness": "med"
}
```

---

## 📄 License

MIT License. Feel free to use, modify, and contribute!
