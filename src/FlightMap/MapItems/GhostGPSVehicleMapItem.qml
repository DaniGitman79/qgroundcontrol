/****************************************************************************
 *
 * New QML Model: GhostGPSVehicleMapItem
 * author : Daniel Gusevski
 * date: 29.05.2026
 ****************************************************************************/

import QtQuick
import QtQuick.Effects
import QtLocation
import QtPositioning

import QGroundControl
import QGroundControl.ScreenTools
import QGroundControl.Vehicle

MapQuickItem {
    id: _root

    // Render behind the normal vehicle icon by using a lower z value
    // Use the global z-order constant so Ghost stays under the main vehicle icons
    z: QGroundControl.zOrderVehicles - 1

    property var  vehicle
    property var  map
    property real size: ScreenTools.defaultFontPixelHeight * 3

    property real courseOverGround: vehicle && vehicle.gps && !isNaN(vehicle.gps.courseOverGround.rawValue)
                                    ? vehicle.gps.courseOverGround.rawValue
                                    : Number.NaN

    // propery for vehicles ground speed
    property real groundSpeed: (vehicle && vehicle.vehicle && vehicle.vehicle.groundSpeed && !isNaN(vehicle.vehicle.groundSpeed.rawValue))
                           ? vehicle.vehicle.groundSpeed.rawValue
                           : 0

    // property for indicating if vehicle is in fw-flight
    property bool fixedwingindicator: vehicle && (
                (typeof vehicle.vtolInFwdFlight === 'boolean') ? vehicle.vtolInFwdFlight
                : (vehicle.vtolInFwdFlight && typeof vehicle.vtolInFwdFlight.rawValue === 'boolean') ? vehicle.vtolInFwdFlight.rawValue
                : false
            )

    property bool isMoving: groundSpeed > 1.0 && fixedwingindicator

    visible: coordinate.isValid

    anchorPoint.x: ghostItem.width / 2
    anchorPoint.y: ghostItem.height / 2

    // Ghost triangular icon for fw-flight and simple circle for multicopter mode of VTOLs, because as Multicopter GPS-Groundspeed 
    // does not correlate with the actual heading of the vehicle. 
    sourceItem: Item {
        id: ghostItem

        width:  _root.size
        height: _root.size

        Image {
            id: ghostIcon

            anchors.centerIn: parent

            source: "../Images/vehicleGhostArrow.svg"
            fillMode: Image.PreserveAspectFit

            visible: _root.isMoving

            rotation: isNaN(_root.courseOverGround) ? 0 : _root.courseOverGround

            width: _root.size * 0.6
            height: width

            sourceSize.width: width
            sourceSize.height: height

            onStatusChanged: {
                if (status === Image.Error) {
                    var fallback = "file:///C:/dev/qgroundcontrol/src/FlightMap/Images/vehicleGhostArrow.svg"
                    source = fallback
                }
            }
        }

        Rectangle {
            id: ghostCircle

            anchors.centerIn: parent

            width: _root.size * 0.4
            height: width
            radius: width / 2

            visible: !_root.isMoving

            color: '#454444'
            opacity: 0.6

            border.color: "#4A90E2"
            border.width: 1
        }
    }
}