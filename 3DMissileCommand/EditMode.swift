//
//  EditMode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SceneKit

class EditMode : InputHandler {

    let gameScene: SCNScene

    init(gameScene: SCNScene) {
        self.gameScene = gameScene
    }

    // MARK: Handlers
    func handlePan(sender: UIPanGestureRecognizer) -> Bool {
        return false
    }

    func handleTap(sender: UITapGestureRecognizer) -> Bool {
        return false
    }

    func handleLongPress(sender: UILongPressGestureRecognizer) -> Bool {
        return false
    }

    func handlePinch(sender: UIPinchGestureRecognizer) -> Bool {
        return false
    }
}
