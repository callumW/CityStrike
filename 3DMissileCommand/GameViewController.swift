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

    var cameraDolly: SCNNode? = nil
    var cameraNode: SCNNode? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        loadGameScene()

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

        overlayScene = SKScene(fileNamed: "UIOverlay.sks")
        overlayScene.isPaused = false
        overlayScene.isUserInteractionEnabled = true

        scnView.overlaySKScene = overlayScene

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
        zoomRecognizer.addTarget(self, action: #selector(GameViewController.handleZoom(sender:)))
        scnView.addGestureRecognizer(zoomRecognizer)

        if let tmp = gameScene.rootNode.childNode(withName: "camera_dolly", recursively: true) {
            cameraDolly = tmp
            if let other_tmp = cameraDolly!.childNode(withName: "camera_node", recursively: true) {
                cameraNode = other_tmp
            }
            else {
                fatalError("Failed to find camera in scene")
            }
        }
        else {
            fatalError("Failed to find camera dolly in scene")
        }
    }

    @objc
    func handleZoom(sender: UIPinchGestureRecognizer) {
        let scalar: Float = 0.1

        cameraNode!.position = cameraNode!.position - (cameraNode!.position * (scalar * Float(sender.velocity)))
    }

    @objc
    func handlePan(sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: self.view)

        let scalar: Float = 0.0003 * cameraNode!.position.y

        let dolly_pos = cameraDolly!.position

        cameraDolly!.position = SCNVector3(x: dolly_pos.x - Float(velocity.x) * scalar, y: dolly_pos.y, z: dolly_pos.z - Float(velocity.y) * scalar)
    }

    @objc
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // handling code

            let point = sender.location(in: self.view)
            print("tap @ \(point)")

            var tapHandled = false
            let convertedPoint = overlayScene.convertPoint(fromView: point)

            let uiNodes = overlayScene.nodes(at: convertedPoint)
            for node in uiNodes {
                if node is ButtonNode {
                    print("hit button!")
                    tapHandled = true
                }
            }

            if !tapHandled {
            }
        }
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
