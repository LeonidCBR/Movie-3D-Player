//
//  PlayerGesture.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 14.12.2023.
//

import Foundation

enum PlayerGesture: Int, CustomStringConvertible, CaseIterable {
    case none = 0
    case singleTap
    case singleTapTwoFingers
    case swipeUp
    case swipeDown
    case swipeLeft
    case swipeRight
    case swipeUpTwoFingers
    case swipeDownTwoFingers

    var description: String {
        switch self {
        case .none: return "None"
        case .singleTap: return "Single tap"
        case .singleTapTwoFingers: return "Single tap by two fingers"
        case .swipeUp: return "Swipe up"
        case .swipeDown: return "Swipe down"
        case .swipeLeft: return "Swipe to left"
        case .swipeRight: return "Swipe to right"
        case .swipeUpTwoFingers: return "Swipe up by two fingers"
        case .swipeDownTwoFingers: return "Swipe down by two fingers"
        }
    }

}
