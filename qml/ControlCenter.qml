import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.15

import org.cyber.Dock 1.0
import MeuiKit 1.0 as Meui
import Cyber.Accounts 1.0 as Accounts

ControlCenterDialog {
    id: control
    width: 500
    height: _mainLayout.implicitHeight + Meui.Units.largeSpacing * 4

    property point position: Qt.point(0, 0)

    onPositionChanged: adjustCorrectLocation()

    color: "transparent"

    function adjustCorrectLocation() {
        var posX = control.position.x
        var posY = control.position.y

        // left
        if (posX < 0)
            posX = Meui.Units.largeSpacing

        // top
        if (posY < 0)
            posY = Meui.Units.largeSpacing

        // right
        if (posX + control.width > Screen.width)
            posX = Screen.width - control.width - Meui.Units.largeSpacing

        // bottom
        if (posY > control.height > Screen.width)
            posY = Screen.width - control.width - Meui.Units.largeSpacing

        control.x = posX
        control.y = posY
    }

    Brightness {
        id: brightness
    }

    Accounts.UserAccount {
        id: currentUser
    }

    Accounts.UsersModel {
        id: userModel
    }

    Accounts.AccountsManager {
        id: accountsManager
    }

    Meui.RoundedRect {
        id: _background
        anchors.fill: parent
        radius: control.height * 0.05
        color: Meui.Theme.backgroundColor
        opacity: 0.5
    }

    Meui.WindowShadow {
        view: control
        geometry: Qt.rect(control.x, control.y, control.width, control.height)
        radius: _background.radius
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: Meui.Units.largeSpacing * 2
        spacing: Meui.Units.largeSpacing * 2

        Item {
            id: topItem
            Layout.fillWidth: true
            height: 50

            RowLayout {
                id: topItemLayout
                anchors.fill: parent
                spacing: Meui.Units.largeSpacing

                Image {
                    id: userIcon
                    Layout.fillHeight: true
                    width: height
                    sourceSize: Qt.size(width, height)
                    // TODO: default icon
                    source: currentUser.iconFileName ? "file:///" + currentUser.iconFileName : ""

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Item {
                            width: userIcon.width
                            height: userIcon.height

                            Rectangle {
                                anchors.fill: parent
                                radius: parent.height / 2
                            }
                        }
                    }
                }

                Label {
                    id: userLabel
                    text: currentUser.userName
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    elide: Label.ElideRight
                }

                IconButton {
                    id: settingsButton
                    implicitWidth: topItem.height * 0.8
                    implicitHeight: topItem.height * 0.8
                    Layout.alignment: Qt.AlignTop
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + "settings.svg"
                    onLeftButtonClicked: {
                        control.visible = false
                        process.startDetached("cyber-settings")
                    }
                }

                IconButton {
                    id: shutdownButton
                    implicitWidth: topItem.height * 0.8
                    implicitHeight: topItem.height * 0.8
                    Layout.alignment: Qt.AlignTop
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + "system-shutdown-symbolic.svg"
                    onLeftButtonClicked: {
                        control.visible = false
                        process.startDetached("cyber-shutdown")
                    }
                }
            }
        }

        Item {
            id: controlItem
            Layout.fillWidth: true
            height: 120
            visible: wirelessItem.visible || bluetoothItem.visible

            RowLayout {
                anchors.fill: parent
                spacing: Meui.Units.largeSpacing

                CardItem {
                    id: wirelessItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width / 3 - Meui.Units.largeSpacing * 3
                    icon: "qrc:/svg/dark/network-wireless-connected-100.svg"
                    visible: networking.wirelessHardwareEnabled
                    checked: networking.wirelessEnabled
                    label: qsTr("Wi-Fi")
                    text: networking.wirelessEnabled ? connectionIconProvider.currentSSID ?
                                                           connectionIconProvider.currentSSID :
                                                           qsTr("On") : qsTr("Off")
                    onClicked: networking.wirelessEnabled = !networking.wirelessEnabled
                }

                CardItem {
                    id: bluetoothItem
                    Layout.fillHeight: true
                    Layout.preferredWidth: contentItem.width / 3 - Meui.Units.largeSpacing * 3
                    icon: "qrc:/svg/light/bluetooth-symbolic.svg"
                    checked: false
                    label: qsTr("Bluetooth")
                    text: qsTr("Off")
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        Item {
            id: brightnessItem
            Layout.fillWidth: true
            height: 50
            visible: brightness.enabled

            Meui.RoundedRect {
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
                    sourceSize: Qt.size(width, height)
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

            Meui.RoundedRect {
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
                    sourceSize: Qt.size(width, height)
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

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                visible: battery.available
                Image {
                    id: batteryIcon
                    width: 22
                    height: 16
                    sourceSize: Qt.size(width, height)
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark/" : "light/") + battery.iconSource
                    asynchronous: true
                }

                Label {
                    text: battery.chargePercent + "%"
                    color: Meui.Theme.textColor
                }
            }
        }
    }
}
