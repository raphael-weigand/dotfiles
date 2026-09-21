import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    property bool panelVisible: false
    property var shell

    function close() {
        if (shell) shell.closePanel()
    }

    visible: panelVisible
    anchors { top: true; bottom: true; left: true; right: true }
    color: "#99000000"
    exclusiveZone: 0
    focusable: true

    onPanelVisibleChanged: {
        if (panelVisible)
            keyHandler.forceActiveFocus()
    }

    function run(command) {
        root.close()
        action.command = ["sh", "-c", command]
        action.running = true
    }

    Process { id: action }

    Item {
        id: keyHandler
        anchors.fill: parent
        focus: root.panelVisible
        Keys.onEscapePressed: root.close()
    }

    Rectangle {
        width: 520
        height: 150
        anchors.centerIn: parent
        radius: 10
        color: "#1c1c1c"

        RowLayout {
            anchors.centerIn: parent
            spacing: 12

            Repeater {
                model: [
                    { icon: "󰌾", label: "Lock", command: "hyprlock" },
                    { icon: "󰤄", label: "Suspend", command: "systemctl suspend" },
                    { icon: "󰗼", label: "Logout", command: "hyprctl dispatch exit" },
                    { icon: "󰜉", label: "Reboot", command: "systemctl reboot" },
                    { icon: "󰐥", label: "Shutdown", command: "systemctl poweroff" }
                ]

                Rectangle {
                    required property var modelData
                    width: 88
                    height: 88
                    radius: 8
                    color: actionMouse.containsMouse ? "#333333" : "#222222"

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon
                            color: "#eeeeee"
                            font.family: "Iosevka Term Extended"
                            font.pixelSize: 24
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            color: "#eeeeee"
                            font.family: "Iosevka Term Extended"
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.run(parent.modelData.command)
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: root.close()
    }
}
