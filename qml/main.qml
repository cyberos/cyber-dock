import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15

import Cyber.NetworkManagement 1.0 as NM
import Cyber.Dock 1.0
import MeuiKit 1.0 as Meui

Item {
    id: root
    visible: true
    clip: true

    property color backgroundColor: Meui.Theme.darkMode ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(255, 255, 255, 0.45)
    property color borderColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.05)
    property real windowRadius: (Settings.direction === DockSettings.Left) ? root.width * 0.3 : root.height * 0.3
    property bool isHorizontal: Settings.direction !== DockSettings.Left
    property var appViewLength: isHorizontal ? appItemView.width : appItemView.height
    property var iconSize: 0

    Timer {
        id: resizeIconTimer
        interval: 100
        running: false
        repeat: false
        triggeredOnStart: true
        onTriggered: calcIconSize()
    }

    function delayCalcIconSize() {
        resizeIconTimer.running = true
    }

    function calcIconSize() {
        var size = Settings.iconSize

        while (1) {
            if (appItemView.count * size <= root.appViewLength)
                break

            size--
        }

        root.iconSize = size
    }

    Volume {
        id: volume
    }

    Battery {
        id: battery
    }

    NM.ConnectionIcon {
        id: connectionIconProvider
    }

    NM.Networking {
        id: networking
    }

    Meui.WindowShadow {
        view: mainWindow
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        radius: _background.radius
    }

    Rectangle {
        id: _background
        anchors.fill: parent
        radius: windowRadius
        color: Meui.Theme.backgroundColor
        opacity: Settings.dockTransparency == true ? 0.5 : 1

        Behavior on color {
            ColorAnimation {
                duration: 125
                easing.type: Easing.InOutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: windowRadius
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.9)
            antialiasing: true
            smooth: true
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: windowRadius - 1
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(255, 255, 255, 0.5)
            antialiasing: true
            smooth: true
        }
    }

    Meui.PopupTips {
        id: popupTips
    }

    GridLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.rightMargin: isHorizontal ? Meui.Units.smallSpacing : 0
        anchors.bottomMargin: isHorizontal ? 0 : Meui.Units.smallSpacing
        flow: isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
        rowSpacing: 0
        columnSpacing: 0

        DockItem {
            id: launcherItem
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
            enableActivateDot: false
            iconName: "qrc:/svg/launcher.svg"
            popupText: qsTr("Launcher")
            onClicked: process.startDetached("cyber-launcher")
            Layout.alignment: Qt.AlignCenter
        }

        ListView {
            id: appItemView
            orientation: isHorizontal ? Qt.Horizontal : Qt.Vertical
            snapMode: ListView.SnapToItem
            clip: true
            model: appModel
            interactive: false

            Layout.fillHeight: true
            Layout.fillWidth: true

            delegate: AppItem {
                implicitWidth: isHorizontal ? root.iconSize : appItemView.width
                implicitHeight: isHorizontal ? appItemView.height : root.iconSize
            }

            moveDisplaced: Transition {
                NumberAnimation {
                    properties: "x, y"
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }
        }

        ListView {
            id: systemTrayView
            spacing: Meui.Units.smallSpacing
            Layout.preferredWidth: isHorizontal ? count * itemHeight + (count - 1) * spacing : mainLayout.width * 0.7
            Layout.preferredHeight: isHorizontal ? mainLayout.height * 0.7 : count * itemHeight + (count - 1) * spacing
            Layout.alignment: Qt.AlignCenter
            model: trayModel
            orientation: isHorizontal ? Qt.Horizontal : Qt.Vertical
            layoutDirection: Qt.RightToLeft
            interactive: false
            clip: true

            onCountChanged: delayCalcIconSize()

            property var itemWidth: isHorizontal ? itemHeight / 2 + Meui.Units.smallSpacing : mainLayout.width * 0.7
            property var itemHeight: isHorizontal ? mainLayout.height * 0.7 : itemWidth / 2

            StatusNotifierModel {
                id: trayModel
            }

            delegate: StandardItem {
                height: systemTrayView.itemHeight
                width: systemTrayView.itemWidth

                Image {
                    anchors.centerIn: parent
                    source: iconName ? "image://icontheme/" + iconName
                                     : iconBytes ? "data:image/png;base64," + iconBytes
                                                 : "image://icontheme/application-x-desktop"
                    width: 16
                    height: width
                    sourceSize.width: width
                    sourceSize.height: height
                    asynchronous: true
                }

                onClicked: trayModel.leftButtonClick(id)
                onRightClicked: trayModel.rightButtonClick(id)
                popupText: toolTip ? toolTip : title
            }
        }

        StandardItem {
            id: controlItem
            Layout.preferredWidth: isHorizontal ? controlLayout.implicitWidth : mainLayout.width * 0.7
            Layout.preferredHeight: isHorizontal ? mainLayout.height * 0.7 : controlLayout.implicitHeight
            Layout.alignment: Qt.AlignCenter
            Layout.rightMargin: isHorizontal ? Meui.Units.smallSpacing : 0
            Layout.bottomMargin: isHorizontal ? 0 : Meui.Units.smallSpacing

            onClicked: {
                if (controlCenter.visible)
                    controlCenter.visible = false
                else {
                    controlCenter.visible = true
                    controlCenter.position = Qt.point(mapToGlobal(0, 0).x, mapToGlobal(0, 0).y)
                }
            }

            GridLayout {
                id: controlLayout
                anchors.fill: parent
                flow: isHorizontal ? Grid.LeftToRight : Grid.TopToBottom
                columnSpacing: isHorizontal ? Meui.Units.largeSpacing * 1.5 : 0
                rowSpacing: isHorizontal ? 0 : Meui.Units.largeSpacing * 1.5

                // Padding
                Item {
                    width: 1
                    height: 1
                }

                Image {
                    id: networkIcon
                    width: 16
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") +
                            connectionIconProvider.connectionTooltipIcon + ".svg"
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                    visible: networking.enabled && status === Image.Ready
                }

                Image {
                    id: batteryIcon
                    visible: battery.available && status === Image.Ready
                    width: 22
                    height: 16
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }

                Image {
                    id: volumeIcon
                    visible: volume.isValid && status === Image.Ready
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + volume.iconName + ".svg"
                    width: 16
                    height: width
                    sourceSize: Qt.size(width, height)
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }

                Label {
                    id: timeLabel
                    Layout.alignment: Qt.AlignCenter
                    font.pixelSize: isHorizontal ? controlLayout.height / 3 : controlLayout.width / 5

                    Timer {
                        interval: 1000
                        repeat: true
                        running: true
                        triggeredOnStart: true
                        onTriggered: {
                            timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
                        }
                    }
                }

                // Padding
                Item {
                    width: 1
                    height: 1
                }
            }

            DropShadow {
                source: controlLayout
                anchors.fill: controlLayout
                radius: 20.0
                samples: 17
                color: "black"
                verticalOffset: 2
                visible: Meui.Theme.darkMode
            }
        }
    }

    ControlCenter {
        id: controlCenter
    }

    Connections {
        target: Settings
        function onDirectionChanged() {
            popupTips.hide()
        }
    }
}
