//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

private let ConstantBufferSize = 1024*1024

private let skyVertexData:[Float] = [
        -1.0, -1.0,
        -1.0,  1.0,
        1.0, -1.0,

        -1.0, 1.0,
        1.0,  1.0,
        1.0,  -1.0,
]

private let textureData:[Float] = [
        0.0,  1.0,
        0.0,  0.0,
        1.0,  1.0,

        0.0,  0.0,
        1.0,  0.0,
        1.0,  1.0,
]



struct SkyInfo {
    var tickCount: Int32
    var viewDiffRatio : Float32
}

class SkyRenderer: Renderer {

    var pipelineState: MTLRenderPipelineState! = nil

    var skyVertexBuffer: MTLBuffer! = nil
    var bgDataBuffer: MTLBuffer! = nil
    var textureBuffer: MTLBuffer! = nil
    var texture: MTLTexture!
    var bgInfoData = SkyInfo(tickCount: 0, viewDiffRatio : 0.0)

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        texture = loadTexture(device, name: "mountains")
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexProgram = defaultLibrary.newFunctionWithName("skyVertex")!
        let fragmentProgram = defaultLibrary.newFunctionWithName("skyFragment")!

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

        bgDataBuffer = device.newBufferWithLength(ConstantBufferSize, options: [])
        bgDataBuffer.label = "sky colors"

        let skyVertexSize = skyVertexData.count * sizeofValue(skyVertexData[0])
        skyVertexBuffer = device.newBufferWithBytes(skyVertexData, length:  skyVertexSize, options: [])
        skyVertexBuffer.label = "sky vertices"

        let textBufferSize = textureData.count * sizeofValue(textureData[0])
        textureBuffer = device.newBufferWithBytes(textureData, length: textBufferSize, options: [])
        textureBuffer.label = "bg texture coords"
        print("loading sky assets done")
    }



    func render(renderEncoder: MTLRenderCommandEncoder) {

        renderEncoder.label = "sky render encoder"
        renderEncoder.pushDebugGroup("draw sky")

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(bgDataBuffer, offset:0 , atIndex: 0)
        renderEncoder.setVertexBuffer(skyVertexBuffer, offset: 0, atIndex: 1)
        renderEncoder.setVertexBuffer(textureBuffer, offset:0 , atIndex: 2)
        renderEncoder.setFragmentTexture(texture, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: skyVertexData.count * 2, instanceCount: 1)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }
}
