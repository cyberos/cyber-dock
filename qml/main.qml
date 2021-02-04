import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import org.cyber.Dock 1.0
import MeuiKit 1.0 as Meui

Item {
    visible: true
    id: root
    clip: true

    property color backgroundColor: Meui.Theme.darkMode ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(255, 255, 255, 0.45)
    property color borderColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1) : Qt.rgba(0, 0, 0, 0.05)
    property color activateDotColor: Meui.Theme.highlightColor
    property color inactiveDotColor: Meui.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.6) : Qt.rgba(0, 0, 0, 0.9)
    property real windowRadius: (Settings.direction === DockSettings.Left) ? root.width * 0.3 : root.height * 0.3
    property bool isHorizontal: Settings.direction !== DockSettings.Left

    Volume {
        id: volume
    }

    Battery {
        id: battery
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
            implicitWidth: appItemView.iconSize
            implicitHeight: appItemView.iconSize
            enableActivateDot: false
            iconName: "qrc:/svg/launcher.svg"
            popupText: qsTr("Launcher")
            onClicked: process.startDetached("cyber-launcher")
        }

        ListView {
            id: appItemView
            orientation: isHorizontal ? Qt.Horizontal : Qt.Vertical
            snapMode: ListView.SnapToItem
            clip: true
            model: appModel

            Layout.fillHeight: true
            Layout.fillWidth: true

            property var iconSize: {
                var size = Settings.iconSize

                while (1) {
                    if (appItemView.count * size <= appItemView.width)
                        break

                    size--
                }

                return size
            }

            delegate: AppItem {
                implicitWidth: appItemView.iconSize
                implicitHeight: appItemView.height
            }

            interactive: false

            moveDisplaced: Transition {
                NumberAnimation {
                    properties: "x, y"
                    duration: 300
                    easing.type: Easing.InOutQuad
                }
            }
        }

        StandardItem {
            id: controlItem
            Layout.preferredWidth: controlLayout.implicitWidth
            Layout.preferredHeight: mainLayout.height * 0.7

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

                Image {
                    id: batteryIcon
                    visible: battery.available
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                    asynchronous: true
                }

                Image {
                    id: volumeIcon
                    visible: volume.isValid
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + volume.iconName + ".svg"
                    asynchronous: true
                }

                Label {
                    id: timeLabel

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
