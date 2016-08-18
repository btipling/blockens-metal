//
// Created by Bjorn Tipling on 8/17/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

let NUM_STARS = 1

class StarsRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var starsVertexBuffer: MTLBuffer! = nil
    var starsSizeBuffer: MTLBuffer! = nil
    var viewDiffBuffer: MTLBuffer! = nil

    var starPositions: [Float32]! = nil
    var starSizes: [Float32]! = nil

    init (utils: RenderUtils) {
        renderUtils = utils
        loadStars()
    }

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState("starsVertex", fragment: "starsFragment", device: device, view: view)

        starsVertexBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "star positions")
        starsSizeBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "star sizes")


        let pointer = UnsafeMutablePointer<Float32>([frameInfo.viewDiffRatio])
        viewDiffBuffer = device.newBufferWithBytes(pointer, length: sizeofValue(frameInfo.viewDiffRatio), options: [])

        print("loading stars assets done")
    }

    func loadStars() {
        starSizes = [15.0]
        starPositions = [0.0, 0.0]
    }

    func update() {
        loadStars()
        if starsVertexBuffer != nil {
            renderUtils.updateBufferFromFloatArray(starsVertexBuffer, data: starPositions)
        }
        if starsSizeBuffer != nil {
            renderUtils.updateBufferFromFloatArray(starsSizeBuffer, data: starSizes)
        }
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "stars")
        for (i, vertexBuffer) in [starsVertexBuffer, starsSizeBuffer, viewDiffBuffer].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }

        renderEncoder.drawPrimitives(.Point, vertexStart: 0, vertexCount: starPositions.count/2, instanceCount: 1)
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }


}
