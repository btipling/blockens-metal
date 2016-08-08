//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class SpriteLayerController: RenderController {

    let _renderer: SpriteLayerRenderer

    init () {
        _renderer = SpriteLayerRenderer()
    }

    func renderer() -> Renderer {
        return _renderer
    }

}
