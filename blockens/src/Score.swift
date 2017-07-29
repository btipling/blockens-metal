//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

private let BASE_MOVEMENT_MODIFIER = 0.01
private let BASE_FOOD_MODIFIER = 100.0
private let FOOD_INCREASE = 100.0
private let SPEED_INCREASE = 0.01



class Score: RenderController {

    let stringController = StringController(scale: 0.018, xPadding: 0.01, yPadding: 0.01)

    fileprivate var currentScore = 0.0
    fileprivate var movementModifier = BASE_MOVEMENT_MODIFIER
    fileprivate var foodModifier = BASE_FOOD_MODIFIER

    init() {
        reset()
    }

    fileprivate func updateScore() {
        stringController.set(" SCORE: \(String(score()))")
    }

    func move() {
        currentScore += movementModifier
        updateScore()
    }

    func eat() {
        currentScore += foodModifier
        movementModifier += SPEED_INCREASE
        foodModifier += FOOD_INCREASE
    }

    func score() -> Int32 {
        return Int32(floor(currentScore));
    }

    func reset() {
        currentScore = 0;
    }

    func renderer() -> Renderer {
        return stringController.renderer()
    }
}
