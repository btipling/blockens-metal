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

private let textureData:[Float] = [
        0.0,  1.0,
        0.0,  0.0,
        1.0,  1.0,

        0.0,  0.0,
        1.0,  0.0,
        1.0,  1.0,
]

let maxSecondsUntilBGAnimation: Int32 = 18
let framesPerSecond: NSTimeInterval = 15.0
let framesOnFullWind: NSTimeInterval = 10.0
let secondsUntilNextFrame: NSTimeInterval = 1.0/framesPerSecond

enum WindDirection {
    case Forward, Backward, Stopped
}

func getSecondsUntilBGAnimation() -> NSTimeInterval {
    return NSTimeInterval(getRandomNum(maxSecondsUntilBGAnimation))
}

class BackgroundRenderer: Renderer {

    var pipelineState: MTLRenderPipelineState! = nil

    var backgroundVertexBuffer: MTLBuffer! = nil
    var tickBuffer: MTLBuffer! = nil
    var textureBuffer: MTLBuffer! = nil
    var textures: [MTLTexture!] = []
    var tickCount: Int32 = 0
    var currentFrame = 0
    var lastAnimationTime: NSTimeInterval = NSDate().timeIntervalSince1970
    var lastAnimationFrame: NSTimeInterval = 0
    var windDirection = WindDirection.Stopped
    var secondsUntilBGAnimation = getSecondsUntilBGAnimation()

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

    func loadTexture(device: MTLDevice, name: String) -> MTLTexture {
        var image = NSImage(named: name)!
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
        print("loading assets")
        for i in 1...5 {
            textures.append(loadTexture(device, name: "bg\(i)"))
        }
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

        tickBuffer = device.newBufferWithLength(ConstantBufferSize, options: [])
        tickBuffer.label = "background colors"

        let backgroundVertexSize = backgroundVertexData.count * sizeofValue(backgroundVertexData[0])
        backgroundVertexBuffer = device.newBufferWithBytes(backgroundVertexData, length:  backgroundVertexSize, options: [])
        backgroundVertexBuffer.label = "background vertices"

        let textBufferSize = textureData.count * sizeofValue(textureData[0])
        textureBuffer = device.newBufferWithBytes(textureData, length: textBufferSize, options: [])
        textureBuffer.label = "texture coords"
        print("loading assets done")
    }

    func blowWind() {
        let now = NSDate().timeIntervalSince1970
        if (windDirection == WindDirection.Stopped && now - lastAnimationTime > secondsUntilBGAnimation) {
            lastAnimationFrame = NSDate().timeIntervalSince1970
            windDirection = WindDirection.Forward
            updateTickCount()
        }
        if (windDirection != WindDirection.Stopped && now - lastAnimationFrame > secondsUntilNextFrame) {
            if (windDirection == WindDirection.Forward && tickCount < 4) {
                lastAnimationFrame = now
                tickCount += 1
                if (tickCount == 4) {
                    // Hang on to the full wind state for a little longer.
                    lastAnimationFrame += secondsUntilNextFrame * framesOnFullWind
                }
            } else {
                windDirection = WindDirection.Backward
                lastAnimationFrame = now
                tickCount -= 1
                if (tickCount == 0) {
                    lastAnimationTime = now
                    secondsUntilBGAnimation = getSecondsUntilBGAnimation()
                    windDirection = WindDirection.Stopped
                }
            }
            updateTickCount()
        }
    }

    func updateTickCount() {
        let pData = tickBuffer.contents()
        let vData = UnsafeMutablePointer<Int32>(pData)
        vData.initializeFrom(&tickCount, count: 1)
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {
        blowWind()

        renderEncoder.label = "background render encoder"
        renderEncoder.pushDebugGroup("draw background")

        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(tickBuffer, offset:0 , atIndex: 0)
        renderEncoder.setVertexBuffer(backgroundVertexBuffer, offset: 0, atIndex: 1)
        renderEncoder.setVertexBuffer(textureBuffer, offset:0 , atIndex: 2)
        for i in 0..<5 {
            renderEncoder.setFragmentTexture(textures[i], atIndex: i)
        }
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: backgroundVertexData.count, instanceCount: 1)

        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()
    }
}
