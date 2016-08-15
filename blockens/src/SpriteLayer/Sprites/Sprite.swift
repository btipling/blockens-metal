//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

struct SpriteFrame {
    var frameCount: Int
    var spritePosition: Float32
}

protocol Sprite {
    func setGridPosition(gridPosition: Int32)
    func gridPosition() -> Int32
    func update() -> [Float32]
}

let breezeSpriteFrames = [
    SpriteFrame(frameCount: 3, spritePosition: 0.0),
    SpriteFrame(frameCount: 3, spritePosition: 1.0),
    SpriteFrame(frameCount: 3, spritePosition: 2.0),
    SpriteFrame(frameCount: 3, spritePosition: 3.0),
    SpriteFrame(frameCount: 3, spritePosition: 4.0),
    SpriteFrame(frameCount: 3, spritePosition: 3.0),
    SpriteFrame(frameCount: 3, spritePosition: 4.0),
    SpriteFrame(frameCount: 3, spritePosition: 3.0),
    SpriteFrame(frameCount: 3, spritePosition: 2.0),
    SpriteFrame(frameCount: 3, spritePosition: 1.0),
]