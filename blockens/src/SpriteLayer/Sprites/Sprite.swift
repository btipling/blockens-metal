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
    func gridPosition() -> Int32
    func update() -> [Float32]
}
