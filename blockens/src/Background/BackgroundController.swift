//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class BackgroundController: RenderController {

    fileprivate let _renderer = BackgroundRenderer(utils: RenderUtils())

    func renderer() -> Renderer {
        return _renderer
    }

}
