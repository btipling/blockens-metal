//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct GridInfo {
    var gridDimension: Int32
    var numBoxes: Int32
    var numVertices: Int32
    var viewDiffRatio : Float32
}

private var gridDimension: Int32 = 30

class SnakeRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var vertexBuffer: MTLBuffer! = nil
    var gridInfoBuffer: MTLBuffer? = nil
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
                numBoxes: Int32(pow(Float(gridDimension), 2.0)),
                numVertices: Int32(renderUtils.numVerticesInARectangle()),
                viewDiffRatio: 0.0)
    }


    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        gridInfoData.viewDiffRatio = frameInfo.viewDiffRatio

        pipelineState = renderUtils.createPipeLineState("gameTileVertex", fragment: "gameTileFragment", device: device, view: view)

        foodTexture = renderUtils.loadTexture(device, name: "dark_yellow_block")
        snakeTexture = renderUtils.loadTexture(device, name: "green_block")

        vertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "game tile vertices")
        textureBuffer = renderUtils.createRectangleTextureCoordsBuffer(device, bufferLabel: "game tile texture coords")

        let count = Int(gridInfoData.numBoxes)
        gameTilesBuffer = renderUtils.createBufferFromIntArray(device, count: count, bufferLabel: "game tiles")
        boxTilesBuffer = renderUtils.createBufferFromIntArray(device, count: count, bufferLabel: "box tiles")

        let gridInfoBufferSize = MemoryLayout.size(ofValue: gridInfoData)
        gridInfoBuffer = device.makeBuffer(bytes: &gridInfoData, length: gridInfoBufferSize, options: [])
        gridInfoBuffer!.label = "grid info"

        print("loading snake assets done")
    }

    func updateTileCount(_ count: Int) {
        vertexCount = count * Int(gridInfoData.numVertices)
    }

    func update(_ gameTiles: Array<Int32>, boxTiles: Array<Int32>) {

        if gridInfoBuffer == nil {
            return
        }

        let contents = gridInfoBuffer!.contents()
        let pointer = UnsafeMutablePointer<GridInfo>(contents)
        pointer.initialize(from: &gridInfoData, count: 1)

        renderUtils.updateBufferFromIntArray(gameTilesBuffer, data: gameTiles)
        renderUtils.updateBufferFromIntArray(boxTilesBuffer, data: boxTiles)

    }

    func render(_ renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "snake and food")


        for (i, buffer) in [vertexBuffer, textureBuffer, gridInfoBuffer, gameTilesBuffer, boxTilesBuffer].enumerated() {
            renderEncoder.setVertexBuffer(buffer, offset: 0, at: i)
        }

        renderEncoder.setFragmentTexture(snakeTexture, at: 0)
        renderEncoder.setFragmentTexture(foodTexture, at: 1)

        renderUtils.drawPrimitives(renderEncoder, vertexCount: vertexCount)
    }
}

extension UnsafeMutablePointer {
    init(_ rawPointer: UnsafeMutableRawPointer) {
        self.init(OpaquePointer(rawPointer))
    }
}
