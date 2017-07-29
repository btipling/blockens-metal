//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct StringInfo {
    var gridWidth: Int32
    var gridHeight: Int32

    // Character vertices are multiplied by this scale from normal coordinates
    var scale: Float32

    // Character vertices are added by these values after scale has been applied.
    var xPadding: Float32
    var yPadding: Float32


    var numBoxes: Int32
    var numVertices: Int32
    var numCharacters: Int32
    var numSegments: Int32
}

class StringRenderer: Renderer  {

    let renderUtils: RenderUtils

    var stringInfo: StringInfo

    var pipelineState: MTLRenderPipelineState! = nil

    var stringVertexBuffer: MTLBuffer! = nil
    var segmentPositionsBuffer: MTLBuffer! = nil
    var segmentsPerCharacterBuffer: MTLBuffer! = nil
    var stringInfoBuffer: MTLBuffer? = nil

    // Sixes vertices for two triangles to make a rectangle.
    let gridWidth: Int32 = 5
    let gridHeight: Int32 = 8

    init(utils: RenderUtils, scale: Float32, xPadding: Float32, yPadding: Float32) {
        renderUtils = utils
        stringInfo = StringInfo(
                gridWidth: gridWidth,
                gridHeight: gridHeight,
                scale: scale,
                xPadding: xPadding,
                yPadding: yPadding,
                numBoxes: gridWidth * gridHeight,
                numVertices: 0,
                numCharacters: 0,
                numSegments: 0)
    }


    func update(_ segmentPositions: [Int32], segmentsPerCharacter: [Int32]) {

        if stringInfoBuffer == nil {
            return
        }

        stringInfo.numCharacters = Int32(segmentsPerCharacter.count)
        stringInfo.numSegments = Int32(segmentPositions.count)
        stringInfo.numVertices = stringInfo.numSegments
        stringInfo.numVertices *= Int32(renderUtils.numVerticesInARectangle())
        let contents = stringInfoBuffer!.contents()
        let pointer = UnsafeMutablePointer<StringInfo>(contents)
        pointer.initialize(from: &stringInfo, count: 1)

        renderUtils.updateBufferFromIntArray(segmentPositionsBuffer, data: segmentPositions)
        renderUtils.updateBufferFromIntArray(segmentsPerCharacterBuffer, data: segmentsPerCharacter)
    }

    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        pipelineState = renderUtils.createPipeLineState("stringVertex", fragment: "stringFragment", device: device, view: view)

        stringInfoBuffer = device.makeBuffer(bytes: &stringInfo, length: MemoryLayout.size(ofValue: stringInfo), options: [])
        stringInfoBuffer!.label = "string info"

        stringVertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "string vertices")
        segmentPositionsBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "string box tile vertices")
        segmentsPerCharacterBuffer = renderUtils.createSizedBuffer(device, bufferLabel: "segment tracker vertices")

        print("loading string assets done")
    }

    func render(_ renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "string")

        for (i, buffer) in [stringVertexBuffer, segmentPositionsBuffer, segmentsPerCharacterBuffer, stringInfoBuffer].enumerated() {
            renderEncoder.setVertexBuffer(buffer, offset: 0, at: i)
        }

        renderUtils.drawPrimitives(renderEncoder, vertexCount: Int(stringInfo.numVertices))
    }


}
