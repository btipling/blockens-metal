//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class StringRenderer: Renderer  {

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.endEncoding()
    }

}
