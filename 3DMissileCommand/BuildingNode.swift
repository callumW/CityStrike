//
//  BuildingNode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 02/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SceneKit
import SpriteKit

class BuildingNode : SCNNode, Mappable3DNode {

    func updatePosition(relativeTo: SCNNode) {
        if let parentNode = self.parent {
            let relativePosition = parentNode.convertPosition(position, to: relativeTo)
            minimapNode.position = CGPoint(x: CGFloat(relativePosition.x), y: CGFloat(relativePosition.y))
        }
    }


    static var buildingReference: SCNNode? = nil

    let houseNode: SCNNode
    let collisionCallback: (BuildingNode) -> Void

    let minimapNode: MinimapNode

    init(collisionCallback: @escaping (BuildingNode) -> Void) {
        self.collisionCallback = collisionCallback

        if BuildingNode.buildingReference == nil {
            if let sceneURL = Bundle.main.url(forResource: "House", withExtension: "scn", subdirectory: "art.scnassets") {
                if let ref = SCNReferenceNode(url: sceneURL) {
                    ref.load()
                    print("loaded reference node")
                    if let house = ref.childNode(withName: "house", recursively: true) {
                        BuildingNode.buildingReference = house.clone()
                        print("initialised satic building reference")
                    }
                    else {
                        fatalError("Failed to find building node in reference node")
                    }
                }
                else {
                    fatalError("Failed to load building reference node")
                }
            }
            else {
                fatalError("Failed to get URL for building scene")
            }

        }
        houseNode = BuildingNode.buildingReference!.clone()

        minimapNode = BuildingMinimapNode()

        super.init()

        self.addChildNode(houseNode)
    }

    override var position: SCNVector3 {
        didSet {
            if self.parent != nil && self.parent!.parent != nil {
                
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collidesWithMissile() {
        self.collisionCallback(self)
        minimapNode.removeFromParent()
    }

}
