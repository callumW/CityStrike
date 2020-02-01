//
//  InputHandler.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/01/2020.
//  Copyright © 2020 Callum Wilson. All rights reserved.
//

import SceneKit


/// InputHandler protocol. All functions return true if the handler handled the input, false otherwise
protocol InputHandler {
    func handlePan(sender: UIPanGestureRecognizer) -> Bool
    func handleTap(sender: UITapGestureRecognizer) -> Bool
    func handleLongPress(sender: UILongPressGestureRecognizer) -> Bool
    func handlePinch(sender: UIPinchGestureRecognizer) -> Bool
}
