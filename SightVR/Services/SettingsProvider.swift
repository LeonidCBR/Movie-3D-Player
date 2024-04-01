//
//  SettingsProvider.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 18.12.2023.
//

import Foundation

final class SettingsProvider {

    // MARK: - Properties

    let userDefaults: UserDefaults

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

    var orientation: DeviceOrientation {
        get {
            return getDeviceOrientation()
        }
        set {
            setDeviceOrientation(to: newValue)
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

    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Methods

    // MARK: FieldOfView
    func getFieldOfView() -> CGFloat {
        if let fieldOfViewObject = userDefaults.object(forKey: SettingsProperties.FieldOfView.key),
           let fieldOfViewValue = (fieldOfViewObject as? CGFloat) {
            return fieldOfViewValue
        } else {
            return SettingsProperties.FieldOfView.defaultValue
        }
    }

    func setFieldOfView(to fieldOfView: CGFloat) {
        userDefaults.set(fieldOfView, forKey: SettingsProperties.FieldOfView.key)
    }

    // MARK: Space
    func getSpace() -> CGFloat {
        if let spaceObject = userDefaults.object(forKey: SettingsProperties.Space.key),
        let spaceValue = (spaceObject as? CGFloat) {
            return spaceValue
        } else {
            return SettingsProperties.Space.defaultValue
        }
    }

    func setSpace(to space: CGFloat) {
        userDefaults.set(space, forKey: SettingsProperties.Space.key)
    }

    // MARK: DeviceOrientation
    func getDeviceOrientation() -> DeviceOrientation {
        if let orientationRawValue = userDefaults.object(forKey: SettingsProperties.Orientation.key) as? Int,
           let orientation = DeviceOrientation(rawValue: orientationRawValue) {
            return orientation
        } else {
            return SettingsProperties.Orientation.defaultValue
        }
    }

    func setDeviceOrientation(to orientation: DeviceOrientation) {
        userDefaults.set(orientation.rawValue, forKey: SettingsProperties.Orientation.key)
    }

    // MARK: ActionSettings
    func getActionSettings() -> [PlayerAction: PlayerGesture] {
        if let encodedSettings = userDefaults.object(forKey: SettingsProperties.actionSettingsKey)
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
        userDefaults.setValue(encodedSettings, forKey: SettingsProperties.actionSettingsKey)
    }
}
