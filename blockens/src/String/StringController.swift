//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class StringController: RenderController {
    private let _renderer: StringRenderer = StringRenderer()

    func renderer() -> Renderer {
        return _renderer
    }
}
