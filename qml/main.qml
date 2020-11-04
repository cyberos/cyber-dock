import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import org.cyber.Dock 1.0
import MeuiKit 1.0 as Meui

Item {
    visible: true
    id: root

    property color backgroundColor: Meui.Theme.darkMode ? Qt.rgba(0, 0, 0, 0.05) : Qt.rgba(255, 255, 255, 0.5)
    property color foregroundColor: Meui.Theme.darkMode ? "white" : "black"
    property color borderColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.05)
    property color activateDotColor: Meui.Theme.darkMode ? "#4d81ff" : "#2E64E6"
    property color inactiveDotColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.6) : Qt.rgba(0, 0, 0, 0.9)
    property real windowRadius: (Settings.direction === DockSettings.Left) ? root.width * 0.3 : root.height * 0.3

    Rectangle {
        id: outerFrame
        anchors.fill: parent
        radius: windowRadius
        color: backgroundColor
        border.color: Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
    }

    Rectangle {
        id: innerBorder
        anchors.fill: parent
        anchors.margins: 1.5
        radius: windowRadius
        color: "transparent"
        border.color: Qt.rgba(255, 255, 255, 0.4)
        border.width: 1
        visible: Meui.Theme.darkMode
    }

    Meui.PopupTips {
        id: popupTips
    }

    GridLayout {
        anchors.fill: parent
        rows: (Settings.direction === DockSettings.Left) ? 3 : 1
        columns: (Settings.direction === DockSettings.Left) ? 1 : 3

        DockItem {
            id: launcherItem
            iconSizeRatio: 0.75
            enableActivateDot: false
            iconName: "qrc:/svg/launcher.svg"
            popupText: qsTr("Launcher")
            onClicked: process.start("cyber-launcher")
        }

        ListView {
            id: appItemView
            orientation: (Settings.direction === DockSettings.Left) ? Qt.Vertical : Qt.Horizontal
            snapMode: ListView.SnapToItem
            clip: true
            model: appModel
            delegate: AppItem { }

            onCountChanged: {
                // Automatically scroll list to end / bottom
                appItemView.currentIndex = count - 1
            }

            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        DockItem {
            id: trashItem
            popupText: qsTr("Trash")
            iconSizeRatio: 0.75
            enableActivateDot: false
            iconName: "user-trash-empty"
            onClicked: process.start("gio", ["open", "trash:///"])
        }
    }

    Connections {
        target: Settings
        onDirectionChanged: {
            popupTips.hide()
        }
    }
}
