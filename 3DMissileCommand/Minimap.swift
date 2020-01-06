//
//  Minimap.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 05/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SpriteKit

func convertToPlane(point: CGPoint) -> CGPoint {
    return CGPoint(x: ((point.x + 14) / 26) * 400, y: (point.y / 9) * 200)
}

class PlaneMinimapNode: SKNode {

    let borderNode: SKShapeNode
    let bgNode: SKShapeNode

    override init() {
        borderNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 400, height: 200))
        borderNode.lineWidth = 3
        borderNode.strokeColor = .red

        bgNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 400, height: 200))
        bgNode.fillColor = UIColor.red.withAlphaComponent(0.2)

        super.init()

        addChild(bgNode)
        addChild(borderNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MinimapNode : SKNode {
    override var position: CGPoint {
        set {
            super.position = convertToPlane(point: newValue)
        }
        get {
            return super.position
        }
    }
}

class MissileMinimapNode : MinimapNode {

    init(planeSize: CGSize) {
        super.init()
        let tmp = SKShapeNode(circleOfRadius: 5)
        tmp.fillColor = .red
        self.addChild(tmp)
    }

    func update() {

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MissileBatteryNode : MinimapNode {
    override init() {
        super.init()

        let tmp = SKShapeNode(rect: CGRect(x:0, y: 0, width: 8, height: 8))
        tmp.fillColor = .red
        addChild(tmp)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
