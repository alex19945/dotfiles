import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitHeight: 30
    implicitWidth: netText.implicitWidth

    property string label: "Net?"
    property bool wifiEnabled: true

    function run(cmd) { runner.command = cmd; runner.running = true }
    Process { id: runner }

    function refresh() {
        wifiStateProc.running = true
        connProc.running = true
    }

    // Wi-Fi enabled?
    Process {
        id: wifiStateProc
        command: ["bash", "-lc", "nmcli -t -f WIFI g 2>/dev/null || true"]
        stdout: SplitParser {
            onRead: (line) => {
                const v = line.trim().toLowerCase()
                root.wifiEnabled = (v === "enabled")
            }
        }
    }

    // Active connection label (SSID or Ethernet)
    Process {
        id: connProc
        command: ["bash", "-lc",
            // If Wi-Fi connected, show SSID; else if ethernet connected, show 'Ethernet'; else 'Disconnected'
            "nmcli -t -f TYPE,STATE,CONNECTION dev status 2>/dev/null | " +
            "awk -F: '($2==\"connected\"){print $1\":\"$3; exit} END{}' | " +
            "sed 's/^wifi:/WiFi: /; s/^ethernet:/Eth: /; s/:$//; /^$/ {print \"Offline\"}'"
        ]
        stdout: SplitParser {
            onRead: (line) => root.label = line.trim()
        }
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
        width: netText.implicitWidth + 16
        radius: 8
        color: "#26263a"

        Text {
            id: netText
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
                    // Toggle Wi-Fi
                    root.run(["bash", "-lc", "nmcli radio wifi " + (root.wifiEnabled ? "off" : "on")])
                    Qt.callLater(root.refresh)
                } else if (mouse.button === Qt.RightButton) {
                    // Open a network UI if available
                    root.run(["bash", "-lc", "command -v nm-connection-editor >/dev/null && nm-connection-editor || (command -v nmtui >/dev/null && nmtui || true)"])
                }
            }
        }
    }
}
