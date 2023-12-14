//
//  PlayerAction.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 14.12.2023.
//

import Foundation

enum PlayerAction: Int, CaseIterable, CustomStringConvertible {
    case closeVC = 0
    case play

    var description: String {
        switch self {
        case .closeVC: return "Close video"
        case .play: return "Play/Pause"
        }
    }
}
