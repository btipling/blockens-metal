//
//  GameViewController.swift
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

import Cocoa
import MetalKit

let ConstantBufferSize = 1024*1024

let vertexData:[Float] = [
    -1.0, -1.0,
    -1.0,  1.0,
    1.0, -1.0,

    1.0, -1.0,
    -1.0,  1.0,
    1.0,  1.0,
]

let vertexColorData:[Float] = [
    0.0, 0.0, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0,
    0.0, 1.0, 0.0, 1.0,
]

class GameViewController: NSViewController, MTKViewDelegate {
    
    var device: MTLDevice! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil

    var vertexBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var gridInfoBuffer: MTLBuffer! = nil
    var gameTilesBuffer: MTLBuffer! = nil
    var boxTilesBuffer: MTLBuffer! = nil
    
    let inflightSemaphore = dispatch_semaphore_create(1)
    var currentTickWait = MAX_TICK_MILLISECONDS

    var timer: NSTimer?
    var gameStatus: GameStatus = GameStatus.Running
    var vertexCount = 0

    let snake: Snake = Snake(data: gridInfoData)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
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
        resetGame()
        loadAssets()
    }

    func resetGame() {
        currentTickWait = MAX_TICK_MILLISECONDS
        snake.reset()
        scheduleTick()
    }

    func handleKeyEvent(event: NSEvent) {
        if Array(movementMap.keys).contains(event.keyCode) {
            let newDirection = movementMap[event.keyCode]!
            switch (newDirection) {
                case Direction.Down:
                    if snake.oneEighty(Direction.Up) {
                        return
                    }
                    break
                case Direction.Up:
                    if snake.oneEighty(Direction.Down) {
                        return
                    }
                    break
                case Direction.Left:
                    if snake.oneEighty(Direction.Right) {
                        return
                    }
                    break
                case Direction.Right:
                    if snake.oneEighty(Direction.Left) {
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
                    case GameStatus.Running:
                        break
                    case GameStatus.Stopped:
                        resetGame()
                        break
                    default:
                        gameStatus = GameStatus.Running
                        scheduleTick()
                        break
                }
                break
            case P_KEY:
                gameStatus = GameStatus.Paused
                break
            default:
                // Unhandled key code.
                break
        }

    }

    func scheduleTick() {
        if gameStatus != GameStatus.Running {
            return
        }
        if timer?.valid ?? false {
            // If timer isn't nil and is valid don't start a new one.
            return
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(currentTickWait) / 1000.0, target: self,
                selector: #selector(GameViewController.tick), userInfo: nil, repeats: false)
    }


    func updateGameTiles() {
        snake.update()
        vertexCount = snake.vertexCount()
    }


    func tick() {
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        if gameStatus != GameStatus.Running {
            return
        }
        if (snake.eatFoodIfOnFood()) {
            currentTickWait -= log_e(currentTickWait)
        }
        if !snake.move() {
            print("Collision")
            gameStatus = GameStatus.Stopped
            return
        }
        scheduleTick()
    }

    func loadAssets() {
        
        // Load any resources required for rendering.
        let view = self.view as! MTKView
        commandQueue = device.newCommandQueue()
        commandQueue.label = "main command queue"
        
        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.newFunctionWithName("passThroughFragment")!
        let vertexProgram = defaultLibrary.newFunctionWithName("passThroughVertex")!
        
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

        // Generate a large enough buffer to allow streaming vertices for 3 semaphore controlled frames.
        vertexBuffer = device.newBufferWithLength(ConstantBufferSize, options: [])
        vertexBuffer.label = "vertices"

        let vertexColorSize = vertexColorData.count * sizeofValue(vertexColorData[0])
        vertexColorBuffer = device.newBufferWithBytes(vertexColorData, length: vertexColorSize, options: [])
        vertexColorBuffer.label = "colors"

        let gridInfoBufferSize = sizeofValue(gridInfoData)
        gridInfoBuffer = device.newBufferWithBytes(&gridInfoData, length: gridInfoBufferSize, options: [])
        gridInfoBuffer.label = "gridInfo"

        let gameTileBufferSize = sizeofValue(snake.gameTiles())
        gameTilesBuffer = device.newBufferWithLength(gameTileBufferSize, options: [])
        gameTilesBuffer.label = "gameTiles"

        let boxTileBufferSize = sizeofValue(snake.boxTiles())
        boxTilesBuffer = device.newBufferWithLength(boxTileBufferSize, options: [])
        boxTilesBuffer.label = "boxTiles"


    }
    
    func update() {
        // vData is pointer to the MTLBuffer's Float data contents.
        let pData = vertexBuffer.contents()
        let vData = UnsafeMutablePointer<Float>(pData + 256)
        vData.initializeFrom(vertexData)

        let gData = gridInfoBuffer.contents()
        let gvData = UnsafeMutablePointer<GridInfo>(gData + 0)
        gvData.initializeFrom(&gridInfoData, count: 1)

        updateGameTiles()
        let tData = gameTilesBuffer.contents()
        let tvData = UnsafeMutablePointer<Int32>(tData + 0)
        tvData.initializeFrom(snake.gameTiles())

        let bData = boxTilesBuffer.contents()
        let bvData = UnsafeMutablePointer<Int32>(bData + 0)
        bvData.initializeFrom(snake.boxTiles())
    }
    
    func drawInMTKView(view: MTKView) {
        
        // Use semaphore to encode 3 frames ahead.
        dispatch_semaphore_wait(inflightSemaphore, DISPATCH_TIME_FOREVER)
        
        self.update()
        
        let commandBuffer = commandQueue.commandBuffer()
        commandBuffer.label = "Frame command buffer"
        
        // Use completion handler to signal the semaphore when this frame is completed allowing the encoding of the next frame to proceed.
        // Use capture list to avoid any retain cycles if the command buffer gets retained anywhere besides this stack frame.
        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                dispatch_semaphore_signal(strongSelf.inflightSemaphore)
            }
            return
        }
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor, currentDrawable = view.currentDrawable
        {
            let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
            renderEncoder.label = "render encoder"
            
            renderEncoder.pushDebugGroup("draw morphing triangle")
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 256, atIndex: 0)
            renderEncoder.setVertexBuffer(vertexColorBuffer, offset:0 , atIndex: 1)
            renderEncoder.setVertexBuffer(gridInfoBuffer, offset:0 , atIndex: 2)
            renderEncoder.setVertexBuffer(gameTilesBuffer, offset:0 , atIndex: 3)
            renderEncoder.setVertexBuffer(boxTilesBuffer, offset:0 , atIndex: 4)
            renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
            
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
                
            commandBuffer.presentDrawable(currentDrawable)
        }
        commandBuffer.commit()
    }

    func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
        // Pass through and do nothing.
    }
}
