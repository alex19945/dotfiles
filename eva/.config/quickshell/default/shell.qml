//@ pragma

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell.Io

PanelWindow {

    id: root
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#444b6a"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property color colPower: "#f38ba8"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property int cpuUsage: 0
    property int memUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    property string status: "Discharging"
    property int pct: 0

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: root.colBg

    function run(cmd) {
        runner.command = cmd
        runner.running = true
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Repeater {
            model: 10 
            Text {
                property var ws:
                Hyprland.workspaces.values.find(w=> w.id === index + 1)
                property bool isActive:
                Hyprland.focusedWorkspace?.id === (index + 1)
                text: index + 1
                color: isActive ? root.colCyan : (ws ? root.colBlue : root.colMuted)
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true}

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }
        Item { Layout.fillWidth: true}

        Text {
            text: "CPU: " + cpuUsage + "%"
            color: root.colYellow
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true} 
        
            Process {
                id: cpuProc
                command: ["sh", "-c", "head -1 /proc/stat"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var p = data.trim().split(/\s+/)
                        var idle = parseInt(p[4]) + parseInt(p[5])
                        var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
                        if (lastCpuTotal > 0) {
                            cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
                        }
                        lastCpuTotal = total
                        lastCpuIdle = idle
                    }
                }
                Component.onCompleted: running = true
            }
            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: {
                    cpuProc.running = true
                    }
            }
        }

        Rectangle { width: 1; height: 16; color: root.colMuted}

        Text {
            text: "Mem: " + memUsage + "%"
            color: root.colCyan
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true}
        
            Process {
                id: memProc
                command: ["sh", "-c", "free | grep Mem"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var parts = data.trim().split(/\s+/)
                        var total = parseInt(parts[1]) || 1
                        var used = parseInt(parts[2]) || 0
                        memUsage = Math.round(100 * used / total)
                    }
                }
                Component.onCompleted: running = true
            }
            Timer {
                interval: 2000
                running: true
                repeat: true
                onTriggered: {
                    memProc.running = true
                    }
            }
        }
        Rectangle { width: 1; height: 16; color: root.colMuted}

        Text {
            id: clock
            color: root.colBlue
            font { family: root.fontFamily; pixelSize: root.fontSize; bold: true}
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
            }
        }
        Rectangle { width: 1; height: 16; color: root.colMuted}

        Text {
            text: "Battery: " +root.status + ", " + root.pct +"%"
            color: root.colFg
            font { family: fontFamily; pixelSize: root.fontSize; bold:true}

            Process {
                id: batteryProc
                command: ["sh", "-c", "echo $(cat /sys/class/power_supply/BAT0/capacity),$(cat /sys/class/power_supply/BAT0/status)"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!data) return
                        var parts =  data.trim().split(",")
                        if (parts.length < 2) return

                        var capNum = parseInt(parts[0].trim(), 10)
                        var statStr = parts[1].trim()

                        root.pct = isNaN(capNum) ? 0 : capNum
                        root.status = statStr
                    }
                }
                Component.onCompleted: running = true
            }
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    batteryProc.running = true
                }
            }
        }

        Rectangle { width: 1; height: 16; color: root.colMuted}

        Rectangle {

            Text {
                id: power_menu
                anchors.centerIn: parent
                text: "⏻"
                color: root.colPower
                font {pixelSize: fontSize; bold: true}
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: (mouse => {
                    if (mouse.button === Qt.LeftButton)
                        root.run(["systemctl", "poweroff"])
                    else if (mouse.button === Qt.RightButton)
                        root.run(["systemctl", "reboot"])
                })
            }
        }

        Rectangle { width: 1; height: 16; color: root.colMuted}
    }
}
