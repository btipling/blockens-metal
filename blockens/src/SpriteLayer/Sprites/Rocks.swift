//
// Created by Bjorn Tipling on 8/9/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class Rocks: Sprite {

    fileprivate var textCoords: [Float32] = [1.0, 1.0]
    fileprivate var gridPos: Int32 = 0

    func setGridPosition(_ gridPosition: Int32) {
        gridPos = gridPosition
    }

    func gridPosition() -> Int32 {
        return gridPos
    }

    func update() -> [Float32] {
        return textCoords
    }

}
