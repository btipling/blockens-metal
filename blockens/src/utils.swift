//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

struct GridInfo {
    var gridDimension: Int32
    var gridOffset: Float32
    var numBoxes: Int32
    var numVertices: Int32
    var numColors: Int32
}

var gridDimension: Int32 = 25
var gridInfoData = GridInfo(
        gridDimension: gridDimension,
        gridOffset: 2.0/Float32(gridDimension),
        numBoxes: Int32(pow(Float(gridDimension), 2.0)),
        numVertices: Int32(vertexData.count/2),
        numColors: Int32(vertexColorData.count/4))

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

func getRandomBox() -> Int32 {
    return Int32(arc4random_uniform(UInt32(gridInfoData.numBoxes)))
}

func log_e(n: Double) -> Double {
    return log(n)/log(M_E)
}