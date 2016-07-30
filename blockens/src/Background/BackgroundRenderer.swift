//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

private let ConstantBufferSize = 1024*1024

private let backgroundVertexData:[Float] = [
        -1.0, -1.0,
        -1.0,  1.0,
        1.0, -1.0,

        -1.0, 1.0,
        1.0,  1.0,
        1.0,  -1.0,
]

private let vertexColorData:[Float] = [
        1.0, 1.0, 1.0, 1.0,
]

private let textureData:[Float] = [
        0.0,  1.0,
        0.0,  0.0,
        1.0,  1.0,

        0.0,  0.0,
        1.0,  0.0,
        1.0,  1.0,
]


class BackgroundRenderer: Renderer {

    var pipelineState: MTLRenderPipelineState! = nil

    var backgroundVertexBuffer: MTLBuffer! = nil
    var backgroundColorBuffer: MTLBuffer! = nil
    var textureBuffer: MTLBuffer! = nil
    var texture: MTLTexture! = nil

    func flipImage(image: NSImage) -> NSImage {
        var imageBounds = NSZeroRect
        imageBounds.size = image.size
        let transform = NSAffineTransform()
        transform.translateXBy(0.0, yBy: imageBounds.height)
        transform.scaleXBy(1, yBy: -1)
        transform.concat()
        let flippedImage = NSImage(size: imageBounds.size)

        flippedImage.lockFocus()
        transform.concat()
        image.drawInRect(imageBounds, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeCopy, fraction: 1.0)
        flippedImage.unlockFocus()

        return flippedImage
    }

    func loadTextureRIP(device: MTLDevice) -> MTLTexture {
        var image = NSImage(named: "wall_texture")!
        image = flipImage(image)
        var imageRect:CGRect = CGRectMake(0, 0, image.size.width, image.size.height)
        let imageRef = image.CGImageForProposedRect(&imageRect, context: nil, hints: nil)!
        let textureLoader = MTKTextureLoader(device: device)
        var texture: MTLTexture? = nil
        do {
            texture = try textureLoader.newTextureWithCGImage(imageRef, options: .None)
        } catch {
            print("Got an error trying to texture \(error)")
        }
        return texture!
    }

    func loadAssets(device: MTLDevice, view: MTKView) {
        texture = loadTextureRIP(device)
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexProgram = defaultLibrary.newFunctionWithName("backgroundVertex")!
        let fragmentProgram = defaultLibrary.newFunctionWithName("backgroundFragment")!

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

        backgroundVertexBuffer = device.newBufferWithLength(ConstantBufferSize, options: [])
        backgroundVertexBuffer.label = "background vertices"

        let vertexColorSize = vertexColorData.count * sizeofValue(vertexColorData[0])
        backgroundColorBuffer = device.newBufferWithBytes(vertexColorData, length: vertexColorSize, options: [])
        backgroundColorBuffer.label = "background colors"

        let textBufferSize = textureData.count * sizeofValue(textureData[0])
        textureBuffer = device.newBufferWithBytes(textureData, length: textBufferSize, options: [])
        textureBuffer.label = "texture coords"
    }

    func update() {
        let pData = backgroundVertexBuffer.contents()
        let vData = UnsafeMutablePointer<Float>(pData + 256)
        vData.initializeFrom(backgroundVertexData)

    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        update()

        renderEncoder.label = "background render encoder"
        renderEncoder.pushDebugGroup("draw background")

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(backgroundVertexBuffer, offset: 256, atIndex: 0)
        renderEncoder.setVertexBuffer(backgroundColorBuffer, offset:0 , atIndex: 1)
        renderEncoder.setVertexBuffer(textureBuffer, offset:0 , atIndex: 2)
        renderEncoder.setFragmentTexture(texture, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: backgroundVertexData.count, instanceCount: 1)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }
}
