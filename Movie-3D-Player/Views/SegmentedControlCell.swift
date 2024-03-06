//
//  SegmentedControlCell.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 06.03.2024.
//

import UIKit

class SegmentedControlCell: UITableViewCell {

    // MARK: - Properties

    let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Left", "Right"])
        control.selectedSegmentIndex = 0
        return control
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Methods

    func configureUI() {
        selectionStyle = .none
        clipsToBounds = true
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(segmentedControl)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
            segmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0),
            segmentedControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

}
