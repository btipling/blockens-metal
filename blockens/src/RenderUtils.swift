//
// Created by Bjorn Tipling on 8/7/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit

protocol Renderer {
    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo)
    func render(renderEncoder: MTLRenderCommandEncoder)
}

protocol RenderController {
    func renderer() -> Renderer
}


class RenderUtils {

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

    func createPipeLineState(vertex: String, fragment: String, device: MTLDevice, view: MTKView) -> MTLRenderPipelineState {
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexProgram = defaultLibrary.newFunctionWithName(vertex)!
        let fragmentProgram = defaultLibrary.newFunctionWithName(fragment)!

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.sampleCount = view.sampleCount

        var pipelineState: MTLRenderPipelineState! = nil
        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }

        return pipelineState
    }

    func setPipeLineState(renderEncoder: MTLRenderCommandEncoder, pipelineState: MTLRenderPipelineState, name: String) {

        renderEncoder.label = "\(name) render encoder"
        renderEncoder.pushDebugGroup("draw \(name)")
        renderEncoder.setRenderPipelineState(pipelineState)

    }

    func drawPrimitives(renderEncoder: MTLRenderCommandEncoder, vertexCount: Int) {

        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
        renderEncoder.popDebugGroup()
        renderEncoder.endEncoding()

    }
}
