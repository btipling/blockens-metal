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
    var starColorsBuffer: MTLBuffer! = nil
    var starsSizeBuffer: MTLBuffer! = nil
    var viewDiffBuffer: MTLBuffer! = nil

    var starPositions: [Float32] = Array()
    var starColors: [Float32] = Array()
    var starSizes: [Float32] = Array()

    let colors = [
            ANGEL_PROTECTION,
            ANGEL_GLOW,
            HEAVEN_LIGHTS,
            ANGEL_WHITE,
            WHITE,
    ]

    init (utils: RenderUtils) {
        renderUtils = utils
        loadStars()
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState("starsVertex", fragment: "starsFragment", device: device, view: view)

        starsVertexBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "star positions")
        starColorsBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "star colors")
        starsSizeBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "star sizes")


        let pointer = UnsafeMutablePointer<Float32>(mutating: [frameInfo.viewDiffRatio])
        viewDiffBuffer = device.makeBuffer(bytes: pointer, length: MemoryLayout.size(ofValue: frameInfo.viewDiffRatio), options: [])

        print("loading stars assets done")
    }

    func loadStars() {
        starSizes = Array()
        starPositions = Array()
        starColors = Array()
        let numStars = getRandomNum(MAX_STARS - MIN_STARS) + MIN_STARS
        for _ in 0...numStars {
            starSizes += [Float32(getRandomNum(MAX_STAR_SIZE - MIN_STAR_SIZE) + MIN_STAR_SIZE)];
            let x = Float32(getRandomNum(200) - 100)/100.0
            let y = Float32(getRandomNum(200) - 100)/100.0
            starPositions += [x, y]
            let color = colors[Int(getRandomNum(Int32(colors.count)))]
            starColors += color
        }
    }

    func update() {
        if starsVertexBuffer != nil {
            renderUtils.updateBufferFromFloatArray(starsVertexBuffer, data: starPositions)
        }
        if starsSizeBuffer != nil {
            renderUtils.updateBufferFromFloatArray(starsSizeBuffer, data: starSizes)
        }
        if starColorsBuffer != nil {
            renderUtils.updateBufferFromFloatArray(starColorsBuffer, data: starColors)
        }
    }

    func render(_ renderEncoder: MTLRenderCommandEncoder) {
        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "stars")
        for (i, vertexBuffer) in [starsVertexBuffer, starColorsBuffer, starsSizeBuffer, viewDiffBuffer].enumerated() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: i)
        }

        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: starPositions.count/2, instanceCount: 1)
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }


}
