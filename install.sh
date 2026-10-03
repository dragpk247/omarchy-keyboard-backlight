#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing Keyboard Backlight widget & tools for Omarchy..."

# 1. Install CLI scripts
mkdir -p "$HOME/.local/bin"
cp "$REPO_DIR/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/asus-kbd-sync" "$HOME/.local/bin/asus-kbd-menu" "$HOME/.local/bin/asus-sleep-watcher"

# 2. Install Omarchy Plugin
PLUGIN_DIR="$HOME/.config/omarchy/plugins/user.kbd-backlight"
mkdir -p "$PLUGIN_DIR"
cp -r "$REPO_DIR/plugin/"* "$PLUGIN_DIR/"

# 3. Install Systemd Services
SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"
cp "$REPO_DIR/systemd/"*.service "$SYSTEMD_DIR/"

# 4. Initialize Settings
SETTINGS_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/settings"
mkdir -p "$SETTINGS_DIR"
if [ ! -f "$SETTINGS_DIR/kbd-schedule.json" ]; then
    cat << 'EOF' > "$SETTINGS_DIR/kbd-schedule.json"
{
  "enabled": false,
  "off_hour": 9,
  "on_hour": 18,
  "brightness": "med",
  "season": "fall",
  "als_enabled": false,
  "als_threshold": 30
}
EOF
fi

# 5. Enable and start sleep watcher service
systemctl --user daemon-reload
systemctl --user enable --now asus-sleep-watcher.service

# 6. Add widget to bar if not present
if command -v omarchy >/dev/null 2>&1; then
    omarchy-shell shell rescanPlugins 2>/dev/null || true
    echo "==> Ensuring widget is placed on bar..."
    omarchy bar put user.kbd-backlight --before omarchy.bluetooth 2>/dev/null || true
    omarchy restart shell 2>/dev/null || true
fi

echo "==> Installation complete! Click the keyboard icon on your bar to configure."
