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
    var explosion: SCNParticleSystem!
    var globalExplosion: SCNAudioSource!

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
        
        // load explosion
        if let explosionScene = SCNScene(named: "art.scnassets/Explosions.scn") {
            print("Explosion scene has \(explosionScene.rootNode.childNodes.count) nodes")

            for node in explosionScene.rootNode.childNodes {
                print("node has name \(node.name ?? "no name" )")
            }
            if let tmp = explosionScene.rootNode.childNode(withName: "explosion", recursively: true) {
                if let particleSystems = tmp.particleSystems {
                    if particleSystems.count > 0 {
                        explosion = particleSystems[0]
                    }
                }
                else {
                    print("Failed to get particles systems from explosion node")
                }
            }
            else {
                print("Failed find explosion  node")
            }
        }
        else {
            print("Failed to load explosion scene")
        }

        // preload an play explosion to stop initial lag
        globalExplosion = SCNAudioSource(named: "explosion_short.wav")
        globalExplosion.isPositional = true
        globalExplosion.loops = false
        globalExplosion.volume = 0
        globalExplosion.load()

        let player = SCNAudioPlayer(source: globalExplosion)
        let tmp = SCNNode(geometry: nil)
        tmp.position = SCNVector3(0, 0, 0)

        player.didFinishPlayback = { () in
            tmp.removeFromParentNode()
            self.globalExplosion.volume = 0.4
        }

        gameScene.rootNode.addChildNode(tmp)
        tmp.addAudioPlayer(player)
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        enemyController.update(time: time)
        city.cleanUp()
    }

    func addExplosion(at: SCNVector3) {
        if explosion != nil {
            let rotationMatrix = SCNMatrix4MakeRotation(0, 0, 0, 0)
            let translationMatrix = SCNMatrix4MakeTranslation(at.x, at.y, at.z)
            let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)

            self.gameScene.addParticleSystem(explosion, transform: transformMatrix)
        }
        else {
            print("no explosion to add")
        }

        let player = SCNAudioPlayer(source: globalExplosion)
        let tmp = SCNNode(geometry: nil)
        tmp.position = SCNVector3(at.x, at.y, at.z)

        player.didFinishPlayback = { () in
            tmp.removeFromParentNode()
        }

        gameScene.rootNode.addChildNode(tmp)
        tmp.addAudioPlayer(player)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("collision between type: \(contact.nodeA.name ?? "nil") (@\(contact.nodeA.presentation.worldPosition)) and \(contact.nodeB.name ?? "nil") (@\(contact.nodeB.presentation.worldPosition))")
        if (contact.nodeA.name == "missile") {
            addExplosion(at: contact.nodeA.presentation.position)
            contact.nodeA.removeFromParentNode()
            if (contact.nodeB.name == "house") {
                city.houseWasDestroyed(contact.nodeB)
            }
        }
        else if (contact.nodeB.name == "missile") {
            addExplosion(at: contact.nodeB.presentation.position)
            contact.nodeB.removeFromParentNode()
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
