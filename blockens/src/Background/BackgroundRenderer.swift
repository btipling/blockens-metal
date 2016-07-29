//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit


private let ConstantBufferSize = 1024*1024

private let backgroundVertexData:[Float] = [
        -1.0, -1.0,
        -1.0,  1.0,
        1.0, -1.0,

        1.0, -1.0,
        -1.0,  1.0,
        1.0,  1.0,
]

private let vertexColorData:[Float] = [
        1.0, 1.0, 1.0, 1.0,
]

class BackgroundRenderer: Renderer {

    var pipelineState: MTLRenderPipelineState! = nil

    var backgroundVertexBuffer: MTLBuffer! = nil
    var backgroundColorBuffer: MTLBuffer! = nil

    func loadAssets(device: MTLDevice, view: MTKView) {

        let defaultLibrary = device.newDefaultLibrary()!
        let vertexProgram = defaultLibrary.newFunctionWithName("backgroundVertex")!
        let fragmentProgram = defaultLibrary.newFunctionWithName("backgroundFragment")!

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.sampleCount = view.sampleCount

        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }

        backgroundVertexBuffer = device.newBufferWithLength(ConstantBufferSize, options: [])
        backgroundVertexBuffer.label = "background vertices"

        let vertexColorSize = vertexColorData.count * sizeofValue(vertexColorData[0])
        backgroundColorBuffer = device.newBufferWithBytes(vertexColorData, length: vertexColorSize, options: [])
        backgroundColorBuffer.label = "background colors"
    }

    func update() {
        let pData = backgroundVertexBuffer.contents()
        let vData = UnsafeMutablePointer<Float>(pData + 256)
        vData.initializeFrom(backgroundVertexData)

    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        update()

        renderEncoder.label = "background render encoder"
        renderEncoder.pushDebugGroup("draw background")

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(backgroundVertexBuffer, offset: 256, atIndex: 0)
        renderEncoder.setVertexBuffer(backgroundColorBuffer, offset:0 , atIndex: 1)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: backgroundVertexData.count, instanceCount: 1)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }
}
