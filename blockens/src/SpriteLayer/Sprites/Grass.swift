//
// Created by Bjorn Tipling on 8/9/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class Grass: Sprite {

    private var currentFrame = 0
    private var frameModifier: Float32 = 1.0
    private var currentTextCoords: [Float32] = [0.0, 0.0]


    private let spritesPerLoop: Float32 = 4.0
    private let spriteFrames = [
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
    private var frames: [Float32] = Array()

    init() {
        setupFrames()
        newStartFrame()
    }

    func setupFrames() {
        frames = Array()
        for spriteFrame in spriteFrames {
            var frameCount = spriteFrame.frameCount
            while (frameCount > 0) {
                frames.append(spriteFrame.spritePosition)
                frameCount -= 1
            }
        }
    }

    func newStartFrame() {
        currentFrame = Int(getRandomNum(100) * -1)
    }

    func gridPosition() -> Int32 {
        return 0
    }

    func update() -> [Float32] {
        currentFrame += 1
        if currentFrame > 0 {
            if currentFrame >= frames.count {
                newStartFrame()
                currentTextCoords[0] = 0.0
                return currentTextCoords
            }

            currentTextCoords[0] = frames[currentFrame]
        }
        return currentTextCoords
    }

}
