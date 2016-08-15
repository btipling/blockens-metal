//
// Created by Bjorn Tipling on 8/9/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class Bush: Sprite {

    private var currentFrame = 0
    private var currentTextCoords: [Float32] = [0.0, 2.0]
    private var gridPos: Int32 = 0
    private var frames: [Float32] = Array()

    init() {
        frames = setupFrames(breezeSpriteFrames)
        currentFrame = newStartFrame()
    }

    func setGridPosition(gridPosition: Int32) {
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
