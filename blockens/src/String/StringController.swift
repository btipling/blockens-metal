//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class StringController: RenderController {
    fileprivate let _renderer: StringRenderer!
    fileprivate var _str: String = "";

    init (scale: Float32, xPadding: Float32, yPadding: Float32) {
        _renderer = StringRenderer(utils: RenderUtils(), scale: scale, xPadding: xPadding, yPadding: yPadding)
    }

    func set(_ str: String) {
        _str = str

        // Put together the complete grid. We could do this in one loop, but that would be messy. It's still O(n).
        var characterGrids:[[Int32]] = Array()
        for char in str.characters {
            if let characterGrid = CharacterMap[char] {
                characterGrids.append(characterGrid)
            }
        }

        // Put together the boxTiles per character.
        var boxTiles: [Int32] = Array()
        // The segmentTracker tracks the number of segments per character.
        var segmentsPerCharacter: [Int32] = Array()
        var count: Int32 = 0
        for characterGrid in characterGrids {
            for i in 0..<characterGrid.count {
                let val = characterGrid[i]
                if val == 1 {
                    boxTiles.append(Int32(i))
                    count += 1
                }
            }
            segmentsPerCharacter.append(count)
        }
        self._renderer.update(boxTiles, segmentsPerCharacter: segmentsPerCharacter)
    }

    func renderer() -> Renderer {
        return _renderer
    }
}
