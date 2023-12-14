//
//  PlayerGesture.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 14.12.2023.
//

import Foundation

enum PlayerGesture: Int, CustomStringConvertible {
    case singleTap = 0
    case swipeDown

    var description: String {
        switch self {
        case .singleTap: return "Single tap"
        case .swipeDown: return "Swipe down"
        }
    }
}
