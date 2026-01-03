import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitHeight: 30
    implicitWidth: btText.implicitWidth

    property bool powered: false
    property int connected: 0
    property string label: "BT?"

    function run(cmd) { runner.command = cmd; runner.running = true }
    Process { id: runner }

    function refresh() {
        poweredProc.running = true
        connectedProc.running = true
    }

    Process {
        id: poweredProc
        command: ["bash", "-lc", "bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2; exit}'"]
        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim().toLowerCase()
                root.powered = (v === "yes")
                root.updateLabel()
            }
        }
    }

    Process {
        id: connectedProc
        command: ["bash", "-lc",
            // Count connected devices (requires controller on; still safe if off)
            "bluetoothctl devices Connected 2>/dev/null | wc -l"
        ]
        stdout: SplitParser {
            onRead: (line) => {
                const n = parseInt(line.trim(), 10)
                root.connected = isNaN(n) ? 0 : n
                root.updateLabel()
            }
        }
    }

    function updateLabel() {
        if (!root.powered) root.label = "BT: Off"
        else root.label = (root.connected > 0) ? ("BT: " + root.connected) : "BT: On"
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        height: 22
        width: btText.implicitWidth + 16
        radius: 8
        color: "#26263a"

        Text {
            id: btText
            anchors.centerIn: parent
            text: root.label
            color: "#cdd6f4"
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    // Toggle power
                    root.run(["bash", "-lc", "bluetoothctl power " + (root.powered ? "off" : "on")])
                    Qt.callLater(root.refresh)
                } else if (mouse.button === Qt.RightButton) {
                    // Open bluetooth UI if available
                    root.run(["bash", "-lc", "command -v blueman-manager >/dev/null && blueman-manager || true"])
                }
            }
        }
    }
}
