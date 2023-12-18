//
//  SettingsProvider.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 18.12.2023.
//

import Foundation

final class SettingsProvider {
    var actionSettings: [PlayerAction: PlayerGesture] {
        get {
            return getActionSettings()
        }
        set {
            saveActionSettings(newValue)
        }
    }

    /** Default settings
     Play/pause                 - single tap by two fingers
     Init position of the scene - single tap
     Increase value of FOV      - swipe up by two fingers
     Decrease value of FOV      - swipe down by two fingers
     Rewind backward            - swipe left
     Rewind forward             - swipe right
     Dismiss video controller   - swipe down
     */
    func getActionSettings() -> [PlayerAction: PlayerGesture] {
        // TODO: Implement fetching from UserDefaults
        return [.play: .singleTapTwoFingers,
                .resetScenePosition: .singleTap,
                .increaseFOV: .swipeUpTwoFingers,
                .decreaseFOV: .swipeDownTwoFingers,
                .rewindBackward: .swipeLeft,
                .rewindForward: .swipeRight,
                .closeVC: .swipeDown]
    }

    func saveActionSettings(_ actionSettings: [PlayerAction: PlayerGesture]) {
        // TODO: Implement saving to UserDefaults
        print("DEBUG: Implement saving to UserDefaults")
    }
}
