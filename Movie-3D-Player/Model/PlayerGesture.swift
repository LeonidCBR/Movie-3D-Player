//
//  PlayerGesture.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 14.12.2023.
//

import Foundation

enum PlayerGesture: Int, CustomStringConvertible {
    case singleTap = 0
    case singleTwoFingersTap
    case swipeUp
    case swipeDown
    case swipeLeft
    case swipeRight
    case swipeDownTwoFingers

    var description: String {
        switch self {
        case .singleTap: return "Single tap"
        case .singleTwoFingersTap: return "Single tap by two fingers"
        case .swipeUp: return "Swipe up"
        case .swipeDown: return "Swipe down"
        case .swipeLeft: return "Swipe to left"
        case .swipeRight: return "Swipe to right"
        case .swipeDownTwoFingers: return "Swipe down by two fingers"
        }
    }
}
