//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

private let stringVertexData:[Float] = [
        -1.0, -1.0,
        -1.0,  1.0,
        1.0, -1.0,

        -1.0, 1.0,
        1.0,  1.0,
        1.0,  -1.0,
]

class StringRenderer: Renderer  {

    var pipelineState: MTLRenderPipelineState! = nil
    var stringVertexBuffer: MTLBuffer! = nil

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        let defaultLibrary = device.newDefaultLibrary()!
        let vertexProgram = defaultLibrary.newFunctionWithName("stringVertex")!
        let fragmentProgram = defaultLibrary.newFunctionWithName("stringFragment")!

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

        let stringVertexSize = stringVertexData.count * sizeofValue(stringVertexData[0])
        stringVertexBuffer = device.newBufferWithBytes(stringVertexData, length:  stringVertexSize, options: [])
        stringVertexBuffer.label = "string vertices"

        print("loading string assets done")
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {

        renderEncoder.label = "string render encoder"
        renderEncoder.pushDebugGroup("draw string")

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(stringVertexBuffer, offset:0 , atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: stringVertexData.count, instanceCount: 1)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }


}
