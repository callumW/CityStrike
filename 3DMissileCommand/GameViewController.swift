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
    
    let missileSpawnInterval: Double = 0.5
    var lastMissileSpawn: Double = 0.0
    var missileSpawnHeight:Float = 10
    var missileSpawnMinZ:Float = -1.0
    var missileSpawnMaxZ:Float = 1.0
    var missileSpawnArea:SCNNode!
    // let missileEmitterLocation = SCNVector3(x: -6, y: 2.5, z: 0)
    var missileNode:SCNNode!
    var gameScene: SCNScene!
    var randomHouseDist: GKRandomDistribution!
    var randomSpawnDist: GKRandomDistribution!
    
    var houseList: Array<SCNNode> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        gameScene = SCNScene(named: "art.scnassets/Theatre.scn")!
        gameScene?.physicsWorld.contactDelegate = self
        
        
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
        
        // Load in our missile node
        let missileScene = SCNScene(named: "art.scnassets/Missile.scn")
        
        // get our missile node
        missileNode = missileScene?.rootNode.childNode(withName: "missile", recursively: true)
        missileNode.physicsBody?.contactTestBitMask = 2
        
        // get our houses
        for node in gameScene.rootNode.childNodes {
            if node.name == "House reference" {
                houseList.append(node)
            }
        }
        
        randomHouseDist = GKRandomDistribution(lowestValue: 0, highestValue: houseList.count - 1)
        
        missileSpawnArea = gameScene.rootNode.childNode(withName: "missile spawn", recursively: true)
        
        missileSpawnHeight = missileSpawnArea.position.y

        let spawnPlane:SCNPlane = missileSpawnArea.geometry as! SCNPlane
        
        missileSpawnMinZ = missileSpawnArea.worldPosition.z - Float(spawnPlane.height / 2)
        
        missileSpawnMaxZ = missileSpawnArea.worldPosition.z + Float(spawnPlane.height / 2)
        
        randomSpawnDist = GKRandomDistribution(lowestValue:0, highestValue: 100)
        
        print("mssile spawn min/max: \(missileSpawnMinZ)/\(missileSpawnMaxZ)")
        

    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        // let scnView = self.view as! SCNView
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // check if we need to create missile
        // print("render")
        if (lastMissileSpawn == 0) {
            lastMissileSpawn = time
        }
        else if (time - lastMissileSpawn > missileSpawnInterval) {
            lastMissileSpawn = time
            // get random location along spawn pane
            
            let spawnZ:Float = missileSpawnMinZ + (Float(randomSpawnDist.nextInt()) / 100.0) * (missileSpawnMaxZ - missileSpawnMinZ)
            
            let spawnLocation = SCNVector3(x: -20, y: Float(missileSpawnHeight), z: spawnZ)
            // choose random target
            
            let houseIndex: Int = randomHouseDist.nextInt()
            var target:SCNVector3 = SCNVector3(0, 0, 0)
            if (houseIndex < houseList.count) {
                target = houseList[houseIndex].position
            }
            else {
                print("index: \(houseIndex) is too big")
                target = houseList[0].position
            }
            
            // Get direction
            let dir:SCNVector3 = normalise(target - spawnLocation)
            let force = dir * Float(20.0)
            
            
            print("Firing missile at \(target) from \(spawnLocation) (\(dir)) with force \(force)")
            
            // spawn and apply force
            
            let newMissile:SCNNode = missileNode.clone()
            
            newMissile.physicsBody?.applyForce(force, asImpulse: false)
            newMissile.position = spawnLocation
            newMissile.look(at: target, up: SCNVector3(1, 0, 0), localFront: SCNVector3(0, 1, 0))
            
            
            
            gameScene?.rootNode.addChildNode(newMissile)
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode: SCNNode!
        print("Collision")
        if (contact.nodeA.name == "missile") {
            contactNode = contact.nodeA
        }
        else{
            contactNode = contact.nodeB
        }
        
        contactNode.removeFromParentNode()
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
