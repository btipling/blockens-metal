//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct SpriteLayerInfo {
    let gridWidth: Int32
    let gridHeight: Int32
}

class SpriteLayerRenderer: Renderer {

    private var sprites: [Sprite] = Array()
    private var gridLocations: [Int32] = Array()
    private var info: SpriteLayerInfo! = nil

    private var texture: MTLTexture! = nil

    private var spriteVertexBuffer: MTLBuffer! = nil
    private var gridLocationsBuffer: MTLBuffer! = nil
    private var textCoordBuffer: MTLBuffer! = nil
    private var spriteInfoBuffer: MTLBuffer! = nil

    init (width: Int32, height: Int32) {
        info = SpriteLayerInfo(gridWidth: width, gridHeight: height)
    }

    func setTexture(newTexture: MTLTexture) {
        texture = newTexture
    }

    func addSprite(sprite: Sprite) {
        sprites.append(sprite)
        gridLocations.append(sprite.gridNumber())
    }

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
    }

    func update() {
        for sprite in sprites {
            sprite.update()
        }
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.endEncoding()
    }

}
