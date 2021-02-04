import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.cyber.Dock 1.0
import MeuiKit 1.0 as Meui
import QtGraphicalEffects 1.0

Window {
    id: control
    width: 500
    height: _mainLayout.implicitHeight + Meui.Units.largeSpacing * 4

    flags: Qt.FramelessWindowHint
    color: "transparent"

    Brightness {
        id: brightness
    }

    Rectangle {
        id: _background
        anchors.fill: parent
        radius: Meui.Theme.bigRadius
        color: Meui.Theme.backgroundColor
        opacity: 0.7
        border.color: Meui.Theme.textColor
        border.width: 1
    }

    Meui.WindowShadow {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        radius: _background.radius
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: Meui.Units.largeSpacing
        spacing: Meui.Units.largeSpacing

        Item {
            id: topItem
            Layout.fillWidth: true
            height: 35

            RowLayout {
                anchors.fill: parent
                spacing: Meui.Units.largeSpacing

                Item {
                    Layout.fillWidth: true
                }

                IconButton {
                    id: settingsButton
                    implicitWidth: topItem.height
                    implicitHeight: topItem.height
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + "settings.svg"
                    onLeftButtonClicked: process.startDetached("cyber-settings")
                }

                IconButton {
                    id: shutdownButton
                    implicitWidth: topItem.height
                    implicitHeight: topItem.height
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + "system-shutdown-symbolic.svg"
                    onLeftButtonClicked: process.startDetached("cyber-shutdown")
                }
            }
        }

        Item {
            id: brightnessItem
            Layout.fillWidth: true
            height: 50
            visible: true

            Rectangle {
                id: brightnessItemBg
                anchors.fill: parent
                anchors.margins: 0
                radius: Meui.Theme.bigRadius
                color: Meui.Theme.backgroundColor
                opacity: 0.3
            }

            RowLayout {
                anchors.fill: brightnessItemBg
                anchors.margins: Meui.Units.largeSpacing
                spacing: Meui.Units.largeSpacing

                Image {
                    width: parent.height * 0.6
                    height: parent.height * 0.6
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark" : "light") + "/brightness.svg"
                }

                Slider {
                    id: brightnessSlider
                    from: 0
                    to: 100
                    stepSize: 1
                    value: brightness.value
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onMoved: {
                        brightness.setValue(brightnessSlider.value)
                    }
                }
            }
        }

        Item {
            id: volumeItem
            Layout.fillWidth: true
            height: 50
            visible: volume.isValid

            Rectangle {
                id: volumeItemBg
                anchors.fill: parent
                anchors.margins: 0
                radius: Meui.Theme.bigRadius
                color: Meui.Theme.backgroundColor
                opacity: 0.3
            }

            RowLayout {
                anchors.fill: volumeItemBg
                anchors.margins: Meui.Units.largeSpacing
                spacing: Meui.Units.largeSpacing

                Image {
                    width: parent.height * 0.6
                    height: parent.height * 0.6
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark" : "light") + "/" + volume.iconName + ".svg"
                }

                Slider {
                    id: slider
                    from: 0
                    to: 100
                    stepSize: 1
                    value: volume.volume
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onValueChanged: {
                        volume.setVolume(value)

                        if (volume.isMute && value > 0)
                            volume.setMute(false)
                    }
                }
            }
        }

        RowLayout {
            RowLayout {
                Image {
                    id: batteryIcon
                    visible: battery.available
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                    asynchronous: true
                }

                Label {
                    text: battery.chargePercent + "%"
                    color: Meui.Theme.textColor
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                id: timeLabel

                Timer {
                    interval: 1000
                    repeat: true
                    running: true
                    triggeredOnStart: true
                    onTriggered: {
                        timeLabel.text = new Date().toLocaleString(Qt.locale(), Locale.ShortFormat)
                    }
                }
            }
        }
    }
}
