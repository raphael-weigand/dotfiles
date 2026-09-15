import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    property string cpuText: "…"
    property string ramText: "…"
    property string tempText: "…"
    property string diskText: "…"
    property string uptimeText: "…"

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
            implicitHeight: 560
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
                    spacing: 14

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
                            onClicked: wifiSettings.running = true
                        }

                        Button {
                            Layout.fillWidth: true
                            text: "Bluetooth"
                            onClicked: bluetoothSettings.running = true
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

                    Button {
                        Layout.fillWidth: true
                        text: "Audio settings"
                        onClicked: audioSettings.running = true
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

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#383838"
                    }

                    Label {
                        text: "System"
                        color: "#ffffff"
                        font.family: "Iosevka Term Extended"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 16
                        rowSpacing: 7

                        Label { text: "CPU"; color: "#999999"; font.family: "Iosevka Term Extended" }
                        Label { text: cpuText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                        Label { text: "RAM"; color: "#999999"; font.family: "Iosevka Term Extended" }
                        Label { text: ramText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                        Label { text: "Temperature"; color: "#999999"; font.family: "Iosevka Term Extended" }
                        Label { text: tempText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                        Label { text: "Disk /"; color: "#999999"; font.family: "Iosevka Term Extended" }
                        Label { text: diskText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                        Label { text: "Uptime"; color: "#999999"; font.family: "Iosevka Term Extended" }
                        Label { text: uptimeText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: systemStats.running = true
    }

    Process {
        id: systemStats
        command: ["sh", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total1=$((user+nice+system+idle+iowait+irq+softirq+steal)); idle1=$((idle+iowait)); sleep 0.15; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total2=$((user+nice+system+idle+iowait+irq+softirq+steal)); idle2=$((idle+iowait)); dt=$((total2-total1)); di=$((idle2-idle1)); cpu_pct=$(( dt > 0 ? (100*(dt-di)/dt) : 0 )); ram=$(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {printf \"%.1f / %.1f GiB\", (t-a)/1048576, t/1048576}' /proc/meminfo); temp=$(for f in /sys/class/hwmon/hwmon*/temp*_input; do [ -r \"$f\" ] || continue; v=$(cat \"$f\" 2>/dev/null || true); [ -n \"$v\" ] && [ \"$v\" -gt 0 ] 2>/dev/null && { awk -v v=\"$v\" 'BEGIN {printf \"%.0f °C\", v/1000}'; break; }; done); [ -n \"$temp\" ] || temp='n/a'; disk=$(df -hP / | awk 'NR==2 {printf \"%s / %s (%s)\", $3, $2, $5}'); uptime=$(awk '{s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if (d>0) printf \"%dd %dh %dm\",d,h,m; else if (h>0) printf \"%dh %dm\",h,m; else printf \"%dm\",m}' /proc/uptime); printf '%s|%s|%s|%s|%s\\n' \"$cpu_pct%\" \"$ram\" \"$temp\" \"$disk\" \"$uptime\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const values = text.trim().split("|")
                if (values.length === 5) {
                    cpuText = values[0]
                    ramText = values[1]
                    tempText = values[2]
                    diskText = values[3]
                    uptimeText = values[4]
                }
            }
        }
    }

    Process { id: wifiSettings; command: ["nm-connection-editor"] }
    Process { id: bluetoothSettings; command: ["blueman-manager"] }
    Process { id: audioSettings; command: ["pavucontrol"] }
    Process { id: volumeSet }
    Process { id: brightnessSet }
}
