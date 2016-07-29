//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

let MAX_TICK_MILLISECONDS = 300.0

enum Direction {
    case Up, Down, Left, Right
}

let movementMap: [UInt16: Direction] = [
        123: Direction.Left,
        124: Direction.Right,
        125: Direction.Down,
        126: Direction.Up,
]

let S_KEY: UInt16 = 1
let P_KEY: UInt16 = 35

enum GameTile: Int32 {
    case HeadUp = 0, HeadDown, HeadLeft, HeadRight
    case TailUp, TailDown, TailLeft, TailRight
    case BodyHorizontal, BodyVertical
    case CornerUpLeft, CornerUpRight, CornerDownLeft, CornerDownRight
    case EmptyTile, GrowTile
}

struct GameTileInfo {
    var x: Int32
    var y: Int32
    var tile: GameTile
}

enum GameStatus {
    case Stopped, Paused, Running
}

func getRandomNum(n: Int32) -> Int32 {
    return Int32(arc4random_uniform(UInt32(n)))
}

func log_e(n: Double) -> Double {
    return log(n)/log(M_E)
}