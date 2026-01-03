import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitHeight: 30
    implicitWidth: statusText.implicitWidth   // IMPORTANT: makes Row allocate space

    property string batteryText: ""
    property bool hasBattery: true  // you confirmed BAT0 exists, so keep it simple

    visible: hasBattery

    function refresh() {
        batteryProc.running = true
    }

    Process {
        id: batteryProc
        // Capacity + status in one go
        command: ["sh", "-c", "echo $(cat /sys/class/power_supply/BAT0/capacity),$(cat /sys/class/power_supply/BAT0/status)"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(",")
                if (parts.length < 2) return

                const cap = parseInt(parts[0].trim(), 10)
                const status = parts[1].trim()

                // Emoji icons that always render
                let icon = "🔋"
                if (status === "Charging") icon = "⚡"
                else if (status === "Full") icon = "🔌"

                const pct = isNaN(cap) ? "?" : cap.toString()
                root.batteryText = `${icon} ${pct}%`
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Text {
        id: statusText
        anchors.verticalCenter: parent.verticalCenter
        text: root.batteryText
        color: "#cdd6f4"
        font.pixelSize: 12
    }
}
