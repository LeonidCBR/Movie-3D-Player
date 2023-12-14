//
//  SettingsViewController.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 03.04.2023.
//

import UIKit

class SettingsViewController: UITableViewController {
    let numberOfSettingsSections = 2
    let commonSettingsSection = 0
    let actionSettingsSection = 1
    // TODO: Consider to create SettingsProvider
    var fieldOfView = SettingsProperties.FieldOfView.defaultValue
    // The space between left and right views
    var space = SettingsProperties.Space.defaultValue
    let inputTextCellIdentifier = "InputTextCellIdentifier"
    let actionCellIdentifier = "ActionCellIdentifier"
    // TODO: Implement mutable action settings
    let actionSettings: [PlayerAction: PlayerGesture] = [.play: .singleTap,
                                                         .resetScenePosition: .singleTwoFingersTap,
                                                         .increaseFOV: .swipeUp,
                                                         .decreaseFOV: .swipeDown,
                                                         .rewindBackward: .swipeLeft,
                                                         .rewindForward: .swipeRight,
                                                         .closeVC: .swipeDownTwoFingers]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(InputTextCell.self, forCellReuseIdentifier: inputTextCellIdentifier)
        tableView.register(ActionCell.self, forCellReuseIdentifier: actionCellIdentifier)
        title = "Settings"
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        /*
         There could be issues if you are dealing with tableviews and adding this tap gesture,
         selecting the rows, didSelectRowAtIndex path could not be fired until pressed long.
         Solution:
         tap.cancelsTouchesInView = false
         */
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        loadSettings()
    }

    /// Load settings from DB and update model if values exists
    func loadSettings() {
        if let fieldOfView = UserDefaults.standard.object(forKey: SettingsProperties.FieldOfView.id),
           let value = (fieldOfView as? CGFloat) {
            self.fieldOfView = value
        }
        if let space = UserDefaults.standard.object(forKey: SettingsProperties.Space.id),
        let value = (space as? CGFloat) {
            self.space = value
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSettingsSections
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == actionSettingsSection {
            return "Actions"
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == commonSettingsSection {
            return SettingsOption.allCases.count
        } else if section == actionSettingsSection {
            return PlayerAction.allCases.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == commonSettingsSection {
            return getCommonCell(forRowAt: indexPath)
        } else if indexPath.section == actionSettingsSection {
            return getActionCell(forRowAt: indexPath)
        } else {
            // Falling back
            return UITableViewCell()
        }
    }

    func getCommonCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let settingsOption = SettingsOption(rawValue: indexPath.row),
              let commonCell = tableView.dequeueReusableCell(withIdentifier: inputTextCellIdentifier,
                                                                  for: indexPath) as? InputTextCell
        else {
            return UITableViewCell()
        }
        switch settingsOption {
        case .fieldOfView:
            commonCell.setTextField(to: "\(fieldOfView)")
        case .space:
            commonCell.setTextField(to: "\(space)")
        }
        commonCell.delegate = self
        commonCell.setTextCaptionLabel(to: settingsOption.description)
        commonCell.tag = indexPath.row
        return commonCell
    }

    func getActionCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let playerAction = PlayerAction(rawValue: indexPath.row),
              let actionCell = tableView.dequeueReusableCell(withIdentifier: actionCellIdentifier,
                                                                  for: indexPath) as? ActionCell
        else {
            return UITableViewCell()
        }
        actionCell.actionLabel.text = playerAction.description
        let playerGestureDescription = actionSettings[playerAction]?.description ?? "None"
        actionCell.gestureLabel.text = playerGestureDescription
        actionCell.tag = indexPath.row
        return actionCell
    }

    // MARK: - Methods

    func setFieldOfView(to value: Double) {
        let indexPath = IndexPath(row: SettingsOption.fieldOfView.rawValue, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? InputTextCell {
            cell.setTextField(to: "\(value)")
        }
    }

    func setSpace(to value: Double) {
        let indexPath = IndexPath(row: SettingsOption.space.rawValue, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? InputTextCell {
            cell.setTextField(to: "\(value)")
        }
    }

}

// MARK: - InputTextCellDelegate

extension SettingsViewController: InputTextCellDelegate {
    func didGetValue(_ textField: UITextField, tableViewCell: UITableViewCell) {
        guard let option = SettingsOption(rawValue: tableViewCell.tag) else {
            return
        }
        guard let text = textField.text,
        let value = Double(text) else {
            // New value is incorrect. Set an old value
            switch option {
            case .fieldOfView:
                setFieldOfView(to: fieldOfView)
            case .space:
                setSpace(to: space)
            }
            return
        }
        switch option {
        case .fieldOfView:
            if value != fieldOfView {
                guard value < SettingsProperties.FieldOfView.maxThreshold,
                      value > SettingsProperties.FieldOfView.minThreshold else {
                    // Reset to the old value
                    setFieldOfView(to: fieldOfView)
                    return
                }
                fieldOfView = value
                UserDefaults.standard.set(value, forKey: SettingsProperties.FieldOfView.id)
            }
        case .space:
            if value != space {
                guard value < SettingsProperties.Space.maxThreshold,
                      value > SettingsProperties.Space.minThreshold else {
                    // Reset to the old value
                    setSpace(to: space)
                    return
                }
                space = value
                UserDefaults.standard.set(value, forKey: SettingsProperties.Space.id)
            }
        }
    }
}
