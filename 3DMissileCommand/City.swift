//
//  City.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/11/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit


/// City class contains all the houses in the scene and provides automatic targetting for the enemy controller
class City {

    let gameScene:SCNScene
    var houses:Dictionary<Float, SCNNode> = [:]
    var destoryedHouses:Array<SCNNode> = []

    init(_ gameScene: SCNScene) {
        self.gameScene = gameScene

        // load houses from scene into set

        for node in self.gameScene.rootNode.childNodes {
            if node.name != nil && node.name == "house" {
                houses[node.worldPosition.z] = node
                print("Adding house \(node.worldPosition)")
            }
        }
    }



    /// Return a random house in the City, or nil if there are no houses left in the City
    func getRandomHouse() -> SCNNode? {
        return (houses.randomElement())?.value
    }

    func cleanUp() {
        while(destoryedHouses.count > 0) {
            let house = destoryedHouses.removeFirst()
            house.removeFromParentNode()
        }
    }


    /// Notify the City that a house was destroyed
    /// - Parameter house: The house that was destroyed
    /// - Returns: True if house was in the city and successfuly destroyed, false otherwise
    func houseWasDestroyed(_ house:SCNNode) {
        if let removed = houses.removeValue(forKey: house.worldPosition.z){
            print("removed house @ \(house.worldPosition) from set! count now: \(houses.count)")
            destoryedHouses.append(removed)
        }
    }
}
