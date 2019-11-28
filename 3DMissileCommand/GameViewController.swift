//
//  GameViewController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 14/11/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GameplayKit

func *(left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3(x: left.x * right, y: left.y * right, z: left.z * right)
}
func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
}

func magnitude(_ vec: SCNVector3) -> Float {
    let sqrSum = (vec.x * vec.x) + (vec.y * vec.y) + (vec.z * vec.z)
    return sqrtf(sqrSum)
}

func normalise(_ vec: SCNVector3) -> SCNVector3 {
    let mag: Float = magnitude(vec)
    if (mag == 0) {
        return vec
    }
    return SCNVector3(x: vec.x / mag, y: vec.y / mag, z: vec.z / mag)
}

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {

    var missileFactory: MissileFactory!
    var city:City!
    var enemyController: EnemyController!

    var gameScene: SCNScene!

    override func viewDidLoad() {
        super.viewDidLoad()


        // create a new scene
        gameScene = SCNScene(named: "art.scnassets/Theatre.scn")!

        // setup missile factory
        missileFactory = MissileFactory(gameScene)
        if missileFactory == nil {
            fatalError("Unable to create missile factory")
        }

        city = City(gameScene)

        enemyController = EnemyController(gameScene: gameScene, missileFactory: missileFactory,city: city)

        gameScene?.physicsWorld.contactDelegate = self  // register for phsysics contact callback

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        gameScene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        gameScene.rootNode.addChildNode(ambientLightNode)

        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = gameScene
        
        scnView.isPlaying = true
        
        scnView.delegate = self
        
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        // let scnView = self.view as! SCNView

    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        enemyController?.update(time: time)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("collision between type: \(contact.nodeA.name ?? "nil") (@\(contact.nodeA.presentation.worldPosition)) and \(contact.nodeB.name ?? "nil") (@\(contact.nodeB.presentation.worldPosition))")
        if (contact.nodeA.name == "missile") {
            contact.nodeA.removeFromParentNode()
            if (contact.nodeB.name == "house") {
                city.houseWasDestroyed(contact.nodeB)
                contact.nodeB.removeFromParentNode()
            }
        }
        else if (contact.nodeB.name == "missile") {
            contact.nodeB.removeFromParentNode()
            if (contact.nodeA.name == "house") {
                city.houseWasDestroyed(contact.nodeA)
                contact.nodeA.removeFromParentNode()
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

}
