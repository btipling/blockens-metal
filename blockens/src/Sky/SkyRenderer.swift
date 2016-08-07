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
    var skyInfoDataBuffer: MTLBuffer! = nil
    var textureBuffer: MTLBuffer! = nil
    var texture: MTLTexture!
    var skyInfoData = SkyInfo(tickCount: 0, viewDiffRatio : 0.0)

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        texture = loadTexture(device, name: "mountains")
        skyInfoData.viewDiffRatio = frameInfo.viewDiffRatio
        skyInfoData.tickCount = 0

        pipelineState = createPipeLineState("skyVertex", fragment: "skyFragment", device: device, view: view)

        let skyVertexSize = skyVertexData.count * sizeofValue(skyVertexData[0])
        skyVertexBuffer = device.newBufferWithBytes(skyVertexData, length:  skyVertexSize, options: [])
        skyVertexBuffer.label = "sky vertices"

        let textBufferSize = textureData.count * sizeofValue(textureData[0])
        textureBuffer = device.newBufferWithBytes(textureData, length: textBufferSize, options: [])
        textureBuffer.label = "bg texture coords"

        skyInfoDataBuffer = device.newBufferWithLength(ConstantBufferSize, options: [])
        skyInfoDataBuffer.label = "sky colors"
        let pData = skyInfoDataBuffer.contents()
        let vData = UnsafeMutablePointer<SkyInfo>(pData)
        vData.initializeFrom(&skyInfoData, count: 1)

        print("loading sky assets done")
    }



    func render(renderEncoder: MTLRenderCommandEncoder) {

        setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "sky")

        for (i, vertexBuffer) in [skyVertexBuffer, textureBuffer, skyInfoDataBuffer].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }

        renderEncoder.setFragmentTexture(texture, atIndex: 0)

        drawPrimitives(renderEncoder, vertexCount: skyVertexData.count * 2)

    }
}
