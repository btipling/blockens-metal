//
//  GameViewController.swift
//  blockens
//
//  Created by Bjorn Tipling on 7/22/16.
//  Copyright (c) 2016 apphacker. All rights reserved.
//

import Cocoa
import MetalKit

let MaxBuffers = 3

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


struct GridInfo {
    var gridDimension: Int32
    var gridOffset: Float32
    var numBoxes: Int32
    var numVertices: Int32
    var numColors: Int32
}

var gridDimension: Int32 = 25
var gridInfoData = GridInfo(
        gridDimension: gridDimension,
        gridOffset: 2.0/Float32(gridDimension),
        numBoxes: Int32(pow(Float(gridDimension), 2.0)),
        numVertices: Int32(vertexData.count/2),
        numColors: Int32(vertexColorData.count/4))

let MAX_TICK_MILLISECONDS = 300.0

enum Direction {
    case Up, Down, Left, Right
}

let movementMap: [UInt16: Direction] = [
    123: Direction.Left,
    124: Direction.Right,
    125: Direction.Down,
    126: Direction.Up,
]

let S_KEY: UInt16 = 1
let P_KEY: UInt16 = 35

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

enum GameStatus {
    case Stopped, Paused, Running
}

class GameViewController: NSViewController, MTKViewDelegate {
    
    var device: MTLDevice! = nil
    
    var commandQueue: MTLCommandQueue! = nil
    var pipelineState: MTLRenderPipelineState! = nil

    var vertexBuffer: MTLBuffer! = nil
    var vertexColorBuffer: MTLBuffer! = nil
    var gridInfoBuffer: MTLBuffer! = nil
    var gameTilesBuffer: MTLBuffer! = nil
    var boxTilesBuffer: MTLBuffer! = nil
    
    let inflightSemaphore = dispatch_semaphore_create(MaxBuffers)
    var bufferIndex = 0
    var currentTickWait = MAX_TICK_MILLISECONDS
    var currentDirection: Direction = Direction.Right

    var gameTiles: Array<Int32> = []
    var boxTiles: Array<Int32> = []

    var snakeTiles: Array<GameTileInfo> = []
    var timer: NSTimer?
    var foodBoxLocation: Int32 = 0
    var gameStatus: GameStatus = GameStatus.Running
    var vertexCount = 0

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
        currentDirection = Direction.Right

        let newSpot = getRandomBox()
        let x = Int32(newSpot % gridInfoData.gridDimension)
        let y = Int32(newSpot / gridInfoData.gridDimension)
        snakeTiles = [GameTileInfo(x: x, y: y, tile: GameTile.HeadRight)]

        findFood()

        gameStatus = GameStatus.Running
        scheduleTick()
    }

    func handleKeyEvent(event: NSEvent) {
        if Array(movementMap.keys).contains(event.keyCode) {
            let newDirection = movementMap[event.keyCode]!
            switch (newDirection) {
                case Direction.Down:
                    if oneEighty(Direction.Up) {
                        return
                    }
                    break
                case Direction.Up:
                    if oneEighty(Direction.Down) {
                        return
                    }
                    break
                case Direction.Left:
                    if oneEighty(Direction.Right) {
                        return
                    }
                    break
                case Direction.Right:

                    if oneEighty(Direction.Left) {
                        return
                    }
                    break
                default:
                    // Just keep going. I don't know what this is.
                    break
            }
            currentDirection = newDirection
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

    func getRandomBox() -> Int32 {
        return Int32(arc4random_uniform(UInt32(gridInfoData.numBoxes)))
    }

    func findFood() {
        var tries = 1000
        let snakeTilePositions = mapSnakeTiles()
        repeat {
            foodBoxLocation = getRandomBox()
            tries -= 1
        } while (tries > 0 && snakeTilePositions[foodBoxLocation] != nil)
        if tries == 0 {
            // Couldn't find a place to put food in 1k tries.
            gameStatus = GameStatus.Stopped
        }
    }

    func mapSnakeTiles(start: Int = 0) -> [Int32: GameTileInfo] {

        var snakeTilePosition: [Int32: GameTileInfo] = [:]

        if (start >= snakeTiles.count) {
            return snakeTilePosition
        }

        let range = start + ((snakeTiles.count - start) - 1)
        for snakeTile in snakeTiles[start...range] {
            let numBox = snakeTile.y * gridInfoData.gridDimension + snakeTile.x;
            snakeTilePosition[numBox] = snakeTile
        }

        return snakeTilePosition
    }

    func moveSnakeBody() {

        if gameStatus != GameStatus.Running {
                return
        }

        var newSnakeTiles: [GameTileInfo] = []
        var prevX: Int32 = -1
        var prevY: Int32 = -1
        var curX: Int32 = -1
        var curY: Int32 = -1
        for snakeTile in snakeTiles {
            var newSnakeTile = snakeTile
            if prevX == -1 && prevY == -1 {
                prevX = snakeTile.x
                prevY = snakeTile.y
                newSnakeTiles.append(snakeTile)
                continue // First snake tile, all done.
            }
            if prevX == snakeTile.x && prevY == snakeTile.y {
                // We just grew.
                moveHead()
                return
            }
            curX = prevX
            curY = prevY
            prevX = snakeTile.x
            prevY = snakeTile.y
            newSnakeTile.x = curX
            newSnakeTile.y = curY
            newSnakeTiles.append(newSnakeTile)
        }
        snakeTiles = newSnakeTiles
        moveHead()
    }

    func updateGameTiles() {
        let snakeTilePosition = mapSnakeTiles()
        gameTiles = []
        boxTiles = []
        for (boxNum, tileInfo) in snakeTilePosition {
            gameTiles.append(tileInfo.tile.rawValue)
            boxTiles.append(boxNum)
        }
        if snakeTilePosition[foodBoxLocation] == nil {
            gameTiles.append(GameTile.GrowTile.rawValue)
            boxTiles.append(foodBoxLocation)
        }
        vertexCount = gameTiles.count * Int(gridInfoData.numVertices)
    }

    func moveHead() {
        switch (currentDirection) {
            case Direction.Down:
                moveDown()
                break
            case Direction.Up:
                moveUp()
                break
            case Direction.Left:
                moveLeft()
                break
            case Direction.Right:
                moveRight()
                break
        }
        var snakeMap = mapSnakeTiles(1)
        let snakeHead = snakeTiles[0]
        let currentBoxNum = snakeHead.y * gridInfoData.gridDimension + snakeHead.x
        if snakeMap[currentBoxNum] != nil {
            print("Collision")
            gameStatus = GameStatus.Stopped
        }
    }

    func tick() {
        if let currentTimer = timer {
            currentTimer.invalidate()
        }
        eatFoodIfOnFood()
        moveSnakeBody()
        scheduleTick()
    }

    func log_e(n: Double) -> Double {
        return log(n)/log(M_E)
    }

    func eatFoodIfOnFood() {
        let snakeTile = snakeTiles[0]
        let numBox = snakeTile.y * gridInfoData.gridDimension + snakeTile.x;
        if numBox == foodBoxLocation {
            snakeTiles.append(GameTileInfo(x: snakeTile.x, y: snakeTile.y, tile: GameTile.HeadRight))
            currentTickWait -= log_e(currentTickWait)
            findFood()
        }
    }

    func oneEighty(oppositeDirection: Direction) -> Bool {

        if snakeTiles.count > 1 && oppositeDirection == currentDirection {
            // It's a 180.
            return true
        }

        return false
    }

    func moveDown() {

        var snakeHead = snakeTiles[0]
        var y = snakeHead.y

        y -= 1
        if y < 0 {
            y = gridInfoData.gridDimension - 1
        }
        snakeHead.tile = GameTile.HeadDown
        snakeHead.y = y
        snakeTiles[0] = snakeHead
    }

    func moveUp() {

        var snakeHead = snakeTiles[0]
        var y = snakeHead.y

        y += 1
        if y >= gridInfoData.gridDimension {
            y = 0
        }
        snakeHead.tile = GameTile.HeadUp
        snakeHead.y = y
        snakeTiles[0] = snakeHead
    }

    func moveLeft() {

        var snakeHead = snakeTiles[0]
        var x = snakeHead.x

        x -= 1
        if x < 0 {
            x = gridInfoData.gridDimension - 1
        }
        snakeHead.tile = GameTile.HeadLeft
        snakeHead.x = x
        snakeTiles[0] = snakeHead
    }

    func moveRight() {

        var snakeHead = snakeTiles[0]
        var x = snakeHead.x
        
        x += 1
        if x >= gridInfoData.gridDimension {
            x = 0
        }
        snakeHead.tile = GameTile.HeadRight
        snakeHead.x = x
        snakeTiles[0] = snakeHead
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

        let gameTileBufferSize = sizeofValue(gameTiles)
        gameTilesBuffer = device.newBufferWithLength(gameTileBufferSize, options: [])
        gameTilesBuffer.label = "gameTiles"

        let boxTileBufferSize = sizeofValue(boxTiles)
        boxTilesBuffer = device.newBufferWithLength(boxTileBufferSize, options: [])
        boxTilesBuffer.label = "boxTiles"


    }
    
    func update() {
        // vData is pointer to the MTLBuffer's Float data contents.
        let pData = vertexBuffer.contents()
        let vData = UnsafeMutablePointer<Float>(pData + 256*bufferIndex)
        vData.initializeFrom(vertexData)

        let gData = gridInfoBuffer.contents()
        let gvData = UnsafeMutablePointer<GridInfo>(gData + 0)
        gvData.initializeFrom(&gridInfoData, count: 1)

        updateGameTiles()
        let tData = gameTilesBuffer.contents()
        let tvData = UnsafeMutablePointer<Int32>(tData + 0)
        tvData.initializeFrom(gameTiles)

        let bData = boxTilesBuffer.contents()
        let bvData = UnsafeMutablePointer<Int32>(bData + 0)
        bvData.initializeFrom(boxTiles)
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
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 256*bufferIndex, atIndex: 0)
            renderEncoder.setVertexBuffer(vertexColorBuffer, offset:0 , atIndex: 1)
            renderEncoder.setVertexBuffer(gridInfoBuffer, offset:0 , atIndex: 2)
            renderEncoder.setVertexBuffer(gameTilesBuffer, offset:0 , atIndex: 3)
            renderEncoder.setVertexBuffer(boxTilesBuffer, offset:0 , atIndex: 4)
            renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
            
            renderEncoder.popDebugGroup()
            renderEncoder.endEncoding()
                
            commandBuffer.presentDrawable(currentDrawable)
        }
        
        // bufferIndex matches the current semaphore controlled frame index to ensure writing occurs at the correct region in the vertex buffer.
        bufferIndex = (bufferIndex + 1) % MaxBuffers
        
        commandBuffer.commit()
    }

    func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
        // Pass through and do nothing.
    }
}
