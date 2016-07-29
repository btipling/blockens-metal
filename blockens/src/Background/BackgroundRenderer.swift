//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class BackgroundRenderer: Renderer {

    func loadAssets(device: MTLDevice, view: MTKView) {
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.endEncoding()
    }
}
