import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

PanelWindow {
    id: root
    property bool panelVisible: false
    property var usage
    visible: panelVisible
    anchors { top: true; right: true }
    margins.top: 38
    margins.right: 170
    implicitWidth: 330
    implicitHeight: 245
    color: "transparent"

    function percent(value) {
        return value === null || value === undefined ? "—" : Math.round(value) + "%"
    }

    function formatReset(value) {
        if (value === null || value === undefined || value === "") return "Reset: —"
        let date
        if (typeof value === "number") date = new Date(value < 100000000000 ? value * 1000 : value)
        else if (/^\\d+$/.test(String(value))) {
            const n = Number(value)
            date = new Date(n < 100000000000 ? n * 1000 : n)
        } else date = new Date(value)
        if (isNaN(date.getTime())) return "Reset: —"
        return "Reset: " + Qt.formatDateTime(date, "dd.MM. HH:mm")
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.panelBackground
        border.width: 1
        border.color: "#553a3a3a"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Codex Usage"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 17; font.bold: true }
                Item { Layout.fillWidth: true }
                Text { text: "󰑐"; color: "#aaaaaa"; font.pixelSize: 17
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.usage.refreshCodex(true) }
                }
            }

            Text {
                text: root.usage.errorText
                visible: text !== ""
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                color: "#ffb4a9"
                font.pixelSize: 12
            }

            Repeater {
                model: [
                    { label: "5-Stunden-Limit", value: root.usage.sessionPercent, reset: root.usage.sessionReset },
                    { label: "Wochenlimit", value: root.usage.weekPercent, reset: root.usage.weekReset }
                ]
                ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 5
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.label; color: "#dddddd"; font.pixelSize: 13 }
                        Item { Layout.fillWidth: true }
                        Text { text: root.percent(modelData.value); color: "#eeeeee"; font.pixelSize: 13 }
                    }
                    Text {
                        text: root.formatReset(modelData.reset)
                        color: "#aaaaaa"
                        font.pixelSize: 11
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: "#333333"
                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(100, modelData.value === null ? 0 : modelData.value)) / 100
                            height: parent.height
                            radius: 3
                            color: "#289dcc"
                        }
                    }
                }
            }
            Item { Layout.fillHeight: true }
            Text { text: "Rechtsklick auf das Bar-Icon blendet es bis zum Neustart aus."; color: "#999999"; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true }
        }
    }
}
