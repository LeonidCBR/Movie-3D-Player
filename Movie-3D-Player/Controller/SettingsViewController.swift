//
//  SettingsViewController.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 03.04.2023.
//

import UIKit

class SettingsViewController: UITableViewController {

    // TODO: Consider to get rid of these properties
    var fieldOfView = SettingsProperties.FieldOfView.defaultValue
    // The space between left and right views
    var space = SettingsProperties.Space.defaultValue
    let inputTextCellIdentifier = "InputTextCellIdentifier"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(InputTextCell.self, forCellReuseIdentifier: inputTextCellIdentifier)
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsOption.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellOption = SettingsOption(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        let cell: UITableViewCell
        switch cellOption {
        case .fieldOfView:
            guard let fovCell = tableView.dequeueReusableCell(withIdentifier: inputTextCellIdentifier,
                                                              for: indexPath) as? InputTextCell else {
                return UITableViewCell()
            }
            fovCell.delegate = self
            fovCell.setTextCaptionLabel(to: cellOption.description)
            fovCell.setTextField(to: "\(fieldOfView)")
            cell = fovCell
        case .space:
            guard let spaceCell = tableView.dequeueReusableCell(withIdentifier: inputTextCellIdentifier,
                                                                for: indexPath) as? InputTextCell else {
                return UITableViewCell()
            }
            spaceCell.delegate = self
            spaceCell.setTextCaptionLabel(to: cellOption.description)
            spaceCell.setTextField(to: "\(space)")
            cell = spaceCell
        }
        cell.tag = indexPath.row
        return cell
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
