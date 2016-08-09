//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class SpriteLayerController: RenderController {

    let _renderer: SpriteLayerRenderer

    init (width: Int32, height: Int32) {
        _renderer = SpriteLayerRenderer(utils: RenderUtils(), width: width, height: height)
    }

    func renderer() -> Renderer {
        return _renderer
    }

}
