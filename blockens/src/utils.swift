//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import MetalKit


let MAX_TICK_MILLISECONDS = 300.0

let movementMap: [UInt16: Direction] = [
        123: Direction.Left,
        124: Direction.Right,
        125: Direction.Down,
        126: Direction.Up,
]

let S_KEY: UInt16 = 1
let P_KEY: UInt16 = 35

let DARK_GREEN = rgbaToNormalizedGPUColors(31, g: 60, b: 6)
let LIGHT_GREEN = rgbaToNormalizedGPUColors(159, g: 229, b: 88)
let YELLOW = rgbaToNormalizedGPUColors(251, g: 243, b: 131)
let ORANGE = rgbaToNormalizedGPUColors(236, g: 202, b: 0)
let ORANGE_BROWN = rgbaToNormalizedGPUColors(214, g: 158, b: 2)
let BLUE = rgbaToNormalizedGPUColors(2, g: 166, b: 214)

enum GameTile: Int32 {
    case HeadUp = 0, HeadDown, HeadLeft, HeadRight
    case TailUp, TailDown, TailLeft, TailRight
    case BodyHorizontal, BodyVertical
    case CornerUpLeft, CornerUpRight, CornerDownLeft, CornerDownRight
    case EmptyTile, GrowTile
}

struct GameTileInfo {
    var x: Int32
    var y: Int32
    var tile: GameTile
}

struct FrameInfo {
    let viewWidth: Int32
    let viewHeight: Int32
    let viewDiffRatio: Float32
}

enum GameStatus {
    case Stopped, Paused, Running
}

enum Direction {
    case Up, Down, Left, Right
}

protocol Renderer {
    func loadAssets(device: MTLDevice, view: MTKView, frameInfo: FrameInfo)
    func render(renderEncoder: MTLRenderCommandEncoder)
}
protocol RenderController {
    func renderer() -> Renderer
}

func rgbaToNormalizedGPUColors(r: Int, g: Int, b: Int, a: Int = 255) -> [Float32] {
    return [Float32(r)/255.0, Float32(g)/255.0, Float32(b)/255.0, Float32(a)/255.0]
}

func getRandomNum(n: Int32) -> Int32 {
    return Int32(arc4random_uniform(UInt32(n)))
}

func log_e(n: Double) -> Double {
    return log(n)/log(M_E)
}

func flipImage(image: NSImage) -> NSImage {
    var imageBounds = NSZeroRect
    imageBounds.size = image.size
    let transform = NSAffineTransform()
    transform.translateXBy(0.0, yBy: imageBounds.height)
    transform.scaleXBy(1, yBy: -1)
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
