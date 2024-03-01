//
//  SettingsViewController.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 03.04.2023.
//

import UIKit

class SettingsViewController: UITableViewController {
    // TODO: Consider to move into the SettingsProvider
    let numberOfSettingsSections = 2
    let commonSettingsSection = 0
    let actionSettingsSection = 1

    let inputTextCellIdentifier = "InputTextCellIdentifier"
    let actionCellIdentifier = "ActionCellIdentifier"
    let settingsProvider: SettingsProvider

    // MARK: - Lifecycle

    init(settingsProvider: SettingsProvider = SettingsProvider()) {
        self.settingsProvider = settingsProvider
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == actionSettingsSection else {
            return
        }
        let gesturePickerVC = UIViewController()
        gesturePickerVC.view.backgroundColor = .blue
        present(gesturePickerVC, animated: true)
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
            commonCell.setTextField(to: "\(settingsProvider.fieldOfView)")
        case .space:
            commonCell.setTextField(to: "\(settingsProvider.space)")
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
        let playerGestureDescription = settingsProvider.actionSettings[playerAction]?.description ?? "None"
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
        let newValue = Double(text) else {
            // New value is incorrect. Set an old value
            switch option {
            case .fieldOfView:
                setFieldOfView(to: settingsProvider.fieldOfView)
            case .space:
                setSpace(to: settingsProvider.space)
            }
            return
        }
        switch option {
        case .fieldOfView:
            if newValue != settingsProvider.fieldOfView {
                guard newValue < SettingsProperties.FieldOfView.maxThreshold,
                      newValue > SettingsProperties.FieldOfView.minThreshold else {
                    // Reset to the old value
                    setFieldOfView(to: settingsProvider.fieldOfView)
                    return
                }
                settingsProvider.fieldOfView = newValue
            }
        case .space:
            if newValue != settingsProvider.space {
                guard newValue < SettingsProperties.Space.maxThreshold,
                      newValue > SettingsProperties.Space.minThreshold else {
                    // Reset to the old value
                    setSpace(to: settingsProvider.space)
                    return
                }
                settingsProvider.space = newValue
            }
        }
    }
}
