//
//  EnemyController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/11/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

/*
 Class describing an enemy controller which fires missiles at houses in the scene
 */
class EnemyController {

    static let FIRE_INTERVAL: TimeInterval = 2
    static let SPEED_SCALER: Float = 0.5

    let spawnNode: SCNNode
    let targetCity: CityNode
    var lastUpdate: TimeInterval = -1.0

    var missiles: Array<EnemyMissile> = []
    let minimapNode: SKNode

    let plane: SCNNode

    /// Initialise Enemy Controller
    /// - Parameters:
    ///   - city: The City that the enemy controller should attack
    init(city: CityNode, spawnNode: SCNNode, minimap: SKNode, plane: SCNNode) {
        self.spawnNode = spawnNode
        self.targetCity = city
        self.minimapNode = minimap
        self.plane = plane
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
                let missile = EnemyMissile(planeNode: self.plane)
                missile.setCollisionCallback(callback: self.onEnemyMissileCollision)
                spawnNode.addChildNode(missile)
                let target = TargetNode(uiNode: nil)
                spawnNode.addChildNode(target)

                target.position = spawnNode.convertPosition(targetBuilding.worldPosition, from: nil)

                missile.fire(targetNode: target, speed: EnemyController.SPEED_SCALER)
                missiles.append(missile)
                minimapNode.addChild(missile.minimapNode)
            }
            else {
                print("no house to target")
            }
            lastUpdate = time
        }

        var i: Int = 0
        while i < missiles.count {
            let missile = missiles[i]
            if missile.state == .FINISHED {
                missiles.remove(at: i)
                continue
            }
            else {
                missile.update(time)
            }
            i += 1
        }
    }

    func onEnemyMissileCollision(_ missile: SCNNode) {
    }

    func updateMinimap(relativeTo: SCNNode) {
        for missile in missiles {
            missile.updatePosition(relativeTo: relativeTo)
        }
    }
}
