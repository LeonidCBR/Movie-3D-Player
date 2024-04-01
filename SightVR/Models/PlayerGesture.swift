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
        case .none:
            return String(localized: "None")
        case .singleTap:
            return String(localized: "Single tap")
        case .singleTapTwoFingers:
            return String(localized: "Single tap by two fingers")
        case .swipeUp:
            return String(localized: "Swipe up")
        case .swipeDown:
            return String(localized: "Swipe down")
        case .swipeLeft:
            return String(localized: "Swipe to left")
        case .swipeRight:
            return String(localized: "Swipe to right")
        case .swipeUpTwoFingers:
            return String(localized: "Swipe up by two fingers")
        case .swipeDownTwoFingers:
            return String(localized: "Swipe down by two fingers")
        }
    }

}
