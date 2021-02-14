import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15
import Cyber.Dock 1.0
import MeuiKit 1.0 as Meui

Item {
    id: dockItem

    property bool isLeft: Settings.direction === DockSettings.Left

    property bool draggable: false
    property int dragItemIndex

    property alias icon: icon
    property alias mouseArea: iconArea
    property alias dropArea: iconDropArea

    property bool enableActivateDot: true
    property bool isActive: false

    property var popupText

    property double iconSizeRatio: 0.8
    property var iconName

    property bool dragStarted: false

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
    Drag.hotSpot.x: icon.width / 2
    Drag.hotSpot.y: icon.height / 2

    Drag.onDragStarted:  {
        dragStarted = true
    }

    Drag.onDragFinished: {
        dragStarted = false
    }

    Image {
        id: icon
        anchors.centerIn: parent
        source: {
            return iconName ? iconName.indexOf("/") === 0 || iconName.indexOf("file://") === 0 || iconName.indexOf("qrc") === 0
                            ? iconName : "image://icontheme/" + iconName : iconName;
        }
        sourceSize.width: (isLeft ? dockItem.height : dockItem.width) * iconSizeRatio
        sourceSize.height: (isLeft ? dockItem.height : dockItem.width) * iconSizeRatio
        width: sourceSize.width
        height: sourceSize.height
        smooth: true
        cache: true

        visible: !dragStarted

        ColorOverlay {
            id: iconColorize
            anchors.fill: icon
            source: icon
            color: "#000000"
            opacity: iconArea.pressed && !mouseArea.drag.active ? 0.5 : 0
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
        drag.axis: Drag.XAndYAxis

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

        onPositionChanged: {
            if (pressed) {
                if (mouse.source !== Qt.MouseEventSynthesizedByQt) {
                    drag.target = icon
                    icon.grabToImage(function(result) {
                        dockItem.Drag.imageSource = result.url
                    })
                } else {
                    drag.target = null
                }
            }

            dockItem.positionChanged()
        }

        onPressAndHold : dockItem.pressAndHold(mouse)
        onReleased: {
            drag.target = null
            dockItem.released()
        }

        onContainsMouseChanged: {
            if (containsMouse && dockItem.popupText !== "") {
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
        id: activeLine
        width: isLeft ? parent.width * 0.05 : (isActive ? parent.height * 0.4 : parent.height * 0.06)
        height: isLeft ? (isActive ? parent.height * 0.4 : parent.height * 0.05) : parent.height * 0.06
        color: Meui.Theme.textColor
        radius: isLeft ? width / 2 : height / 2
        visible: enableActivateDot && !dragStarted
        opacity: isActive ? 1 : 0.6
        
        Behavior on opacity {
            NumberAnimation {
                duration: 125
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 125
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 125
                easing.type: Easing.InOutCubic
            }
        }

        x: isLeft ? 3 : (parent.width - width) / 2
        y: isLeft ? (parent.height - height) / 2 : icon.y + icon.height + activeLine.height / 2 - 1
        // 1 is the window border
    }
}
