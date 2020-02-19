//
//  GameState.swift
//  ARcade
//
//  Created by Lucas Fernandez Nicolau on 19/02/20.
//

import Foundation

enum GameState {
    case arcade
    case alienXUSLevel0
    case alienXUSLevel1
    case alienXUSLevel2
    case alienXUSLevel3
}

class GSController {
    let shared = GSController(state: .arcade)
    var state: GameState

    private init(state: GameState) {
        self.state = state
    }

    func changeState(to state: GameState) {
        self.state = state
    }
}
