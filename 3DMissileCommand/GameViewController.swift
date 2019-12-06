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
import SpriteKit

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
    var startTime: TimeInterval = 0.0

    var hitTestPlane: SCNNode!

    var gameScene: SCNScene!

    var taps: Array<CGPoint> = []

    var timeLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!

    var score: Int = 0

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

        scnView.overlaySKScene = SKScene(fileNamed: "UIOverlay.sks")

        if let node = scnView.overlaySKScene!.childNode(withName: "time_label") {
            if node is SKLabelNode {
                timeLabel = node as? SKLabelNode
            }
        }

        if let node = scnView.overlaySKScene!.childNode(withName: "score_label") {
            if node is SKLabelNode {
                scoreLabel = node as? SKLabelNode
            }
        }

        
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

    func updateUI(time: TimeInterval) {
        if startTime == 0 {
            startTime = time
        }

        // set time label
        if timeLabel != nil {
            timeLabel.text = String(format: "Time: %.01fs", time - startTime)
        }
        else {
            print("no time label")
        }

        if scoreLabel != nil {
            scoreLabel.text = "Score: \(score)"
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        lastUpdateTime = time
        enemyController.update(time)
        missileFactory.update(time)
        city.cleanUp()

        updateUI(time: time)

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

        let nodeABody: SCNPhysicsBody = contact.nodeA.physicsBody!
        let nodeBBody: SCNPhysicsBody = contact.nodeB.physicsBody!

        /* Player Missile */
        if nodeABody.categoryBitMask & COLLISION_BITMASK.PLAYER_MISSILE != 0 {
            if nodeBBody.categoryBitMask & COLLISION_BITMASK.PLAYER_TARGET_NODE != 0 {
                contact.nodeB.removeFromParentNode()
                if contact.nodeA.parent != nil {    // if we hit a target node, set the explosion as the position of the target node
                    missileFactory.addExplosion(at: contact.nodeB.presentation.position, time: lastUpdateTime)
                    contact.nodeA.removeFromParentNode()
                }
            }
            else {
                print("Player missile collides with something other than target: \(contact.nodeB.name ?? "unknown") | \(nodeBBody.categoryBitMask)")
            }
            if contact.nodeA.parent != nil {
                missileFactory.addExplosion(at: contact.nodeA.presentation.position, time: lastUpdateTime)
                contact.nodeA.removeFromParentNode()
            }
        }
        else if nodeBBody.categoryBitMask & COLLISION_BITMASK.PLAYER_MISSILE != 0 {
            if nodeABody.categoryBitMask & COLLISION_BITMASK.PLAYER_TARGET_NODE != 0 {
                contact.nodeA.removeFromParentNode()
                if contact.nodeB.parent != nil {
                     missileFactory.addExplosion(at: contact.nodeA.presentation.position, time: lastUpdateTime)
                     contact.nodeB.removeFromParentNode()
                 }
            }
            else {
                print("Player missile collides with something other than target: \(contact.nodeA.name ?? "unknown") | \(nodeABody.categoryBitMask)")
            }
            if contact.nodeB.parent != nil {
                missileFactory.addExplosion(at: contact.nodeB.presentation.position, time: lastUpdateTime)
                contact.nodeB.removeFromParentNode()
            }
        }

        /* Enemy Missile */
        if nodeABody.categoryBitMask & COLLISION_BITMASK.ENEMY_MISSILE != 0 {
            if nodeBBody.categoryBitMask & COLLISION_BITMASK.HOUSE != 0 {
                if city.houseWasDestroyed(contact.nodeB) {
                    score -= 10
                }
            }
            else if contact.nodeA.parent != nil {
                score += 1
            }

            if contact.nodeA.parent != nil {
                missileFactory.addExplosion(at: contact.nodeA.presentation.position, time: lastUpdateTime)
                contact.nodeA.removeFromParentNode()
            }
        }
        else if nodeBBody.categoryBitMask & COLLISION_BITMASK.ENEMY_MISSILE != 0 {
            if nodeABody.categoryBitMask & COLLISION_BITMASK.HOUSE != 0 {
                if city.houseWasDestroyed(contact.nodeA) {
                    score -= 10
                }
            }
            else if contact.nodeB.parent != nil {
                score += 1
            }

            if contact.nodeB.parent != nil {
                missileFactory.addExplosion(at: contact.nodeB.presentation.position, time: lastUpdateTime)
                contact.nodeB.removeFromParentNode()
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
