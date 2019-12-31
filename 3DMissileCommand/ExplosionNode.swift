//
//  ExplosionNode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 30/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import SceneKit

class ExplosionNode : SCNNode {

    static let EXPLOSION_LIFE_SPAN: TimeInterval = 0.5
    static let EXPLOSION_RADIUS_START: Double = 0.1
    static let EXPLOSION_RADIUS_END: Double = 1.5

    let audioSource: SCNAudioSource = SCNAudioSource(fileNamed: "explosion_sound_v2_mono.wav")!
    static let particleSystem: SCNReferenceNode = SCNReferenceNode(url: URL(fileURLWithPath: "art.scnassets/Explosions.scn"))!

    let startTime: TimeInterval

    let explosionNode: SCNNode

    init(time: TimeInterval) {
        super.init()
        // TODO create and add audioplay to self
        startTime = time

        // add explosion sphere
        let physicsShape = SCNPhysicsShape(geometry: SCNSphere(radius: CGFloat(MissileFactory.EXPLOSION_RADIUS_START)), options: nil)

        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        physicsBody.categoryBitMask = COLLISION_BITMASK.MISSILE_EXPLOSION
        // physicsBody.contactTestBitMask |= COLLISION_BITMASK.PLAYER_MISSILE   // TODO re-add once target nodes will not be orphaned
        physicsBody.contactTestBitMask |= COLLISION_BITMASK.ENEMY_MISSILE
        physicsBody.collisionBitMask = 0
        physicsBody.isAffectedByGravity = false

        // let explosionNode = SCNNode(geometry: SCNSphere(radius: CGFloat(MissileFactory.EXPLOSION_RADIUS_START)))    // show representation of physics body
        explosionNode = SCNNode(geometry: nil)
        explosionNode.castsShadow = false
        explosionNode.name = "explosion_node"
        explosionNode.physicsBody = physicsBody

        self.addChildNode(explosionNode)

        audioSource.loops = false
        audioSource.isPositional = true
        audioSource.load()
        audioSource.shouldStream = false

        let player = SCNAudioPlayer(source: audioSource)

        self.addAudioPlayer(player)

        self.addChildNode(ExplosionNode.particleSystem.clone())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Update & expand the explosion Node.
    /// - Parameter time: current time
    /// - returns true if explosion is still occuring, false otherwise
    func update(time: TimeInterval) -> Bool {
        if time - startTime < ExplosionNode.EXPLOSION_LIFE_SPAN {
            let newRadius: Double = ExplosionNode.EXPLOSION_RADIUS_START + (ExplosionNode.EXPLOSION_RADIUS_END - ExplosionNode.EXPLOSION_RADIUS_START) * ((time - startTime) / ExplosionNode.EXPLOSION_LIFE_SPAN)

            if let body = explosionNode.physicsBody {
                body.physicsShape = SCNPhysicsShape(geometry: SCNSphere(radius: CGFloat(newRadius)), options: nil)
                // TODO, would it be better to apply some sort of transform here instead?
            }
            return true
        }
        else {
            explosionNode.removeFromParentNode()
            self.removeFromParentNode()
            return false
        }
    }
}
