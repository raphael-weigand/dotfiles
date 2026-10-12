import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

PanelWindow {
    id: root
    property bool panelVisible: false
    property string clockText: ""
    property date today: new Date()
    property int displayedYear: today.getFullYear()
    property int displayedMonth: today.getMonth()
    readonly property int firstWeekday: (new Date(displayedYear, displayedMonth, 1).getDay() + 6) % 7
    readonly property int daysInMonth: new Date(displayedYear, displayedMonth + 1, 0).getDate()
    readonly property int cellCount: 42
    function isoWeek(date) {
        const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
        d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7))
        const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1))
        return Math.ceil((((d - yearStart) / 86400000) + 1) / 7)
    }
    readonly property int yearDays: Math.round((new Date(today.getFullYear() + 1, 0, 1) - new Date(today.getFullYear(), 0, 1)) / 86400000)
    readonly property int dayOfYear: Math.floor((Date.UTC(today.getFullYear(), today.getMonth(), today.getDate()) - Date.UTC(today.getFullYear(), 0, 1)) / 86400000) + 1
    readonly property real yearProgress: Math.max(0, Math.min(1, (Date.now() - new Date(today.getFullYear(), 0, 1).getTime()) / (new Date(today.getFullYear() + 1, 0, 1).getTime() - new Date(today.getFullYear(), 0, 1).getTime())))
    visible: panelVisible
    anchors { top: true }
    implicitWidth: 350
    implicitHeight: 440
    margins.top: 38
    color: "transparent"

    function changeMonth(delta) {
        const date = new Date(displayedYear, displayedMonth + delta, 1)
        displayedYear = date.getFullYear()
        displayedMonth = date.getMonth()
    }
    function refreshDate() {
        const now = new Date()
        if (today.getDate() !== now.getDate() || today.getMonth() !== now.getMonth() || today.getFullYear() !== now.getFullYear()) {
            displayedYear = now.getFullYear()
            displayedMonth = now.getMonth()
        }
        today = now
    }
    onPanelVisibleChanged: {
        if (panelVisible) {
            refreshDate()
            displayedYear = today.getFullYear()
            displayedMonth = today.getMonth()
        }
    }
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.refreshDate()
    }
    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.panelBackground
        border.width: 1
        border.color: "#553a3a3a"
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 10
        Text {
            text: Qt.formatDate(root.today, "dddd, dd. MMMM yyyy")
            color: "#aaaaaa"
            font.family: "Iosevka Term Extended"
            font.pixelSize: 12
        }
        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(new Date(root.displayedYear, root.displayedMonth, 1), "MMMM yyyy")
                color: "#eeeeee"
                font.family: "Iosevka Term Extended"
                font.pixelSize: 18
                font.bold: true
            }
            Repeater {
                model: ["‹", "›"]
                Rectangle {
                    required property int index
                    required property string modelData
                    width: 30
                    height: 28
                    radius: 5
                    color: navMouse.containsMouse ? "#444444" : "transparent"
                    Text { anchors.centerIn: parent; text: modelData; color: "#eeeeee"; font.pixelSize: 23 }
                    MouseArea {
                        id: navMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changeMonth(index === 0 ? -1 : 1)
                    }
                }
            }
        }
        GridLayout {
            columns: 8
            rowSpacing: 5
            columnSpacing: 3
            Layout.fillWidth: true
            Repeater {
                model: ["KW", "Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
                Text {
                    required property string modelData
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 24
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                    color: "#999999"
                    font.family: "Iosevka Term Extended"
                    font.pixelSize: 12
                }
            }
            Repeater {
                model: 48
                Rectangle {
                    required property int index
                    readonly property bool weekColumn: index % 8 === 0
                    readonly property int weekRow: Math.floor(index / 8)
                    readonly property int dayNumber: weekRow * 7 + (index % 8) - root.firstWeekday
                    readonly property date cellDate: new Date(root.displayedYear, root.displayedMonth, dayNumber)
                    readonly property bool inMonth: cellDate.getMonth() === root.displayedMonth && cellDate.getFullYear() === root.displayedYear
                    readonly property bool isToday: !weekColumn && cellDate.getDate() === root.today.getDate() && cellDate.getMonth() === root.today.getMonth() && cellDate.getFullYear() === root.today.getFullYear()
                    Layout.preferredWidth: 35
                    Layout.preferredHeight: 29
                    radius: 5
                    color: isToday ? "#647fba" : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: weekColumn ? String(root.isoWeek(new Date(root.displayedYear, root.displayedMonth, 1 - root.firstWeekday + weekRow * 7))) : String(cellDate.getDate())
                        color: weekColumn ? "#91a9e6" : (inMonth ? "#eeeeee" : "#777777")
                        font.bold: isToday
                        font.family: "Iosevka Term Extended"
                        font.pixelSize: 13
                    }
                }
            }
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: "#444444" }
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Jahresfortschritt"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 13; Layout.fillWidth: true }
            Text { text: (root.yearProgress * 100).toFixed(1).replace(".", ",") + " %"; color: "#eeeeee"; font.family: "Iosevka Term Extended"; font.pixelSize: 13; font.bold: true }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 7
            radius: 4
            color: "#444444"
            Rectangle {
                width: parent.width * root.yearProgress
                height: parent.height
                radius: parent.radius
                color: "#91a9e6"
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Text { text: root.dayOfYear + " von " + root.yearDays + " Tagen"; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 11; Layout.fillWidth: true }
            Text { text: (root.yearDays - root.dayOfYear) + " Tage übrig"; color: "#999999"; font.family: "Iosevka Term Extended"; font.pixelSize: 11 }
        }
    }
}
