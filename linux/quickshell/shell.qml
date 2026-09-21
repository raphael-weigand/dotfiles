import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "panels"

ShellRoot {
    id: root

    property string clockText: ""
    property int volumePercent: 0
    property bool volumeMuted: false
    property string networkIcon: "󰖪"
    property string bluetoothIcon: "󰂲"
    property string batteryIcon: "󰁹"
    property string batteryPercent: ""
    property string batteryStatusText: ""
    property string wifiName: ""
    property string bluetoothDevices: ""
    property string audioOutputName: ""
    property bool calendarVisible: false
    property bool audioPanelVisible: false
    property bool controlCenterVisible: false

    function refreshAudio() {
        audioStatus.running = true
        audioOutputStatus.running = true
    }

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
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            audioStatus.running = true
            networkStatus.running = true
            bluetoothStatus.running = true
            batteryStatus.running = true
            wifiDetails.running = true
            bluetoothDetails.running = true
            audioOutputStatus.running = true
        }
    }

    Process {
        id: audioStatus
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/Volume:\\s+([0-9.]+)/)
                if (m) root.volumePercent = Math.round(Number(m[1]) * 100)
                root.volumeMuted = text.indexOf("[MUTED]") !== -1
            }
        }
    }

    Process {
        id: audioToggle
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        onExited: audioStatus.running = true
    }

    Process {
        id: networkStatus
        command: ["sh", "-c", "type=$(nmcli -t -f TYPE connection show --active 2>/dev/null | head -n1); case \"$type\" in 802-11-wireless) echo wifi;; 802-3-ethernet) echo ethernet;; *) echo offline;; esac"]
        stdout: StdioCollector {
            onStreamFinished: {
                const value = text.trim()
                root.networkIcon = value === "wifi" ? "󰖩" : (value === "ethernet" ? "󰈀" : "󰖪")
            }
        }
    }

    Process {
        id: bluetoothStatus
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo on || echo off"]
        stdout: StdioCollector {
            onStreamFinished: root.bluetoothIcon = text.trim() === "on" ? "󰂯" : "󰂲"
        }
    }

    Process {
        id: bluetoothToggle
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"]
        onExited: bluetoothStatus.running = true
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
        id: wifiDetails
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | sed -n 's/^yes://p' | head -n1"]
        stdout: StdioCollector { onStreamFinished: root.wifiName = text.trim() }
    }

    Process {
        id: bluetoothDetails
        command: ["sh", "-c", "bluetoothctl devices Connected 2>/dev/null | sed 's/^Device [^ ]* //' | paste -sd ', ' -"]
        stdout: StdioCollector { onStreamFinished: root.bluetoothDevices = text.trim() }
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
                        implicitWidth: 30; implicitHeight: 28; radius: 4
                        color: networkMouse.containsMouse ? "#333333" : "transparent"
                        Text { anchors.centerIn: parent; text: root.networkIcon; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                        MouseArea { id: networkMouse; anchors.fill: parent; hoverEnabled: true; onClicked: networkSettings.running = true }
                    }
                    Rectangle {
                        implicitWidth: 30; implicitHeight: 28; radius: 4
                        color: btMouse.containsMouse ? "#333333" : "transparent"
                        Text { anchors.centerIn: parent; text: root.bluetoothIcon; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                        MouseArea {
                            id: btMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => { if (mouse.button === Qt.RightButton) bluetoothToggle.running = true; else bluetoothSettings.running = true }
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
                            onClicked: mouse => { if (mouse.button === Qt.RightButton) audioToggle.running = true; else root.audioPanelVisible = !root.audioPanelVisible }
                            onWheel: wheel => {
                                const delta = wheel.angleDelta.y > 0 ? "5%+" : "5%-"
                                volumeAdjust.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", delta]
                                volumeAdjust.running = true
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

    Variants {
        model: Quickshell.screens
        AudioPanel {
            required property var modelData
            screen: modelData
            panelVisible: root.audioPanelVisible
            onVolumePercentChanged: root.volumePercent = volumePercent
            onMutedChanged: root.volumeMuted = muted
            onOutputNameChanged: root.audioOutputName = outputName
        }
    }

    Process {
        id: volumeAdjust
        onExited: audioStatus.running = true
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
