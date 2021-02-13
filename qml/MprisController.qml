import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import MeuiKit 1.0 as Meui
import Cyber.Mpris 1.0

Item {
    id: control
    visible: mprisManager.availableServices.length > 0

    property bool isPlaying: mprisManager.currentService && mprisManager.playbackStatus === Mpris.Playing

    MprisManager {
        id: mprisManager
    }

    Meui.RoundedRect {
        id: _background
        anchors.fill: parent
        anchors.margins: 0
        radius: Meui.Theme.bigRadius
        color: Meui.Theme.backgroundColor
        opacity: 0.3
    }

    RowLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.margins: Meui.Units.largeSpacing

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            ColumnLayout {
                anchors.fill: parent

                Item {
                    Layout.fillHeight: true
                }

                Label {
                    id: songLabel
                    Layout.fillWidth: true
                    text: if (mprisManager.currentService) {
                        var titleTag = Mpris.metadataToString(Mpris.Title)

                        return (titleTag in mprisManager.metadata) ? mprisManager.metadata[titleTag].toString() : ""
                    }
                    elide: Text.ElideRight
                }

                Label {
                    id: artistLabel
                    Layout.fillWidth: true
                    text: if (mprisManager.currentService) {
                        var artistTag = Mpris.metadataToString(Mpris.Artist)

                        return (artistTag in mprisManager.metadata) ? mprisManager.metadata[artistTag].toString() : ""
                    }
                    elide: Text.ElideRight
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }

        Item {
            id: _buttons
            Layout.fillHeight: true
            Layout.preferredWidth: _mainLayout.width / 3

            RowLayout {
                anchors.fill: parent

                IconButton {
                    width: 33
                    height: 33
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark" : "light") + "/media-skip-backward-symbolic.svg"
                    onLeftButtonClicked: if (mprisManager.canGoPrevious) mprisManager.previous()
                }

                IconButton {
                    width: 33
                    height: 33
                    source: control.isPlaying ? "qrc:/svg/" + (Meui.Theme.darkMode ? "dark" : "light") + "/media-playback-pause-symbolic.svg"
                                              : "qrc:/svg/" + (Meui.Theme.darkMode ? "dark" : "light") + "/media-playback-start-symbolic.svg"
                    onLeftButtonClicked:
                        if ((control.isPlaying && mprisManager.canPause) || (!control.isPlaying && mprisManager.canPlay)) {
                            mprisManager.playPause()
                        }
                }

                IconButton {
                    width: 33
                    height: 33
                    source: "qrc:/svg/" + (Meui.Theme.darkMode ? "dark" : "light") + "/media-skip-forward-symbolic.svg"
                    onLeftButtonClicked: if (mprisManager.canGoPrevious) if (mprisManager.canGoNext) mprisManager.next()
                }
            }
        }
    }
}
