//
// Created by Bjorn Tipling on 8/8/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

struct SpriteLayerInfo {
    var gridWidth: Int32
    var gridHeight: Int32
    var textureWidth: Int32
    var textureHeight: Int32
    var viewDiffRatio : Float32
    var numVertices: Int32
}

class SpriteLayerRenderer: Renderer {

    let renderUtils: RenderUtils

    var timer: Timer?
    var interval: TimeInterval = 1.0/SPRITE_ANIMATION_FPS;

    fileprivate var sprites: [Sprite] = Array()
    fileprivate var gridPositions: [Int32] = Array()
    var info: SpriteLayerInfo! = nil
    fileprivate var spriteCoordinates: [Float32]? = Array()

    var pipelineState: MTLRenderPipelineState! = nil

    fileprivate let textureName: String
    fileprivate var texture: MTLTexture! = nil

    fileprivate var spriteVertexBuffer: MTLBuffer! = nil
    fileprivate var gridPositionsBuffer: MTLBuffer! = nil
    fileprivate var spriteInfoBuffer: MTLBuffer! = nil
    fileprivate var textCoordBuffer: MTLBuffer! = nil
    fileprivate var spriteCoordBuffer: MTLBuffer? = nil

    init (utils: RenderUtils, setup: SpriteLayerSetup) {
        renderUtils = utils
        self.textureName = setup.textureName

        info = SpriteLayerInfo(
                gridWidth: setup.width,
                gridHeight: setup.height,
                textureWidth: setup.textureWidth,
                textureHeight: setup.textureHeight,
                viewDiffRatio: setup.viewDiffRatio,
                numVertices: 0)
    }


    func scheduleTick() {
        if timer?.isValid ?? false {
            // If timer isn't nil and is valid don't start a new one.
            return
        }
        timer = Timer.scheduledTimer(timeInterval: interval, target: self,
                selector: #selector(SpriteLayerRenderer.tick), userInfo: nil, repeats: false)
    }

    @objc func tick() {
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        update()
        scheduleTick()
    }

    func genGridPosition() throws -> Int32 {
        let range = info.gridWidth * info.gridHeight;
        if Int32(gridPositions.count) >= range {
            throw BlockensError.runtimeError("No more sprite positions available.")
        }
        var pos: Int32
        repeat {
            pos = getRandomNum(range)
        } while (gridPositions.contains(pos))
        return pos
    }

    func addSprite(_ sprite: Sprite) {
        sprites.append(sprite)
        sprite.setGridPosition(try! genGridPosition())
        gridPositions.append(sprite.gridPosition())
        info.numVertices += renderUtils.numVerticesInARectangle()
    }

    // Must add all sprites and call update before loading assets.
    func loadAssets(_ device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {

        pipelineState = renderUtils.createPipeLineState("spriteVertex", fragment: "spriteFragment", device: device, view: view)

        texture = renderUtils.loadTexture(device, name: textureName)

        let maxNumSprites = Int(info.gridWidth * info.gridHeight)

        spriteVertexBuffer = renderUtils.createRectangleVertexBuffer(device, bufferLabel: "sprite layer vertices")
        gridPositionsBuffer = renderUtils.createBufferFromIntArray(device, count: maxNumSprites, bufferLabel: "grid positions")
        spriteCoordBuffer = renderUtils.createBufferFromFloatArray(device, count: spriteCoordinates!.count, bufferLabel: "sprite coordinates")

        textCoordBuffer = renderUtils.createBufferFromFloatArray(device, count: renderUtils.numVerticesInARectangle(), bufferLabel: "text coords tiles")
        renderUtils.updateBufferFromFloatArray(textCoordBuffer, data: renderUtils.rectangleTextureCoords)

        spriteInfoBuffer = device.makeBuffer(bytes: &info, length: MemoryLayout.size(ofValue: info), options: [])

        let contents = spriteInfoBuffer.contents()
        let pointer = UnsafeMutablePointer<SpriteLayerInfo>(contents)
        pointer.initialize(from:&info!, count: 1)

        print("loading sprite layer assets done")

        updateSprites()
        tick()
    }

    func updateSprites() {
        if gridPositionsBuffer != nil {
            renderUtils.updateBufferFromIntArray(gridPositionsBuffer, data: gridPositions)
        }
    }

    func clear() {
        sprites.removeAll(keepingCapacity: true)
        gridPositions.removeAll(keepingCapacity: true)
        updateSprites()
        update()
    }

    func update() {

        spriteCoordinates = Array()
        for sprite in sprites {
            spriteCoordinates! += sprite.update()
        }
        if spriteCoordBuffer != nil {
            renderUtils.updateBufferFromFloatArray(spriteCoordBuffer!, data: spriteCoordinates!)
        }
    }

    func render(_ renderEncoder: MTLRenderCommandEncoder) {

        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "sprite layer")

    for (i, buffer) in [spriteVertexBuffer, gridPositionsBuffer, spriteCoordBuffer!, textCoordBuffer, spriteInfoBuffer].enumerated() {
            renderEncoder.setVertexBuffer(buffer, offset: 0, at: i)
        }

        renderEncoder.setFragmentTexture(texture, at: 0)

        renderUtils.drawPrimitives(renderEncoder, vertexCount: Int(info.numVertices))
    }

}
