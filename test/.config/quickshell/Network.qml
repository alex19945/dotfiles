import QtQuick
import Quickshell
import Quickshell.Io

MouseArea {
    id: networkArea
    property string connectionType: "unknown"
    property string wifiDevice: "wlan0"  // Your WiFi device

    width: contentRect.width + 20
    height: parent.height
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    // Timer to periodically check connection type
    Timer {
        id: connectionTimer
        interval: 5000  // Check every 5 seconds
        running: true
        repeat: true
        onTriggered: updateConnectionType()
    }

    // Function to update connection type
    function updateConnectionType() {
        // Check if WiFi is connected using iwctl
        var process = Quickshell.runCommand("iwctl", ["station", networkArea.wifiDevice, "show"]);
        process.onStdout = (data) => {
            console.log("WiFi status:", data);  // Debug output
            if (data.includes("Connected network:")) {
                networkArea.connectionType = "wifi";
            } else {
                networkArea.connectionType = "unknown";
            }
        };
        process.start();
    }

    // Initialize connection type on startup
    Component.onCompleted: updateConnectionType()

    Rectangle {
        id: contentRect
        anchors.centerIn: parent
        width: 40
        height: 32

        color: networkArea.containsMouse ? ThemeManager.surface1 : ThemeManager.surface0
        radius: 6

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        Text {
            id: networkText
            anchors.centerIn: parent
            text: {
                if (networkArea.connectionType === "wifi") return "󰤨"
                else return "󰌙"
            }
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            color: {
                if (networkArea.connectionType === "wifi") return ThemeManager.accentGreen
                else return ThemeManager.accentRed
            }

            Behavior on color {
                ColorAnimation { duration: 200 }
            }
        }
    }

    onClicked: {
        console.log("Network button clicked. Opening network settings...");
        Quickshell.execDetached("alacritty", ["-e", "iwctl"]);
    }
}
