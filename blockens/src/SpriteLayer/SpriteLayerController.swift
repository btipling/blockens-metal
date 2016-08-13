//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

struct SpriteLayerSetup {
    let textureName: String
    let width: Int32
    let height: Int32
    let textureWidth: Int32
    let textureHeight: Int32
    let viewDiffRatio : Float32
}

class SpriteLayerController: RenderController {

    let _renderer: SpriteLayerRenderer

    init (setup: SpriteLayerSetup) {
        _renderer = SpriteLayerRenderer(utils: RenderUtils(), setup: setup)
    }

    func renderer() -> Renderer {
        return _renderer
    }

}
