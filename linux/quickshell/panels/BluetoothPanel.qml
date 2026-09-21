import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

PanelWindow {
    id: root
    property bool panelVisible: false
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property var connectedDevices: devices.filter(d => d && d.connected)
    readonly property var knownDevices: devices.filter(d => d && !d.connected && (d.paired || d.bonded || d.trusted))
    visible: panelVisible
    anchors { top: true; right: true }
    implicitWidth: 360
    implicitHeight: 330
    margins.top: 38
    margins.right: 105
    color: "transparent"

    function label(device) {
        return (device && (device.name || device.alias || device.address)) || "Unknown device"
    }
    function toggleAdapter() {
        if (adapter) adapter.enabled = !adapter.enabled
    }
    function toggleDevice(device) {
        if (!device) return
        if (device.connected) {
            if (device.disconnect) device.disconnect()
        } else if (device.connect) {
            device.connect()
        }
    }

    Rectangle {
        anchors.fill: parent; radius: 10; color: "#c41c1c1c"; border.width: 1; border.color: "#553a3a3a"
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 10
            RowLayout {
                Layout.fillWidth: true
                Text { text: "󰂯  Bluetooth"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 17; font.bold: true }
                Item { Layout.fillWidth: true }
                Rectangle {
                    implicitWidth: 54; implicitHeight: 26; radius: 13
                    color: root.adapter && root.adapter.enabled ? "#eeeeee" : "#3a3a3a"
                    Rectangle { width: 20; height: 20; radius: 10; anchors.verticalCenter: parent.verticalCenter; x: root.adapter && root.adapter.enabled ? 31 : 3; color: root.adapter && root.adapter.enabled ? "#1c1c1c" : "#aaaaaa" }
                    MouseArea { anchors.fill: parent; onClicked: root.toggleAdapter() }
                }
            }
            Text {
                visible: !root.adapter
                text: "No Bluetooth adapter"
                color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 12
            }
            Text {
                visible: root.adapter && !root.adapter.enabled
                text: "Bluetooth is turned off"
                color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 12
            }
            Text { visible: root.connectedDevices.length > 0; text: "CONNECTED"; color: "#777777"; font.family: "Iosevka Term Extended"; font.pixelSize: 10; font.bold: true }
            Repeater {
                model: root.connectedDevices
                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true; implicitHeight: 38; radius: 5
                    color: connectedMouse.containsMouse ? "#333333" : "transparent"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                        Text { text: "󰂱"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 14 }
                        Text { text: root.label(modelData); color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                        Text { text: "Disconnect"; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 10 }
                    }
                    MouseArea { id: connectedMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.toggleDevice(parent.modelData) }
                }
            }
            Text { visible: root.knownDevices.length > 0; text: "PAIRED"; color: "#777777"; font.family: "Iosevka Term Extended"; font.pixelSize: 10; font.bold: true }
            Repeater {
                model: root.knownDevices
                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true; implicitHeight: 38; radius: 5
                    color: knownMouse.containsMouse ? "#333333" : "transparent"
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8
                        Text { text: "󰂯"; color: "#aaaaaa"; font.family: "Iosevka Term Extended"; font.pixelSize: 14 }
                        Text { text: root.label(modelData); color: "#dddddd"; font.family: "Iosevka Term Extended"; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                        Text { text: "Connect"; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 10 }
                    }
                    MouseArea { id: knownMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.toggleDevice(parent.modelData) }
                }
            }
            Item { Layout.fillHeight: true }
            Text { text: "Right-click the bar icon for Blueman"; color: "#777777"; font.family: "Iosevka Term Extended"; font.pixelSize: 10 }
        }
    }
}
