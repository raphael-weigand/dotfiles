import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

PanelWindow {
    id: root
    property bool panelVisible: false

    visible: panelVisible
    anchors { top: true; right: true }
    implicitWidth: 340
    implicitHeight: 230
    margins.top: 38
    margins.right: 8
    color: "transparent"

    Process { id: deskMove }

    function move(profile) {
        if (deskMove.running)
            return
        deskMove.command = ["/home/raphael/.config/hypr/desk-control.sh", profile]
        deskMove.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.panelBackground
        border.color: "#553a3a3a"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰇄"
                    color: "#eeeeee"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 20
                }
                Text {
                    text: "Desk Control"
                    color: "#eeeeee"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 16
                    font.bold: true
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: deskMove.running ? "Moving…" : "Ready"
                    color: "#999999"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 12
                }
            }

            Repeater {
                model: [
                    { label: "Standing", height: "58.51", shortcut: "SUPER D U", profile: "stand", icon: "󰍹" },
                    { label: "Sitting",  height: "9.94",  shortcut: "SUPER D D", profile: "sit",   icon: "󰌢" },
                    { label: "High",     height: "65.0",  shortcut: "SUPER D K", profile: "high",  icon: "󰁝" }
                ]

                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 7
                    color: presetMouse.containsMouse ? "#333333" : "#242424"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: modelData.icon
                            color: "#eeeeee"
                            font.family: "Iosevka Term Extended"
                            font.pixelSize: 16
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: modelData.label
                                color: "#eeeeee"
                                font.family: "Iosevka Term Extended"
                                font.pixelSize: 13
                                font.bold: true
                            }
                            Text {
                                text: modelData.height
                                color: "#999999"
                                font.family: "Iosevka Term Extended"
                                font.pixelSize: 11
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: modelData.shortcut
                            color: "#888888"
                            font.family: "Iosevka Term Extended"
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        id: presetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !deskMove.running
                        onClicked: root.move(modelData.profile)
                    }
                }
            }
        }
    }
}
