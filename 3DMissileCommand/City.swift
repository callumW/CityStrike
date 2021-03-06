//
//  City.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 28/11/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit


/// City class contains all the houses in the scene and provides automatic targetting for the enemy controller
class CityNode: SCNNode {
    func updatePosition(relativeTo: SCNNode) {

    }


    var houses:Set<BuildingNode> = []
    var destoryedHouses:Array<BuildingNode> = []

    var minimapNode: CityBuildingMinimapNode

    /// Initialiser
    /// - Parameter parent: Parent Node of the City
    override init() {
        minimapNode = CityBuildingMinimapNode()
        super.init()
        generate()

        for house in houses {
            minimapNode.addChild(house.minimapNode)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func houseCount() -> Int {
        return houses.count
    }

    /// Return a random house in the City, or nil if there are no houses left in the City
    func getRandomHouse() -> SCNNode? {
        if let ret = houses.randomElement() {
            return ret
        }
        else {
            return nil
        }
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
    func houseWasDestroyed(_ house: SCNNode) -> Void {
        if house is BuildingNode {
            let building = house as! BuildingNode 
            if let removed = houses.remove(building){
                print("removed house @ \(building.worldPosition) from set! count now: \(houses.count)")
                destoryedHouses.append(removed)
            }
        }
    }

    func generate() {
        // TODO add basic city generation (literally just place two houses at predefined points
        let house = BuildingNode(collisionCallback: self.houseWasDestroyed)
        self.addChildNode(house)

        house.position = SCNVector3(-1, 0, 0)
        self.houses.insert(house)
    }

}
