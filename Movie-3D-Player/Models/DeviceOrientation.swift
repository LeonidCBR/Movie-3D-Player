//
//  OrientationProperty.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 06.03.2024.
//

import Foundation

enum DeviceOrientation: Int, CaseIterable, CustomStringConvertible {
    case leftSideDown = 0
    case rightSideDown

    var description: String {
        switch self {
        case .leftSideDown:
            return String(localized: "Left side down")
        case .rightSideDown:
            return String(localized: "Right side down")
        }
    }
}
