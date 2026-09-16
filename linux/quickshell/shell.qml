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
    property string networkDownText: "…"
    property string networkUpText: "…"
    property string networkReceivedText: "…"
    property string networkSentText: "…"
    property double previousRxBytes: -1
    property double previousTxBytes: -1
    property double previousNetworkTimestamp: 0

    function formatRate(bytesPerSecond) {
        if (bytesPerSecond >= 1073741824) return (bytesPerSecond / 1073741824).toFixed(1) + " GiB/s"
        if (bytesPerSecond >= 1048576) return (bytesPerSecond / 1048576).toFixed(1) + " MiB/s"
        if (bytesPerSecond >= 1024) return (bytesPerSecond / 1024).toFixed(1) + " KiB/s"
        return Math.max(0, bytesPerSecond).toFixed(0) + " B/s"
    }

    function formatBytes(bytes) {
        if (bytes >= 1099511627776) return (bytes / 1099511627776).toFixed(1) + " TiB"
        if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(1) + " GiB"
        if (bytes >= 1048576) return (bytes / 1048576).toFixed(1) + " MiB"
        if (bytes >= 1024) return (bytes / 1024).toFixed(1) + " KiB"
        return bytes.toFixed(0) + " B"
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: true
            color: "transparent"

            anchors { top: true; right: true }
            implicitWidth: 380
            implicitHeight: 720
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

                    Label { text: "Control Center"; color: "#ffffff"; font.family: "Iosevka Term Extended"; font.pixelSize: 20; font.bold: true }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            radius: 9
                            color: wifiMouse.containsMouse ? "#2b2b2b" : "#222222"
                            border.width: 1
                            border.color: wifiMouse.containsMouse ? "#ffdd33" : "#303030"
                            Column {
                                anchors.centerIn: parent
                                spacing: 3
                                Label { anchors.horizontalCenter: parent.horizontalCenter; text: "󰖩  Wi-Fi"; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; font.bold: true }
                                Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Network settings"; color: "#777777"; font.family: "Iosevka Term Extended"; font.pixelSize: 10 }
                            }
                            MouseArea { id: wifiMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: wifiSettings.running = true }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            radius: 9
                            color: bluetoothMouse.containsMouse ? "#2b2b2b" : "#222222"
                            border.width: 1
                            border.color: bluetoothMouse.containsMouse ? "#ffdd33" : "#303030"
                            Column {
                                anchors.centerIn: parent
                                spacing: 3
                                Label { anchors.horizontalCenter: parent.horizontalCenter; text: "󰂯  Bluetooth"; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; font.bold: true }
                                Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Device settings"; color: "#777777"; font.family: "Iosevka Term Extended"; font.pixelSize: 10 }
                            }
                            MouseArea { id: bluetoothMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: bluetoothSettings.running = true }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 126
                        radius: 9
                        color: "#222222"
                        border.width: 1
                        border.color: "#303030"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                Label { text: "󰕾  Volume"; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; font.bold: true }
                                Item { Layout.fillWidth: true }
                                Label { text: "Audio settings  ›"; color: audioMouse.containsMouse ? "#ffdd33" : "#777777"; font.family: "Iosevka Term Extended"; font.pixelSize: 11
                                    MouseArea { id: audioMouse; anchors.fill: parent; anchors.margins: -6; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: audioSettings.running = true }
                                }
                            }

                            Slider {
                                Layout.fillWidth: true
                                from: 0
                                to: 1.5
                                value: 0.4
                                onMoved: volumeSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", value.toFixed(2)]
                                onPressedChanged: if (!pressed) volumeSet.running = true
                            }

                            Label { text: "󰃠  Brightness"; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; font.bold: true }

                            Slider {
                                Layout.fillWidth: true
                                from: 1
                                to: 100
                                value: 70
                                onMoved: brightnessSet.command = ["brightnessctl", "set", Math.round(value) + "%"]
                                onPressedChanged: if (!pressed) brightnessSet.running = true
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#383838" }
                    Label { text: "System"; color: "#ffffff"; font.family: "Iosevka Term Extended"; font.pixelSize: 15; font.bold: true }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: systemGrid.implicitHeight + 24
                        radius: 9; color: "#222222"; border.width: 1; border.color: "#303030"
                        GridLayout {
                            id: systemGrid
                            anchors.fill: parent; anchors.margins: 12
                            columns: 2; columnSpacing: 16; rowSpacing: 7
                            Label { text: "CPU"; color: "#999999"; font.family: "Iosevka Term Extended" }
                            Label { text: cpuText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "RAM"; color: "#999999"; font.family: "Iosevka Term Extended" }
                            Label { text: ramText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "Temperature"; color: "#999999"; font.family: "Iosevka Term Extended" }
                            Label { text: tempText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: networkColumn.implicitHeight + 24
                        radius: 9; color: "#222222"; border.width: 1; border.color: "#303030"
                        ColumnLayout {
                            id: networkColumn
                            anchors.fill: parent; anchors.margins: 12; spacing: 8
                            Label { text: "Network"; color: "#ffdd33"; font.family: "Iosevka Term Extended"; font.pixelSize: 13; font.bold: true }
                            GridLayout {
                                Layout.fillWidth: true; columns: 2; columnSpacing: 16; rowSpacing: 7
                                Label { text: "↓ Download"; color: "#999999"; font.family: "Iosevka Term Extended" }
                                Label { text: networkDownText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                                Label { text: "↑ Upload"; color: "#999999"; font.family: "Iosevka Term Extended" }
                                Label { text: networkUpText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                                Label { text: "Received"; color: "#777777"; font.family: "Iosevka Term Extended" }
                                Label { text: networkReceivedText; color: "#b8b8c0"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                                Label { text: "Sent"; color: "#777777"; font.family: "Iosevka Term Extended" }
                                Label { text: networkSentText; color: "#b8b8c0"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: storageGrid.implicitHeight + 24
                        radius: 9; color: "#222222"; border.width: 1; border.color: "#303030"
                        GridLayout {
                            id: storageGrid
                            anchors.fill: parent; anchors.margins: 12
                            columns: 2; columnSpacing: 16; rowSpacing: 7
                            Label { text: "Disk /"; color: "#999999"; font.family: "Iosevka Term Extended" }
                            Label { text: diskText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "Uptime"; color: "#999999"; font.family: "Iosevka Term Extended" }
                            Label { text: uptimeText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { systemStats.running = true; networkStats.running = true }
    }

    Process {
        id: systemStats
        command: ["sh", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total1=$((user+nice+system+idle+iowait+irq+softirq+steal)); idle1=$((idle+iowait)); sleep 0.15; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total2=$((user+nice+system+idle+iowait+irq+softirq+steal)); idle2=$((idle+iowait)); dt=$((total2-total1)); di=$((idle2-idle1)); cpu_pct=$(( dt > 0 ? (100*(dt-di)/dt) : 0 )); ram=$(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {printf \"%.1f / %.1f GiB\", (t-a)/1048576, t/1048576}' /proc/meminfo); temp=$(for f in /sys/class/hwmon/hwmon*/temp*_input; do [ -r \"$f\" ] || continue; v=$(cat \"$f\" 2>/dev/null || true); [ -n \"$v\" ] && [ \"$v\" -gt 0 ] 2>/dev/null && { awk -v v=\"$v\" 'BEGIN {printf \"%.0f °C\", v/1000}'; break; }; done); [ -n \"$temp\" ] || temp='n/a'; disk=$(df -hP / | awk 'NR==2 {printf \"%s / %s (%s)\", $3, $2, $5}'); uptime=$(awk '{s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if (d>0) printf \"%dd %dh %dm\",d,h,m; else if (h>0) printf \"%dh %dm\",h,m; else printf \"%dm\",m}' /proc/uptime); printf '%s|%s|%s|%s|%s\\n' \"$cpu_pct%\" \"$ram\" \"$temp\" \"$disk\" \"$uptime\""]
        stdout: StdioCollector { onStreamFinished: { const values = text.trim().split("|"); if (values.length === 5) { cpuText = values[0]; ramText = values[1]; tempText = values[2]; diskText = values[3]; uptimeText = values[4] } } }
    }

    Process {
        id: networkStats
        command: ["sh", "-c", "awk -F'[: ]+' 'NR>2 && $1 != \"lo\" {rx += $3; tx += $11} END {printf \"%.0f|%.0f\\n\", rx, tx}' /proc/net/dev"]
        stdout: StdioCollector {
            onStreamFinished: {
                const values = text.trim().split("|")
                if (values.length !== 2) return
                const rx = Number(values[0]); const tx = Number(values[1]); const now = Date.now()
                networkReceivedText = formatBytes(rx); networkSentText = formatBytes(tx)
                if (previousRxBytes >= 0 && previousTxBytes >= 0 && previousNetworkTimestamp > 0) {
                    const seconds = (now - previousNetworkTimestamp) / 1000
                    if (seconds > 0) { networkDownText = formatRate((rx - previousRxBytes) / seconds); networkUpText = formatRate((tx - previousTxBytes) / seconds) }
                } else { networkDownText = "0 B/s"; networkUpText = "0 B/s" }
                previousRxBytes = rx; previousTxBytes = tx; previousNetworkTimestamp = now
            }
        }
    }

    Process { id: wifiSettings; command: ["nm-connection-editor"] }
    Process { id: bluetoothSettings; command: ["blueman-manager"] }
    Process { id: audioSettings; command: ["pavucontrol"] }
    Process { id: volumeSet }
    Process { id: brightnessSet }
}
