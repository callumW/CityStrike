//
//  Minimap.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 05/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SpriteKit
import SceneKit

func convertToPlane(point: CGPoint) -> CGPoint {
    return CGPoint(x: ((point.x + 14) / 26) * 400, y: (point.y / 9) * 200)
}



protocol Mappable3DNode {
    var minimapNode: MinimapNode { get }

    func updatePosition(relativeTo: SCNNode)
}


class PlaneMinimapNode: SKNode {

//    let borderNode: SKShapeNode
    let bgNode: SKShapeNode
    let planeSize: CGSize
    let planeXScale: Double
    let planeYScale: Double

    let width: CGFloat = 400
    let height: CGFloat = 200

    /// Init the top level Plane Minimap node.
    /// - Parameter planeSize: actual size of the 3D plane this is representing
    init(planeSize: CGSize) {
        self.planeSize = planeSize
//        borderNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 400, height: 200))
//        borderNode.lineWidth = 3
//        borderNode.strokeColor = .red


        self.planeXScale = Double(width) / Double(planeSize.width)
        self.planeYScale = Double(height) / Double(planeSize.height)

        bgNode = SKShapeNode(rectOf: CGSize(width: width, height: height))
        bgNode.fillColor = UIColor.red.withAlphaComponent(0.2)
        bgNode.strokeColor = .red
        bgNode.lineWidth = 3

        super.init()

        let tmp = SKShapeNode(circleOfRadius: 10)
        tmp.fillColor = .green
        addChild(tmp)

        addChild(bgNode)
//        addChild(borderNode)
    }

    func convertToPlanePosition(point: CGPoint) -> CGPoint {

        // let ret = CGPoint(x: CGFloat(Double(point.x + (planeSize.width / 2)) * self.planeXScale), y: CGFloat(Double(point.y) * self.planeYScale))
        let ret = CGPoint(x: CGFloat(Double(point.x) * self.planeXScale), y: CGFloat(Double(point.y) * self.planeYScale))
        //print("converted \(point) to \(ret)")
        return ret
    }

    override func addChild(_ node: SKNode) {
        node.position = convertToPlanePosition(point: node.position)
        super.addChild(node)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MinimapNode : SKNode {
    override var position: CGPoint {
        set {
            if let parentNode = self.parent {
                if parentNode is PlaneMinimapNode {
                    let planeNode = parentNode as! PlaneMinimapNode
                    super.position = planeNode.convertToPlanePosition(point: newValue)
                    return
                }
            }
            super.position = newValue
        }
        get {
            return super.position
        }
    }
}

class BuildingMinimapNode : MinimapNode {
    override init() {
        let tmp = SKShapeNode(rect: CGRect(x:0, y:0, width: 5, height: 20))
        tmp.fillColor = .red
        tmp.strokeColor = .clear

        super.init()

        self.addChild(tmp)

        position = CGPoint(x: 0, y: 0) 
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        var points: Array<CGPoint> = []
        if self.parent != nil && self.parent is PlaneMinimapNode {
            let parentPlane = self.parent! as! PlaneMinimapNode
            points.append(parentPlane.convertToPlanePosition(point: startPosition))
        }
        else {
            points.append(startPosition)
        }

        points.append(endPosition)

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
