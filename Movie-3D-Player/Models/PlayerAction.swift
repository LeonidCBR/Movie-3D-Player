//
//  PlayerAction.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 14.12.2023.
//

import Foundation

enum PlayerAction: Int, CaseIterable, CustomStringConvertible, CodingKey {
    case closeVC = 0
    case play
    case resetScenePosition
    case increaseFOV
    case decreaseFOV
    case rewindBackward
    case rewindForward

    var description: String {
        switch self {
        case .closeVC:
            return String(localized: "Close video")
        case .play:
            return String(localized: "Play/Pause")
        case .resetScenePosition:
            return String(localized: "Reset position of the scene")
        case .increaseFOV:
            return String(localized: "Increase the field of view")
        case .decreaseFOV:
            return String(localized: "Decrease the field of view")
        case .rewindBackward:
            return String(localized: "Rewind backward")
        case .rewindForward:
            return String(localized: "Rewind forward")
        }
    }

}
