import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    property bool panelVisible: false
    property string interfaceName: ""
    property string connectionType: ""
    property string address: ""
    property string gateway: ""
    property string linkSpeed: ""
    property real downloadRate: 0
    property real uploadRate: 0
    property real previousRx: -1
    property real previousTx: -1
    visible: panelVisible
    anchors { top: true; right: true }
    implicitWidth: 360
    implicitHeight: 220
    margins.top: 38
    margins.right: 150
    color: "transparent"

    function formatRate(bytes) {
        if (bytes >= 1048576) return (bytes / 1048576).toFixed(1) + " MB/s"
        if (bytes >= 1024) return (bytes / 1024).toFixed(1) + " KB/s"
        return Math.round(bytes) + " B/s"
    }

    function refresh() {
        details.running = true
        traffic.running = true
    }

    Process {
        id: details
        command: ["sh", "-c", "iface=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}'); [ -n \"$iface\" ] || exit 0; type=$(cat /sys/class/net/$iface/type 2>/dev/null); [ -d /sys/class/net/$iface/wireless ] && kind=wifi || kind=ethernet; ipaddr=$(ip -4 -o addr show dev $iface scope global 2>/dev/null | awk 'NR==1 {print $4}'); gw=$(ip route show default dev $iface 2>/dev/null | awk 'NR==1 {print $3}'); speed=$(cat /sys/class/net/$iface/speed 2>/dev/null); printf '%s|%s|%s|%s|%s\\n' \"$iface\" \"$kind\" \"$ipaddr\" \"$gw\" \"$speed\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("|")
                if (p.length < 2) return
                root.interfaceName = p[0]
                root.connectionType = p[1]
                root.address = p[2] || ""
                root.gateway = p[3] || ""
                const speed = Number(p[4])
                root.linkSpeed = !isNaN(speed) && speed > 0 ? (speed >= 1000 ? (speed / 1000).toFixed(speed % 1000 === 0 ? 0 : 1) + " Gbit/s" : speed + " Mbit/s") : ""
            }
        }
    }

    Process {
        id: traffic
        command: ["sh", "-c", "iface=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}'); [ -n \"$iface\" ] || exit 0; printf '%s|%s|%s\\n' \"$iface\" \"$(cat /sys/class/net/$iface/statistics/rx_bytes)\" \"$(cat /sys/class/net/$iface/statistics/tx_bytes)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split("|")
                if (p.length !== 3) return
                const rx = Number(p[1]); const tx = Number(p[2])
                if (root.interfaceName !== p[0]) {
                    root.interfaceName = p[0]; root.previousRx = -1; root.previousTx = -1
                }
                if (root.previousRx >= 0) root.downloadRate = Math.max(0, rx - root.previousRx)
                if (root.previousTx >= 0) root.uploadRate = Math.max(0, tx - root.previousTx)
                root.previousRx = rx; root.previousTx = tx
            }
        }
    }

    Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: root.refresh() }
    onPanelVisibleChanged: if (panelVisible) { previousRx = -1; previousTx = -1; refresh() }

    Rectangle {
        anchors.fill: parent; radius: 10; color: "#1c1c1c"; border.width: 1; border.color: "#3a3a3a"
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 10
            RowLayout {
                Layout.fillWidth: true
                Text { text: root.connectionType === "wifi" ? "󰖩  Network" : "󰈀  Ethernet"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 17; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: root.linkSpeed; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
            }
            Text { text: root.interfaceName; color: "#bbbbbb"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
            RowLayout {
                Layout.fillWidth: true
                Text { text: "↓  " + root.formatRate(root.downloadRate); color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: "↑  " + root.formatRate(root.uploadRate); color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15; font.bold: true }
            }
            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#333333" }
            GridLayout {
                columns: 2; columnSpacing: 18; rowSpacing: 6
                Text { text: "IP"; color: "#888888"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
                Text { text: root.address !== "" ? root.address : "—"; color: "#dddddd"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
                Text { text: "Gateway"; color: "#888888"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
                Text { text: root.gateway !== "" ? root.gateway : "—"; color: "#dddddd"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
            }
            Item { Layout.fillHeight: true }
        }
    }
}
