//
// Created by Bjorn Tipling on 8/9/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class Grass: Sprite {

    fileprivate var currentFrame = 0
    fileprivate var currentTextCoords: [Float32] = [0.0, 0.0]
    fileprivate var gridPos: Int32 = 0
    fileprivate var frames: [Float32] = Array()

    init() {
        frames = setupFrames(breezeSpriteFrames)
        currentFrame = newStartFrame()
    }

    func setGridPosition(_ gridPosition: Int32) {
        gridPos = gridPosition
    }

    func gridPosition() -> Int32 {
        return gridPos
    }

    func update() -> [Float32] {
        (currentTextCoords, currentFrame) = updateSpriteFrames(frames, currentTextCoords: currentTextCoords, currentFrame: currentFrame)
        return currentTextCoords
    }

}
