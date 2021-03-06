/*
 * QML Air - A lightweight and mostly flat UI widget collection for QML
 * Copyright (C) 2014 Michael Spencer
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import QtGraphicalEffects 1.0

PopupBase {
    id: popover
    width: Math.min(implicitWidth, overlayLayer.width - units.gu(2))
    implicitWidth: maxWidth
    height: contentHeight + contents.anchors.margins * 2

    property int contentHeight: contents.childrenRect.height

    default property alias data: contents.data

    //----- STYLE PROPERTIES -----//

    property color background: "#fff"
    property color borderColor: Qt.rgba(0,0,0,0.2)
    property int maxWidth: units.gu(35)
    radius: units.gu(0.6)

    border.color: borderColor
    border.width: 0.5
    color: background

    property int offset: 0
    property int padding: 0

    property Item caller

    z: 3

    property int side: Qt.AlignBottom

    function openAt(widget, x, y) {
        if (!widget)
            throw "Caller cannot be undefined!"

        caller = widget
        popover.parent = overlayLayer

        var position = widget.mapToItem(popover.parent, x, y)
        popover.x = position.x - popover.width/2

        if (position.y + popover.height + units.gu(2.5) + padding > overlayLayer.height) {
            side = Qt.AlignTop
            popover.y = position.y - popover.height - units.gu(1.5) - padding - widget.height
            if (position.y - popover.height - units.gu(1.5) - widget.height - padding < units.gu(1.5)) {
                popover.y = units.gu(1.5) + padding
                side = Qt.AlignVCenter
            }
        } else {
            side = Qt.AlignBottom
            popover.y = position.y + units.gu(1.5) + padding
        }

        if (popover.x < units.gu(1)) {
            popover.offset = popover.x - units.gu(1)
            popover.x = units.gu(1)
        } else if (popover.x + popover.width > popover.parent.width - units.gu(1)) {
            popover.offset = popover.x + popover.width - (popover.parent.width - units.gu(1))
            popover.x = popover.parent.width - units.gu(1) - popover.width
        } else {
            popover.offset = 0
        }

        showing = true
        currentOverlay = popover
        opened()
    }

    function open(widget) {
        openAt(widget, widget.width/2, widget.height)
    }

    RectangularGlow {
        id: glowEffect

        opacity: 0.3
        anchors.fill: parent
        glowRadius: units.gu(1)
        //cornerRadius: 0
        color: "black"
    }

    Rectangle {
        border.color: borderColor
        color: background
        width: units.gu(2)
        height: width
        visible: side != Qt.AlignVCenter

        rotation: 45

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: side == Qt.AlignBottom ? parent.top : parent.bottom
            verticalCenterOffset:side == Qt.AlignBottom ? 1 : -1
            horizontalCenterOffset: offset

            Behavior on verticalCenterOffset {
                NumberAnimation { duration: 200 }
            }
        }
    }

    Rectangle {
        id: contents
        anchors.fill: parent
        anchors.margins: 1
        color: background
        radius: popover.radius
    }
}
