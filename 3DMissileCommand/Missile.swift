//
//  MissileNode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 30/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import SceneKit
import Foundation

enum MISSILE_STATE {
    case IN_FLIGHT, EXPLODING, FINISHED
}

class TargetNode : SCNNode {

    override init() {
        super.init()

        geometry = nil

        /*
            We could omit setting up a physics shape here, and instead construct our node with some geometry and let the physics body use that
            however, when it comes to hidding our node we disable collisions! Instead, we don't give our node geometry, so that it won't be rendered
            and setup a physics shape.
         */
        let physicsShape = SCNPhysicsShape(geometry: SCNSphere(radius: 0.1), options: nil)

        self.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: physicsShape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = COLLISION_BITMASK.PLAYER_TARGET_NODE
        self.castsShadow = false
        self.name = "target_node"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MissileNode : SCNNode {

    static let MISSILE_SPEED: Float = 5
    static var missileReference: SCNNode? = nil

    var state: MISSILE_STATE = .IN_FLIGHT

    let audioSource = SCNAudioSource(named: "rocket_sound_mono.wav")

    let missileNode: SCNNode
    var explosionNode: ExplosionNode? = nil

    var targetNode: TargetNode? = nil

    var collisionCallback: (SCNNode) -> Void

    override init() {
        if MissileNode.missileReference == nil {
            if let sceneURL = Bundle.main.url(forResource: "Missile", withExtension: "scn", subdirectory: "art.scnassets") {
                if let ref = SCNReferenceNode(url: sceneURL) {
                    ref.load()
                    print("loaded reference node")
                    if let missile = ref.childNode(withName: "missile", recursively: true) {
                        MissileNode.missileReference = missile.clone()
                        // MissileNode.missileReference?.removeFromParentNode()
                        print("initialised satic missile reference")
                    }
                    else {
                        fatalError("Failed to find missile node in reference node")
                    }
                }
                else {
                    fatalError("Failed to load missile reference node")
                }
            }
            else {
                fatalError("Failed to get URL for missile scene")
            }

        }

        missileNode = MissileNode.missileReference!.clone()

        collisionCallback = { (missile: SCNNode) -> Void in
        }

        super.init()

        if missileNode.constraints == nil {
            missileNode.constraints = []
        }

        // All missiles can collide with explosions and targets
        missileNode.physicsBody?.contactTestBitMask = COLLISION_BITMASK.MISSILE_EXPLOSION | COLLISION_BITMASK.PLAYER_TARGET_NODE | COLLISION_BITMASK.FLOOR

        audioSource?.loops = true
        audioSource?.isPositional = true
        audioSource?.shouldStream = false
        audioSource?.load()

        let player = SCNAudioPlayer(source: audioSource!)

        self.addAudioPlayer(player)

        self.addChildNode(missileNode)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCollisionCallback(callback: @escaping (SCNNode) -> Void) {
        self.collisionCallback = callback
    }

    func fire(targetNode: TargetNode, speed: Float) {

        self.targetNode = targetNode

        let lookAtConstraint = SCNLookAtConstraint(target: self.targetNode!)
        lookAtConstraint.localFront = SCNVector3(0, 1, 0)
        lookAtConstraint.worldUp = SCNVector3(1, 0, 0)
        lookAtConstraint.isGimbalLockEnabled = false

        missileNode.constraints?.append(lookAtConstraint)

        let dir:SCNVector3 = normalise(self.targetNode!.parent!.convertPosition(self.targetNode!.position, to: self) - missileNode.position)
        let force = dir * speed * MissileNode.MISSILE_SPEED

        missileNode.physicsBody?.applyForce(force, asImpulse: false)
    }

    /// Trigger the missile to explode
    /// - Parameter time: The time of explosion
    func explode(time: TimeInterval) {
        print("missile explodes")
        if targetNode != nil {
            targetNode!.removeFromParentNode()
            targetNode = nil
        }
        explosionNode = ExplosionNode(time: time)
        explosionNode!.position = missileNode.presentation.position
        missileNode.removeFromParentNode()
        self.addChildNode(explosionNode!)
        self.state = .EXPLODING
        self.collisionCallback(self)
    }


    /// Update the missile explosion
    /// - Parameter time: current time
    func update(_ time: TimeInterval) {
        if state == .EXPLODING {
            if !explosionNode!.update(time: time) {
                state = .FINISHED
                explosionNode?.removeFromParentNode()
                self.removeFromParentNode()
            }
        }
    }

}

class PlayerMissile : MissileNode {
    override init() {
        super.init()
        missileNode.physicsBody?.categoryBitMask = COLLISION_BITMASK.PLAYER_MISSILE
        print("initialsed PLayerMissile")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EnemyMissile : MissileNode {
    override init () {
        super.init()
        // TODO set collision for houses
        missileNode.physicsBody?.categoryBitMask = COLLISION_BITMASK.ENEMY_MISSILE
        missileNode.physicsBody?.contactTestBitMask |= COLLISION_BITMASK.HOUSE
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
