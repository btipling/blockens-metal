//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

private let ConstantBufferSize = 1024*1024

private let squareTileVertexData:[Float] = [
        -1.0, -1.0,
        -1.0,  1.0,
        1.0, -1.0,

        1.0, -1.0,
        -1.0,  1.0,
        1.0,  1.0,
]

private let vertexColorData:[Float] = [
        0.33, 0.33, 0.33, 1.0,
        1.0, 1.0, 1.0, 1.0,
        0.55, 0.55, 0.55, 1.0,
]


struct GridInfo {
    var gridDimension: Int32
    var gridOffset: Float32
    var numBoxes: Int32
    var numVertices: Int32
    var numColors: Int32
}

private var gridDimension: Int32 = 40

class SnakeRenderer: Renderer {

    var pipelineState: MTLRenderPipelineState! = nil

    var vertexBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var gridInfoBuffer: MTLBuffer! = nil
    var gameTilesBuffer: MTLBuffer! = nil
    var boxTilesBuffer: MTLBuffer! = nil
    var vertexCount = 0
    var gridInfoData = GridInfo(
            gridDimension: gridDimension,
            gridOffset: 2.0/Float32(gridDimension),
            numBoxes: Int32(pow(Float(gridDimension), 2.0)),
            numVertices: Int32(squareTileVertexData.count/2),
            numColors: Int32(vertexColorData.count/4))


    func loadAssets(device: MTLDevice, view: MTKView) {

        let defaultLibrary = device.newDefaultLibrary()!
        let vertexProgram = defaultLibrary.newFunctionWithName("gameTileVertex")!
        let fragmentProgram = defaultLibrary.newFunctionWithName("gameTileFragment")!

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

        vertexBuffer = device.newBufferWithLength(ConstantBufferSize, options: [])
        vertexBuffer.label = "game tile vertices"

        let vertexColorSize = vertexColorData.count * sizeofValue(vertexColorData[0])
        vertexColorBuffer = device.newBufferWithBytes(vertexColorData, length: vertexColorSize, options: [])
        vertexColorBuffer.label = "game tile colors"

        let gridInfoBufferSize = sizeofValue(gridInfoData)
        gridInfoBuffer = device.newBufferWithBytes(&gridInfoData, length: gridInfoBufferSize, options: [])
        gridInfoBuffer.label = "grid info"

        let gameTileBufferSize = sizeofValue(Array<Int32>(count: Int(gridInfoData.numBoxes), repeatedValue: 0))
        gameTilesBuffer = device.newBufferWithLength(gameTileBufferSize, options: [])
        gameTilesBuffer.label = "game tiles"

        let boxTileBufferSize = sizeofValue(Array<Int32>(count: Int(gridInfoData.numBoxes), repeatedValue: 0))
        boxTilesBuffer = device.newBufferWithLength(boxTileBufferSize, options: [])
        boxTilesBuffer.label = "box tiles"

    }

    func updateTileCount(count: Int) {
        vertexCount = count * Int(gridInfoData.numVertices)
    }

    func update(gameTiles: Array<Int32>, boxTiles: Array<Int32>) {
        // vData is pointer to the MTLBuffer's Float data contents.
        let pData = vertexBuffer.contents()
        let vData = UnsafeMutablePointer<Float>(pData + 256)
        vData.initializeFrom(squareTileVertexData)

        let gData = gridInfoBuffer.contents()
        let gvData = UnsafeMutablePointer<GridInfo>(gData + 0)
        gvData.initializeFrom(&gridInfoData, count: 1)

        let tData = gameTilesBuffer.contents()
        let tvData = UnsafeMutablePointer<Int32>(tData + 0)
        tvData.initializeFrom(gameTiles)

        let bData = boxTilesBuffer.contents()
        let bvData = UnsafeMutablePointer<Int32>(bData + 0)
        bvData.initializeFrom(boxTiles)

    }

    func render(renderEncoder: MTLRenderCommandEncoder) {

        renderEncoder.label = "snake render encoder"
        renderEncoder.pushDebugGroup("draw snake and food")

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 256, atIndex: 0)
        renderEncoder.setVertexBuffer(vertexColorBuffer, offset:0 , atIndex: 1)
        renderEncoder.setVertexBuffer(gridInfoBuffer, offset:0 , atIndex: 2)
        renderEncoder.setVertexBuffer(gameTilesBuffer, offset:0 , atIndex: 3)
        renderEncoder.setVertexBuffer(boxTilesBuffer, offset:0 , atIndex: 4)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }
}
