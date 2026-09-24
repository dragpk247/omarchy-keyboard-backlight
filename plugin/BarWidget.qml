import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "user.kbd-backlight"

  property bool isOn: false

  function refresh() {
    if (!checkProc.running) checkProc.running = true
  }

  function toggle() {
    if (root.bar) {
      root.bar.run("asus-kbd-sync toggle")
    }
    root.isOn = !root.isOn
    refreshTimer.restart()
  }

  function openMenu() {
    if (root.bar) {
      root.bar.run("asus-kbd-menu")
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Process {
    id: checkProc
    command: ["bash", "-c", "brightnessctl --device='asus::kbd_backlight' get 2>/dev/null || echo 0"]
    stdout: SplitParser {
      onRead: function(line) {
        var val = parseInt(String(line).trim(), 10)
        root.isOn = !isNaN(val) && val > 0
      }
    }
  }

  Timer {
    id: refreshTimer
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    active: root.isOn
    tooltipText: root.isOn ? "Keyboard Backlight: ON (Click for menu & toggle)" : "Keyboard Backlight: OFF (Click for menu & toggle)"
    onPressed: function(b) {
      root.openMenu()
    }
  }
}
