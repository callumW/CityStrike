//
//  MissileManager.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 27/11/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

/*
 Missile Factory Class
 */
class MissileFactory {

    let masterMissileNode: SCNNode
    let missileSpawnY: Float
    let missileSpawnX: Float
    let missileSpawnMaxZ: Float
    let missileSpawnMinZ: Float
    let missileSpawnRangeZ: Float
    let randomDist: GKRandomDistribution

    /// - parameter gameScene: The SCNScene in which the missile spawn area can be found
    init?(_ gameScene: SCNScene) {
        // Load in missile scene
        if let missileScene = SCNScene(named: "art.scnassets/Missile.scn") {
            if let missile = missileScene.rootNode.childNode(withName: "missile", recursively: true) {
                masterMissileNode = missile
            }
            else {
                print("Failed to load missile from scene")
                return nil
            }
        }
        else {
            print("Failed to load missile scene")
            return nil
        }

        // Find spawn strip to get height
        if let missileSpawnArea = gameScene.rootNode.childNode(withName: "missile spawn", recursively: true) {
            missileSpawnY = missileSpawnArea.position.y
            missileSpawnX = missileSpawnArea.position.x
            if let geometry = missileSpawnArea.geometry {
                if let plane = geometry as? SCNPlane {
                    missileSpawnMinZ = missileSpawnArea.worldPosition.z - Float(plane.height / 2)

                    missileSpawnMaxZ = missileSpawnArea.worldPosition.z + Float(plane.height / 2)

                    missileSpawnRangeZ = missileSpawnMaxZ - missileSpawnMinZ
                }
                else {
                    print("Failed to get min/max misisle spawn area")
                    return nil
                }
            }
            else {
                print("Failed to get geometry of missle spawn area node")
                return nil
            }
        }
        else {
            print("Failed to find missle spawn area node")
            return nil
        }

        // setup random generators
        randomDist = GKRandomDistribution(lowestValue: 0, highestValue: 100)
    }

    /// returns a missile node
    func createMissile() -> SCNNode {
        return masterMissileNode.clone()
    }

    /// returns a missile node positioned at a random point along the spawn strip defined in game scene
    func spawnEnemyMissile() -> SCNNode {
        let missile = createMissile()
        let spawnZ:Float = missileSpawnMinZ + randomDist.nextUniform() * missileSpawnRangeZ
        missile.position = SCNVector3(missileSpawnX, missileSpawnY, spawnZ)
        return missile
    }

}
