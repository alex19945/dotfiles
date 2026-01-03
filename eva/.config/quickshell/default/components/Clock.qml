import QtQuick

Item {
    id: root
    implicitHeight: 30
    implicitWidth: timeText.implicitWidth

    property string format: "HH:mm"

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: timeText.text = Qt.formatDateTime(new Date(), root.format)
    }

    Text {
        id: timeText
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(new Date(), root.format)
        color: "#cdd6f4"
        font.pixelSize: 12
    }
}
