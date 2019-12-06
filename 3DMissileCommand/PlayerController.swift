//
//  PlayerMissileController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 01/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit

class PlayerController: MissileController {
    static let PLAYER_MISSILE_SPEED_SCALER: Float = MissileController.BASE_MISSILE_SPEED_SCALER * 8

    let gameScene: SCNScene
    let missileFactory: MissileFactory

    let genericTargetNode: SCNNode

    var missileBatteries: Array<SCNNode> = []

    var targetNodes: Dictionary<String, SCNNode> = [:]


    init(scene: SCNScene, factory: MissileFactory) {
        gameScene = scene
        missileFactory = factory

        /*
            We could omit setting up a physics shape here, and instead construct our node with some geometry and let the physics body use that
            however, when it comes to hidding our node we disable collisions! Instead, we don't give our node geometry, so that it won't be rendered
            and setup a physics shape.
         */
        let physicsShape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.1), options: nil)

        genericTargetNode = SCNNode(geometry: nil)
        genericTargetNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: physicsShape)
        genericTargetNode.physicsBody?.isAffectedByGravity = false
        genericTargetNode.physicsBody?.categoryBitMask = COLLISION_BITMASK.PLAYER_TARGET_NODE
        genericTargetNode.castsShadow = false
        genericTargetNode.name = "target_node"

        for node in gameScene.rootNode.childNodes {
            if node.name == "missile_battery" {
                missileBatteries.append(node)
            }
        }
    }

    func fireMissile(at: SCNVector3) {
        let targetNode = genericTargetNode.clone()

        targetNode.position = at

        let missile = missileFactory.spawnPlayerMissile()

        if missileBatteries.count > 0 {
            missile.position = missileBatteries.randomElement()!.position
        }

        missile.physicsBody?.contactTestBitMask |= COLLISION_BITMASK.PLAYER_TARGET_NODE
        // missile.physicsBody?.contactTestBitMask |= COLLISION_BITMASK.FLOOR
        missile.physicsBody?.categoryBitMask = COLLISION_BITMASK.PLAYER_MISSILE

        super.prepareMissile(missile: missile, target: targetNode, forceScale: PlayerController.PLAYER_MISSILE_SPEED_SCALER)

        gameScene.rootNode.addChildNode(targetNode)
        gameScene.rootNode.addChildNode(missile)
    }

    /// To be called in the Scene renderer function. Updates the Player controlled objects
    /// - Parameter time: Current time in seconds
    override func update(_ time: TimeInterval) {

    }

//    func removeTarget(for: SCNNode) {
//
//    }
}
