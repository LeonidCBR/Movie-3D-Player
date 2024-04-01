//
//  SettingsOption.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 04.04.2023.
//

import Foundation

enum SettingsOption: Int, CaseIterable, CustomStringConvertible {
    case fieldOfView
    case space

    var description: String {
        switch self {
        case .fieldOfView:
            return String(localized: "Field of view")
        case .space:
            return String(localized: "Space")
        }
    }
}
