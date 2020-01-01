//
//  CollisionBitmasks.swift
//  3DMissileCommand
//
//  Created by Callum Wilson on 06/12/2019.
//  Copyright © 2019 Callum Wilson. All rights reserved.
//

class COLLISION_BITMASK {
    static let FLOOR: Int              = 1 << 0    // Also used for general static bodies
    static let PLAYER_MISSILE: Int     = 1 << 1
    static let ENEMY_MISSILE: Int      = 1 << 2
    static let HOUSE: Int              = 1 << 3
    static let PLAYER_TARGET_NODE: Int = 1 << 4
    static let MISSILE_EXPLOSION: Int  = 1 << 5
    static let TARGET_PANE: Int        = 1 << 6
}
