import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    property bool panelVisible: false
    property int volumePercent: 0
    property bool muted: false
    property string outputName: ""
    visible: panelVisible
    anchors { top: true; right: true }
    implicitWidth: 360
    implicitHeight: 230
    margins.top: 38
    margins.right: 76
    color: "transparent"

    function refresh() { status.running = true; output.running = true }

    Process {
        id: status
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/Volume:\\s+([0-9.]+)/)
                if (m) root.volumePercent = Math.round(Number(m[1]) * 100)
                root.muted = text.indexOf("[MUTED]") !== -1
            }
        }
    }
    Process {
        id: output
        command: ["sh", "-c", "wpctl status | awk '/Sinks:/ {s=1; next} s && /Sources:/ {exit} s && /\\*/ {line=$0; sub(/^.*\\*[[:space:]]*/, \"\", line); sub(/^[0-9]+\\.[[:space:]]*/, \"\", line); sub(/[[:space:]]+\\[vol:.*$/, \"\", line); print line; exit}'"]
        stdout: StdioCollector { onStreamFinished: root.outputName = text.trim() }
    }
    Process { id: setVolume; onExited: root.refresh() }
    Process { id: toggleMute; command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]; onExited: root.refresh() }
    Process { id: settings; command: ["pavucontrol"] }
    Process {
        id: outputMenu
        command: ["sh", "-c", "~/.config/quickshell/audio-output-menu.sh"]
        onExited: {
            root.refresh()
            delayedRefresh.restart()
        }
    }

    Timer {
        id: delayedRefresh
        interval: 500
        repeat: false
        onTriggered: root.refresh()
    }

    onPanelVisibleChanged: if (panelVisible) refresh()

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#1c1c1c"
        border.width: 1
        border.color: "#3a3a3a"
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Audio"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 17; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: root.volumePercent + "%"; color: "#aaaaaa"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
            }
            Text {
                Layout.fillWidth: true
                text: root.outputName !== "" ? root.outputName : "Default output"
                elide: Text.ElideRight
                color: "#bbbbbb"
                font.family: "Iosevka Term Extended"
                font.pixelSize: 12
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Rectangle {
                    implicitWidth: 34; implicitHeight: 34; radius: 6
                    color: muteMouse.containsMouse ? "#3a3a3a" : "#292929"
                    Text { anchors.centerIn: parent; text: root.muted ? "󰝟" : "󰕾"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 17 }
                    MouseArea { id: muteMouse; anchors.fill: parent; hoverEnabled: true; onClicked: toggleMute.running = true }
                }
                Slider {
                    id: slider
                    Layout.fillWidth: true
                    from: 0; to: 100
                    value: root.volumePercent
                    onMoved: {
                        root.volumePercent = Math.round(value)
                        setVolume.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(value) + "%"]
                        setVolume.running = true
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true; implicitHeight: 34; radius: 6
                color: outputMouse.containsMouse ? "#3a3a3a" : "#292929"
                Text { anchors.centerIn: parent; text: "Switch output"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
                MouseArea { id: outputMouse; anchors.fill: parent; hoverEnabled: true; onClicked: outputMenu.running = true }
            }
            Item { Layout.fillHeight: true }
            Rectangle {
                Layout.fillWidth: true; implicitHeight: 34; radius: 6
                color: settingsMouse.containsMouse ? "#3a3a3a" : "#292929"
                Text { anchors.centerIn: parent; text: "Audio settings"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
                MouseArea { id: settingsMouse; anchors.fill: parent; hoverEnabled: true; onClicked: settings.running = true }
            }
        }
    }
}
