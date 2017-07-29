//
//  GameViewController.swift
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

import Cocoa
import MetalKit

class GameViewController: NSViewController, MTKViewDelegate {

    var device: MTLDevice! = nil

    var commandQueue: MTLCommandQueue! = nil

    let inflightSemaphore = DispatchSemaphore(value: 1)
    var currentTickWait = MAX_TICK_MILLISECONDS

    var timer: Timer?
    var gameStatus: GameStatus = GameStatus.running

    let snake: SnakeController = SnakeController()
    var backgroundSpriteLayer: SpriteLayerController! = nil
    let score = Score()
    let stars = StarsController()
    var renderers: [Renderer] = Array()

    override func viewDidLoad() {

        super.viewDidLoad()

        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let gameWindow = appDelegate.getWindow()
        gameWindow.addKeyEventCallback(handleKeyEvent)

        device = MTLCreateSystemDefaultDevice()
        guard device != nil else { // Fallback to a blank NSView, an application could also fallback to OpenGL here.
            print("Metal is not supported on this device")
            self.view = NSView(frame: self.view.frame)
            return
        }

        // Setup view properties.
        let view = self.view as! MTKView
        view.delegate = self
        view.device = device
        view.sampleCount = 4


        let frameInfo = setupFrameInfo(view)

        setupBackgroundSpriteLayer(frameInfo)

        // Add render controllers, order matters.
        let renderControllers: [RenderController] = [
                BackgroundController(),
                stars,
                SkyController(),
                backgroundSpriteLayer,
                score,
                snake,
        ]

        for renderController in renderControllers {
            renderers.append(renderController.renderer())
        }
        loadAssets(view, frameInfo: frameInfo)
        resetGame()
    }

    func setupFrameInfo(_ view: MTKView) -> FrameInfo {
        let frame = view.frame
        let width = frame.size.width
        let height = frame.size.height
        let maxDimension = max(width, height)
        let sizeDiff = abs(width - height)
        let ratio: Float = Float(sizeDiff)/Float(maxDimension)

        return FrameInfo(viewWidth: Int32(width), viewHeight: Int32(height), viewDiffRatio: ratio)
    }

    func setupBackgroundSpriteLayer(_ frameInfo: FrameInfo) {

        backgroundSpriteLayer = SpriteLayerController(setup: SpriteLayerSetup(
                textureName: "bg_sprites",
                width: 13,
                height: 13,
                textureWidth: 5,
                textureHeight: 3,
                viewDiffRatio: frameInfo.viewDiffRatio))
    }

    func getBackgroundSprite() -> Sprite {
        switch getRandomNum(100) {
            case 1...10:
                return Bush()
            case 11...25:
                return Crater()
            case 26...50:
                return Rocks()
            default:
                return Grass()
        }
    }

    func resetBackgroundSprites() {
        let renderer = backgroundSpriteLayer.renderer() as! SpriteLayerRenderer
        renderer.clear()
        for _ in 0..<NUM_BACKGROUND_SPRITES {
            renderer.addSprite(getBackgroundSprite())
        }
        renderer.updateSprites()
    }

    func loadAssets(_ view: MTKView, frameInfo: FrameInfo) {
        commandQueue = device.makeCommandQueue()
        commandQueue.label = "main command queue"

        for renderer in renderers {
            renderer.loadAssets(device, view: view, frameInfo: frameInfo)
        }
    }

    func resetGame() {
        resetBackgroundSprites()
        score.reset()
        gameStatus = GameStatus.running
        currentTickWait = MAX_TICK_MILLISECONDS
        snake.reset()
        stars.reset()
        scheduleTick()
    }

    func handleKeyEvent(_ event: NSEvent) {
        if Array(movementMap.keys).contains(event.keyCode) {
            let newDirection = movementMap[event.keyCode]!
            switch (newDirection) {
                case Direction.down:
                    if snake.oneEighty(Direction.up) {
                        return
                    }
                    break
                case Direction.up:
                    if snake.oneEighty(Direction.down) {
                        return
                    }
                    break
                case Direction.left:
                    if snake.oneEighty(Direction.right) {
                        return
                    }
                    break
                case Direction.right:
                    if snake.oneEighty(Direction.left) {
                        return
                    }
                    break
            }
            snake.setDirection(newDirection)
            tick()
            return
        }

        switch event.keyCode {
            case S_KEY:
                switch gameStatus {
                    case GameStatus.running:
                        break
                    case GameStatus.stopped:
                        resetGame()
                        break
                    default:
                        gameStatus = GameStatus.running
                        scheduleTick()
                        break
                }
                break
            case P_KEY:
                gameStatus = GameStatus.paused
                break
            case N_KEY:
                resetGame()
                break
            default:
                // Unhandled key code.
                break
        }

    }

    func scheduleTick() {
        if gameStatus != GameStatus.running {
            return
        }
        if timer?.isValid ?? false {
            // If timer isn't nil and is valid don't start a new one.
            return
        }
        timer = Timer.scheduledTimer(timeInterval: Double(currentTickWait) / 1000.0, target: self,
                selector: #selector(GameViewController.tick), userInfo: nil, repeats: false)
    }


    func tick() {
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        if gameStatus != GameStatus.running {
            return
        }
        if (snake.eatFoodIfOnFood()) {
            score.eat()
            currentTickWait -= log_e(currentTickWait)
        } else {
            score.move()
        }
        if !snake.move() {
            print("Collision")
            gameStatus = GameStatus.stopped
            return
        }
        scheduleTick()
    }

    func draw(in view: MTKView) {
        inflightSemaphore.wait(timeout: DispatchTime.distantFuture)

        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.label = "Frame command buffer"

        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                strongSelf.inflightSemaphore.signal()
            }
            return
        }

        if let renderPassDescriptor = view.currentRenderPassDescriptor, let currentDrawable = view.currentDrawable {

            let parallelCommandEncoder = commandBuffer.makeParallelRenderCommandEncoder(descriptor: renderPassDescriptor)

            for renderer in renderers {
                renderer.render(parallelCommandEncoder.makeRenderCommandEncoder())
            }

            parallelCommandEncoder.endEncoding()
            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Pass through and do nothing.
    }
}
