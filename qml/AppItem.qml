import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.platform 1.0
import org.cyber.Dock 1.0

DockItem {
    id: appItem

    iconName: model.iconName
    isActive: model.isActive
    popupText: model.visibleName
    enableActivateDot: model.windowCount !== 0
    draggable: true
    dragItemIndex: index

    function updateGeometry() {
        appModel.updateGeometries(model.appId, Qt.rect(appItem.mapToGlobal(0, 0).x,
                                                       appItem.mapToGlobal(0, 0).y,
                                                       appItem.width, appItem.height))
    }

    onPositionChanged: updateGeometry()
    onPressed: updateGeometry()
    onClicked: appModel.clicked(model.appId)
    onRightClicked: contextMenu.open()

    onPressAndHold: {
        mouseArea.drag.target = appItem.icon
        popupTips.hide()
    }

    dropArea.onEntered: {
        appModel.move(drag.source.dragItemIndex, dragItemIndex)
    }

    dropArea.onDropped: {
        appModel.save()
        updateGeometry()
    }

    Menu {
        id: contextMenu

        MenuItem {
            text: qsTr("Open")
            visible: model.windowCount === 0
            onTriggered: appModel.openNewInstance(model.appId)
        }

        MenuItem {
            text: model.visibleName
            visible: model.windowCount > 0
            onTriggered: appModel.openNewInstance(model.appId)
        }

        MenuItem {
            text: model.isPinned ? qsTr("Unpin") : qsTr("Pin")
            onTriggered: {
                model.isPinned ? appModel.unPin(model.appId) : appModel.pin(model.appId)
            }
        }

        MenuItem {
            text: qsTr("Close All")
            visible: model.windowCount !== 0
            onTriggered: appModel.closeAllByAppId(model.appId)
        }
    }
}