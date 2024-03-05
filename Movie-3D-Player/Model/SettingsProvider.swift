//
//  SettingsProvider.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 18.12.2023.
//

import Foundation

final class SettingsProvider {
    var fieldOfView: CGFloat {
        get {
            return getFieldOfView()
        }
        set {
            setFieldOfView(to: newValue)
        }
    }

    var space: CGFloat {
        get {
            return getSpace()
        }
        set {
            setSpace(to: newValue)
        }
    }

    var actionSettings: [PlayerAction: PlayerGesture] {
        get {
            return getActionSettings()
        }
        set {
            setActionSettings(to: newValue)
        }
    }

    func getFieldOfView() -> CGFloat {
        if let fieldOfViewObject = UserDefaults.standard.object(forKey: SettingsProperties.FieldOfView.key),
           let fieldOfViewValue = (fieldOfViewObject as? CGFloat) {
            return fieldOfViewValue
        } else {
            return SettingsProperties.FieldOfView.defaultValue
        }
    }

    func setFieldOfView(to fieldOfView: CGFloat) {
        UserDefaults.standard.set(fieldOfView, forKey: SettingsProperties.FieldOfView.key)
    }

    func getSpace() -> CGFloat {
        if let spaceObject = UserDefaults.standard.object(forKey: SettingsProperties.Space.key),
        let spaceValue = (spaceObject as? CGFloat) {
            return spaceValue
        } else {
            return SettingsProperties.Space.defaultValue
        }
    }

    func setSpace(to space: CGFloat) {
        UserDefaults.standard.set(space, forKey: SettingsProperties.Space.key)
    }

    func getActionSettings() -> [PlayerAction: PlayerGesture] {
        if let encodedSettings = UserDefaults.standard.object(forKey: SettingsProperties.actionSettingsKey)
            as? [String: Int] {
            var actionSettings: [PlayerAction: PlayerGesture] = [:]
            for (key, value) in encodedSettings {
                if let action = PlayerAction(stringValue: key) {
                    actionSettings[action] = PlayerGesture(rawValue: value)
                }
            }
            return actionSettings
        } else {
            return SettingsProperties.defaultActionSettings
        }
    }

    func setActionSettings(to actionSettings: [PlayerAction: PlayerGesture]) {
        var encodedSettings: [String: Int] = [:]
        for (action, gesture) in actionSettings {
            encodedSettings[action.stringValue] = gesture.rawValue
        }
        UserDefaults.standard.setValue(encodedSettings, forKey: SettingsProperties.actionSettingsKey)
    }
}
