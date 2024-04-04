//
//  ActionCell.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 14.12.2023.
//

import UIKit

/// A cell represents an action and a gesture
class ActionCell: UITableViewCell {

    // MARK: - Properties

    weak var delegate: InputTextCellDelegate?

    let actionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    let gestureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
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
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        gestureLabel.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView(arrangedSubviews: [actionLabel, gestureLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .trailing
//        stackView.spacing = 20.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0)
        ])
    }
}
