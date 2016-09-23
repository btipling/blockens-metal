//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation
import Cocoa

let MAX_TICK_MILLISECONDS = 300.0
let SPRITE_ANIMATION_FPS = 60.0;
let NUM_BACKGROUND_SPRITES = 75;
let ANIMATION_PAUSE_RANGE = 10000;
let MAX_STARS: Int32 = 100;
let MIN_STARS: Int32 = 20;
let MAX_STAR_SIZE: Int32 = 15;
let MIN_STAR_SIZE: Int32 = 5;

let movementMap: [UInt16: Direction] = [
        123: Direction.Left,
        124: Direction.Right,
        125: Direction.Down,
        126: Direction.Up,
]

let S_KEY: UInt16 = 1
let P_KEY: UInt16 = 35
let N_KEY: UInt16 = 45

// Colors from http://www.colourlovers.com/palette/689633/Light_of_the_Angels
let ANGEL_PROTECTION = rgbaToNormalizedGPUColors(254, g: 236, b: 174)
let ANGEL_GLOW = rgbaToNormalizedGPUColors(255, g: 244, b: 194)
let HEAVEN_LIGHTS = rgbaToNormalizedGPUColors(255, g: 247, b: 219)
let ANGEL_WHITE = rgbaToNormalizedGPUColors(255, g: 252, b: 246)
let WHITE = rgbaToNormalizedGPUColors(255, g: 255, b: 255)

enum GameTile: Int32 {
    case HeadUp = 0, HeadDown, HeadLeft, HeadRight
    case TailUp, TailDown, TailLeft, TailRight
    case BodyHorizontal, BodyVertical
    case CornerUpLeft, CornerUpRight, CornerDownLeft, CornerDownRight
    case EmptyTile, GrowTile
}

enum BlockensError: ErrorType {
    case RuntimeError(String)
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
    image.drawInRect(imageBounds, fromRect: NSZeroRect, operation: NSCompositingOperation.Copy, fraction: 1.0)
    flippedImage.unlockFocus()

    return flippedImage
}

func newStartFrame() -> Int {
    return Int(getRandomNum(Int32(ANIMATION_PAUSE_RANGE)) * -1)
}

func updateSpriteFrames(frames: [Float32], currentTextCoords: [Float32], currentFrame: Int) -> ([Float32], Int) {
    var frame = currentFrame
    var textCoords = currentTextCoords
    frame += 1
    if frame > 0 {
        if frame >= frames.count {
            frame = newStartFrame()
            textCoords[0] = 0.0
            return (textCoords, frame)
        }

        textCoords[0] = frames[frame]
    }
    return (textCoords, frame)
}

func setupFrames(spriteFrames: [SpriteFrame]) -> [Float32] {
    var frames: [Float32] = Array()
    for spriteFrame in spriteFrames {
        var frameCount = spriteFrame.frameCount
        while (frameCount > 0) {
            frames.append(spriteFrame.spritePosition)
            frameCount -= 1
        }
    }
    return frames
}
