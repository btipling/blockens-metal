//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class Score: RenderController {

    let stringController = StringController(scale: 0.03, xPadding: 0.01, yPadding: 0.01)

    private var currentScore: Int32 = 0

    init() {
        reset()
    }

    func setScore(newScore: Int32) {
        currentScore = newScore
        stringController.set("2102")//String(newScore))
    }

    func score() -> Int32 {
        return currentScore;
    }

    func reset() {
        currentScore = 0;
    }

    func renderer() -> Renderer {
        return stringController.renderer()
    }
}
