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
    case resetScenePosition
    case increaseFOV
    case decreaseFOV
    case rewindBackward
    case rewindForward

    var description: String {
        switch self {
        case .closeVC: return "Close video"
        case .play: return "Play/Pause"
        case .resetScenePosition: return "Reset position of the scene"
        case .increaseFOV: return "Increase the field of view"
        case .decreaseFOV: return "Decrease the field of view"
        case .rewindBackward: return "Rewind backward"
        case .rewindForward: return "Rewind forward"
        }
    }
}
