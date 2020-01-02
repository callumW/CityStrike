//
//  PlayerMissileController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 01/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit
import GameplayKit

struct MissileBattery {
    let node: SCNNode
    var heatValue: Double
    var overheated: Bool
}

struct TargetedMissile : Hashable {
    let targetNode: SCNNode
    let uiHint: SKNode
}

class PlayerController {
    static let PLAYER_MISSILE_SPEED_SCALER: Float = 1
    let gameScene: SCNScene
    let uiOverlay: SKScene
    let planeNode: SCNNode

    var missileBatteries: Array<SCNNode> = []
    var explodingMissiles: Array<MissileNode> = []

    var lastUpdate: TimeInterval = 0

    var indexPicker: GKRandomDistribution = GKRandomDistribution(lowestValue: 0, highestValue: 1)

    let targetHintAction: SKAction


    init(scene: SCNScene, ui: SKScene, planeNode: SCNNode) {
        gameScene = scene
        uiOverlay = ui
        self.planeNode = planeNode
        /* Setup action to animate ui target hints */
        let scaleAction = SKAction.scale(by: 1.5, duration: 0.2)
        let pulseAction = SKAction.sequence([scaleAction, scaleAction.reversed()])
        targetHintAction = SKAction.group([SKAction.repeatForever(pulseAction)])

        // Find missile batteries:
        for node in planeNode.childNodes {
            if node.name != nil && node.name! == "missile_battery" {
                missileBatteries.append(node)
            }
        }
    }


    /// add target hint node to UI and return it
    /// - Parameter at: The tap point
    /// returns the hint node
    func addTargetHint(at: CGPoint) -> SKSpriteNode {
        // create shape node:
        let targetCircle = SKSpriteNode(imageNamed: "target_hint.png")

        targetCircle.position = uiOverlay.convertPoint(fromView: at) // need to convert from view space to scene space
        uiOverlay.addChild(targetCircle)

        targetCircle.run(targetHintAction)

        return targetCircle
    }

    func getMissile() -> MissileNode {
        let missile = PlayerMissile()
        let source = missileBatteries.randomElement()!
        let sourcePosition = source.position
        missile.position = sourcePosition

        missile.setCollisionCallback(callback: { (missile: SCNNode) -> Void in
            self.onPlayerMissileCollision(missile: missile)
        })

        return missile
    }

    /// To be called in the Scene renderer function. Updates the Player controlled objects
    /// - Parameter time: Current time in seconds
    func update(_ time: TimeInterval) {
        lastUpdate = time
        var i: Int = 0
        while i < explodingMissiles.count {
            let missile = explodingMissiles[i]
            if missile.state == .FINISHED {
                explodingMissiles.remove(at: i)
                continue
            }
            else {
                missile.update(time)
            }
            i += 1
        }
    }


    /// To be called when the player missile has collided with something in the scene (typically the target node, but not necessarily)
    /// - Parameter missile: The player missile which collided with something
    /// returns true if player node has not collided previously (in which case explosion will be placed, false otherwise
    @discardableResult func onPlayerMissileCollision(missile: SCNNode) -> Bool {
        // TODO add to list of exploding missiles for later updating
        explodingMissiles.append(missile as! MissileNode)
        return false
    }
}
