//
//  MissileNode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 30/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import SceneKit

enum MISSILE_STATE {
    case IN_FLIGHT, EXPLODING, FINISHED
}

class TargetNode : SCNNode {

    override init() {
        super.init()
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
    static let missileReference = SCNReferenceNode(url: URL(fileURLWithPath: "art.scnassets/Missile.scn"))

    var state: MISSILE_STATE = .IN_FLIGHT

    let audioSource = SCNAudioSource(named: "rocket_sound_mono.wav")

    let missileNode: SCNNode
    var explosionNode: ExplosionNode? = nil

    var targetNode: TargetNode? = nil

    override init() {
        MissileNode.missileReference?.load()
        if let tmp = MissileNode.missileReference?.childNode(withName: "", recursively: true) {
            missileNode = tmp.clone()
        }
        else {
            missileNode = SCNNode()
        }
        super.init()

        if missileNode.constraints == nil {
            missileNode.constraints = []
        }

        // All missiles can collide with explosions and targets
        missileNode.physicsBody?.contactTestBitMask = COLLISION_BITMASK.MISSILE_EXPLOSION | COLLISION_BITMASK.PLAYER_TARGET_NODE

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

    func fire(at: SCNVector3, speed: Float) {
        targetNode = TargetNode()
        targetNode?.position = at
        self.addChildNode(targetNode!)

        let lookAtConstraint = SCNLookAtConstraint(target: targetNode!)
        lookAtConstraint.localFront = SCNVector3(0, 1, 0)
        lookAtConstraint.worldUp = SCNVector3(1, 0, 0)
        lookAtConstraint.isGimbalLockEnabled = false

        missileNode.constraints?.append(lookAtConstraint)

        let dir:SCNVector3 = normalise(targetNode!.position - missileNode.position)
        let force = dir * speed * MissileNode.MISSILE_SPEED

        missileNode.physicsBody?.applyForce(force, asImpulse: false)
    }

    /// Trigger the missile to explode
    /// - Parameter time: The time of explosion
    func explode(time: TimeInterval) {
        explosionNode = ExplosionNode(time: time)
        missileNode.removeFromParentNode()
        self.addChildNode(explosionNode!)
        self.state = .EXPLODING
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
