import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.cyber.Dock 1.0
import MeuiKit 1.0 as Meui
import Cyber.NetworkManagement 1.0 as NM
import QtGraphicalEffects 1.15

Item {
    id: root
    visible: true
    clip: true

    property color backgroundColor: Meui.Theme.darkMode ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(255, 255, 255, 0.45)
    property color borderColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.05)
    property color activateDotColor: Meui.Theme.highlightColor
    property color inactiveDotColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.6) : Qt.rgba(0, 0, 0, 0.9)
    property real windowRadius: (Settings.direction === DockSettings.Left) ? root.width * 0.3 : root.height * 0.3
    property bool isHorizontal: Settings.direction !== DockSettings.Left
    property var appViewLength: isHorizontal ? appItemView.width : appItemView.height
    property var iconSize: 0

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
        view: rootWindow
        geometry: Qt.rect(root.x, root.y, root.width, root.height)
        radius: outerFrame.radius
    }

    Rectangle {
        id: outerFrame
        anchors.fill: parent
        radius: windowRadius
        color: backgroundColor
        border.color: Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
        antialiasing: true
        smooth: true

        Behavior on color {
            ColorAnimation {
                duration: 250
            }
        }
    }

    Rectangle {
        id: innerBorder
        anchors.fill: parent
        anchors.margins: 1
        radius: windowRadius
        color: "transparent"
        border.color: Qt.rgba(255, 255, 255, 0.2)
        border.width: 1
        antialiasing: true
        smooth: true
        visible: true
    }

    Meui.PopupTips {
        id: popupTips
    }

    GridLayout {
        id: mainLayout
        anchors.fill: parent
        anchors.rightMargin: isHorizontal ? windowRadius / 3 : 0
        anchors.bottomMargin: isHorizontal ? 0 : windowRadius / 3
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
                    easing.type: Easing.InOutQuad
                }
            }
        }

//        ListView {
//            spacing: Meui.Units.largeSpacing
//            Layout.preferredWidth: count * root.height + (count - 1) * spacing
//            Layout.preferredHeight: isHorizontal ? mainLayout.height * 0.7 : controlLayout.implicitHeight
//            Layout.alignment: Qt.AlignCenter
//            model: trayModel
//            orientation: Qt.Horizontal
//            layoutDirection: Qt.RightToLeft
//            interactive: false
//            clip: true

//            StatusNotifierModel {
//                id: trayModel
//            }

//            delegate: StandardItem {
//                width: isHorizontal ? mainLayout.height * 0.7 : controlLayout.implicitHeight
//                height: width

//                Image {
//                    anchors.centerIn: parent
//                    source: iconName ? "image://icontheme/" + iconName
//                                     : iconBytes ? "data:image/png;base64," + iconBytes
//                                                 : "image://icontheme/application-x-desktop"
//                    width: 16
//                    height: width
//                    sourceSize.width: width
//                    sourceSize.height: height
//                    asynchronous: true
//                }

//                onClicked: trayModel.leftButtonClick(id)
//                onRightClicked: trayModel.rightButtonClick(id)
//                // popupText: toolTip ? toolTip : title
//            }
//        }

        StandardItem {
            id: controlItem
            Layout.preferredWidth: isHorizontal ? controlLayout.implicitWidth : mainLayout.width * 0.7
            Layout.preferredHeight: isHorizontal ? mainLayout.height * 0.7 : controlLayout.implicitHeight
            Layout.alignment: Qt.AlignCenter
            Layout.rightMargin: isHorizontal ? 4 : 0
            Layout.bottomMargin: isHorizontal ? 0 : 4

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
                    visible: networking.wirelessEnabled
                }

                Image {
                    id: batteryIcon
                    visible: battery.available
                    width: 22
                    height: 16
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                    asynchronous: true
                    Layout.alignment: Qt.AlignCenter
                }

                Image {
                    id: volumeIcon
                    visible: volume.isValid
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
        }

        DropShadow {
            anchors.fill: controlItem
            radius: Meui.Theme.darkMode ? 8.0 : 2.0
            samples: 17
            color: "#80000000"
            source: controlItem
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
