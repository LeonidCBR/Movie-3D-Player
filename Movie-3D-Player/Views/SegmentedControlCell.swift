//
//  SegmentedControlCell.swift
//  Movie-3D-Player
//
//  Created by Yana Latysheva on 06.03.2024.
//

import UIKit

protocol SegmentedControlCellDelegate: AnyObject {
    func orientationDidChange(to orientation: DeviceOrientation)
}

class SegmentedControlCell: UITableViewCell {

    // MARK: - Properties

    weak var delegate: SegmentedControlCellDelegate?

    let orientationControl: UISegmentedControl = {
        let orientationLabels = DeviceOrientation.allCases.map { $0.description }
        let control = UISegmentedControl(items: orientationLabels)
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
        orientationControl.addTarget(self,
                                     action: #selector(handleOrientationValueChanged),
                                     for: .valueChanged)
        orientationControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(orientationControl)
        NSLayoutConstraint.activate([
            orientationControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
            orientationControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0),
            orientationControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    func setDeviceOrientation(to orientation: DeviceOrientation) {
        orientationControl.selectedSegmentIndex = orientation.rawValue
    }

    // MARK: - Selectors

    @objc func handleOrientationValueChanged() {
        if let newOrientation = DeviceOrientation(rawValue: orientationControl.selectedSegmentIndex) {
            delegate?.orientationDidChange(to: newOrientation)
        }
    }
}
