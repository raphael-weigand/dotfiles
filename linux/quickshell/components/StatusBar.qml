import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import ".."

PanelWindow {
    id: bar
    property var shell
    anchors { top: true; left: true; right: true }
    implicitHeight: 32
    color: Theme.barBackground

    Rectangle {
        anchors.fill: parent; color: Theme.barBackground
        RowLayout {
            anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter; spacing: 2
            Repeater {
                model: shell.workspaceIds()
                Rectangle {
                    required property int modelData
                    property var workspace: shell.workspaceById(modelData)
                    property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
                    property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData
                    implicitWidth: 28; implicitHeight: 28; radius: 4
                    color: wsMouse.containsMouse ? "#333333" : "transparent"; opacity: occupied || focused ? 1 : 0.5
                    Text { anchors.centerIn: parent; text: parent.focused ? "󰮯" : (parent.modelData === 10 ? "0" : String(parent.modelData)); color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 13 }
                    MouseArea { id: wsMouse; anchors.fill: parent; hoverEnabled: true; onClicked: Hyprland.dispatch("workspace " + parent.modelData) }
                }
            }
        }
        Text {
            anchors.centerIn: parent; text: shell.clockText; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 13; font.bold: true
            MouseArea { anchors.fill: parent; anchors.margins: -8; cursorShape: Qt.PointingHandCursor; onClicked: shell.togglePanel("calendar") }
        }
        RowLayout {
            anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; spacing: 2
            Rectangle {
                implicitWidth: 30; implicitHeight: 28; radius: 4; color: deskMouse.containsMouse ? "#333333" : "transparent"
                Text { anchors.centerIn: parent; text: "󰇄"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                MouseArea { id: deskMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: shell.togglePanel("desk") }
            }
            Rectangle {
                implicitWidth: 30; implicitHeight: 28; radius: 4; color: networkMouse.containsMouse ? "#333333" : "transparent"
                Text { anchors.centerIn: parent; text: shell.networkIcon; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                MouseArea { id: networkMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => shell.openNetwork(mouse.button === Qt.RightButton) }
            }
            Rectangle {
                implicitWidth: 30; implicitHeight: 28; radius: 4; color: btMouse.containsMouse ? "#333333" : "transparent"
                Text { anchors.centerIn: parent; text: shell.bluetoothIcon; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                MouseArea { id: btMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => shell.openBluetooth(mouse.button === Qt.RightButton) }
            }

            Rectangle {
                implicitWidth: 30; implicitHeight: 28; radius: 4; color: audioMouse.containsMouse ? "#333333" : "transparent"
                Text { anchors.centerIn: parent; text: shell.volumeMuted ? "󰝟" : "󰕾"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                MouseArea { id: audioMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => { if (mouse.button === Qt.RightButton) shell.toggleAudioMute(); else shell.togglePanel("audio") }
                    onWheel: wheel => shell.changeVolume(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
                }
            }
            Rectangle {
                visible: shell.batteryPercent !== ""; implicitWidth: 30; implicitHeight: 28; radius: 4; color: powerMouse.containsMouse ? "#333333" : "transparent"
                Text { anchors.centerIn: parent; text: shell.batteryIcon; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 15 }
                MouseArea { id: powerMouse; anchors.fill: parent; hoverEnabled: true; onClicked: shell.togglePanel("power") }
            }
        }
    }
}
