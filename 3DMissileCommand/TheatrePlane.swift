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
class TheatrePlane {
    let scene: SCNReferenceNode
    let camera: SCNNode
    let targetPlane: SCNNode

    let missileFactory: MissileFactory
    let playerController: PlayerController
    let enemyController: EnemyController
    let targettingUI: MissileTargetUI

    let city: City

    init?(gameScene: SCNScene, factory: MissileFactory, ui: SKScene) {
        self.missileFactory = factory

        scene = SCNReferenceNode(url: URL(fileURLWithPath: "art.scnassets/TheatrePlane.scn"))!
        scene.load()

        if let tmp = scene.childNode(withName: "camera", recursively: true) {
            camera = tmp
        }
        else {
            print("Failed to find camera in TheatrePlane")
            return nil
        }

        if let tmp = scene.childNode(withName: "target_plane", recursively: true) {
            targetPlane = tmp
        }
        else {
            print("Failed to find target plane in TheatrePlane")
            return nil
        }

        playerController = PlayerController(scene: gameScene, factory: factory, ui: ui)

        city = City(parent: scene)

        enemyController = EnemyController(gameScene: gameScene, missileFactory: factory, city: city)

        targettingUI = MissileTargetUI()

        print("Initialised Plane")
    }


    /// Add the plane's elements to the scene.
    /// - Parameter into: The scene to add elements to
    func load(into: SCNScene) {
        into.rootNode.addChildNode(scene)
    }


    /// Remove the TheatrePlane from the scene
    func removeFromScene() {
        scene.removeFromParentNode()
    }


    /// Set the plane as the active plane
    /// - Parameter in: Scene that the plane is active in
    func activate(in: SCNScene) {

    }


    /// Deactivate the plane
    func deactivate() {
        // TODO remove target nodes from ui overlay scene
    }
}
