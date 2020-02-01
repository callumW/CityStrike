//
//  EditController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 25/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SceneKit

class EditController: InputHandler {

    var isMoving: Bool = false
    var isPlacing: Bool = false
    var currentBuilding: BuildingNode? = nil
    var longPressInFlight: Bool = false

    let gameScene: SCNScene
    let view: SCNView

    let floorNode: SCNNode

    init(gameScene: SCNScene, view: SCNView, floorNode: SCNNode) {
        self.gameScene = gameScene
        self.view = view
        self.floorNode = floorNode
    }

    func startPlacement(location: SCNVector3) {
        if !isPlacing {
            // Snap Location to grid?

            let snappedLocation = FloorGrid.snapTo(point: location)
            isPlacing = true
            currentBuilding = BuildingNode(collisionCallback: {(_ tmp : BuildingNode ) in })
            currentBuilding!.position = snappedLocation
            currentBuilding!.opacity = 0.2
            gameScene.rootNode.addChildNode(currentBuilding!)
        }
    }

    func confirmPlacement() {
        if isPlacing && currentBuilding != nil {
            print("confirmed placement!")
            currentBuilding!.opacity = 1
            isPlacing = false
            currentBuilding = nil
        }
    }

    func updatePosition(point: CGPoint) {
        if isMoving {
            let newPos = SCNVector3(x: currentBuilding!.position.x + Float(point.x * 0.01), y: currentBuilding!.position.y, z: currentBuilding!.position.z + Float(point.y * 0.01))
            currentBuilding!.position = newPos
        }
    }

    func hitsBuilding(tap: CGPoint) -> Bool {
        if isPlacing && currentBuilding != nil {
            let results = self.view.hitTest(tap, options: [SCNHitTestOption.categoryBitMask: currentBuilding!.categoryBitMask])
            for result in results {
                if result.node == currentBuilding!.houseNode {
                    return true
                }
            }
        }
        return false
    }

    func notifyTap(location: SCNVector3, hitResults: [SCNHitTestResult]) {
        if isPlacing && currentBuilding != nil {
            for result in hitResults {
                if result.node == currentBuilding {
                    confirmPlacement()
                }
            }
        }
    }

    func quit() {
        isPlacing = false
        if currentBuilding != nil {
            currentBuilding!.removeFromParentNode()
            currentBuilding = nil
        }
    }

    // MARK: Input Handler Functions

    func handlePan(sender: UIPanGestureRecognizer) -> Bool {
        return false
    }

    func handleTap(sender: UITapGestureRecognizer) -> Bool {
        let point = sender.location(in: self.view)
        if isPlacing && currentBuilding != nil {
            if hitsBuilding(tap: point) {
                confirmPlacement()
            }
            else {
                print("cancel building placement")
                quit()
            }
            return true
        }
        else {
            return false
        }
    }

    func handleLongPress(sender: UILongPressGestureRecognizer) -> Bool {
        if !self.longPressInFlight && sender.state == .began {
            self.longPressInFlight = true
            let pressPoint = sender.location(in: self.view)

            // check intersection with floor?
            let results = self.view.hitTest(pressPoint, options: [SCNHitTestOption.categoryBitMask: self.floorNode.categoryBitMask])
            for res in results {
                startPlacement(location: res.worldCoordinates)
            }
        }
        else if sender.state == .ended {
            self.longPressInFlight = false
        }
        return true
    }

    func handlePinch(sender: UIPinchGestureRecognizer) -> Bool {
        return false
    }
}
