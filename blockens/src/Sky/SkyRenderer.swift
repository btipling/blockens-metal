//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct SkyInfo {
    var tickCount: Int32
    var viewDiffRatio : Float32
}

class SkyRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var skyVertexBuffer: MTLBuffer! = nil
    var skyInfoDataBuffer: MTLBuffer! = nil
    var textureBuffer: MTLBuffer! = nil
    var texture: MTLTexture!
    var skyInfoData = SkyInfo(tickCount: 0, viewDiffRatio : 0.0)

    init (utils: RenderUtils) {
        renderUtils = utils
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        texture = renderUtils.loadTexture(device, name: "mountains")
        skyInfoData.viewDiffRatio = frameInfo.viewDiffRatio
        skyInfoData.tickCount = 0

        pipelineState = renderUtils.createPipeLineState("skyVertex", fragment: "skyFragment", device: device, view: view)
        skyVertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "sky vertices")
        textureBuffer = renderUtils.createRectangleTextureCoordsBuffer(device, bufferLabel: "sky texture coords")
        skyInfoDataBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "sky colors")

        let contents = skyInfoDataBuffer.contents()
        let pointer = UnsafeMutablePointer<SkyInfo>(contents)
        pointer.initialize(from:&skyInfoData, count: 1)

        print("loading sky assets done")
    }



    func render(_ renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "sky")

        for (i, vertexBuffer) in [skyVertexBuffer, textureBuffer, skyInfoDataBuffer].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }

        renderEncoder.setFragmentTexture(texture, at: 0)

        renderUtils.drawPrimitives(renderEncoder, vertexCount: renderUtils.numVerticesInARectangle())

    }
}
