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
    property string activeNetworkType: "Checking…"
    property string activeNetworkName: ""
    property double previousRxBytes: -1
    property double previousTxBytes: -1
    property double previousNetworkTimestamp: 0
    property bool wifiEnabled: false
    property string wifiText: "Checking…"
    property bool bluetoothEnabled: false
    property string bluetoothText: "Checking…"
    property real volumeLevel: 0
    property int volumePercent: 0
    property bool volumeMuted: false
    property string audioOutputName: "Checking…"
    property int brightnessPercent: 1
    property string batteryText: "Checking…"
    property string batteryHealthText: "Checking…"
    property string batteryCyclesText: "Checking…"
    property string batteryLimitText: "Checking…"

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
            implicitWidth: 420
            implicitHeight: 850
            margins.top: 44
            margins.right: 12

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: "#181818"
                border.width: 1
                border.color: "#383838"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    Label { text: "Control Center"; color: "#ffffff"; font.family: "Iosevka Term Extended"; font.pixelSize: 21; font.bold: true }

                    GridLayout {
                        Layout.fillWidth: true; columns: 2; columnSpacing: 10; rowSpacing: 10
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 76; radius: 12
                            color: wifiCardMouse.containsMouse ? "#2b2b2b" : "#222222"; border.width: 1; border.color: wifiEnabled ? "#ffdd33" : "#303030"
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12; spacing: 10
                                Rectangle { width: 42; height: 42; radius: 21; color: wifiEnabled ? "#3a3520" : "#303030"; Label { anchors.centerIn: parent; text: "󰖩"; color: wifiEnabled ? "#ffdd33" : "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 20 } }
                                ColumnLayout { Layout.fillWidth: true; spacing: 2; Label { text: "Wi-Fi"; color: "#ffffff"; font.family: "Iosevka Term Extended"; font.bold: true } Label { text: wifiText; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true } }
                                Label { text: "›"; color: wifiSettingsMouse.containsMouse ? "#ffdd33" : "#777777"; font.pixelSize: 20; MouseArea { id: wifiSettingsMouse; anchors.fill: parent; anchors.margins: -10; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: wifiSettings.running = true } }
                            }
                            MouseArea { id: wifiCardMouse; anchors.fill: parent; anchors.rightMargin: 36; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: wifiToggle.running = true }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 76; radius: 12
                            color: bluetoothCardMouse.containsMouse ? "#2b2b2b" : "#222222"; border.width: 1; border.color: bluetoothEnabled ? "#ffdd33" : "#303030"
                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12; spacing: 10
                                Rectangle { width: 42; height: 42; radius: 21; color: bluetoothEnabled ? "#3a3520" : "#303030"; Label { anchors.centerIn: parent; text: "󰂯"; color: bluetoothEnabled ? "#ffdd33" : "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 20 } }
                                ColumnLayout { Layout.fillWidth: true; spacing: 2; Label { text: "Bluetooth"; color: "#ffffff"; font.family: "Iosevka Term Extended"; font.bold: true } Label { text: bluetoothText; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true } }
                                Label { text: "›"; color: bluetoothSettingsMouse.containsMouse ? "#ffdd33" : "#777777"; font.pixelSize: 20; MouseArea { id: bluetoothSettingsMouse; anchors.fill: parent; anchors.margins: -10; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: bluetoothSettings.running = true } }
                            }
                            MouseArea { id: bluetoothCardMouse; anchors.fill: parent; anchors.rightMargin: 36; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: bluetoothToggle.running = true }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 92; radius: 12; color: audioCardMouse.containsMouse ? "#2b2b2b" : "#222222"; border.width: 1; border.color: "#303030"
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 12; spacing: 5
                                RowLayout { Layout.fillWidth: true; spacing: 9
                                    Rectangle { width: 38; height: 38; radius: 19; color: "#303030"; Label { anchors.centerIn: parent; text: volumeMuted ? "󰝟" : "󰕾"; color: volumeMuted ? "#999999" : "#e4e4ef"; font.family: "Iosevka Term Extended"; font.pixelSize: 18 } }
                                    ColumnLayout { Layout.fillWidth: true; spacing: 1; Label { text: "Audio"; color: "#ffffff"; font.family: "Iosevka Term Extended"; font.bold: true } Label { text: audioOutputName + " · " + (volumeMuted ? "Muted" : volumePercent + "%"); color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 10; elide: Text.ElideRight; Layout.fillWidth: true } }
                                    Label { text: "›"; color: outputMouse.containsMouse ? "#ffdd33" : "#777777"; font.pixelSize: 20 }
                                }
                                Slider {
                                    Layout.fillWidth: true; from: 0; to: 1.5; value: volumeLevel
                                    onMoved: { volumeLevel = value; volumePercent = Math.round(value * 100); volumeSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", value.toFixed(2)] }
                                    onPressedChanged: if (!pressed) { volumeSet.running = true; Qt.callLater(function() { audioStatus.running = true }) }
                                }
                            }
                            MouseArea { id: audioCardMouse; anchors.fill: parent; anchors.bottomMargin: 30; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: audioOutputMenu.running = true }
                            MouseArea { id: outputMouse; anchors.right: parent.right; anchors.top: parent.top; width: 36; height: 60; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: audioSettings.running = true }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 92; radius: 12; color: displayCardMouse.containsMouse ? "#2b2b2b" : "#222222"; border.width: 1; border.color: "#303030"
                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: 12; spacing: 5
                                RowLayout { Layout.fillWidth: true; spacing: 9
                                    Rectangle { width: 38; height: 38; radius: 19; color: "#303030"; Label { anchors.centerIn: parent; text: "󰍹"; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; font.pixelSize: 18 } }
                                    ColumnLayout { Layout.fillWidth: true; spacing: 1; Label { text: "Display"; color: "#ffffff"; font.family: "Iosevka Term Extended"; font.bold: true } Label { text: "Brightness · " + brightnessPercent + "%"; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 10 } }
                                }
                                Slider {
                                    Layout.fillWidth: true; from: 1; to: 100; value: brightnessPercent
                                    onMoved: { brightnessPercent = Math.round(value); brightnessSet.command = ["brightnessctl", "set", brightnessPercent + "%"] }
                                    onPressedChanged: if (!pressed) { brightnessSet.running = true; Qt.callLater(function() { brightnessStatus.running = true }) }
                                }
                            }
                            MouseArea { id: displayCardMouse; anchors.fill: parent; anchors.bottomMargin: 30; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#303030" }
Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 112
    radius: 12
    color: "#222222"
    border.width: 1
    border.color: "#303030"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                width: 42
                height: 42
                radius: 21
                color: "#3a3520"

                Label {
                    anchors.centerIn: parent
                    text: "󰁹"
                    color: "#ffdd33"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 20
                }
            }

            ColumnLayout {
                Layout.leftMargin: 4
                spacing: 1

                Label {
                    text: "Battery"
                    color: "#ffffff"
                    font.family: "Iosevka Term Extended"
                    font.bold: true
                }

                Label {
                    text: batteryText
                    color: "#999999"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 10
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                text: batteryText.split("%")[0] + "%"
                color: "#ffffff"
                font.family: "Iosevka Term Extended"
                font.pixelSize: 22
                font.bold: true
            }
        }

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    text: "Health"
                    color: "#777777"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 10
                }

                Label {
                    text: batteryHealthText
                    color: "#e4e4ef"
                    font.family: "Iosevka Term Extended"
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    text: "Cycles"
                    color: "#777777"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 10
                }

                Label {
                    text: batteryCyclesText
                    color: "#e4e4ef"
                    font.family: "Iosevka Term Extended"
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Label {
                    text: "Charge limit"
                    color: "#777777"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 10
                }

                Label {
                    text: batteryLimitText
                    color: "#ffdd33"
                    font.family: "Iosevka Term Extended"
                    font.bold: true
                }
            }
        }
    }
}
                    Label { text: "System"; color: "#ffffff"; font.family: "Iosevka Term Extended"; font.pixelSize: 14; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: systemGrid.implicitHeight + 24; radius: 12; color: "#222222"; border.width: 1; border.color: "#303030"
                        GridLayout {
                            id: systemGrid; anchors.fill: parent; anchors.margins: 12; columns: 2; columnSpacing: 16; rowSpacing: 7
                            Label { text: "CPU"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: cpuText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "RAM"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: ramText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "Temperature"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: tempText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "󰁹  Battery"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: batteryText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "Battery health"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: batteryHealthText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "Cycles"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: batteryCyclesText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "Charge limit"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: batteryLimitText; color: "#ffdd33"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: networkColumn.implicitHeight + 24; radius: 12; color: "#222222"; border.width: 1; border.color: "#303030"
                        ColumnLayout {
                            id: networkColumn; anchors.fill: parent; anchors.margins: 12; spacing: 8
                            Label { text: "Network"; color: "#ffdd33"; font.family: "Iosevka Term Extended"; font.pixelSize: 13; font.bold: true }
                            RowLayout { Layout.fillWidth: true; Label { text: activeNetworkType === "Ethernet" ? "󰈀  Ethernet" : (activeNetworkType === "Wi-Fi" ? "󰖩  Wi-Fi" : "󰖪  Network"); color: "#e4e4ef"; font.family: "Iosevka Term Extended"; font.bold: true } Item { Layout.fillWidth: true } Label { text: activeNetworkName; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 11; elide: Text.ElideRight; Layout.maximumWidth: 175 } }
                            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#303030" }
                            GridLayout { Layout.fillWidth: true; columns: 2; columnSpacing: 16; rowSpacing: 7
                                Label { text: "↓ Download"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: networkDownText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                                Label { text: "↑ Upload"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: networkUpText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                                Label { text: "Received"; color: "#777777"; font.family: "Iosevka Term Extended" } Label { text: networkReceivedText; color: "#b8b8c0"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                                Label { text: "Sent"; color: "#777777"; font.family: "Iosevka Term Extended" } Label { text: networkSentText; color: "#b8b8c0"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: storageGrid.implicitHeight + 24; radius: 12; color: "#222222"; border.width: 1; border.color: "#303030"
                        GridLayout { id: storageGrid; anchors.fill: parent; anchors.margins: 12; columns: 2; columnSpacing: 16; rowSpacing: 7
                            Label { text: "Disk /"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: diskText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                            Label { text: "Uptime"; color: "#999999"; font.family: "Iosevka Term Extended" } Label { text: uptimeText; color: "#e4e4ef"; font.family: "Iosevka Term Extended"; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }
        }
    }

    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { systemStats.running = true; networkStats.running = true; connectionStatus.running = true; wifiStatus.running = true; bluetoothStatus.running = true; audioStatus.running = true; audioOutputStatus.running = true; brightnessStatus.running = true; batteryStatus.running = true } }
    Process { id: systemStats; command: ["sh", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total1=$((user+nice+system+idle+iowait+irq+softirq+steal)); idle1=$((idle+iowait)); sleep 0.15; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total2=$((user+nice+system+idle+iowait+irq+softirq+steal)); idle2=$((idle+iowait)); dt=$((total2-total1)); di=$((idle2-idle1)); cpu_pct=$(( dt > 0 ? (100*(dt-di)/dt) : 0 )); ram=$(awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {printf \"%.1f / %.1f GiB\", (t-a)/1048576, t/1048576}' /proc/meminfo); temp=$(for f in /sys/class/hwmon/hwmon*/temp*_input; do [ -r \"$f\" ] || continue; v=$(cat \"$f\" 2>/dev/null || true); [ -n \"$v\" ] && [ \"$v\" -gt 0 ] 2>/dev/null && { awk -v v=\"$v\" 'BEGIN {printf \"%.0f °C\", v/1000}'; break; }; done); [ -n \"$temp\" ] || temp='n/a'; disk=$(df -hP / | awk 'NR==2 {printf \"%s / %s (%s)\", $3, $2, $5}'); uptime=$(awk '{s=int($1); d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if (d>0) printf \"%dd %dh %dm\",d,h,m; else if (h>0) printf \"%dh %dm\",h,m; else printf \"%dm\",m}' /proc/uptime); printf '%s|%s|%s|%s|%s\\n' \"$cpu_pct%\" \"$ram\" \"$temp\" \"$disk\" \"$uptime\""]; stdout: StdioCollector { onStreamFinished: { const values = text.trim().split("|"); if (values.length === 5) { cpuText = values[0]; ramText = values[1]; tempText = values[2]; diskText = values[3]; uptimeText = values[4] } } } }
    Process { id: networkStats; command: ["sh", "-c", "awk -F'[: ]+' 'NR>2 && $1 != \"lo\" {rx += $3; tx += $11} END {printf \"%.0f|%.0f\\n\", rx, tx}' /proc/net/dev"]; stdout: StdioCollector { onStreamFinished: { const values = text.trim().split("|"); if (values.length !== 2) return; const rx = Number(values[0]); const tx = Number(values[1]); const now = Date.now(); networkReceivedText = formatBytes(rx); networkSentText = formatBytes(tx); if (previousRxBytes >= 0 && previousTxBytes >= 0 && previousNetworkTimestamp > 0) { const seconds = (now - previousNetworkTimestamp) / 1000; if (seconds > 0) { networkDownText = formatRate((rx - previousRxBytes) / seconds); networkUpText = formatRate((tx - previousTxBytes) / seconds) } } else { networkDownText = "0 B/s"; networkUpText = "0 B/s" } previousRxBytes = rx; previousTxBytes = tx; previousNetworkTimestamp = now } } }
    Process { id: connectionStatus; command: ["sh", "-c", "nmcli -t -f TYPE,NAME connection show --active 2>/dev/null | awk -F: '$1==\"802-3-ethernet\" {print \"Ethernet|\" $2; found=1; exit} $1==\"802-11-wireless\" && !wifi {wifi=\"Wi-Fi|\" $2} END {if (!found && wifi) print wifi; else if (!found && !wifi) print \"Disconnected|\"}'"]; stdout: StdioCollector { onStreamFinished: { const values = text.trim().split("|"); activeNetworkType = values[0] || "Disconnected"; activeNetworkName = values[1] || (activeNetworkType === "Disconnected" ? "Disconnected" : "Connected") } } }
    Process { id: wifiStatus; command: ["sh", "-c", "radio=$(nmcli -t -f WIFI general 2>/dev/null); ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | sed -n 's/^yes://p' | head -n1); printf '%s|%s\\n' \"$radio\" \"$ssid\""]; stdout: StdioCollector { onStreamFinished: { const values = text.trim().split("|"); wifiEnabled = values[0] === "enabled"; wifiText = !wifiEnabled ? "Off" : (values.length > 1 && values[1] !== "" ? values[1] : "On · not connected") } } }
    Process { id: wifiToggle; command: ["sh", "-c", "nmcli radio wifi | grep -q enabled && nmcli radio wifi off || nmcli radio wifi on"]; onExited: Qt.callLater(function() { wifiStatus.running = true; connectionStatus.running = true }) }
    Process { id: bluetoothStatus; command: ["sh", "-c", "powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}'); count=$(bluetoothctl devices Connected 2>/dev/null | grep -c '^Device ' || true); printf '%s|%s\\n' \"$powered\" \"$count\""]; stdout: StdioCollector { onStreamFinished: { const values = text.trim().split("|"); bluetoothEnabled = values[0] === "yes"; bluetoothText = !bluetoothEnabled ? "Off" : ((Number(values[1]) || 0) > 0 ? values[1] + " connected" : "On · no devices") } } }
    Process { id: bluetoothToggle; command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"]; onExited: Qt.callLater(function() { bluetoothStatus.running = true }) }
    Process { id: audioStatus; command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]; stdout: StdioCollector { onStreamFinished: { const match = text.match(/Volume:\s+([0-9.]+)/); if (match) { volumeLevel = Number(match[1]); volumePercent = Math.round(volumeLevel * 100); volumeMuted = text.indexOf("[MUTED]") !== -1 } } } }
    Process { id: audioOutputStatus; command: ["sh", "-c", "wpctl status | awk '/Sinks:/ {s=1; next} s && /^[[:space:]│]*[├└]─ Sources:/ {exit} s && /\\*/ {line=$0; sub(/^.*\\*[[:space:]]*/, \"\", line); sub(/^[0-9]+\\.[[:space:]]*/, \"\", line); sub(/[[:space:]]+\\[vol:.*$/, \"\", line); print line; exit}'"]; stdout: StdioCollector { onStreamFinished: { const value = text.trim(); audioOutputName = value !== "" ? value : "No output device" } } }
    Process { id: audioOutputMenu; command: ["bash", "-lc", "~/.config/quickshell/audio-output-menu.sh"]; onExited: Qt.callLater(function() { audioOutputStatus.running = true; audioStatus.running = true }) }
    Process { id: brightnessStatus; command: ["brightnessctl", "-m"]; stdout: StdioCollector { onStreamFinished: { const values = text.trim().split(","); if (values.length >= 4) { const value = Number(values[3].replace("%", "")); if (!isNaN(value)) brightnessPercent = value } } } }
    Process { id: batteryStatus; command: ["sh", "-c", "bat=/sys/class/power_supply/BAT0; limit=/sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:104/APP0001:00/battery_charge_limit; if [ -r \"$bat/capacity\" ]; then capacity=$(cat \"$bat/capacity\"); status=$(cat \"$bat/status\"); full=$(cat \"$bat/charge_full\" 2>/dev/null || echo 0); design=$(cat \"$bat/charge_full_design\" 2>/dev/null || echo 0); cycles=$(cat \"$bat/cycle_count\" 2>/dev/null || echo n/a); health=$(awk -v f=\"$full\" -v d=\"$design\" 'BEGIN {if (d > 0) printf \"%.0f%%\", f*100/d; else printf \"n/a\"}'); if [ -r \"$limit\" ]; then charge_limit=$(cat \"$limit\")%; else charge_limit=n/a; fi; printf '%s%% · %s|%s|%s|%s\\n' \"$capacity\" \"$status\" \"$health\" \"$cycles\" \"$charge_limit\"; else printf 'No battery|n/a|n/a|n/a\\n'; fi"]; stdout: StdioCollector { onStreamFinished: { const values = text.trim().split("|"); if (values.length === 4) { batteryText = values[0]; batteryHealthText = values[1]; batteryCyclesText = values[2]; batteryLimitText = values[3] } } } }
    Process { id: wifiSettings; command: ["nm-connection-editor"] }
    Process { id: bluetoothSettings; command: ["blueman-manager"] }
    Process { id: audioSettings; command: ["pavucontrol"] }
    Process { id: volumeSet }
    Process { id: brightnessSet }
}
