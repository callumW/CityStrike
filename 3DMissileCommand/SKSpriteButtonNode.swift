//
//  SKSpriteButtonNode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 23/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import SpriteKit

class SKSpriteButtonNode : SKSpriteNode {

    var buttonClickCallbacks: [() -> Void] = []

    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }

        set {
            // ignore
        }
    }


    /// Added a callback to be called on button press
    /// - Parameter callback:
    func registerCallback(_ callback: @escaping () -> Void) {
        buttonClickCallbacks.append(callback)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("TOuched button!!")
        for callback in buttonClickCallbacks {
            callback()
        }
    }

}
