//
//  ButtonNode.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 26/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import SpriteKit

func *(size: CGSize, scale: Double) -> CGSize {
    return CGSize(width: Double(size.width) * scale, height: Double(size.height) * scale)
}

class ButtonNode : SKNode {
    var upNode: SKSpriteNode
    var downNode: SKSpriteNode
    var callback: () -> Void

    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }
        set {

        }
    }

    init(upImage: String, downImage: String, position: CGPoint, scale: Double, callback: @escaping () -> Void) {
        upNode = SKSpriteNode(imageNamed: upImage)
        upNode.isHidden = false
        upNode.size = upNode.size * scale
        //upNode.isUserInteractionEnabled = true

        downNode = SKSpriteNode(imageNamed: downImage)
        downNode.isHidden = true
        downNode.size = downNode.size * scale
        //downNode.isUserInteractionEnabled = true

        self.callback = callback

        super.init()
        self.position = position

        self.addChild(downNode)
        self.addChild(upNode)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch began!")
        upNode.isHidden = true
        downNode.isHidden = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        upNode.isHidden = false
        downNode.isHidden = true
        callback()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
