import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import "panels"

ShellRoot {
    id: root

    property string clockText: ""
    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property int volumePercent: audioSink && audioSink.audio ? Math.round(audioSink.audio.volume * 100) : 0
    readonly property bool volumeMuted: audioSink && audioSink.audio ? audioSink.audio.muted : false

    PwObjectTracker {
        objects: root.audioSink ? [root.audioSink] : []
    }
    readonly property var networkDevices: Networking.devices ? Networking.devices.values : []
    readonly property var wifiDevice: {
        for (let i = 0; i < networkDevices.length; i++)
            if (networkDevices[i].type === DeviceType.Wifi) return networkDevices[i]
        return null
    }
    readonly property var wifiNetworks: wifiDevice && wifiDevice.networks ? wifiDevice.networks.values : []
    readonly property var connectedWifi: {
        for (let i = 0; i < wifiNetworks.length; i++)
            if (wifiNetworks[i].connected) return wifiNetworks[i]
        return null
    }
    readonly property string networkIcon: connectedWifi ? "󰖩" : "󰖪"
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property var bluetoothDeviceList: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property var connectedBluetoothDevices: {
        let result = []
        for (let i = 0; i < bluetoothDeviceList.length; i++)
            if (bluetoothDeviceList[i].connected) result.push(bluetoothDeviceList[i])
        return result
    }
    readonly property string bluetoothIcon: !bluetoothAdapter || !bluetoothAdapter.enabled ? "󰂲" : (connectedBluetoothDevices.length > 0 ? "󰂱" : "󰂯")
    property string batteryIcon: "󰁹"
    property string batteryPercent: ""
    property string batteryStatusText: ""
    readonly property string wifiName: connectedWifi ? (connectedWifi.name || connectedWifi.ssid || "") : ""
    readonly property string bluetoothDevices: {
        let names = []
        for (let i = 0; i < connectedBluetoothDevices.length; i++)
            names.push(connectedBluetoothDevices[i].name || connectedBluetoothDevices[i].alias || "Bluetooth device")
        return names.join(", ")
    }
    property string audioOutputName: ""
    property bool calendarVisible: false
    property bool audioPanelVisible: false
    property bool networkPanelVisible: false
    property bool controlCenterVisible: false

    function refreshClock() {
        clockText = Qt.formatDateTime(new Date(), "HH:mm")
    }

    function workspaceById(id) {
        const values = Hyprland.workspaces.values
        for (let i = 0; i < values.length; i++)
            if (values[i].id === id) return values[i]
        return null
    }

    function workspaceIds() {
        let ids = [1, 2, 3, 4, 5]
        const values = Hyprland.workspaces.values
        for (let i = 0; i < values.length; i++) {
            const id = values[i].id
            if (id > 0 && id <= 10 && ids.indexOf(id) === -1) ids.push(id)
        }
        ids.sort((a, b) => a - b)
        return ids
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshClock()
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batteryStatus.running = true
            audioOutputStatus.running = true
        }
    }

    function toggleAudioMute() {
        if (audioSink && audioSink.audio)
            audioSink.audio.muted = !audioSink.audio.muted
    }

    function toggleBluetooth() {
        if (bluetoothAdapter)
            bluetoothAdapter.enabled = !bluetoothAdapter.enabled
    }

    Process {
        id: batteryStatus
        command: ["sh", "-c", "bat=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' | head -n1); [ -n \"$bat\" ] || exit 0; cat \"$bat/capacity\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = Number(text.trim())
                if (isNaN(p)) {
                    root.batteryPercent = ""
                    return
                }
                root.batteryPercent = p + "%"
                root.batteryIcon = p <= 20 ? "󰁺" : (p <= 50 ? "󰁾" : (p <= 80 ? "󰂀" : "󰁹"))
            }
        }
    }

    Process {
        id: audioOutputStatus
        command: ["sh", "-c", "wpctl status | awk '/Sinks:/ {s=1; next} s && /Sources:/ {exit} s && /\\*/ {line=$0; sub(/^.*\\*[[:space:]]*/, \"\", line); sub(/^[0-9]+\\.[[:space:]]*/, \"\", line); sub(/[[:space:]]+\\[vol:.*$/, \"\", line); print line; exit}'"]
        stdout: StdioCollector { onStreamFinished: root.audioOutputName = text.trim() }
    }

    Process { id: launcher; command: ["fuzzel"] }
    Process { id: terminal; command: ["ghostty"] }
    Process { id: networkSettings; command: ["nm-connection-editor"] }
    Process { id: bluetoothSettings; command: ["blueman-manager"] }
    Process { id: audioSettings; command: ["pavucontrol"] }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 32
            color: "#1c1c1c"

            Rectangle {
                anchors.fill: parent
                color: "#1c1c1c"

                RowLayout {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Rectangle {
                        implicitWidth: 32; implicitHeight: 28; radius: 4
                        color: menuMouse.containsMouse ? "#333333" : "transparent"
                        Text { anchors.centerIn: parent; text: "󰣇"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 16 }
                        MouseArea {
                            id: menuMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => { if (mouse.button === Qt.RightButton) terminal.running = true; else launcher.running = true }
                        }
                    }

                    Item { implicitWidth: 8; implicitHeight: 28 }

                    Repeater {
                        model: root.workspaceIds()
                        Rectangle {
                            required property int modelData
                            property var workspace: root.workspaceById(modelData)
                            property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
                            property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
                            implicitWidth: 28; implicitHeight: 28; radius: 4
                            color: wsMouse.containsMouse ? "#333333" : "transparent"
                            opacity: occupied || focused ? 1 : 0.5
                            Text {
                                anchors.centerIn: parent
                                text: parent.focused ? "󰮯" : (parent.modelData === 10 ? "0" : String(parent.modelData))
                                color: "#eeeeee"
                                font.family: "Iosevka Term Extended"
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: wsMouse; anchors.fill: parent; hoverEnabled: true
                                onClicked: Hyprland.dispatch("workspace " + parent.modelData)
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.clockText
                    color: "#eeeeee"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 13
                    font.bold: true
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.calendarVisible = !root.calendarVisible
                    }
                }

                RowLayout {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Rectangle {
                        implicitWidth: 118; implicitHeight: 28; radius: 4
                        color: networkMouse.containsMouse ? "#333333" : "transparent"
                        Row {
                            anchors.centerIn: parent; spacing: 5
                            Text { text: root.networkIcon; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                            Text { text: networkPanelLoader.item ? "↓" + networkPanelLoader.item.formatRate(networkPanelLoader.item.downloadRate).replace("/s", "") + " ↑" + networkPanelLoader.item.formatRate(networkPanelLoader.item.uploadRate).replace("/s", "") : ""; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 10 }
                        }
                        MouseArea {
                            id: networkMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => { if (mouse.button === Qt.RightButton) networkSettings.running = true; else root.networkPanelVisible = !root.networkPanelVisible }
                        }
                    }
                    Rectangle {
                        implicitWidth: 30; implicitHeight: 28; radius: 4
                        color: btMouse.containsMouse ? "#333333" : "transparent"
                        Text { anchors.centerIn: parent; text: root.bluetoothIcon; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                        MouseArea {
                            id: btMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => { if (mouse.button === Qt.RightButton) root.toggleBluetooth(); else bluetoothSettings.running = true }
                        }
                    }
                    Rectangle {
                        implicitWidth: 52; implicitHeight: 28; radius: 4
                        color: audioMouse.containsMouse ? "#333333" : "transparent"
                        Row { anchors.centerIn: parent; spacing: 5
                            Text { text: root.volumeMuted ? "󰝟" : "󰕾"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                            Text { text: root.volumePercent + "%"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 11 }
                        }
                        MouseArea {
                            id: audioMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => { if (mouse.button === Qt.RightButton) root.toggleAudioMute(); else root.audioPanelVisible = !root.audioPanelVisible }
                            onWheel: wheel => {
if (root.audioSink && root.audioSink.audio) {
                                    const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                                    root.audioSink.audio.volume = Math.max(0, Math.min(1.5, root.audioSink.audio.volume + step))
                                }
                            }
                        }
                    }
                    Rectangle {
                        visible: root.batteryPercent !== ""
                        implicitWidth: 62; implicitHeight: 28; radius: 4
                        color: powerMouse.containsMouse ? "#333333" : "transparent"
                        Row { anchors.centerIn: parent; spacing: 5
                            Text { text: root.batteryIcon; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                            Text { text: root.batteryPercent; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 11 }
                        }
                        MouseArea { id: powerMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.controlCenterVisible = !root.controlCenterVisible }
                    }
                }
            }
        }
    }

    Loader {
        id: networkPanelLoader
        active: true
        sourceComponent: NetworkPanel {
            panelVisible: root.networkPanelVisible
        }
    }

    Variants {
        model: Quickshell.screens
        AudioPanel {
            required property var modelData
            screen: modelData
            panelVisible: root.audioPanelVisible
            onOutputNameChanged: root.audioOutputName = outputName
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            visible: root.calendarVisible
            anchors { top: true }
            implicitWidth: 300
            implicitHeight: 190
            margins.top: 38
            color: "transparent"
            Rectangle {
                anchors.fill: parent; radius: 10; color: "#1c1c1c"; border.width: 1; border.color: "#3a3a3a"
                Column {
                    anchors.centerIn: parent; spacing: 10
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(new Date(), "dddd"); color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 13 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(new Date(), "dd. MMMM yyyy"); color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 20; font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.clockText; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 36; font.bold: true }
                }
            }
        }
    }

    // Keep the richer system controls available from the battery area without
    // making the status bar depend on Omarchy's shell host.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: root.controlCenterVisible
            anchors { top: true; right: true }
            implicitWidth: 330
            implicitHeight: 230
            margins.top: 38
            margins.right: 8
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: "#1c1c1c"
                border.width: 1
                border.color: "#3a3a3a"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    Text { text: "System"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 17; font.bold: true }
                    Text { text: "Network   " + root.networkIcon + (root.wifiName !== "" ? "  " + root.wifiName : ""); color: "#dddddd"; font.family: "Iosevka Term Extended"; font.pixelSize: 13 }
                    Text { text: "Bluetooth " + root.bluetoothIcon + (root.bluetoothDevices !== "" ? "  " + root.bluetoothDevices : ""); color: "#dddddd"; font.family: "Iosevka Term Extended"; font.pixelSize: 13 }
                    Text { text: "Audio     " + (root.volumeMuted ? "Muted" : root.volumePercent + "%") + (root.audioOutputName !== "" ? "  ·  " + root.audioOutputName : ""); color: "#dddddd"; font.family: "Iosevka Term Extended"; font.pixelSize: 13 }
                    Text { visible: root.batteryPercent !== ""; text: "Battery   " + root.batteryPercent; color: "#dddddd"; font.family: "Iosevka Term Extended"; font.pixelSize: 13 }
                    Item { Layout.fillHeight: true }
                    Text { text: "Click the bar icons for settings"; color: "#888888"; font.family: "Iosevka Term Extended"; font.pixelSize: 11 }
                }
            }
        }
    }
}
