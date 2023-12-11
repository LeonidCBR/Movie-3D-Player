//
//  SettingsViewController.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 03.04.2023.
//

import UIKit

class SettingsViewController: UITableViewController {

    var fieldOfView: CGFloat // = 85.0
    // The space between left and right views
    var space: CGFloat // = 20.0

    let inputTextCellIdentifier = "InputTextCellIdentifier"

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
    }

    // MARK: - Lifecycle

    init(withFieldOfView fov: CGFloat, andSpace space: CGFloat) {
        self.fieldOfView = fov
        self.space = space
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsOption.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellOption = SettingsOption(rawValue: indexPath.row)!
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
        print("DEBUG: The value of text field: \(textField.textInputView)")
        print("DEBUG: Tag: \(tableViewCell.tag)")
        guard let option = SettingsOption(rawValue: tableViewCell.tag) else {
            return
        }
        guard let text = textField.text,
        let value = Double(text) else {
            //if .litersAmount == option { setLiters(to: refuelModel.liters) }
            // TODO: Remove debug prints
            print("DEBUG: Wrong value: \(textField.text)")

            // New value is incorrect. Set an old value
            if .fieldOfView == option {
                setFieldOfView(to: fieldOfView)
            }
            if .space == option {
                setSpace(to: space)
            }

            return
        }
        switch option {
        case .fieldOfView:
            if value != fieldOfView {
                print("DEBUG: Save FOV: \(value)")
                fieldOfView = value
                // TODO: - save fov
                // settingsManager.save(fov)
            }
        case .space:
            if value != space {
                print("DEBUG: Save space: \(value)")
                space = value
                // TODO: - save space
                // settingsManager.save(space)
            }
        }
        /*
        guard let text = textField.text,
              let value = Double(from: text)
        else {
            // Got wrong value. Set old values back to the text field
            if .litersAmount == option { setLiters(to: refuelModel.liters) }
            else if .cost == option { setCost(to: refuelModel.cost) }
            else if .odometer == option { setOdometer(to: refuelModel.odometer) }
            return
        }

        switch option {
        case .litersAmount: refuelModel.liters = value // number.doubleValue
        case .cost: refuelModel.cost = value // number.doubleValue
        case .odometer: refuelModel.odometer = Int(value) // number.intValue
        default: break
        }
        */
    }
}
