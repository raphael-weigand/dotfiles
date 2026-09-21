import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

PanelWindow {
    id: root
    property bool panelVisible: false
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int volumePercent: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property var mediaPlayers: Mpris.players ? Mpris.players.values : []
    readonly property var activePlayer: {
        let fallback = null
        for (let i = 0; i < mediaPlayers.length; i++) {
            const p = mediaPlayers[i]
            if (!p || !(p.trackTitle || p.trackArtist)) continue
            if (p.isPlaying) return p
            if (!fallback) fallback = p
        }
        return fallback
    }
    readonly property bool hasMedia: activePlayer !== null

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
    readonly property string outputName: sink ? (sink.description || sink.nick || sink.name || "Default output") : "Default output"
    visible: panelVisible
    anchors { top: true; right: true }
    implicitWidth: 360
    implicitHeight: root.hasMedia ? 390 : 230
    margins.top: 38
    margins.right: 76
    color: "transparent"

    Process { id: settings; command: ["pavucontrol"] }
    Process {
        id: focusPlayer
        property string desktopEntry: ""
        command: ["sh", "-c", "entry=" + JSON.stringify(desktopEntry) + "; class=$(basename \"$entry\" .desktop); hyprctl dispatch focuswindow \"class:($class)\" >/dev/null 2>&1 || gtk-launch \"$class\" >/dev/null 2>&1"]
    }

    function focusMediaPlayer() {
        if (!activePlayer) return
        focusPlayer.desktopEntry = activePlayer.desktopEntry || activePlayer.identity || ""
        if (focusPlayer.desktopEntry !== "") focusPlayer.running = true
    }

    Process {
        id: outputMenu
        command: ["sh", "-c", "~/.config/quickshell/audio-output-menu.sh"]

    }


    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#c41c1c1c"
        border.width: 1
        border.color: "#553a3a3a"
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
                    MouseArea {
                        id: muteMouse; anchors.fill: parent; hoverEnabled: true
                        onClicked: if (root.sink && root.sink.audio) root.sink.audio.muted = !root.sink.audio.muted
                    }
                }
                Slider {
                    id: slider
                    Layout.fillWidth: true
                    from: 0; to: 100
                    value: root.volumePercent
                    onMoved: {
                        if (root.sink && root.sink.audio)
                            root.sink.audio.volume = Math.max(0, Math.min(1.5, value / 100))
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true; implicitHeight: 34; radius: 6
                color: outputMouse.containsMouse ? "#3a3a3a" : "#292929"
                Text { anchors.centerIn: parent; text: "Switch output"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 12 }
                MouseArea { id: outputMouse; anchors.fill: parent; hoverEnabled: true; onClicked: outputMenu.running = true }
            }
            ColumnLayout {
                visible: root.hasMedia
                Layout.fillWidth: true
                spacing: 6
                Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#333333" }
                Text { text: "NOW PLAYING"; color: "#777777"; font.family: "Iosevka Term Extended"; font.pixelSize: 10; font.bold: true }
                Text {
                    Layout.fillWidth: true
                    text: root.activePlayer ? (root.activePlayer.trackTitle || "Unknown title") : ""
                    elide: Text.ElideRight; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 14; font.bold: true
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.focusMediaPlayer() }
                }
                Text {
                    Layout.fillWidth: true
                    text: root.activePlayer ? ((root.activePlayer.trackArtist || "") + (root.activePlayer.identity ? "  ·  " + root.activePlayer.identity : "")) : ""
                    elide: Text.ElideRight; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 11
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.focusMediaPlayer() }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 18
                    Text { text: "󰒮"; color: root.activePlayer && root.activePlayer.canGoPrevious ? "#eeeeee" : "#555555"; font.family: "Iosevka Term Extended"; font.pixelSize: 20
                        MouseArea { anchors.fill: parent; enabled: root.activePlayer && root.activePlayer.canGoPrevious; onClicked: root.activePlayer.previous() } }
                    Text { text: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 22
                        MouseArea { anchors.fill: parent; enabled: root.activePlayer && root.activePlayer.canTogglePlaying; onClicked: root.activePlayer.togglePlaying() } }
                    Text { text: "󰒭"; color: root.activePlayer && root.activePlayer.canGoNext ? "#eeeeee" : "#555555"; font.family: "Iosevka Term Extended"; font.pixelSize: 20
                        MouseArea { anchors.fill: parent; enabled: root.activePlayer && root.activePlayer.canGoNext; onClicked: root.activePlayer.next() } }
                }
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
