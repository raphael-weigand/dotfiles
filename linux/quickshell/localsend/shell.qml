import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

ShellRoot {
    property bool localSendActive: false

    Process {
        id: statusProcess
        command: ["sh", "-c", "pgrep -x localsend >/dev/null && printf 1 || printf 0"]
        stdout: StdioCollector {
            onStreamFinished: localSendActive = text.trim() === "1"
        }
    }

    Process {
        id: toggleProcess
        command: ["sh", "-c", "~/.config/waybar/localsend-toggle.sh"]
        onExited: Qt.callLater(function() { statusProcess.running = true })
    }

    Process {
        id: openProcess
        command: ["sh", "-c", "pgrep -x localsend >/dev/null || (nohup localsend >/dev/null 2>&1 &)"]
        onExited: {
            Qt.callLater(function() { statusProcess.running = true })
            Qt.quit()
        }
    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!statusProcess.running) statusProcess.running = true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: true
            color: "transparent"
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore

            Rectangle {
                anchors.fill: parent
                color: "#99000000"

                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.quit()
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 520
                    height: 360
                    radius: 22
                    color: "#181818"
                    border.width: 1
                    border.color: "#3a3a3a"

                    MouseArea { anchors.fill: parent }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 30
                        spacing: 16

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Dateiübertragung"
                            color: "#ffffff"
                            font.family: "Iosevka Term Extended"
                            font.pixelSize: 22
                            font.bold: true
                        }

                        Item { Layout.preferredHeight: 4 }

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 92
                            height: 92
                            radius: 46
                            color: localSendActive ? "#3a3520" : "#292929"
                            border.width: 1
                            border.color: localSendActive ? "#ffdd33" : "#404040"

                            Label {
                                anchors.centerIn: parent
                                text: "󰒍"
                                color: localSendActive ? "#ffdd33" : "#888888"
                                font.family: "Iosevka Term Extended"
                                font.pixelSize: 42
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: localSendActive ? "LocalSend ist aktiv" : "LocalSend ist aus"
                            color: "#ffffff"
                            font.family: "Iosevka Term Extended"
                            font.pixelSize: 17
                            font.bold: true
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: localSendActive ? "Bereit für Geräte im lokalen Netzwerk" : "Aktivieren, um Dateien zu senden und zu empfangen"
                            color: "#999999"
                            font.family: "Iosevka Term Extended"
                            font.pixelSize: 11
                        }

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                text: "LocalSend öffnen"
                                onClicked: openProcess.running = true
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                text: localSendActive ? "Deaktivieren" : "Aktivieren"
                                onClicked: toggleProcess.running = true
                            }
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Klick außerhalb schließt das Overlay"
                            color: "#666666"
                            font.family: "Iosevka Term Extended"
                            font.pixelSize: 9
                        }
                    }
                }
            }
        }
    }
}
