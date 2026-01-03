import QtQuick
import Quickshell.Io

Item {
    id: root
    implicitHeight: 30
    implicitWidth: label.implicitWidth + 12

    function run(cmd) {
        runner.command = cmd
        runner.running = true
    }

    Process { id: runner }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.implicitWidth
        height: 22
        radius: 8
        color: "#313244"

        Text {
            id: label
            anchors.centerIn: parent
            text: "⏻"
            color: "#f38ba8"
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    // Shutdown
                    root.run(["systemctl", "poweroff"])
                } else if (mouse.button === Qt.RightButton) {
                    // Reboot
                    root.run(["systemctl", "reboot"])
                }
            }
        }
    }
}
