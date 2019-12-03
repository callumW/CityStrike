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
    var playerController: PlayerController!
    var lastUpdateTime: TimeInterval = 0.0

    var hitTestPlane: SCNNode!

    var gameScene: SCNScene!

    var taps: Array<CGPoint> = []

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

        playerController = PlayerController(scene: gameScene, factory: missileFactory)

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

        scnView.preferredFramesPerSecond = 30

        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true


        // Setup tap handler
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1

        tapRecognizer.addTarget(self, action: #selector(GameViewController.handleTap(sender:)))
        scnView.addGestureRecognizer(tapRecognizer)

        // get hitTestPlane
        hitTestPlane = gameScene.rootNode.childNode(withName: "hit_test_plane", recursively: false)

        if hitTestPlane == nil {
            print("Failed to find hit test plane")
        }

        missileFactory.preloadAudio()
    }

    @objc
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // handling code

            let point = sender.location(in: self.view)
            // print("tap @ \(point)")

            taps.append(point)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        lastUpdateTime = time
        enemyController.update(time)
        missileFactory.update(time)
        city.cleanUp()

        while (taps.count > 0) {

            let point = taps.removeFirst()

//            print("evaluating tap  \(point)")

            let results = renderer.hitTest(point, options: [SCNHitTestOption.categoryBitMask: 16, SCNHitTestOption.ignoreHiddenNodes: false, SCNHitTestOption.backFaceCulling: false])

            for result in results {
//                print("hit plane @ \(result.worldCoordinates)")
                playerController.fireMissile(at: result.worldCoordinates)
            }

        }
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("collision between type: \(contact.nodeA.name ?? "nil") (@\(contact.nodeA.presentation.worldPosition)) and \(contact.nodeB.name ?? "nil") (@\(contact.nodeB.presentation.worldPosition))")
        if (contact.nodeA.name == "missile") {
            /*
                We may get multiple contact callbacks for the same node, therefore to avoid placing multiple explosions for the same missile, we check whether
                it belongs to a parent node, i.e. has it already been removed from its parent node
             */
            if contact.nodeA.parent != nil {
                var explosionLoc: SCNVector3?
                if (contact.nodeB.name == "target_node") {
                    print("hit target node!")
                    explosionLoc = contact.nodeB.worldPosition
                    contact.nodeB.removeFromParentNode()
                }
                else {
                    explosionLoc = contact.nodeA.presentation.position
                }
                print("missile explodes @ \(explosionLoc!)")
                missileFactory.addExplosion(at: explosionLoc!, time: lastUpdateTime)
                contact.nodeA.removeFromParentNode()
            }

            if (contact.nodeB.name == "house") {
                city.houseWasDestroyed(contact.nodeB)
            }
        }
        else if (contact.nodeB.name == "missile") {
            /*
                We may get multiple contact callbacks for the same node, therefore to avoid placing multiple explosions for the same missile, we check whether
                it belongs to a parent node, i.e. has it already been removed from its parent node
             */
            if contact.nodeB.parent != nil {
                var explosionLoc: SCNVector3?
                if (contact.nodeA.name == "target_node") {
                    print("hit target node!")
                    explosionLoc = contact.nodeA.worldPosition
                    contact.nodeA.removeFromParentNode()
                }
                else {
                    explosionLoc = contact.nodeB.presentation.position
                }
                print("missile explodes @ \(explosionLoc!)")
                missileFactory.addExplosion(at: explosionLoc!, time: lastUpdateTime)
                contact.nodeB.removeFromParentNode()
            }

            if (contact.nodeA.name == "house") {
                city.houseWasDestroyed(contact.nodeA)
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
