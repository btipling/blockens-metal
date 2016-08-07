//
// Created by Bjorn Tipling on 8/6/16.
// Copyright (c) 2016 apphacker. All rights reserved.
//

import Foundation

class Score: RenderController {

    let stringController = StringController()

    private var currentScore: Int32 = 0

    init() {
        reset()
    }

    private func setScore(newScore: Int32) {
        currentScore = newScore
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
