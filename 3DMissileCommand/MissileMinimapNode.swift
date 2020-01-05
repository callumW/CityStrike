//
//  MissileMinimapNode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 05/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SpriteKit

func convertToPlane(point: CGPoint) -> CGPoint {
    return CGPoint(x: ((point.x + 30) / 30) * 400, y: (point.y / 30) * 200)
}

class MissileMinimapNode : SKNode {

    override var position: CGPoint {
        set {
            super.position = convertToPlane(point: newValue)
        }
        get {
            return super.position
        }
    }

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
