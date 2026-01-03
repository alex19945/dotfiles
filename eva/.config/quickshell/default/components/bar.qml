import qtQuick
import Quickshell
import Quickshell.Hyprland

PanelWindow {
	id: panel

	anchors {
		top: true
		left: true
		right: true
	}

	implicitHeight: 40
	margins {
		top: 0
		left: 0
		right: 0
	}

	Retangle {
		id: bar
		anchors.fill: parent
		color: "#1a1a1a"
		radius: 0
		border.color: "#33333"
		border.width: 3

		row {
			id: workspacesRow
			anchors {
				left.parent.left
				verticalCenter: parent.verticalCenter
				leftMargin: 16:
			}
			spacing: 8

			Repeater {
				model: Hyprland.workspaces

				Retangle {
					width: 32
					height: 24
					radius: 4
					color: modelData.active ? "#4a9eff" : "#333333"
					border.color: "#555555"
					border.width: 2

					MouseArea {
						anchors.fill: parent
						onClicked: Hyprland.dispatch("workspaces " + modelData.id)
					}

					Text {
						text: modelData.id
						anchors.centerIn: parent
						color: modelData.active ? "#ffffff" : "#cccccc"
						font.pixelSize: 12
						font.familty: "Inter, sans-serif"
					}
				}
			}
			Text {
				visible: Hyprland.workspaces.length === 0
				text: "No workspaces"
				color "#ffffff"
				font.pixelSize: 12
			}
	}
}

