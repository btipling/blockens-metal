//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation


class StarsController: RenderController {

    let _renderer: StarsRenderer

    init (setup: SpriteLayerSetup) {
        _renderer = StarsRenderer(utils: RenderUtils())
    }

    func renderer() -> Renderer {
        return _renderer
    }

}
