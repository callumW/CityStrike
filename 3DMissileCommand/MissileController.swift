//
//  MissileController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 01/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit

class MissileController {

    static let BASE_MISSILE_SPEED_SCALER: Float = 5

    func update(_ time: TimeInterval) {}


    /// Prepare and fire missile.
    /// This specifid missile will be oriented towards the target node, and fired by means of a costant force
    /// The passed missile will also be set to be collidable with explosion nodes
    /// - Parameters:
    ///   - missile: The missile to prepare
    ///   - target: Target to fire the missile at
    ///   - forceScale: scale of the force which will be applied to the missile to move it
    func prepareMissile(missile: SCNNode, target: SCNNode, forceScale: Float) {

        let dir:SCNVector3 = normalise(target.position - missile.position)
        let force = dir * forceScale

        missile.physicsBody?.applyForce(force, asImpulse: false)
        missile.physicsBody?.contactTestBitMask |= COLLISION_BITMASK.MISSILE_EXPLOSION
        missile.physicsBody?.collisionBitMask = 0

        if missile.constraints == nil {
            missile.constraints = []
        }

        let lookAtConstraint = SCNLookAtConstraint(target: target)
        lookAtConstraint.localFront = SCNVector3(0, 1, 0)
        lookAtConstraint.worldUp = SCNVector3(1, 0, 0)
        lookAtConstraint.isGimbalLockEnabled = false
        missile.constraints?.append(lookAtConstraint)
    }
}
