//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

class SnakeRenderer {

    var pipelineState: MTLRenderPipelineState! = nil

    var vertexBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var gridInfoBuffer: MTLBuffer! = nil
    var gameTilesBuffer: MTLBuffer! = nil
    var boxTilesBuffer: MTLBuffer! = nil
    var vertexCount = 0


    func loadAssets(device: MTLDevice, view: MTKView, gridInfoData: GridInfo) {

        // Load any resources required for rendering.

        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.newFunctionWithName("passThroughFragment")!
        let vertexProgram = defaultLibrary.newFunctionWithName("passThroughVertex")!

        var gridInfoDataCopy = gridInfoData

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

        // Generate a large enough buffer to allow streaming vertices for 3 semaphore controlled frames.
        vertexBuffer = device.newBufferWithLength(ConstantBufferSize, options: [])
        vertexBuffer.label = "vertices"

        let vertexColorSize = vertexColorData.count * sizeofValue(vertexColorData[0])
        vertexColorBuffer = device.newBufferWithBytes(vertexColorData, length: vertexColorSize, options: [])
        vertexColorBuffer.label = "colors"

        let gridInfoBufferSize = sizeofValue(gridInfoData)
        gridInfoBuffer = device.newBufferWithBytes(&gridInfoDataCopy, length: gridInfoBufferSize, options: [])
        gridInfoBuffer.label = "gridInfo"

        let gameTileBufferSize = sizeofValue(Array<Int32>(count: Int(gridInfoData.numBoxes), repeatedValue: 0))
        gameTilesBuffer = device.newBufferWithLength(gameTileBufferSize, options: [])
        gameTilesBuffer.label = "gameTiles"

        let boxTileBufferSize = sizeofValue(Array<Int32>(count: Int(gridInfoData.numBoxes), repeatedValue: 0))
        boxTilesBuffer = device.newBufferWithLength(boxTileBufferSize, options: [])
        boxTilesBuffer.label = "boxTiles"

    }

    func updateTileCount(count: Int, gridInfoData: GridInfo) {
        vertexCount = count * Int(gridInfoData.numVertices)
    }

    func update(gameTiles: Array<Int32>, boxTiles: Array<Int32>) {
        // vData is pointer to the MTLBuffer's Float data contents.
        let pData = vertexBuffer.contents()
        let vData = UnsafeMutablePointer<Float>(pData + 256)
        vData.initializeFrom(vertexData)

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

    func render(snakeRenderEncoder: MTLRenderCommandEncoder) {

        snakeRenderEncoder.label = "snake render encoder"

        snakeRenderEncoder.pushDebugGroup("draw snake and food")
        snakeRenderEncoder.setRenderPipelineState(pipelineState)
        snakeRenderEncoder.setVertexBuffer(vertexBuffer, offset: 256, atIndex: 0)
        snakeRenderEncoder.setVertexBuffer(vertexColorBuffer, offset:0 , atIndex: 1)
        snakeRenderEncoder.setVertexBuffer(gridInfoBuffer, offset:0 , atIndex: 2)
        snakeRenderEncoder.setVertexBuffer(gameTilesBuffer, offset:0 , atIndex: 3)
        snakeRenderEncoder.setVertexBuffer(boxTilesBuffer, offset:0 , atIndex: 4)
        snakeRenderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)

        snakeRenderEncoder.popDebugGroup()
        snakeRenderEncoder.endEncoding()
    }
}
