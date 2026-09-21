import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

PanelWindow {
    id: root
    property bool panelVisible: false
    property string activeProfile: ""
    readonly property var battery: UPower.displayDevice
    readonly property int percentage: battery ? Math.round(battery.percentage * 100) : 0
    readonly property bool onBattery: UPower.onBattery
    readonly property string statusText: !battery ? "Unknown" : (onBattery ? "Discharging" : "Charging / AC")
    visible: panelVisible
    anchors { top: true; right: true }
    implicitWidth: 390
    implicitHeight: 250
    margins.top: 38
    margins.right: 8
    color: "transparent"

    function refreshProfile() { if (!profileRead.running) profileRead.running = true }
    function setProfile(profile) {
        if (profileSet.running) return
        profileSet.command = ["powerprofilesctl", "set", profile]
        profileSet.running = true
    }
    function profileLabel(profile) {
        if (profile === "power-saver") return "Power Saver"
        if (profile === "performance") return "Performance"
        return "Balanced"
    }

    Process {
        id: profileRead
        command: ["busctl", "--json=short", "get-property", "net.hadess.PowerProfiles", "/net/hadess/PowerProfiles", "net.hadess.PowerProfiles", "ActiveProfile"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try { root.activeProfile = String(JSON.parse(text).data || "").trim() }
                catch (e) { root.activeProfile = "" }
            }
        }
    }
    Process { id: profileSet; onExited: root.refreshProfile() }
    Timer { interval: 2000; running: root.panelVisible; repeat: true; triggeredOnStart: true; onTriggered: root.refreshProfile() }

    Rectangle {
        anchors.fill: parent; radius: 10; color: "#1c1c1c"; border.width: 1; border.color: "#3a3a3a"
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 16; spacing: 12
            RowLayout {
                Layout.fillWidth: true
                Text { text: "󰁹  Battery"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 17; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: root.percentage + "%"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 17; font.bold: true }
            }
            Rectangle {
                Layout.fillWidth: true; implicitHeight: 6; radius: 3; color: "#333333"
                Rectangle { width: parent.width * Math.max(0, Math.min(1, root.percentage / 100)); height: parent.height; radius: 3; color: "#dddddd" }
            }
            Text { text: root.statusText; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 11 }
            Text { text: "POWER PROFILE"; color: "#777777"; font.family: "Iosevka Term Extended"; font.pixelSize: 10; font.bold: true }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                Repeater {
                    model: ["power-saver", "balanced", "performance"]
                    Rectangle {
                        required property string modelData
                        Layout.fillWidth: true; implicitHeight: 38; radius: 6
                        color: root.activeProfile === modelData ? "#eeeeee" : (profileMouse.containsMouse ? "#333333" : "#272727")
                        Text {
                            anchors.centerIn: parent
                            text: root.profileLabel(parent.modelData)
                            color: root.activeProfile === parent.modelData ? "#1c1c1c" : "#dddddd"
                            font.family: "Iosevka Term Extended"; font.pixelSize: 11
                        }
                        MouseArea { id: profileMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.setProfile(parent.modelData) }
                    }
                }
            }
            Text {
                text: root.activeProfile !== "" ? "Active: " + root.profileLabel(root.activeProfile) : "Power Profiles unavailable"
                color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 11
            }
            Item { Layout.fillHeight: true }
        }
    }
}
