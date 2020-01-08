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

//    let borderNode: SKShapeNode
    let bgNode: SKShapeNode

    override init() {
//        borderNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 400, height: 200))
//        borderNode.lineWidth = 3
//        borderNode.strokeColor = .red

        bgNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 400, height: 200))
        bgNode.fillColor = UIColor.red.withAlphaComponent(0.2)
        bgNode.strokeColor = .red
        bgNode.lineWidth = 3

        super.init()

        addChild(bgNode)
//        addChild(borderNode)
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
    var lineNode: SKShapeNode? = nil
    let startPosition: CGPoint

    override var position: CGPoint {
        didSet {
            updateLine(endPosition: position)
        }
    }

    init(startPosition: CGPoint) {
       self.startPosition = startPosition

        super.init()
    }

    func updateLine(endPosition: CGPoint) {
        if lineNode != nil {
            lineNode?.removeFromParent()
        }

        if endPosition == startPosition {
            return
        }

        var points = [startPosition, endPosition]
        lineNode = SKShapeNode(points: &points, count: points.count)
        lineNode?.strokeColor = .red
        lineNode?.lineWidth = 3
        self.parent?.addChild(lineNode!)
    }

    override func removeFromParent() {
        lineNode?.removeFromParent()
        super.removeFromParent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PlayerMissileMinimapNode : MissileMinimapNode {

    override init(startPosition: CGPoint) {
        super.init(startPosition: startPosition)
        let tmp = SKShapeNode(circleOfRadius: 5)
        tmp.fillColor = .red
        tmp.strokeColor = .clear
        self.addChild(tmp)
    }

    func update() {

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EnemyMissileMinimapNode : MissileMinimapNode {
    override init(startPosition: CGPoint) {
        super.init(startPosition: startPosition)

        var points = [CGPoint(x: -1, y: 0), CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1.7), CGPoint(x: -1, y: 0)]
        let tmp = SKShapeNode(points: &points, count: points.count)
        tmp.fillColor = .red
        tmp.strokeColor = .clear
        tmp.setScale(7)
        addChild(tmp)
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
