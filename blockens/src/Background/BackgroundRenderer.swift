//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

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

struct BGInfo {
    var tickCount: Int32
    var viewDiffRatio : Float32
}

class BackgroundRenderer: Renderer {

    let renderUtils: RenderUtils

    var pipelineState: MTLRenderPipelineState! = nil

    var backgroundVertexBuffer: MTLBuffer! = nil
    var bgDataBuffer: MTLBuffer! = nil
    var textureBuffer: MTLBuffer! = nil
    var textures: [MTLTexture!] = []
    var bgInfoData = BGInfo(tickCount: 0, viewDiffRatio : 0.0)
    var currentFrame = 0
    var lastAnimationTime: NSTimeInterval = NSDate().timeIntervalSince1970
    var lastAnimationFrame: NSTimeInterval = 0
    var windDirection = WindDirection.Stopped
    var secondsUntilBGAnimation = getSecondsUntilBGAnimation()

    init (utils: RenderUtils) {
        renderUtils = utils
    }

    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo) {
        for i in 1...5 {
            textures.append(renderUtils.loadTexture(device, name: "bg\(i)"))
        }
        bgInfoData.viewDiffRatio = frameInfo.viewDiffRatio

        pipelineState = renderUtils.createPipeLineState("backgroundVertex", fragment: "backgroundFragment", device: device, view: view)

        bgDataBuffer = device.newBufferWithLength(CONSTANT_BUFFER_SIZE, options: [])
        bgDataBuffer.label = "background colors"

        let backgroundVertexSize = backgroundVertexData.count * sizeofValue(backgroundVertexData[0])
        backgroundVertexBuffer = device.newBufferWithBytes(backgroundVertexData, length:  backgroundVertexSize, options: [])
        backgroundVertexBuffer.label = "background vertices"

        let textBufferSize = textureData.count * sizeofValue(textureData[0])
        textureBuffer = device.newBufferWithBytes(textureData, length: textBufferSize, options: [])
        textureBuffer.label = "bg texture coords"
        updateTickCount()
        print("loading bg assets done")
    }

    func blowWind() {
        let now = NSDate().timeIntervalSince1970
        if (windDirection == WindDirection.Stopped && now - lastAnimationTime > secondsUntilBGAnimation) {
            lastAnimationFrame = NSDate().timeIntervalSince1970
            windDirection = WindDirection.Forward
            updateTickCount()
        }
        if (windDirection != WindDirection.Stopped && now - lastAnimationFrame > secondsUntilNextFrame) {
            if (windDirection == WindDirection.Forward && bgInfoData.tickCount < 4) {
                lastAnimationFrame = now
                bgInfoData.tickCount += 1
                if (bgInfoData.tickCount == 4) {
                    // Hang on to the full wind state for a little longer.
                    lastAnimationFrame += secondsUntilNextFrame * framesOnFullWind
                }
            } else {
                windDirection = WindDirection.Backward
                lastAnimationFrame = now
                bgInfoData.tickCount -= 1
                if (bgInfoData.tickCount == 0) {
                    lastAnimationTime = now
                    secondsUntilBGAnimation = getSecondsUntilBGAnimation()
                    windDirection = WindDirection.Stopped
                }
            }
            updateTickCount()
        }
    }

    func updateTickCount() {
        let pData = bgDataBuffer.contents()
        let vData = UnsafeMutablePointer<BGInfo>(pData)
        vData.initializeFrom(&bgInfoData, count: 1)
    }

    func render(renderEncoder: MTLRenderCommandEncoder) {

        blowWind()
        renderUtils.setPipeLineState(renderEncoder, pipelineState: pipelineState, name: "background")

        for (i, vertexBuffer) in [bgDataBuffer, backgroundVertexBuffer, textureBuffer].enumerate() {
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: i)
        }

        for i in 0..<5 {
            renderEncoder.setFragmentTexture(textures[i], atIndex: i)
        }

        renderUtils.drawPrimitives(renderEncoder, vertexCount: backgroundVertexData.count)
    }
}
