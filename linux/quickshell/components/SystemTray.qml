import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    id: root
    spacing: 2

    readonly property var items: {
        let result = []
        const values = SystemTray.items ? SystemTray.items.values : []
        for (let i = 0; i < values.length; i++)
            if (values[i] && values[i].status !== Status.Passive) result.push(values[i])
        return result
    }

    Repeater {
        model: root.items

        Rectangle {
            required property var modelData
            implicitWidth: 28
            implicitHeight: 28
            radius: 4
            color: trayMouse.containsMouse ? "#333333" : "transparent"

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: parent.modelData.icon || ""
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: mouse => {
                    const item = parent.modelData
                    if (mouse.button === Qt.MiddleButton) {
                        item.secondaryActivate()
                    } else if (mouse.button === Qt.RightButton || item.onlyMenu) {
                        const point = parent.QsWindow.contentItem.mapFromItem(parent, mouse.x, mouse.y)
                        item.display(parent.QsWindow.window, point.x, point.y)
                    } else {
                        item.activate()
                    }
                }

                onWheel: wheel => parent.modelData.scroll(wheel.angleDelta.y, false)
            }
        }
    }
}
