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
            return NSLocalizedString("Field of view", comment: "")
        case .space:
            return NSLocalizedString("Space", comment: "")
        }
    }
}
