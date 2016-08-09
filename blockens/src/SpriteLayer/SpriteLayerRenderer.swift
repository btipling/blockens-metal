//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct SpriteLayerInfo {
    let gridWidth: Int32
    let gridHeight: Int32
    var numVertices: Int32
}

class SpriteLayerRenderer: Renderer {

    let renderUtils: RenderUtils

    private var sprites: [Sprite] = Array()
    private var gridPositions: [Int32] = Array()
    private var info: SpriteLayerInfo! = nil
    private var textureCoordinates: [Int32]? = nil

    var pipelineState: MTLRenderPipelineState! = nil

    private let textureName: String
    private var texture: MTLTexture! = nil

    private var spriteVertexBuffer: MTLBuffer! = nil
    private var gridPositionsBuffer: MTLBuffer! = nil
    private var spriteInfoBuffer: MTLBuffer! = nil
    private var textCoordBuffer: MTLBuffer? = nil

    init (utils: RenderUtils, textureName: String, width: Int32, height: Int32) {
        renderUtils = utils
        self.textureName = textureName

        info = SpriteLayerInfo(
                gridWidth: width,
                gridHeight: height,
                numVertices: 0)
    }


    func addSprite(sprite: Sprite) {
        sprites.append(sprite)
        gridPositions.append(sprite.gridPosition())
        info.numVertices += renderUtils.numVerticesInARectangle()
    }

    // Must add all sprites and call update before loading assets.
    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState("spriteVertex", fragment: "spriteFragment", device: device, view: view)

        texture = renderUtils.loadTexture(device, name: textureName)

        spriteVertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "sprite layer vertices")
        gridPositionsBuffer = renderUtils.createBufferFromIntArray(device, count: gridPositions.count, bufferLabel: "grid positions")
        textCoordBuffer = renderUtils.createBufferFromIntArray(device, count: textureCoordinates!.count, bufferLabel: "text coords tiles")

        spriteInfoBuffer = device.newBufferWithBytes(&spriteInfoBuffer, length: sizeofValue(spriteInfoBuffer), options: [])
        spriteInfoBuffer.label = "sprite layer info"


        print("loading sprite layer assets done")

    }

    func update() {
        textureCoordinates = Array()
        for sprite in sprites {
            textureCoordinates! += sprite.update()
        }
        renderUtils.updateBufferFromIntArray(textCoordBuffer!, data: textureCoordinates!)
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "sprite layer")

        for (i, buffer) in [spriteVertexBuffer, gridPositionsBuffer, textCoordBuffer, spriteInfoBuffer].enumerate() {
            renderEncoder.setVertexBuffer(buffer, offset: 0, atIndex: i)
        }

        renderEncoder.setFragmentTexture(texture, atIndex: 0)

        renderUtils.drawPrimitives(renderEncoder, vertexCount: Int(info.numVertices))
    }

}
