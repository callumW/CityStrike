//
//  CameraController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SceneKit

class CameraController : InputHandler {

    let cameraDolly: SCNNode
    let cameraNode: SCNNode

    init(dolly: SCNNode) {
        cameraDolly = dolly
        if let other_tmp = cameraDolly.childNode(withName: "camera_node", recursively: true) {
            cameraNode = other_tmp
        }
        else {
            fatalError("Failed to find camera in scene")
        }
    }

    // MARK: Handlers

    func handlePan(sender: UIPanGestureRecognizer) -> Bool {
        let velocity = sender.velocity(in: nil)

        let scalar: Float = 0.0003 * cameraNode.position.y

        let dolly_pos = cameraDolly.position

        cameraDolly.position = SCNVector3(x: dolly_pos.x - Float(velocity.x) * scalar, y: dolly_pos.y, z: dolly_pos.z - Float(velocity.y) * scalar)

        return true
    }

    func handleTap(sender: UITapGestureRecognizer) -> Bool {
        return false
    }

    func handleLongPress(sender: UILongPressGestureRecognizer) -> Bool {
        return false
    }

    func handlePinch(sender: UIPinchGestureRecognizer) -> Bool {
        let scalar: Float = 0.1

         cameraNode.position = cameraNode.position - (cameraNode.position * (scalar * Float(sender.velocity)))
        return true
    }


}
