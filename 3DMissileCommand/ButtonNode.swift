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
    var upNode: SKNode
    var downNode: SKNode?
    var callback: () -> Void

    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }
        set {

        }
    }

    init(node: SKNode, callback: @escaping () -> Void, replace: SKNode) {
        upNode = node

        let dstSize = replace.calculateAccumulatedFrame()

        let srcSize = upNode.calculateAccumulatedFrame()

        let yScale = dstSize.height / srcSize.height
        let xScale = dstSize.width / srcSize.width

        upNode.xScale = xScale
        upNode.yScale = yScale


        self.callback = callback
        super.init()

        position = replace.position
        replace.removeFromParent()
        self.addChild(upNode)
    }

    init(upImage: String, downImage: String, callback: @escaping () -> Void) {
        upNode = SKSpriteNode(imageNamed: upImage)
        upNode.isHidden = false
        //upNode.isUserInteractionEnabled = true

        downNode = SKSpriteNode(imageNamed: downImage)
        downNode?.isHidden = true
        //downNode.isUserInteractionEnabled = true

        self.callback = callback

        super.init()
        self.position = position

        self.addChild(downNode!)
        self.addChild(upNode)
    }

    func texture(newTexture: SKTexture) {
        // upNode = SKSpriteNode(texture: newTexture)
        self.addChild(SKSpriteNode(texture: newTexture))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch began!")
        if downNode != nil {
            upNode.isHidden = true
            downNode!.isHidden = false
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
        if downNode != nil {
            upNode.isHidden = false
            downNode!.isHidden = true
        }
        callback()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches cancelled")
        if downNode != nil {
            upNode.isHidden = false
            downNode!.isHidden = true
        }
        callback()
    }

//    override func contains(_ p: CGPoint) -> Bool {
//        return upNode.contains(p) || (downNode == nil ? false : downNode!.contains(p))
//    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
