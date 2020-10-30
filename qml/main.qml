import QtQuick 2.12
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0
import MeuiKit 1.0 as Meui

Rectangle {
    visible: true
    id: root

    color: "transparent"

    property color backgroundColor: Meui.Theme.darkMode ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(255, 255, 255, 0.5)
    property color foregroundColor: Meui.Theme.darkMode ? "white" : "black"
    property color borderColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.05)
    property color activateDotColor: Meui.Theme.darkMode ? "#4d81ff" : "#2E64E6"
    property color inactiveDotColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.6) : Qt.rgba(0, 0, 0, 0.9)

    Rectangle {
        id: outerFrame
        anchors.fill: parent
        radius: parent.height * 0.3
        color: backgroundColor
        border.color: Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
    }

    Rectangle {
        id: innerBorder
        anchors.fill: parent
        anchors.margins: 1.5
        radius: parent.height * 0.3
        color: "transparent"
        border.color: Qt.rgba(255, 255, 255, 0.4)
        border.width: 1
    }

    Meui.PopupTips {
        id: popupTips
    }

    DockItem {
        id: launcherItem
        anchors.left: parent.left
        anchors.top: parent.top

        iconSizeRatio: 0.75
        enableActivateDot: false
        iconName: "qrc:/svg/launcher.svg"
        popupText: qsTr("Launcher")

        onClicked: {
            process.start("cyber-launcher")
        }
    }

    Item {
        id: appList
        anchors.left: launcherItem.right
        anchors.top: parent.top
        width: parent.width - launcherItem.width * 2
        height: parent.height

        ListView {
            id: pageView
            anchors.fill: parent
            orientation: Qt.Horizontal
            snapMode: ListView.SnapOneItem
            model: appModel
            clip: true

            delegate: AppItemDelegate { }
        }
    }

    DockItem {
        id: trashItem
        anchors.left: appList.right
        anchors.top: parent.top
        popupText: qsTr("Trash")

        iconSizeRatio: 0.75
        enableActivateDot: false
        iconName: "user-trash-empty"

        onClicked: {
            process.start("gio", ["open", "trash:///"])
        }
    }
}
