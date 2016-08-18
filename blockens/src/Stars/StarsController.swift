//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation


class StarsController: RenderController {

    let _renderer: StarsRenderer

    init () {
        _renderer = StarsRenderer(utils: RenderUtils())
    }

    func reset () {
        _renderer.loadStars()
        _renderer.update()
    }

    func renderer() -> Renderer {
        return _renderer
    }

}
