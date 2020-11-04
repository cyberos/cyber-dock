import QtQuick 2.12
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0
import org.cyber.Dock 1.0
import MeuiKit 1.0 as Meui

MouseArea {
    id: dockItem

    implicitWidth: (Settings.direction === DockSettings.Left) ? root.width : root.height
    implicitHeight: (Settings.direction === DockSettings.Left) ? root.width : root.height

    property bool enableActivateDot: true
    property bool isActive: false

    property var activateDotColor: root.activateDotColor
    property var inactiveDotColor: root.inactiveDotColor

    property var popupText

    property double iconSizeRatio: 0.8
    property var iconName

    signal pressed()
    signal clicked()
    signal rightClicked()

    Image {
        id: icon
        source: {
            return iconName ? iconName.indexOf("/") === 0 || iconName.indexOf("file://") === 0 || iconName.indexOf("qrc") === 0
                              ? iconName : "image://icontheme/" + iconName : iconName;
        }
        sourceSize.width: parent.height * iconSizeRatio
        sourceSize.height: parent.height * iconSizeRatio
        width: sourceSize.width
        height: sourceSize.height
        smooth: true

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        ColorOverlay {
            id: iconColorize
            anchors.fill: icon
            source: icon
            color: "#000000"
            opacity: 0.5
            visible: iconArea.pressed
        }
    }

    MouseArea {
        id: iconArea
        anchors.fill: icon
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: dockItem.pressed()

        onClicked: {
            if (mouse.button === Qt.LeftButton)
                dockItem.clicked()
            else if (mouse.button === Qt.RightButton)
                dockItem.rightClicked()
        }

        onContainsMouseChanged: {
            if (containsMouse) {
                popupTips.popupText = dockItem.popupText

                if (Settings.direction == DockSettings.Left)
                    popupTips.position = Qt.point(root.width + Settings.edgeMargins,
                                                  dockItem.mapToGlobal(0, 0).y + (dockItem.height / 2 - popupTips.height / 2))
                else
                    popupTips.position = Qt.point(dockItem.mapToGlobal(0, 0).x + (dockItem.width / 2 - popupTips.width / 2),
                                                  dockItem.mapToGlobal(0, 0).y - popupTips.height - Settings.edgeMargins)

                popupTips.show()
            } else {
                popupTips.hide()
            }
        }
    }

    Rectangle {
        id: activeDot
        width: parent.height * 0.07
        height: width
        color: isActive ? activateDotColor : inactiveDotColor
        radius: height
        visible: enableActivateDot

        anchors {
            leftMargin: (Settings.direction === DockSettings.Left) ? dockItem.height * 0.07 / 2 : 0
            left: (Settings.direction === DockSettings.Left) ? parent.left : undefined
            verticalCenter: (Settings.direction === DockSettings.Left) ? parent.verticalCenter : undefined

            top: (Settings.direction === DockSettings.Left) ? undefined : icon.bottom
            horizontalCenter: (Settings.direction === DockSettings.Left) ? undefined : parent.horizontalCenter
        }
    }
}
