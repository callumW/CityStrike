//
//  PlayerMissileController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 01/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

struct MissileBattery {
    let node: SCNNode
    var heatValue: Double
    var overheated: Bool
}

class PlayerController: MissileController {
    static let PLAYER_MISSILE_SPEED_SCALER: Float = MissileController.BASE_MISSILE_SPEED_SCALER * 6

    static let HEAT_PER_MISSILE: Double = 1.0           // Heat increase from 1 missile fire
    static let MAX_TEMP: Double = 5.0                   // When this value is reached, the silo must cool down fully before firing again
    static let HEAT_DISAPATION_RATE: TimeInterval = 1.0 // Amount of heat reduced in 1 second

    let gameScene: SCNScene
    let missileFactory: MissileFactory

    let genericTargetNode: SCNNode

    var missileBatteries: Array<MissileBattery> = []
    var overheatedMissileBatteries: Array<MissileBattery> = []

    var targetNodes: Dictionary<String, SCNNode> = [:]

    var lastUpdate: TimeInterval = 0

    var indexPicker: GKRandomDistribution = GKRandomDistribution(lowestValue: 0, highestValue: 1)


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
                missileBatteries.append(MissileBattery(node: node, heatValue: 0.0, overheated: false))
            }
        }
    }

    func fireMissile(at: SCNVector3) {
        let targetNode = genericTargetNode.clone()

        targetNode.position = at

        let missile = missileFactory.spawnPlayerMissile()


        if missileBatteries.count > 0 {

            var index = indexPicker.nextInt()
            if index > missileBatteries.count {
                index = 0
            }
            if missileBatteries[index].overheated {
                print("misfire, battery overheated!")
                return
            }

            missileBatteries[index].heatValue = missileBatteries[index].heatValue + PlayerController.HEAT_PER_MISSILE

            if missileBatteries[index].heatValue > PlayerController.MAX_TEMP {
                missileBatteries[index].overheated = true
                // TODO move to overheated list!
            }

            missile.position = missileBatteries[index].node.position
        }

        missile.physicsBody?.contactTestBitMask |= COLLISION_BITMASK.PLAYER_TARGET_NODE
        // missile.physicsBody?.contactTestBitMask |= COLLISION_BITMASK.FLOOR
        missile.physicsBody?.categoryBitMask = COLLISION_BITMASK.PLAYER_MISSILE

        super.prepareMissile(missile: missile, target: targetNode, forceScale: PlayerController.PLAYER_MISSILE_SPEED_SCALER)

        gameScene.rootNode.addChildNode(targetNode)
        gameScene.rootNode.addChildNode(missile)

        missileFactory.addEngineSound(to: missile)
    }

    /// To be called in the Scene renderer function. Updates the Player controlled objects
    /// - Parameter time: Current time in seconds
    override func update(_ time: TimeInterval) {

        if lastUpdate != 0 {
            for i in 0..<missileBatteries.count {
                if missileBatteries[i].heatValue > 0 {
                    missileBatteries[i].heatValue -= (time - lastUpdate) * PlayerController.HEAT_PER_MISSILE
                }
                if missileBatteries[i].heatValue <= 0 {
                    missileBatteries[i].heatValue = 0
                    missileBatteries[i].overheated = false
                }
            }
        }
        lastUpdate = time
    }

    func getSiloHeatLevel(_ i: Int) -> Double {
        return missileBatteries[i].heatValue
    }

//    func removeTarget(for: SCNNode) {
//
//    }
}
