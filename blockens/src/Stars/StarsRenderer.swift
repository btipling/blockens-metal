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
    }

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState("starsVertex", fragment: "starsFragment", device: device, view: view)


        starsVertexBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "star positions")
        let contents = starsVertexBuffer.contents()
        let pointer = UnsafeMutablePointer<Float32>(contents)
        pointer.initializeFrom(&starPositions, count: NUM_STARS * 2)


        starsSizeBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "star sizes")
        let contents = starsSizeBuffer.contents()
        let pointer = UnsafeMutablePointer<Float32>(contents)
        pointer.initializeFrom(&starSizes, count: NUM_STARS)


        let bufferSize = rectangleVertexData.count * sizeofValue(rectangleVertexData[0])
        let buffer = device.newBufferWithBytes(rectangleVertexData, length: bufferSize, options: [])
        buffer.label = bufferLabel

        print("loading stars assets done")
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.endEncoding()
    }


}
