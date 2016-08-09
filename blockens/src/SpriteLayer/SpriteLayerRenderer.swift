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
    private var gridLocations: [Int32] = Array()
    private var info: SpriteLayerInfo! = nil
    private var textureCoordinates: [Int32]? = nil

    var pipelineState: MTLRenderPipelineState! = nil

    private var texture: MTLTexture! = nil

    private var spriteVertexBuffer: MTLBuffer! = nil
    private var gridLocationsBuffer: MTLBuffer! = nil
    private var spriteInfoBuffer: MTLBuffer! = nil
    private var textCoordBuffer: MTLBuffer? = nil

    init (utils: RenderUtils, width: Int32, height: Int32) {
        renderUtils = utils

        info = SpriteLayerInfo(
                gridWidth: width,
                gridHeight: height,
                numVertices: 0)
    }

    func setTexture(newTexture: MTLTexture) {
        texture = newTexture
    }

    func addSprite(sprite: Sprite) {
        sprites.append(sprite)
        gridLocations.append(sprite.gridNumber())
        info.numVertices += renderUtils.numVerticesInARectangle()
    }

    // Must add all sprites and call update before loading assets.
    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        pipelineState = renderUtils.createPipeLineState("spriteVertex", fragment: "spriteFragment", device: device, view: view)

        spriteVertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "sprite layer vertices")
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

        for (i, buffer) in [spriteVertexBuffer, textCoordBuffer, spriteInfoBuffer].enumerate() {
            renderEncoder.setVertexBuffer(buffer, offset: 0, atIndex: i)
        }

        renderEncoder.setFragmentTexture(texture, atIndex: 0)

        renderUtils.drawPrimitives(renderEncoder, vertexCount: Int(info.numVertices))
    }

}
