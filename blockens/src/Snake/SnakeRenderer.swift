//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct GridInfo {
    var gridDimension: Int32
    var gridOffset: Float32
    var numBoxes: Int32
    var numVertices: Int32
    var viewDiffRatio : Float32
}

private var gridDimension: Int32 = 30

class SnakeRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var vertexBuffer: MTLBuffer! = nil
    var gridInfoBuffer: MTLBuffer! = nil
    var gameTilesBuffer: MTLBuffer! = nil
    var boxTilesBuffer: MTLBuffer! = nil
    var textureBuffer: MTLBuffer! = nil

    var foodTexture: MTLTexture! = nil
    var snakeTexture: MTLTexture! = nil

    var vertexCount = 0
    var gridInfoData: GridInfo

    init (utils: RenderUtils) {
        renderUtils = utils
        gridInfoData = GridInfo(
                gridDimension: gridDimension,
                gridOffset: 2.0/Float32(gridDimension),
                numBoxes: Int32(pow(Float(gridDimension), 2.0)),
                numVertices: Int32(renderUtils.rectangleVertexData.count/2),
                viewDiffRatio: 0.0)
    }


    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        gridInfoData.viewDiffRatio = frameInfo.viewDiffRatio

        pipelineState = renderUtils.createPipeLineState("gameTileVertex", fragment: "gameTileFragment", device: device, view: view)

        foodTexture = renderUtils.loadTexture(device, name: "yellow_block")
        snakeTexture = renderUtils.loadTexture(device, name: "green_block")

        vertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "game tile vertices")
        textureBuffer = renderUtils.createRectangleTextureCoordsBuffer(device, bufferLabel: "game tile texture coords")

        let gridInfoBufferSize = sizeofValue(gridInfoData)
        gridInfoBuffer = device.newBufferWithBytes(&gridInfoData, length: gridInfoBufferSize, options: [])
        gridInfoBuffer.label = "grid info"

        let gameTileBufferSize = sizeofValue(Array<Int32>(count: Int(gridInfoData.numBoxes), repeatedValue: 0))
        gameTilesBuffer = device.newBufferWithLength(gameTileBufferSize, options: [])
        gameTilesBuffer.label = "game tiles"

        let boxTileBufferSize = sizeofValue(Array<Int32>(count: Int(gridInfoData.numBoxes), repeatedValue: 0))
        boxTilesBuffer = device.newBufferWithLength(boxTileBufferSize, options: [])
        boxTilesBuffer.label = "box tiles"

        print("loading snake assets done")
    }

    func updateTileCount(count: Int) {
        vertexCount = count * Int(gridInfoData.numVertices)
    }

    func update(gameTiles: Array<Int32>, boxTiles: Array<Int32>) {

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

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "snake and food")


        for (i, buffer) in [vertexBuffer, textureBuffer, gridInfoBuffer, gameTilesBuffer, boxTilesBuffer].enumerate() {
            renderEncoder.setVertexBuffer(buffer, offset: 0, atIndex: i)
        }

        renderEncoder.setFragmentTexture(snakeTexture, atIndex: 0)
        renderEncoder.setFragmentTexture(foodTexture, atIndex: 1)

        renderUtils.drawPrimitives(renderEncoder, vertexCount: vertexCount)
    }
}
