//
//  TheatrePlane.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import SceneKit
import SpriteKit

/*
 A TheatrePlane contains an instance of the Missile game. It holds player missiles, enemy missiles,
 buildings, and everything else required for the game to operate.
 The user can switch between these planes and launch missiles for each one.
 */
class TheatrePlane: SCNNode {
    static let scene: SCNScene? = SCNScene(named: "art.scnassets/TheatrePlane.scn")
    let planeNode: SCNNode
    let targetPlane: SCNNode
    let cameraNode: SCNNode

    let playerController: PlayerController
    var playerMissileBatteries: Array<SCNNode> = []

    let enemyController: EnemyController
    let enemySpawn: SCNNode

    let targettingUI: MissileTargetUI
    var taps: Array<CGPoint> = []

    let city: CityNode

    let containingView: SCNView

    let uiParentNode: SKNode
    let uiScene: SKScene

    let minimapParentNode: SKNode

    init?(gameScene: SCNScene, ui: SKScene, view: SCNView) {

        containingView = view
        uiScene = ui

        if TheatrePlane.scene == nil {
            print("Template TheatrePlane scene not loaded")
            return nil
        } else {
            planeNode = TheatrePlane.scene!.rootNode.clone()
        }

        if let tmp = planeNode.childNode(withName: "camera_position", recursively: true) {
            cameraNode = tmp
        }
        else {
            print("Failed to find camera in TheatrePlane")
            return nil
        }

        if let tmp = planeNode.childNode(withName: "target_plane", recursively: true) {
            targetPlane = tmp
            targetPlane.categoryBitMask = COLLISION_BITMASK.TARGET_PANE
        }
        else {
            print("Failed to find target plane in TheatrePlane")
            return nil
        }


        // TODO how do we work out the size when the plane isn't in the scene yet!
        minimapParentNode = PlaneMinimapNode(planeSize: CGSize(width: 26.68, height: 8.82))

        // Get missile silos
        for node in planeNode.childNodes {
            if node.name != nil && node.name! == "missile_battery" {
                playerMissileBatteries.append(node)
                let tmp = MissileBatteryNode()
                let posInTargetPlane = node.parent!.convertPosition(node.position, to: targetPlane)
                tmp.position = CGPoint(x: CGFloat(posInTargetPlane.x), y: CGFloat(posInTargetPlane.y))
                minimapParentNode.addChild(tmp)
                print("added missile battery to \(tmp.position) (\(posInTargetPlane))")
            }
        }

        playerController = PlayerController(scene: gameScene, ui: ui, planeNode: planeNode)

        city = CityNode()
        planeNode.addChildNode(city)

        minimapParentNode.addChild(city.minimapNode)

        enemySpawn = SCNNode(geometry: nil)
        enemySpawn.position = SCNVector3(0, 20, 0)
        planeNode.addChildNode(enemySpawn)
        enemyController = EnemyController(city: city, spawnNode: enemySpawn, minimap: minimapParentNode, plane: planeNode)

        targettingUI = MissileTargetUI()

        uiParentNode = SKNode()

        super.init()

        self.addChildNode(planeNode)



        print("Initialised Plane")
    }

    func getViewableSize() -> CGSize {
        let topLeftPoint = CGPoint(x: 0, y: 5)
        let topRightPoint = CGPoint(x: uiScene.size.width, y: 5)
        var topLeftPosition: SCNVector3? = nil
        var topRightPosition: SCNVector3? = nil

        var height: CGFloat = 0

        let topLeftResults = containingView.hitTest(topLeftPoint, options: [SCNHitTestOption.categoryBitMask: COLLISION_BITMASK.TARGET_PANE, SCNHitTestOption.ignoreHiddenNodes: false, SCNHitTestOption.backFaceCulling: false, SCNHitTestOption.searchMode: 1])

        for result in topLeftResults {
            if result.node == targetPlane {
                topLeftPosition = result.localCoordinates
                break
            }
        }

        let topRightResults = containingView.hitTest(topRightPoint, options: [SCNHitTestOption.categoryBitMask: COLLISION_BITMASK.TARGET_PANE, SCNHitTestOption.ignoreHiddenNodes: false, SCNHitTestOption.backFaceCulling: false, SCNHitTestOption.searchMode: 1])

        for result in topRightResults {
            if result.node == targetPlane {
                topRightPosition = result.localCoordinates
                height = CGFloat(result.worldCoordinates.y)
                break
            }
        }

        if topRightPosition == nil || topLeftPosition == nil {
            return CGSize(width: 0, height: 0)
        }

        // print("top left: \(topLeftPosition) | top right: \(topRightPosition)")

        return CGSize(width: CGFloat(topRightPosition!.x - topLeftPosition!.x), height: height)
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Set the plane as the active plane
    /// - Parameter in: Scene that the plane is active in
    func activate(camera: SCNNode, uiScene: SKScene) {
        self.cameraNode.addChildNode(camera)
        uiScene.addChild(self.uiParentNode)
    }


    /// Deactivate the plane
    func deactivate() {
        self.uiParentNode.removeFromParent()
    }

    func notifyTap(point: CGPoint) {
//        print("Was notified of tap at: \(point)")
        taps.append(point)
    }

    /// Process user taps that occured since the last update
    func processUserInput() {

        for tap in taps {
            print("testing for hit results")
            let results = containingView.hitTest(tap, options: [SCNHitTestOption.categoryBitMask: COLLISION_BITMASK.TARGET_PANE, SCNHitTestOption.ignoreHiddenNodes: false, SCNHitTestOption.backFaceCulling: false, SCNHitTestOption.searchMode: 1])
            print("got results")

            for result in results {
                if result.node == targetPlane {
                    print("Tap \(tap) hits \(result.node.name ?? "no_name") @ \(result.worldCoordinates)")

                    let targetUiNode = SKSpriteNode(imageNamed: "target_hint.png")
                    targetUiNode.position = uiScene.convertPoint(fromView: tap)
                    self.uiParentNode.addChild(targetUiNode)

                    let target = TargetNode(uiNode: targetUiNode)
                    target.position = self.convertPosition(result.worldCoordinates, from: nil)
                    self.addChildNode(target)
                    let missile = playerController.getMissile()

                    self.addChildNode(missile)

                    missile.fire(targetNode: target, speed: PlayerController.PLAYER_MISSILE_SPEED_SCALER)
                    minimapParentNode.addChild(missile.minimapNode)
                }
                else {
                    print("skipping inactive plane")
                }
            }
        }

        // print("Viewable area: \(getViewableSize())")

        taps.removeAll()
    }

    func updateMinimap() {
        playerController.updateMinimap(relativeTo: targetPlane)
        enemyController.updateMinimap(relativeTo: targetPlane)
        city.updatePosition(relativeTo: targetPlane)
    }

    /// Update the TheatrePlane and its contents
    /// - Parameter time: current time
    func update(time: TimeInterval) {
        city.cleanUp()
        processUserInput()
        playerController.update(time)
        enemyController.update(time)
        updateMinimap()
    }

    func houseWasDestroyed(_ house: SCNNode) {
        _ = city.houseWasDestroyed(house)
    }

}
