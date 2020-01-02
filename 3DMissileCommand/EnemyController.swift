//
//  EnemyController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/11/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit

/*
 Class describing an enemy controller which fires missiles at houses in the scene
 */
class EnemyController {

    static let FIRE_INTERVAL: TimeInterval = 2
    static let SPEED_SCALER: Float = 0.5

    let spawnNode: SCNNode
    let targetCity: CityNode
    var lastUpdate: TimeInterval = -1.0

    var explodingMissiles: Array<MissileNode> = []


    /// Initialise Enemy Controller
    /// - Parameters:
    ///   - city: The City that the enemy controller should attack
    init(city: CityNode, spawnNode: SCNNode) {
        self.spawnNode = spawnNode
        self.targetCity = city
    }


    /// Update the enemy controller, if necessary the enemy controller will fire a missile at a house. This function should be called on the renderer call.
    /// - Parameter time: current time
    func update(_ time: TimeInterval) {
        if lastUpdate == -1 {
            lastUpdate = time
        }
        if time - lastUpdate > EnemyController.FIRE_INTERVAL {
            // target & fire a missile
            if let targetBuilding = targetCity.getRandomHouse() {
                print("Enemy: firing missile")
                let missile = EnemyMissile()
                missile.setCollisionCallback(callback: self.onEnemyMissileCollision)
                spawnNode.addChildNode(missile)
                let target = TargetNode()
                spawnNode.addChildNode(target)

                target.position = spawnNode.convertPosition(targetBuilding.worldPosition, from: nil)

                print("Enemy targetting: \(target.position) | \(target.worldPosition) (building: \(targetBuilding.position) | \(targetBuilding.worldPosition)")
                missile.fire(targetNode: target, speed: EnemyController.SPEED_SCALER)

                print("missile location: \(missile.worldPosition) | target location: \(target.worldPosition)")
            }
            else {
                print("no house to target")
            }
            lastUpdate = time
        }

        var i: Int = 0
        while i < explodingMissiles.count {
            let missile = explodingMissiles[i]
            if missile.state == .FINISHED {
                explodingMissiles.remove(at: i)
                continue
            }
            else {
                missile.update(time)
            }
            i += 1
        }
    }

    func onEnemyMissileCollision(_ missile: SCNNode) {
        if missile is MissileNode {
            explodingMissiles.append(missile as! MissileNode)
        }
    }
}
