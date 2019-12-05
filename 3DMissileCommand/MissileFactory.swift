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

    static let EXPLOSION_LIFE_SPAN: TimeInterval = 0.5
    static let EXPLOSION_RADIUS_START: Double = 0.1
    static let EXPLOSION_RADIUS_END: Double = 1.5

    let gameScene: SCNScene
    let masterMissileNode: SCNNode
    let missileSpawnY: Float
    let missileSpawnX: Float
    let missileSpawnMaxZ: Float
    let missileSpawnMinZ: Float
    let missileSpawnRangeZ: Float
    let randomDist: GKRandomDistribution

    var explosionSoundSource: SCNAudioSource!
    let explosionParticleSystem: SCNParticleSystem

    var explosions: Array<(SCNNode, TimeInterval)> = []

    /// - parameter gameScene: The SCNScene in which the missile spawn area can be found
    init?(_ gameScene: SCNScene) {
        self.gameScene = gameScene
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

        // Setup Audio
        explosionSoundSource = SCNAudioSource(named: "explosion_sound_v2.wav")
        if explosionSoundSource == nil {
            print("failed to load explosion audio")
            return nil
        }
        explosionSoundSource.isPositional = true
        explosionSoundSource.loops = false
        explosionSoundSource.volume = 0
        explosionSoundSource.load()

        // Load particle system
        // load explosion
        if let explosionScene = SCNScene(named: "art.scnassets/Explosions.scn") {
            print("Explosion scene has \(explosionScene.rootNode.childNodes.count) nodes")

            for node in explosionScene.rootNode.childNodes {
                print("node has name \(node.name ?? "no name" )")
            }
            if let tmp = explosionScene.rootNode.childNode(withName: "explosion", recursively: true) {
                if let particleSystems = tmp.particleSystems {
                    if particleSystems.count > 0 {
                        self.explosionParticleSystem = particleSystems[0]
                    }
                    else {
                        print("Unable to find explosion particle system!")
                        return nil
                    }
                }
                else {
                    print("Failed to get particles systems from explosion node")
                    return nil
                }
            }
            else {
                print("Failed find explosion node")
                return nil
            }
        }
        else {
            print("Failed to load explosion scene")
            return nil
        }
    }

    func preloadAudio() {
        let player = SCNAudioPlayer(source: explosionSoundSource)
        let tmp = SCNNode(geometry: nil)
        tmp.position = SCNVector3(0, 0, 0)

        player.didFinishPlayback = { () in
            tmp.removeFromParentNode()
            self.explosionSoundSource.volume = 0.3
        }

        gameScene.rootNode.addChildNode(tmp)
        tmp.addAudioPlayer(player)
    }

    /// returns a missile node
    private func createMissile() -> SCNNode {
        return masterMissileNode.clone()
    }

    /// returns a missile node positioned at a random point along the spawn strip defined in game scene
    func spawnEnemyMissile() -> SCNNode {
        let missile = createMissile()
        let spawnZ:Float = missileSpawnMinZ + randomDist.nextUniform() * missileSpawnRangeZ
        missile.position = SCNVector3(missileSpawnX, missileSpawnY, spawnZ)
        return missile
    }

    func spawnPlayerMissile() -> SCNNode {
        let missile = createMissile()

        missile.position = SCNVector3(1, 1, 1)
        return missile
    }

    func addExplosion(at: SCNVector3, time: TimeInterval) {
        // Add particle system
        let rotationMatrix = SCNMatrix4MakeRotation(0, 0, 0, 0)
        let translationMatrix = SCNMatrix4MakeTranslation(at.x, at.y, at.z)
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)

        self.gameScene.addParticleSystem(explosionParticleSystem, transform: transformMatrix)

        // add explosion sphere
        let physicsShape = SCNPhysicsShape(geometry: SCNSphere(radius: CGFloat(MissileFactory.EXPLOSION_RADIUS_START)), options: nil)

        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        physicsBody.categoryBitMask = MissileController.EXPLOSION_COLLIDER_BIT_MASK
        physicsBody.collisionBitMask = 0
        physicsBody.isAffectedByGravity = false

        // let explosionNode = SCNNode(geometry: SCNSphere(radius: CGFloat(MissileFactory.EXPLOSION_RADIUS_START)))    // show representation of physics body
        let explosionNode = SCNNode(geometry: nil)
        explosionNode.castsShadow = false
        explosionNode.name = "explosion_node"
        explosionNode.physicsBody = physicsBody
        explosionNode.position = at

        gameScene.rootNode.addChildNode(explosionNode)

        explosions.append((explosionNode, time))

        let player = SCNAudioPlayer(source: explosionSoundSource)
        let tmp = SCNNode(geometry: nil)
        tmp.position = SCNVector3(at.x, at.y, at.z)

        player.didFinishPlayback = { () in
            tmp.removeFromParentNode()
        }

        gameScene.rootNode.addChildNode(tmp)
        tmp.addAudioPlayer(player)
    }


    /// Increase the size of the explosion physics body
    /// - Parameters:
    ///   - node: The SCNNode which holds the explosion physics body
    ///   - creationTime: The creation time of the explosion
    ///   - time: current time
    func expandExplosion(_ node: SCNNode, _ creationTime: TimeInterval, _ time: TimeInterval) {
        let newRadius: Double = MissileFactory.EXPLOSION_RADIUS_START + (MissileFactory.EXPLOSION_RADIUS_END - MissileFactory.EXPLOSION_RADIUS_START) * ((time - creationTime) / MissileFactory.EXPLOSION_LIFE_SPAN)

        if let body = node.physicsBody {
            body.physicsShape = SCNPhysicsShape(geometry: SCNSphere(radius: CGFloat(newRadius)), options: nil)
            // TODO, would it be better to apply some sort of transform here instead?
        }

        // node.geometry = SCNSphere(radius: CGFloat(newRadius))    // show representation of physics body
    }

    func update(_ time: TimeInterval) {
        // check if any explosions need to be removed?


        var finished: Bool = false
        while(!finished) {
            /*
                Oldest explosion nodes will be at front, therefore, we can assume that once we find a node
                which is too young, there will be no older nodes
             */
            if let element = explosions.first {
                if time - element.1 > MissileFactory.EXPLOSION_LIFE_SPAN {
                    element.0.removeFromParentNode()
                    explosions.removeFirst()
                }
                else {
                    expandExplosion(element.0, element.1, time)
                    finished = true
                }
            }
            else {
                finished = true
            }
        }
    }

}
