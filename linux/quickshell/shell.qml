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
    property string clockTextPanel: ""
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
    // Hyprland emits a "submap" event whenever the active keymap changes.
    property string activeSubmap: ""
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "submap")
                root.activeSubmap = event.data === "reset" ? "" : event.data
        }
    }
    property string activePanel: ""
    property bool codexEnabled: true
    property var sessionPercent: null
    property var weekPercent: null
    property var sessionReset: null
    property var weekReset: null
    property string errorText: ""
    function hideCodex() {
        codexEnabled = false
        if (activePanel === "codex") closePanel()
    }
    function refreshCodex(force = false) {
        if (!codexEnabled || codexProcess.running) return
        codexProcess.command = ["python3", Quickshell.shellDir + "/codex-usage.py"].concat(force ? ["--refresh"] : [])
        codexProcess.running = true
    }
    Process {
        id: codexProcess
        command: ["python3", Quickshell.shellDir + "/codex-usage.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim())
                    root.sessionPercent = data.session
                    root.weekPercent = data.week
                    root.sessionReset = data.sessionReset ?? null
                    root.weekReset = data.weekReset ?? null
                    root.errorText = data.error || ""
                } catch (error) {
                    root.errorText = "Codex-Daten konnten nicht gelesen werden"
                }
            }
        }
    }
    Timer {
        interval: 60000
        repeat: true
        running: root.codexEnabled
        triggeredOnStart: true
        onTriggered: root.refreshCodex()
    }


    function togglePanel(name) {
        activePanel = activePanel === name ? "" : name
    }

    function closePanel() {
        activePanel = ""
    }

    IpcHandler {
        target: "session"
        function toggle(): void { root.togglePanel("session") }
    }

    function refreshClock() {
        clockText = Qt.formatDateTime(new Date(), "MMM dd, HH:mm")
        clockTextPanel = Qt.formatDateTime(new Date(), "HH:mm:ss")
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
        else togglePanel("network")
    }

    function openBluetooth(rightClick) {
        if (rightClick) bluetoothSettings.running = true
        else togglePanel("bluetooth")
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
        active: root.codexEnabled
        sourceComponent: CodexPanel { usage: root; panelVisible: root.activePanel === "codex" }
    }

    Loader {
        active: true
        sourceComponent: SessionPanel {
            shell: root
            panelVisible: root.activePanel === "session"
        }
    }

    Loader {
        active: true
        sourceComponent: PowerPanel {
            panelVisible: root.activePanel === "power"
        }
    }

    Loader {
        active: true
        sourceComponent: DeskPanel {
            panelVisible: root.activePanel === "desk"
        }
    }

    Loader {
        active: true
        sourceComponent: BluetoothPanel {
            panelVisible: root.activePanel === "bluetooth"
        }
    }

    Loader {
        id: networkPanelLoader
        active: true
        sourceComponent: NetworkPanel {
            panelVisible: root.activePanel === "network"
        }
    }

    Variants {
        model: Quickshell.screens
        AudioPanel {
            required property var modelData
            screen: modelData
            panelVisible: root.activePanel === "audio"
        }
    }

    Variants {
        model: Quickshell.screens
        CalendarPanel {
            required property var modelData
            screen: modelData
            panelVisible: root.activePanel === "calendar"
            clockText: clockTextPanel
        }
    }}
