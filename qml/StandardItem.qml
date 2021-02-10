import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import MeuiKit 1.0 as Meui

Item {
    id: control

    signal clicked
    signal rightClicked

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onClicked: {
            if (mouse.button == Qt.LeftButton)
                control.clicked()
            else if (mouse.button == Qt.RightButton)
                control.rightClicked()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Meui.Theme.smallRadius

        color: {
            if (_mouseArea.containsMouse) {
                if (_mouseArea.containsPress)
                    return (Meui.Theme.darkMode) ? Qt.rgba(255, 255, 255, 0.3) : Qt.rgba(0, 0, 0, 0.2)
                else
                    return (Meui.Theme.darkMode) ? Qt.rgba(255, 255, 255, 0.2) : Qt.rgba(0, 0, 0, 0.1)
            }

            return "transparent"
        }

        Behavior on color {
            ColorAnimation { duration: 125 }
        }
    }
}
