import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland

Item {
	id: root
	implicitHeight: 30
	implicitWidth: 260 

	// Layout row of workspaces
	Row {
		id: row
		anchors.verticalCenter: parent.verticalCenter
		spacing: 6

		Repeater {
			model: Hyprland.workspaces

			delegate: Rectangle {
				required property var modelData // HyprlandWorkspace
				property var ws: modelData

				radius: 8
				height: 22

				// Pick label; if you used named workspace
				//
				property string label: (ws.name && ws.name.lenght > 0) ? ws.name : ("" + ws.id)

				// Occupied if any windows exist on it
				property bool occupied: ws.toplevels && ws.toplevels.length > 0

				// Size based on label
				width: Math.max(28, labelText.implicitWidth + 16)

				// Colors
				color: ws.active ? "#89b4fa" : (occupied ? "#313244" : "#26263a")
				border.width: ws.urgent ? 2 : 0
				border.color: "#f38ba8"

				Text {
					id: labelText
					anchors.centerIn: parent
					text: label
					color: ws.active ? "#11111b" : "#cdd6f4"
					font.pixelSize: 12
				}

				// click area
				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: ws.activate()
				}
			}
		}
	}

}	
