import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: true
            color: "transparent"

            anchors {
                top: true
                right: true
            }

            implicitWidth: 380
            implicitHeight: 390
            margins.top: 44
            margins.right: 12

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: "#181818"
                border.width: 2
                border.color: "#ffdd33"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    Label {
                        text: "Control Center"
                        color: "#ffffff"
                        font.family: "Iosevka Term Extended"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Button {
                            Layout.fillWidth: true
                            text: "Wi-Fi"
                            onClicked: wifiToggle.running = true
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "Bluetooth"
                            onClicked: bluetoothToggle.running = true
                        }
                    }

                    Label {
                        text: "Volume"
                        color: "#e4e4ef"
                        font.family: "Iosevka Term Extended"
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 1.5
                        value: 0.4
                        onMoved: volumeSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", value.toFixed(2)]
                        onPressedChanged: if (!pressed) volumeSet.running = true
                    }

                    Label {
                        text: "Brightness"
                        color: "#e4e4ef"
                        font.family: "Iosevka Term Extended"
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: 1
                        to: 100
                        value: 70
                        onMoved: brightnessSet.command = ["brightnessctl", "set", Math.round(value) + "%"]
                        onPressedChanged: if (!pressed) brightnessSet.running = true
                    }

                    Item { Layout.fillHeight: true }

                    Label {
                        text: "First prototype — live status follows next"
                        color: "#777777"
                        font.family: "Iosevka Term Extended"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }

    Process {
        id: wifiToggle
        command: ["sh", "-c", "nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"]
    }

    Process {
        id: bluetoothToggle
        command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"]
    }

    Process { id: volumeSet }
    Process { id: brightnessSet }
}
