//
//  PlaneMinimapNode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 04/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SpriteKit

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
