//
//  Minimap.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 05/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SpriteKit
import SceneKit


class PlaneMinimapNode: SKNode {

//    let borderNode: SKShapeNode
    let bgNode: SKShapeNode
    let planeSize: CGSize
    let planeXScale: Double
    let planeYScale: Double

    let width: CGFloat = 400
    let height: CGFloat = 200

    let selectedHint: SKShapeNode

    /// Init the top level Plane Minimap node.
    /// - Parameter planeSize: actual size of the 3D plane this is representing
    init(planeSize: CGSize) {
        self.planeSize = planeSize

        self.planeXScale = Double(width) / Double(planeSize.width)
        self.planeYScale = Double(height) / Double(planeSize.height)

        bgNode = SKShapeNode(rectOf: CGSize(width: width, height: height))
        bgNode.fillColor = UIColor.red.withAlphaComponent(0.2)
        bgNode.strokeColor = .red
        bgNode.lineWidth = 3
        bgNode.position = CGPoint(x: 0, y: 0)

        selectedHint = SKShapeNode(rect: CGRect(x: 0 - width / 2, y: height / 2 + 10, width: width, height: 10), cornerRadius: 5)
        selectedHint.fillColor = bgNode.strokeColor
        selectedHint.strokeColor = .clear
        selectedHint.isHidden = true

        super.init()

        let tmp = SKShapeNode(circleOfRadius: 10)
        tmp.fillColor = .green
        tmp.position = CGPoint(x: 0, y: -100)
        addChild(tmp)

        addChild(bgNode)
        addChild(selectedHint)
    }

    func select() {
        selectedHint.isHidden = false
    }

    func unselect() {
        selectedHint.isHidden = true
    }

    func convertToPlanePosition(point: CGPoint) -> CGPoint {

        // let ret = CGPoint(x: CGFloat(Double(point.x + (planeSize.width / 2)) * self.planeXScale), y: CGFloat(Double(point.y) * self.planeYScale))
        let preScalePoint = CGPoint(x: point.x, y: CGFloat(Double(((20 - 8.82) / 2) + point.y)))
        let ret = CGPoint(x: CGFloat(Double(point.x) * self.planeXScale), y: CGFloat(Double(point.y + ((20 - 8.82) / 2)) * self.planeYScale))
        print("converted \(point) -> \(preScalePoint) -> \(ret)")
        return ret
    }

    func updateNodes(targetPlane: SCNNode) {
        for child in children {
            if child is MinimapNode {
                let tmp = child as! MinimapNode
                tmp.updatePosition(relativeTo: targetPlane, transform: convertToPlanePosition, viewRect: bgNode.calculateAccumulatedFrame())
            }
        }
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MinimapNode : SKNode {

    var scenePosition: SCNVector3 = SCNVector3()    // position of the 3D object in its parent coordinate system
    var sceneParent: SCNNode? = nil     // parent of the 3D object this node represents

    /// Calculate the nodes position based on the 3D object it represents position relative to the passed node
    /// - Parameter relativeTo: Node which represents the minimap in 3D space
    func getPosition(relativeTo: SCNNode) -> CGPoint {
        let convertedPos = relativeTo.convertPosition(scenePosition, from: sceneParent)

        print("converted \(scenePosition) to \(convertedPos)")

        let point = CGPoint(x: CGFloat(convertedPos.x), y: CGFloat(convertedPos.y))

        return point
    }

    func updatePosition(relativeTo: SCNNode, transform: (CGPoint) -> CGPoint, viewRect: CGRect? = nil) {
        position = transform(getPosition(relativeTo: relativeTo))
    }
}

class CityBuildingMinimapNode : MinimapNode {

    override func updatePosition(relativeTo: SCNNode, transform: (CGPoint) -> CGPoint, viewRect: CGRect?) {
        for child in children {
            if child is MinimapNode {
                let tmp = child as! MinimapNode
                tmp.updatePosition(relativeTo: relativeTo, transform: transform, viewRect: viewRect)
                print("new building pos: \(tmp.position)")
            }
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
    var startPoint: CGPoint = CGPoint.zero
    let startPosition: SCNVector3

    init(startPosition: SCNVector3) {
        self.startPosition = startPosition
        super.init()
    }
    override func updatePosition(relativeTo: SCNNode, transform: (CGPoint) -> CGPoint, viewRect: CGRect?) {
        super.updatePosition(relativeTo: relativeTo, transform: transform, viewRect: viewRect)
        let convertedPos = relativeTo.convertPosition(startPosition, from: sceneParent)
        let point = CGPoint(x: CGFloat(convertedPos.x), y: CGFloat(convertedPos.y))
        startPoint = transform(point)
        updateLine(endPosition: position, viewRect: viewRect)
    }

    func updateLine(endPosition: CGPoint, viewRect: CGRect? = nil) {
        if lineNode != nil {
            lineNode?.removeFromParent()
        }

        if endPosition == startPoint {
            return
        }
        var points: Array<CGPoint> = []

        var lineStart = startPoint
        if !(viewRect?.contains(startPoint) ?? true) {

            if endPosition.x == startPoint.x {
                lineStart = CGPoint(x: startPoint.x, y: viewRect!.maxY)
            }
            else {
                // find intersection with rect?
                let deltaY = startPoint.y - (endPosition.y)

                let minorDeltaY = startPoint.y - viewRect!.maxY

                let ratio = minorDeltaY / deltaY

                lineStart.y = viewRect!.maxY

                if (endPosition.x < startPoint.x) {
                    lineStart.x = startPoint.x - (startPoint.x - endPosition.x) * ratio
                }
                else {
                    lineStart.x = startPoint.x + (endPosition.x - startPoint.x) * ratio
                }
            }
        }

        points.append(lineStart)
        points.append(endPosition)

        lineNode = SKShapeNode(points: &points, count: points.count)
        lineNode?.strokeColor = .red
        lineNode?.lineWidth = 3

        if !(viewRect?.contains(endPosition) ?? true) {
            self.isHidden = true
        }
        else {
            self.isHidden = false
            self.parent?.addChild(lineNode!)
        }
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

    override init(startPosition: SCNVector3) {
        super.init(startPosition: startPosition)
        let tmp = SKShapeNode(circleOfRadius: 5)
        tmp.fillColor = .red
        tmp.strokeColor = .clear
        self.addChild(tmp)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class EnemyMissileMinimapNode : MissileMinimapNode {
    override init(startPosition: SCNVector3) {
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
