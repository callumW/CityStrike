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

    var activePlane: TheatrePlane? = nil

    var planes: Array<TheatrePlane> = []

    var uiButtons: Array<SKNode> = []

    var mainCamera: SCNNode? = nil

    var spriteView: SKView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        loadGameScene()

        if let newPlane = TheatrePlane(gameScene: gameScene, ui: overlayScene, view: self.view as! SCNView) {
            newPlane.position = SCNVector3(-15, 0, 0)
            gameScene.rootNode.addChildNode(newPlane)
            planes.append(newPlane)
        }
        else {
            fatalError("Failed to create TheatrePlane")
        }

        if let tmp = TheatrePlane(gameScene: gameScene, ui: overlayScene, view: self.view as! SCNView) {
            tmp.position = SCNVector3(-15, 0, 2)
            tmp.rotation = SCNVector4(0, Float.pi / 3, 0, 1)
            gameScene.rootNode.addChildNode(tmp)
            planes.append(tmp)
        }
        else {
            fatalError("Failed to create TheatrePlane")
        }

        spriteView = SKView()

        planes[0].activate(camera: mainCamera!, uiScene: overlayScene)
        activePlane = planes[0]

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

        _ = CityNode()

        _ = ExplosionNode(time: 0)
    }

    func loadButtons() {

        print("UI Scene: \(overlayScene.size)")

        let maxX = overlayScene.size.width / 2
        let minX = 0 - maxX

        let maxY = overlayScene.size.height / 2

        let padding = CGFloat(10)
        let margin = CGFloat(50)


        let plane1Button = ButtonNode(node: planes[0].minimapParentNode, callback: self.setPlaneOne)
        plane1Button.setScale(0.25)
        let plane1Size = plane1Button.calculateAccumulatedFrame()
        print("button size: \(plane1Size)")
        let plane1Pos = CGPoint(x: minX + margin + (plane1Size.width / 2), y: maxY - margin - (plane1Size.height / 2))
        let plane2Pos = CGPoint(x: plane1Pos.x + (plane1Size.width / 2) + padding + (plane1Size.width / 2), y: plane1Pos.y)
        plane1Button.position = plane1Pos
        overlayScene.addChild(plane1Button)
        uiButtons.append(plane1Button)

        let plane2Button = ButtonNode(node: planes[1].minimapParentNode, callback: self.setPlaneTwo)
        plane2Button.setScale(0.25)
        plane2Button.position = plane2Pos
        overlayScene.addChild(plane2Button)
        uiButtons.append(plane2Button)


    }

    func setPlaneOne() {
        print("set plane 1")
        if activePlane != planes[0] {
            activePlane?.deactivate()
            planes[0].activate(camera: mainCamera!, uiScene: overlayScene)
            activePlane = planes[0]
        }
    }

    func setPlaneTwo() {
        print("set plane 2")
        if activePlane != planes[1] {
            activePlane?.deactivate()
            planes[1].activate(camera: mainCamera!, uiScene: overlayScene)
            activePlane = planes[1]
        }
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

        mainCamera = SCNNode(geometry: nil)
        mainCamera!.camera = SCNCamera()
        scnView.pointOfView = mainCamera

        scnView.audioListener = mainCamera

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

        if let node = gameScene.rootNode.childNode(withName: "game_over_text", recursively: true) {
            gameOverTextNode = node
        }

        if let source = SCNAudioSource(fileNamed: "game_over.wav") {
            source.isPositional = true
            source.loops = true
            source.volume = 0.1
            source.load()

            gameOverAudioSource = source
        }

        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true


        // Setup tap handler
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1

        tapRecognizer.addTarget(self, action: #selector(GameViewController.handleTap(sender:)))
        scnView.addGestureRecognizer(tapRecognizer)

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
                activePlane?.notifyTap(point: point)
            }
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
        if gamePlaying {

            lastUpdateTime = time
            for plane in planes {
                plane.update(time: time)
            }
            updateUI(time: time)

//            if city.houseCount() > 0 {
//
//                updateUI(time: time)
//
//                while (taps.count > 0) {
//
//                    let point = taps.removeFirst()
//
//        //            print("evaluating tap  \(point)")
//
//                    let results = renderer.hitTest(point, options: [SCNHitTestOption.categoryBitMask: 16,
//                                                                    SCNHitTestOption.ignoreHiddenNodes: false,
//                                                                    SCNHitTestOption.backFaceCulling: false])
//
//                    for result in results {
//        //                print("hit plane @ \(result.worldCoordinates)")
//                        playerController.fireMissile(at: result.worldCoordinates, tapPoint: point)
//                        // addTargetHint(at: point)
//                    }
//
//                }
//            }
//            else {  // game over
//                gamePlaying = false
//                print("game over")
//
//                if gameOverTextNode != nil {
//                    gameOverTextNode.isHidden = false
//                    let player = SCNAudioPlayer(source: gameOverAudioSource)
//
//                    gameOverTextNode.addAudioPlayer(player)
//                }
//
//                let animation = CABasicAnimation(keyPath: "rotation")
//                animation.fromValue = SCNVector4(x: 0, y: 1, z: 0, w: 0)
//                animation.toValue = SCNVector4(x: 0, y: 1, z: 0, w: Float(2 * Float.pi))
//                animation.duration = 3
//                animation.repeatCount = .greatestFiniteMagnitude
//
//                gameOverTextNode.addAnimation(animation, forKey: nil)
//
//            }
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
