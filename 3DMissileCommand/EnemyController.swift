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
    static let SPEED_SCALER: Float = 5

    let gameScene:SCNScene
    let targetCity: CityNode
    var lastUpdate: TimeInterval = -1.0


    /// Initialise Enemy Controller
    /// - Parameters:
    ///   - gameScene: Scene which the enemy will operate within
    ///   - missileFactory: The missile factory which the enemy will use to create missiles.
    ///   - city: The City that the enemy controller should attack
    init(gameScene:SCNScene, city: CityNode) {
        self.gameScene = gameScene
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
            if let target = targetCity.getRandomHouse() {
                print("Enemy: firing missile")
            }
            else {
                print("no house to target")
            }
            lastUpdate = time
        }
    }
}
