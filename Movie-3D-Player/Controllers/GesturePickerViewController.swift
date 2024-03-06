//
//  GesturePickerViewController.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 01.03.2024.
//

import UIKit

protocol GesturePickerViewControllerDelegate: AnyObject {
    func didSelectGesture(_ playerGesture: PlayerGesture, for action: PlayerAction)
}

class GesturePickerViewController: UITableViewController {

    let gestureCellIdentifier = "GestureCellIdentifier"
    var selectedGesture: PlayerGesture?
    var playerAction: PlayerAction?
    weak var delegate: GesturePickerViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: gestureCellIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        PlayerGesture.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0, let playerGesture = PlayerGesture(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: gestureCellIdentifier, for: indexPath)
        if selectedGesture == playerGesture {
            cell.accessoryType = .checkmark
        }
        var content = cell.defaultContentConfiguration()
        content.text = playerGesture.description
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0,
           let playerGesture = PlayerGesture(rawValue: indexPath.row),
           let playerAction = playerAction {
            delegate?.didSelectGesture(playerGesture, for: playerAction)
        }
        navigationController?.popViewController(animated: true)
    }

}
