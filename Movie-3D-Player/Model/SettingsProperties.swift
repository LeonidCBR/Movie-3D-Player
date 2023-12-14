//
//  SettingsProperties.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 12.12.2023.
//

import Foundation

struct SettingsProperties {

    struct FieldOfView {
        static let id = "FieldOfView"
        static let defaultValue: CGFloat = 85.0
        static let maxThreshold: CGFloat = 115.0
        static let minThreshold: CGFloat = 40.0
    }

    struct Space {
        static let id = "Space"
        static let defaultValue: CGFloat = 20.0
        static let maxThreshold: CGFloat = 50.0
        static let minThreshold: CGFloat = 0
    }

    static let actionSettingsKey = "ActionSettingsKey"
}
