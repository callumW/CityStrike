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

    func prepareMissile(missile: SCNNode, target: SCNNode, forceScale: Float) {

        let dir:SCNVector3 = normalise(target.position - missile.position)
        let force = dir * forceScale

        missile.physicsBody?.applyForce(force, asImpulse: false)

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
