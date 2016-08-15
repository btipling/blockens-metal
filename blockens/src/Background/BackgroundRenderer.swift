//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct BGInfo {
    var viewDiffRatio : Float32
}

class BackgroundRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var backgroundVertexBuffer: MTLBuffer! = nil
    var bgDataBuffer: MTLBuffer! = nil
    var bgInfoData = BGInfo(viewDiffRatio : 0.0)

    init (utils: RenderUtils) {
        renderUtils = utils
    }

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        bgInfoData.viewDiffRatio = frameInfo.viewDiffRatio
        pipelineState = renderUtils.createPipeLineState("backgroundVertex", fragment: "backgroundFragment", device: device, view: view)

        bgDataBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "background colors")
        let pData = bgDataBuffer.contents()
        let vData = UnsafeMutablePointer<BGInfo>(pData)
        vData.initializeFrom(&bgInfoData, count: 1)

        backgroundVertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "background vertices")

        print("loading bg assets done")
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "background")

        for (i, vertexBuffer) in [bgDataBuffer, backgroundVertexBuffer].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }

        renderUtils.drawPrimitives(renderEncoder, vertexCount: renderUtils.numVerticesInARectangle())
    }
}
