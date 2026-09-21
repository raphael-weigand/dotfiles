import QtQuick
import Quickshell

PanelWindow {
    id: root
    property bool panelVisible: false
    property string clockText: ""
    visible: panelVisible
    anchors { top: true }
    implicitWidth: 300
    implicitHeight: 190
    margins.top: 38
    color: "transparent"
    Rectangle {
        anchors.fill: parent; radius: 10; color: "#ee1c1c1c"; border.width: 1; border.color: "#553a3a3a"
        Column {
            anchors.centerIn: parent; spacing: 10
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(new Date(), "dddd"); color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 13 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(new Date(), "dd. MMMM yyyy"); color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 20; font.bold: true }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.clockText; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 36; font.bold: true }
        }
    }
}
