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

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
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

    var lastUpdateTime: TimeInterval = 0.0
    var startTime: TimeInterval = 0.0

    var gameScene: SCNScene!

    var taps: Array<CGPoint> = []

    var timeLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var overlayScene: SKScene!

    var score: Int = 0
    var gamePlaying: Bool = true

    var gameOverTextNode: SCNNode! = nil
    var gameOverAudioSource: SCNAudioSource! = nil

    var listenerPosition: SCNNode!

    let globalViewPosition: SCNNode = SCNNode()

    var game: Game? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        loadGameScene()

        game = Game(gameScene: self.gameScene, view: self.view as! SCNView)

        globalViewPosition.position = SCNVector3(8, 15, 8)
        gameScene.rootNode.addChildNode(globalViewPosition)


        loadStaticVariables()

        loadButtons()
    }

    func loadStaticVariables() {
        /*
         Note: we need to load nodes that load models from scenes (via SCNReferenceNode) outside of the
            render call, otherwise we get an error. Therefore, we create an instance of these nodes which
            will cause the static reference node to be loaded
         */
        _ = MissileNode()

        _ = ExplosionNode(time: 0)
    }

    func loadButtons() {

    }

    func loadGameScene() {

        // create a new scene
        gameScene = SCNScene(named: "art.scnassets/Theatre.scn")!

        // retrieve the SCNView
        let scnView = self.view as! SCNView

        // set the scene to the view
        scnView.scene = gameScene

        scnView.isPlaying = true

        scnView.delegate = self

        scnView.preferredFramesPerSecond = 30

        scnView.debugOptions.insert(.showBoundingBoxes)

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

        //scnView.audioListener = mainCamera
        // TODO set listener as camera


        // show statistics such as fps and timing information
        scnView.showsStatistics = true

        // Setup tap handler
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1

        tapRecognizer.addTarget(self, action: #selector(GameViewController.handleTap(sender:)))
        scnView.addGestureRecognizer(tapRecognizer)

        let panRecognizer = UIPanGestureRecognizer()
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.minimumNumberOfTouches = 1

        panRecognizer.addTarget(self, action: #selector(GameViewController.handlePan(sender:)))
        scnView.addGestureRecognizer(panRecognizer)

        let zoomRecognizer = UIPinchGestureRecognizer()
        zoomRecognizer.addTarget(self, action: #selector(GameViewController.handlePinch(sender:)))
        scnView.addGestureRecognizer(zoomRecognizer)

        let longPressRecognizer = UILongPressGestureRecognizer()
        longPressRecognizer.addTarget(self, action: #selector(GameViewController.handleLongPress(sender:)))
        longPressRecognizer.numberOfTouchesRequired = 1
        scnView.addGestureRecognizer(longPressRecognizer)
    }

    @objc
    func handleLongPress(sender: UILongPressGestureRecognizer) {
        _ = game?.handleLongPress(sender: sender)
    }

    @objc
    func handlePinch(sender: UIPinchGestureRecognizer) {
        _ = game?.handlePinch(sender: sender)
    }

    @objc
    func handlePan(sender: UIPanGestureRecognizer) {
        _ = game?.handlePan(sender: sender)
    }

    @objc
    func handleTap(sender: UITapGestureRecognizer) {
        _ = game?.handleTap(sender: sender)
    }

    func updateUI(time: TimeInterval) {
        if startTime == 0 {
            startTime = time
        }
    }
    func triggerGameOver() {

    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if gamePlaying {
            lastUpdateTime = time
        }
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("collision between type: \(contact.nodeA.name ?? "nil") (@\(contact.nodeA.presentation.worldPosition)) and \(contact.nodeB.name ?? "nil") (@\(contact.nodeB.presentation.worldPosition))")

        let nodeABody: SCNPhysicsBody = contact.nodeA.physicsBody!
        let nodeBBody: SCNPhysicsBody = contact.nodeB.physicsBody!

        /* Player Missile */
        if nodeABody.categoryBitMask & COLLISION_BITMASK.PLAYER_MISSILE != 0 {
            if contact.nodeA.parent != nil {
                let parentNode = contact.nodeA.parent!
                if parentNode is PlayerMissile {
                    let missile = parentNode as! PlayerMissile
                    missile.explode(time: self.lastUpdateTime)
                }
                else {
                    print("contact is not missile node")
                }
            }
        }
        else if nodeBBody.categoryBitMask & COLLISION_BITMASK.PLAYER_MISSILE != 0 {
            if contact.nodeB.parent != nil {
                let parentNode = contact.nodeB.parent!
                if parentNode is PlayerMissile {
                    let missile = parentNode as! PlayerMissile
                    missile.explode(time: self.lastUpdateTime)
                }
                else {
                    print("contact is not missile node")
                }
            }
        }

        /* Enemy Missile */
        if nodeABody.categoryBitMask & COLLISION_BITMASK.ENEMY_MISSILE != 0 {
            if nodeBBody.categoryBitMask & COLLISION_BITMASK.HOUSE != 0 {
                if contact.nodeB.parent != nil && contact.nodeB.parent is BuildingNode {
                    let house = contact.nodeB.parent as! BuildingNode
                    house.collidesWithMissile()
                }
            }

            if contact.nodeA.parent != nil {
                let parentNode = contact.nodeA.parent!
                if parentNode is MissileNode {
                    let missile = parentNode as! MissileNode
                    missile.explode(time: self.lastUpdateTime)
                }
            }
        }
        else if nodeBBody.categoryBitMask & COLLISION_BITMASK.ENEMY_MISSILE != 0 {
            if nodeABody.categoryBitMask & COLLISION_BITMASK.HOUSE != 0 {
                if contact.nodeA.parent != nil && contact.nodeA.parent is BuildingNode {
                    let house = contact.nodeA.parent as! BuildingNode
                    house.collidesWithMissile()
                }
            }

            if contact.nodeB.parent != nil {
                let parentNode = contact.nodeB.parent!
                if parentNode is MissileNode {
                    let missile = parentNode as! MissileNode
                    missile.explode(time: self.lastUpdateTime)
                }
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
