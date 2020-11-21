import QtQuick 2.12
import QtQuick.Controls 2.5
import QtGraphicalEffects 1.0
import org.cyber.Dock 1.0
import MeuiKit 1.0 as Meui

Item {
    id: dockItem

    implicitWidth: (Settings.direction === DockSettings.Left) ? root.width : root.height
    implicitHeight: (Settings.direction === DockSettings.Left) ? root.width : root.height

    property bool isLeft: Settings.direction === DockSettings.Left

    property bool draggable: false
    property int dragItemIndex

    property alias icon: icon
    property alias mouseArea: iconArea
    property alias dropArea: iconDropArea

    property bool enableActivateDot: true
    property bool isActive: false

    property var activateDotColor: root.activateDotColor
    property var inactiveDotColor: root.inactiveDotColor

    property var popupText

    property double iconSizeRatio: 0.8
    property var iconName

    signal positionChanged()
    signal released()
    signal pressed(var mouse)
    signal pressAndHold(var mouse)
    signal clicked(var mouse)
    signal rightClicked(var mouse)
    signal doubleClicked(var mouse)

    Drag.active: mouseArea.drag.active && dockItem.draggable
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.MoveAction

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
        cache: true

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
            visible: iconArea.pressed && !mouseArea.drag.active
        }
    }

    DropArea {
        id: iconDropArea
        anchors.fill: icon
        enabled: draggable
    }

    MouseArea {
        id: iconArea
        anchors.fill: icon
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        drag.target: icon

        onClicked: {
            if (mouse.button === Qt.RightButton)
                dockItem.rightClicked(mouse)
            else
                dockItem.clicked(mouse)
        }

        onPressed: {
            dockItem.pressed(mouse)
            popupTips.hide()
        }

        onPressAndHold : dockItem.pressAndHold(mouse)
        onPositionChanged: dockItem.positionChanged()
        onReleased: dockItem.released()

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
        x: isLeft ? icon.x - activeDot.width : (parent.width - width) / 2
        y: isLeft ? (parent.height - height) / 2 : icon.y + icon.height
    }
}
