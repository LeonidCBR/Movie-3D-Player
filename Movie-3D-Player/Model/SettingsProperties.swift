//
//  SettingsProperties.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 12.12.2023.
//

import Foundation

struct SettingsProperties {

    struct FieldOfView {
        static let key = "FieldOfView"
        static let defaultValue: CGFloat = 85.0
        static let maxThreshold: CGFloat = 115.0
        static let minThreshold: CGFloat = 40.0
    }

    /// The space between left and right views
    struct Space {
        static let key = "Space"
        static let defaultValue: CGFloat = 20.0
        static let maxThreshold: CGFloat = 50.0
        static let minThreshold: CGFloat = 0
    }

    static let actionSettingsKey = "ActionSettingsKey"

    /** Default settings
     Play/pause                 - single tap by two fingers
     Init position of the scene - single tap
     Increase value of FOV      - swipe up by two fingers
     Decrease value of FOV      - swipe down by two fingers
     Rewind backward            - swipe left
     Rewind forward             - swipe right
     Dismiss video controller   - swipe down
     */
    static let defaultActionSettings: [PlayerAction: PlayerGesture] = [.play: .singleTapTwoFingers,
                                                                       .resetScenePosition: .singleTap,
                                                                       .increaseFOV: .swipeUpTwoFingers,
                                                                       .decreaseFOV: .swipeDownTwoFingers,
                                                                       .rewindBackward: .swipeLeft,
                                                                       .rewindForward: .swipeRight,
                                                                       .closeVC: .swipeDown]
}
