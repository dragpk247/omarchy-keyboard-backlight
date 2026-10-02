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

## 🔋 Battery Impact & Power Management

Understanding how hardware LED levels and background services affect battery runtime on portable devices (such as the ASUS ROG Flow 13 and other thin-and-light laptops):

### 1. Hardware Backlight Power Draw Across States

| Backlight State | Sysfs Level | Estimated Power Draw | Battery Runtime Impact (on ~62Wh Battery) | Recommended Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Off** | `0` | **0 mW** | **0% impact** (Maximum battery life) | Daytime, bright rooms, battery-saving mode |
| **Low** | `1` | **~50 – 100 mW** | Negligible (~1–2% total battery over a full discharge) | Dim environments, night typing |
| **Medium** | `2` | **~150 – 250 mW** | Mild (~3–5% reduction in total battery runtime) | Default night setting, balanced illumination |
| **High** | `3` | **~400 – 600 mW** | **Significant** (Can reduce battery runtime by 20–45 mins) | Dark gaming sessions, plugged into AC |

> [!TIP]
> On laptops with compact batteries, keeping the keyboard backlight at **High** while running on battery can draw as much power as an idle CPU core. Setting the brightness preset to `low` or `med` preserves runtime.

---

### 2. Behavior in Different System States

#### 🟢 Awake & Active
* **In Manual Mode (`enabled: false`)**: The backlight stays strictly at whatever level you set. If left at `High` while running on battery, it will continually draw power until manually lowered or toggled off.
* **In Schedule Mode (`enabled: true`)**: Automatically cuts LED power during your configured daytime hours, preventing unintentional battery drain in well-lit environments.

#### 🟡 Screen Idle / Lock Screen
* When the display dims or turns off due to inactivity, the keyboard backlight remains at its current hardware level.
* If you frequently step away from your desk while on battery, either tap the widget / hotkey to toggle the LEDs off or enable the schedule.

#### 💤 Sleep / Suspend (`PrepareForSleep`)
* **Zero Battery Leak:** When the laptop enters suspend (lid closed or idle sleep), the Linux kernel sysfs driver and ASUS EC hardware immediately cut power to the keyboard LEDs.
* Upon wake, `asus-sleep-watcher` ensures hardware state consistency without keeping the CPU awake or blocking low-power sleep states.

#### ⚙️ Background Daemon Impact (CPU & C-States)
* The background services are engineered with zero polling overhead:
  * **CPU Usage:** `0.0%`
  * **Memory Usage:** `< 0.05%` (negligible)
  * **CPU C-States:** The watcher uses D-Bus signal monitoring (`gdbus monitor`) rather than aggressive polling loops, allowing the CPU package to enter deep low-power sleep states (C8/C10) uninterrupted.

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
