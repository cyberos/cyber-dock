import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import MeuiKit 1.0 as Meui

Item {
    id: control

    property bool checked: false
    property alias icon: _image.source
    property alias text: _label.text

    signal clicked

    property var hoverColor: Meui.Theme.darkMode ? Qt.lighter(Meui.Theme.secondBackgroundColor, 1.3)
                                                 : Qt.darker(Meui.Theme.secondBackgroundColor, 1.1)
    property var pressedColor: Meui.Theme.darkMode ? Qt.lighter(Meui.Theme.secondBackgroundColor, 1.1)
                                                 : Qt.darker(Meui.Theme.secondBackgroundColor, 1.3)
    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: control.clicked()
    }

    Meui.RoundedRect {
        anchors.fill: parent
        radius: Meui.Theme.bigRadius
        opacity: 0.5
        color: control.checked ? Meui.Theme.highlightColor : Meui.Theme.secondBackgroundColor
    }

    ColumnLayout {
        anchors.fill: parent

        Image {
            id: _image
            Layout.preferredWidth: control.height / 3
            Layout.preferredHeight: control.height / 3
            sourceSize: Qt.size(width, height)
            asynchronous: true
            Layout.alignment: Qt.AlignCenter

            ColorOverlay {
                anchors.fill: _image
                source: _image
                color: control.checked ? Meui.Theme.highlightedTextColor : Meui.Theme.disabledTextColor
            }
        }

        Label {
            id: _label
            color: control.checked ? Meui.Theme.highlightedTextColor : Meui.Theme.textColor
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
