//
// Created by Bjorn Tipling on 7/28/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class SnakeController {

    var currentDirection: Direction = Direction.Right

    var gameTiles: Array<Int32> = []
    var boxTiles: Array<Int32> = []

    var snakeTiles: Array<GameTileInfo> = []
    var foodBoxLocation: Int32 = 0
    private let _renderer: SnakeRenderer = SnakeRenderer()

    init() {
        reset()
    }

    func reset() {
        currentDirection = Direction.Right
        let newSpot = getRandomNum(_renderer.gridInfoData.numBoxes)
        let x = Int32(newSpot % _renderer.gridInfoData.gridDimension)
        let y = Int32(newSpot / _renderer.gridInfoData.gridDimension)
        snakeTiles = [GameTileInfo(x: x, y: y, tile: GameTile.HeadRight)]
        findFood()

    }

    func setDirection(direction: Direction) {
        currentDirection = direction
    }

    func direction() -> Direction {
        return currentDirection
    }

    func renderer() -> SnakeRenderer {
        return _renderer
    }

    func findFood() -> Bool {
        var tries = 1000
        let snakeTilePositions = mapSnakeTiles()
        repeat {
            foodBoxLocation = getRandomNum(_renderer.gridInfoData.numBoxes)
            tries -= 1
        } while (tries > 0 && snakeTilePositions[foodBoxLocation] != nil)
        if tries == 0 {
            // Couldn't find a place to put food in 1k tries.
            return false
        }
        return true
    }

    func mapSnakeTiles(start: Int = 0) -> [Int32: GameTileInfo] {

        var snakeTilePosition: [Int32: GameTileInfo] = [:]

        if (start >= snakeTiles.count) {
            return snakeTilePosition
        }

        let range = start + ((snakeTiles.count - start) - 1)
        for snakeTile in snakeTiles[start...range] {
            let numBox = snakeTile.y * _renderer.gridInfoData.gridDimension + snakeTile.x;
            snakeTilePosition[numBox] = snakeTile
        }

        return snakeTilePosition
    }

    func move() -> Bool {

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
                return moveHead()
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
        let result = moveHead()
        update()
        return result
    }

    private func update() {
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
        _renderer.updateTileCount(gameTiles.count)
        _renderer.update(gameTiles, boxTiles: boxTiles)
    }


    func moveHead() -> Bool {
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

        let currentBoxNum = snakeHead.y * _renderer.gridInfoData.gridDimension + snakeHead.x
        return snakeMap[currentBoxNum] == nil // This returns true if snake moved without colliding.
    }

    func log_e(n: Double) -> Double {
        return log(n)/log(M_E)
    }

    func eatFoodIfOnFood() -> Bool {
        let snakeTile = snakeTiles[0]
        let numBox = snakeTile.y * _renderer.gridInfoData.gridDimension + snakeTile.x;
        if numBox == foodBoxLocation {
            snakeTiles.append(GameTileInfo(x: snakeTile.x, y: snakeTile.y, tile: GameTile.HeadRight))
            return findFood()
        }
        return false
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
            y = _renderer.gridInfoData.gridDimension - 1
        }
        snakeHead.tile = GameTile.HeadDown
        snakeHead.y = y
        snakeTiles[0] = snakeHead
    }

    func moveUp() {

        var snakeHead = snakeTiles[0]
        var y = snakeHead.y

        y += 1
        if y >= _renderer.gridInfoData.gridDimension {
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
            x = _renderer.gridInfoData.gridDimension - 1
        }
        snakeHead.tile = GameTile.HeadLeft
        snakeHead.x = x
        snakeTiles[0] = snakeHead
    }

    func moveRight() {

        var snakeHead = snakeTiles[0]
        var x = snakeHead.x

        x += 1
        if x >= _renderer.gridInfoData.gridDimension {
            x = 0
        }
        snakeHead.tile = GameTile.HeadRight
        snakeHead.x = x
        snakeTiles[0] = snakeHead
    }


}
