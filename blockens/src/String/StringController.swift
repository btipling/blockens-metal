//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class StringController: RenderController {
    private let _renderer: StringRenderer!
    private var _str: String = "";

    init (xScale: Float32, yScale: Float32, xPadding: Float32, yPadding: Float32) {
        _renderer = StringRenderer(utils: RenderUtils(), xScale: xScale, yScale: yScale, xPadding: xPadding, yPadding: yPadding)
    }

    func set(str: String) {
        _str = str

        // Put together the complete grid. We could do this in one loop, but that would be messy. It's still O(n).
        var grids:[[Int32]] = Array()
        for char in str.characters {
            if let grid = CharacterMap[char] {
                grids.append(grid)
            }
        }

        // Put together the boxTiles per character.
        var boxTiles: [Int32] = Array()
        // The segmentTracker tracks the number of segments per character.
        var segmentTracker: [Int32] = Array()
        var count: Int32 = 0
        for grid in grids {
            for i in 0..<grid.count {
                let val = grid[i]
                if val == 1 {
                    boxTiles.append(Int32(i))
                    count += 1
                }
            }
            segmentTracker.append(count)
        }
        self._renderer.update(boxTiles, segmentTracker: segmentTracker)
    }

    func renderer() -> Renderer {
        return _renderer
    }
}
