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

    var inFlightMissiles: Set<MissileNode> = []
    var explodingMissiles: Array<MissileNode> = []

    let gameScene: SCNScene

    init(gameScene: SCNScene) {
        self.gameScene = gameScene
    }


    /// Fire a player missile at the specified point
    /// - Parameter at: Target of the missile
    func firePlayerMissile(at: SCNVector3) {

    }

    /// Fire an enemy missile at the specified point
    /// - Parameter at: Target of the missile
    func fireEnemyMissile(at: SCNVector3) {

    }

    /// Notify the MissileController that a missile has collided with something.
    /// - Parameter node: The missiles that has collided
    func notifyCollision(node: MissileNode) {

    }

    /// Notify the MissileController to update it's state
    /// - Parameter time: current time
    func update(time: TimeInterval) {
        for missile in explodingMissiles {
            missile.update(time)
        }
    }
}
