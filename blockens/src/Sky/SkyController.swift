//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class SkyController {
    private let _renderer = SkyRenderer()

    func renderer () -> SkyRenderer {
        return _renderer
    }
}
