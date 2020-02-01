//
//  FloorGrid.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 01/02/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SceneKit

class FloorGrid : SCNNode {

    static let GRID_SIZE: Float = 2
    static let MARGIN_SIZE: Float = 0.1
    static let ACTIVE_AREA_SIZE: Int = 10
    static let STAND_OFF_VALUE: Float = 0.2   // y height above ground

    override init() {
        super.init()

        let offset = FloorGrid.GRID_SIZE * Float(FloorGrid.ACTIVE_AREA_SIZE) / 2

        let elementSize = FloorGrid.GRID_SIZE

        for x in 0..<FloorGrid.ACTIVE_AREA_SIZE {
            for y in 0..<FloorGrid.ACTIVE_AREA_SIZE {
                let tmp = SCNPlane(width: CGFloat(Float(FloorGrid.GRID_SIZE) - FloorGrid.MARGIN_SIZE * 2), height: CGFloat(Float(FloorGrid.GRID_SIZE) - FloorGrid.MARGIN_SIZE * 2))
                tmp.cornerRadius = 0.3
                let tmpNode = SCNNode(geometry: tmp)

                let pos = SCNVector3(x: Float(x) * elementSize - offset + (elementSize * 0.5), y: FloorGrid.STAND_OFF_VALUE, z: Float(y) * elementSize - offset + (elementSize * 0.5))

                tmpNode.position = pos
                tmpNode.rotation = SCNVector4(x: -1, y: 0, z: 0, w: Float.pi / 2)

                self.addChildNode(tmpNode)
                self.opacity = 0.1
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func snapTo(point: SCNVector3) -> SCNVector3 {
        var x = point.x - (point.x.truncatingRemainder(dividingBy: FloorGrid.GRID_SIZE))
        var z = point.z - (point.z.truncatingRemainder(dividingBy: FloorGrid.GRID_SIZE))

        if point.x <= 0 {
            x -= FloorGrid.GRID_SIZE / 2
        }
        else {
            x += FloorGrid.GRID_SIZE / 2
        }

        if point.z <= 0 {
            z -= FloorGrid.GRID_SIZE / 2
        }
        else {
            z += FloorGrid.GRID_SIZE / 2
        }

        print("snap \(point) -> \(SCNVector3(x: x, y: point.y, z: z))")

        return SCNVector3(x: x, y: point.y, z: z)
    }

    static func snapToNoOffset(point: SCNVector3) -> SCNVector3 {
        var x = point.x - (point.x.truncatingRemainder(dividingBy: FloorGrid.GRID_SIZE))
        var z = point.z - (point.z.truncatingRemainder(dividingBy: FloorGrid.GRID_SIZE))

        return SCNVector3(x: x, y: point.y, z: z)
    }

    override var position: SCNVector3 {
        didSet {
            super.position = FloorGrid.snapToNoOffset(point: position)
        }
    }
}
