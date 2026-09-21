import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import "panels"
import "components"

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
    readonly property string networkIcon: "󰈀"
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property var bluetoothDeviceList: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property var connectedBluetoothDevices: {
        let result = []
        for (let i = 0; i < bluetoothDeviceList.length; i++)
            if (bluetoothDeviceList[i].connected) result.push(bluetoothDeviceList[i])
        return result
    }
    readonly property string bluetoothIcon: !bluetoothAdapter || !bluetoothAdapter.enabled ? "󰂲" : (connectedBluetoothDevices.length > 0 ? "󰂱" : "󰂯")
    readonly property var batteryDevice: UPower.displayDevice
    readonly property int batteryLevel: batteryDevice ? Math.round(batteryDevice.percentage * 100) : 0
    readonly property string batteryPercent: batteryDevice ? batteryLevel + "%" : ""
    readonly property string batteryIcon: batteryLevel <= 20 ? "󰁺" : (batteryLevel <= 50 ? "󰁾" : (batteryLevel <= 80 ? "󰂀" : "󰁹"))
    readonly property string wifiName: connectedWifi ? (connectedWifi.name || connectedWifi.ssid || "") : ""
    readonly property string bluetoothDevices: {
        let names = []
        for (let i = 0; i < connectedBluetoothDevices.length; i++)
            names.push(connectedBluetoothDevices[i].name || connectedBluetoothDevices[i].alias || "Bluetooth device")
        return names.join(", ")
    }
    property bool calendarVisible: false
    property bool audioPanelVisible: false
    property bool networkPanelVisible: false
    property bool bluetoothPanelVisible: false
    property bool powerPanelVisible: false

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

    function toggleAudioMute() {
        if (audioSink && audioSink.audio)
            audioSink.audio.muted = !audioSink.audio.muted
    }

    function toggleBluetooth() {
        if (bluetoothAdapter)
            bluetoothAdapter.enabled = !bluetoothAdapter.enabled
    }

    Process { id: launcher; command: ["fuzzel"] }
    Process { id: terminal; command: ["ghostty"] }
    Process { id: networkSettings; command: ["nm-connection-editor"] }
    Process { id: bluetoothSettings; command: ["blueman-manager"] }
    Process { id: audioSettings; command: ["pavucontrol"] }

    function openMenu(rightClick) {
        if (rightClick) terminal.running = true
        else launcher.running = true
    }

    function openNetwork(rightClick) {
        if (rightClick) networkSettings.running = true
        else networkPanelVisible = !networkPanelVisible
    }

    function openBluetooth(rightClick) {
        if (rightClick) bluetoothSettings.running = true
        else bluetoothPanelVisible = !bluetoothPanelVisible
    }

    function changeVolume(step) {
        if (audioSink && audioSink.audio)
            audioSink.audio.volume = Math.max(0, Math.min(1.5, audioSink.audio.volume + step))
    }

    Variants {
        model: Quickshell.screens
        StatusBar {
            required property var modelData
            screen: modelData
            shell: root
        }
    }

    Loader {
        active: true
        sourceComponent: PowerPanel {
            panelVisible: root.powerPanelVisible
        }
    }

    Loader {
        active: true
        sourceComponent: BluetoothPanel {
            panelVisible: root.bluetoothPanelVisible
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
        }
    }

    Variants {
        model: Quickshell.screens
        CalendarPanel {
            required property var modelData
            screen: modelData
            panelVisible: root.calendarVisible
            clockText: root.clockText
        }
    }}
