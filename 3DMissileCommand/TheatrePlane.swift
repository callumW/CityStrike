//
//  TheatrePlane.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import SceneKit
import SpriteKit

/*
 A TheatrePlane contains an instance of the Missile game. It holds player missiles, enemy missiles,
 buildings, and everything else required for the game to operate.
 The user can switch between these planes and launch missiles for each one.
 */
class TheatrePlane: SCNNode {
    static let scene: SCNScene? = SCNScene(named: "art.scnassets/TheatrePlane.scn")
    let planeNode: SCNNode
    let targetPlane: SCNNode
    let cameraNode: SCNNode

    let playerController: PlayerController
    var playerMissileBatteries: Array<SCNNode> = []

    let enemyController: EnemyController
    let targettingUI: MissileTargetUI

    let city: CityNode

    init?(gameScene: SCNScene, ui: SKScene) {

        if TheatrePlane.scene == nil {
            print("Template TheatrePlane scene not loaded")
            return nil
        } else {
            planeNode = TheatrePlane.scene!.rootNode.clone()
        }

        if let tmp = planeNode.childNode(withName: "camera", recursively: true) {
            cameraNode = tmp
        }
        else {
            print("Failed to find camera in TheatrePlane")
            return nil
        }

        if let tmp = planeNode.childNode(withName: "target_plane", recursively: true) {
            targetPlane = tmp
        }
        else {
            print("Failed to find target plane in TheatrePlane")
            return nil
        }

        // Get missile silos
        for node in planeNode.childNodes {
            if node.name != nil && node.name! == "missile_battery" {
                playerMissileBatteries.append(node)
            }
        }

        playerController = PlayerController(scene: gameScene, ui: ui)

        city = CityNode()
        planeNode.addChildNode(city)

        enemyController = EnemyController(gameScene: gameScene, city: city)

        targettingUI = MissileTargetUI()

        super.init()

        self.addChildNode(planeNode)

        print("Initialised Plane")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Set the plane as the active plane
    /// - Parameter in: Scene that the plane is active in
    func activate(in: SCNScene) {

    }


    /// Deactivate the plane
    func deactivate() {
        // TODO remove target nodes from ui overlay scene
    }

    /// Update the TheatrePlane and its contents
    /// - Parameter time: current time
    func update(time: TimeInterval) {

    }
}
