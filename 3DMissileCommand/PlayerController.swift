//
//  PlayerController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 30/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import Foundation
import UIKit

class PlayerController : InputHandler {

    // MARK: Member Variables


    init() {

    }

    // MARK: InputHandler Functions

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
