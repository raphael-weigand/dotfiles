import QtQuick
import Quickshell
import ".."

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
    function refreshDate() {
        clockText = Qt.formatDateTime(new Date(), "MMM dd, HH:mm")
    }
    Timer {
        interval: (5000 * 20 * 60)
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshClock()
    }
    Rectangle {
        anchors.fill: parent; radius: 10; color: Theme.panelBackground; border.width: 1; border.color: "#553a3a3a"
        Column {
            anchors.centerIn: parent; spacing: 10
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(new Date(), "dddd"); color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 13 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(new Date(), "dd. MMMM yyyy"); color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 20; font.bold: true }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.clockText; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 36; font.bold: true }
        }
    }
}
