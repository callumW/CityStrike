//
//  MainMenuViewController.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 12/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class MainMenuViewController: UIViewController {

    var menuScene: SCNScene! = nil
    var overlayScene: SKScene! = nil

    var playButton: ButtonNode! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load scene
        menuScene = SCNScene(named: "art.scnassets/Main Menu.scn")

        let scnView = self.view as! SCNView
        scnView.scene = menuScene
        scnView.isPlaying = true


        // Setup tap handler
//        let tapRecognizer = UITapGestureRecognizer()
//        tapRecognizer.numberOfTapsRequired = 1
//        tapRecognizer.numberOfTouchesRequired = 1
//
//        tapRecognizer.addTarget(self, action: #selector(MainMenuViewController.handleTap(sender:)))
//        scnView.addGestureRecognizer(tapRecognizer)

        overlayScene = SKScene(fileNamed: "MainMenuUI.sks")
        overlayScene.isPaused = false
        overlayScene.isUserInteractionEnabled = true

        // TODO find play button and add callback

        scnView.overlaySKScene = overlayScene

        addButtons()
    }

    func onPlayButton() {
        print("PLAY!")
        switchToGameScene()
    }

    func switchToGameScene() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameController = storyboard.instantiateViewController(identifier: "game_view_controller")

        self.present(gameController, animated: true, completion: { () in
            print("finished presenting new view controller!")
        })
    }

    func addButtons() {
        // find play button placeholder in scene
        var placeholderPlayButton: SKSpriteNode! = nil
        if let tmp = self.overlayScene.childNode(withName: "play_button") {
            placeholderPlayButton = tmp as? SKSpriteNode
        }
        else {
            print("Failed to find play button placeholder")
            return
        }

        let position = placeholderPlayButton.position

        playButton = ButtonNode(upImage: "play_button_front", downImage: "play_button_back", callback: self.onPlayButton)
        playButton.position = position
        playButton.setScale(0.25)
        placeholderPlayButton.removeFromParent()

        self.overlayScene.addChild(playButton)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}
