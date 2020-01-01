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

    var missileBatteries: Array<SCNNode> = []

    var lastUpdate: TimeInterval = 0

    var indexPicker: GKRandomDistribution = GKRandomDistribution(lowestValue: 0, highestValue: 1)

    let targetHintAction: SKAction


    init(scene: SCNScene, ui: SKScene, planeNode: SCNNode) {
        gameScene = scene
        uiOverlay = ui

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

    func fireMissile(at: SCNVector3) -> MissileNode {
        let missile = PlayerMissile()
        let sourcePosition = missileBatteries.randomElement()!.position
        missile.position = SCNVector3(sourcePosition.x, sourcePosition.y + 1, sourcePosition.z)
        //missile.position = SCNVector3(0, 4, 0)
        missile.fire(at: at, speed: PlayerController.PLAYER_MISSILE_SPEED_SCALER)
        return missile
    }

    /// To be called in the Scene renderer function. Updates the Player controlled objects
    /// - Parameter time: Current time in seconds
    func update(_ time: TimeInterval) {
        lastUpdate = time
    }


    /// To be called when the player missile has collided with something in the scene (typically the target node, but not necessarily)
    /// - Parameter missile: The player missile which collided with something
    /// returns true if player node has not collided previously (in which case explosion will be placed, false otherwise
    @discardableResult func onPlayerMissileCollision(_ missile: SCNNode) -> Bool {
        if missile is MissileNode {
            let tmp = missile as! MissileNode
        }
        return false
    }
}
