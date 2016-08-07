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

struct StringInfo {
    var gridWidth: Int32
    var gridHeight: Int32

    // Character vertices are multiplied by these scales from normal coordinates
    var xScale: Float32
    var yScale: Float32

    // Character vertices are added by these values after scale has been applied.
    var xPadding: Float32
    var yPadding: Float32


    var numBoxes: Int32
    var numVertices: Int32
    var numCharacters: Int32
    var numSegments: Int32
}

class StringRenderer: Renderer  {

    var pipelineState: MTLRenderPipelineState! = nil
    var stringVertexBuffer: MTLBuffer! = nil
    var boxTilesBuffer: MTLBuffer! = nil
    var segmentTrackerBuffer: MTLBuffer! = nil
    var stringInfo: StringInfo! = nil

    // Sixes vertices for two triangles to make a rectangle.
    let numVerticesInARectangle: Int32 = 6
    let gridWidth: Int32 = 5
    let gridHeight: Int32 = 8
    init(xScale: Float32, yScale: Float32, xPadding: Float32, yPadding: Float32) {
        stringInfo = StringInfo(
                gridWidth: gridWidth,
                gridHeight: gridHeight,
                xScale: xScale,
                yScale: yScale,
                xPadding: xPadding,
                yPadding: yPadding,
                numBoxes: gridWidth * gridHeight,
                numVertices: 0,
                numCharacters: 0,
                numSegments: 0)
    }

    func calcNumVertices() {
        stringInfo.numVertices = stringInfo.numSegments
        stringInfo.numVertices *= numVerticesInARectangle

    }


    func update(boxTiles: [Int32], segmentTracker: [Int32]) {
        stringInfo.numCharacters = Int32(segmentTracker.count)
        stringInfo.numSegments = 0
        for segmentCount in segmentTracker {
            stringInfo.numSegments += segmentCount
        }
        calcNumVertices()
    }

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
