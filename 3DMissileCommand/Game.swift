//
//  Game.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 30/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit


class Game : InputHandler {

    // MARK: Member Variables
    var playerController: PlayerController
    let editController: EditController
    let cameraController: CameraController

    let cameraDolly: SCNNode
    let cameraNode: SCNNode
    let floorNode: SCNNode
    let grid: FloorGrid = FloorGrid()

    let gameScene: SCNScene
    let view: SCNView
    let overlayScene: SKScene

    var activeController: InputHandler? = nil

    init(gameScene: SCNScene, view: SCNView) {

        self.gameScene = gameScene
        self.view = view
        self.playerController = PlayerController()

        self.gameScene.rootNode.addChildNode(self.grid)
        self.grid.isHidden = true

        /* Load Camera */
        if let tmp = gameScene.rootNode.childNode(withName: "camera_dolly", recursively: true) {
            self.cameraDolly = tmp
            if let other_tmp = cameraDolly.childNode(withName: "camera_node", recursively: true) {
                self.cameraNode = other_tmp
            }
            else {
                fatalError("Failed to find camera in scene")
            }
        }
        else {
            fatalError("Failed to find camera dolly in scene")
        }

        self.cameraController = CameraController(dolly: self.cameraDolly)

        self.grid.position = cameraDolly.position

        /* Load Floor */
        if let tmp = gameScene.rootNode.childNode(withName: "floor", recursively: true) {
            self.floorNode = tmp
        }
        else {
            fatalError("Failed to find floor!")
        }

        self.editController = EditController(gameScene: self.gameScene, view: self.view, floorNode: self.floorNode)

        /* Load UI */
        self.overlayScene = SKScene(fileNamed: "UIOverlay.sks")!
        self.overlayScene.isPaused = false
        self.overlayScene.isUserInteractionEnabled = true

        self.view.overlaySKScene = self.overlayScene

        if let editButton = overlayScene.childNode(withName: "edit_button_placeholder") {
            let button = ButtonNode(replaceNode: editButton, callback: onEdit)
            overlayScene.addChild(button)
        }
        else {
            fatalError("Failed to get edit button")
        }

        if let cameraButton = overlayScene.childNode(withName: "camera_button_placeholder") {
            let button = ButtonNode(replaceNode: cameraButton, callback: onCamera)
            overlayScene.addChild(button)
        }
        else {
            fatalError("Failed to get camera button")
        }
    }

    // MARK: Button Callbacks

    func onEdit() {
        print("edit!")
        self.grid.isHidden = false
        self.activeController = self.editController

    }

    func onCamera() {
        print("camera!")
        self.grid.isHidden = true
        self.activeController = nil
    }


    // MARK: Input Handler Functions

    func handlePan(sender: UIPanGestureRecognizer) -> Bool {
        if self.activeController == nil || !self.activeController!.handlePan(sender: sender) {
            let velocity = sender.velocity(in: nil)

            let scalar: Float = 0.0003 * cameraNode.position.y

            let dolly_pos = cameraDolly.position

            cameraDolly.position = SCNVector3(x: dolly_pos.x - Float(velocity.x) * scalar, y: dolly_pos.y, z: dolly_pos.z - Float(velocity.y) * scalar)

            self.grid.position = cameraDolly.position
        }
        return true
    }

    func handleTap(sender: UITapGestureRecognizer) -> Bool {
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
                _ = self.activeController?.handleTap(sender: sender)
            }
        }
        return true
    }

    func handleLongPress(sender: UILongPressGestureRecognizer) -> Bool {
        _ = self.activeController?.handleLongPress(sender: sender)
        return true
    }

    func handlePinch(sender: UIPinchGestureRecognizer) -> Bool {
        if self.activeController == nil || self.activeController!.handlePinch(sender: sender) {
            let scalar: Float = 0.1

            self.cameraNode.position = self.cameraNode.position - (self.cameraNode.position * (scalar * Float(sender.velocity)))
        }
        return true
    }


    func update(time: TimeInterval) {

    }
}
