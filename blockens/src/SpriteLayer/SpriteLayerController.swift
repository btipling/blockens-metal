//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class SpriteLayerController: RenderController {

    let _renderer: SpriteLayerRenderer

    init (textureName: String, width: Int32, height: Int32, position: Int32) {
        _renderer = SpriteLayerRenderer(utils: RenderUtils(), textureName: textureName, width: width, height: height)
    }

    func renderer() -> Renderer {
        return _renderer
    }

}
