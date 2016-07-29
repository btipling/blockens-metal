//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class BackgroundController {
    private let _renderer = BackgroundRenderer()

    func renderer () -> BackgroundRenderer {
        return _renderer
    }
}
