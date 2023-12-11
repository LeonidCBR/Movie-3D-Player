//
//  InputTextCell.swift
//  Movie-3D-Player
//
//  Created by Яна Латышева on 08.12.2020.
//

import UIKit

protocol InputTextCellDelegate: AnyObject {

    func didGetValue(_ textField: UITextField, tableViewCell: UITableViewCell)
}

class InputTextCell: UITableViewCell {

    // MARK: - Properties

    weak var delegate: InputTextCellDelegate?

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let textField: UITextField = {
        let text = UITextField()
        text.font = UIFont.preferredFont(forTextStyle: .body)
        text.adjustsFontForContentSizeCategory = true
        text.borderStyle = .roundedRect
        text.keyboardType = .decimalPad
        return text
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

    private func configureUI() {
        selectionStyle = .none
        clipsToBounds = true
        textField.delegate = self
        contentView.addSubview(captionLabel)
        contentView.addSubview(textField)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        /*
         top & bottom greater or equal 20.0 & centerY
         label leading = 15.0
         field trailing = 15.0 & 100.0x34.0
         */
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 100.0),
            textField.heightAnchor.constraint(equalToConstant: 34.0),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0),
            // TODO: - Test it
            textField.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20.0),
            textField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20.0),
            captionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            captionLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20.0),
            captionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20.0),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0),
            captionLabel.trailingAnchor.constraint(lessThanOrEqualTo: textField.leadingAnchor, constant: -20.0)
        ])
    }

    func setTextCaptionLabel(to text: String) {
        captionLabel.text = text
    }

    func setTextField(to text: String) {
        textField.text = text
    }

}

// MARK: - UITextFieldDelegate (Text validation)

extension InputTextCell: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let decimalSeparator = NumberFormatter().decimalSeparator else {
            return true
        }
        // Ignore input if text have contaned decimal separator ("," or ".") already
        if string == decimalSeparator {
            if let text = textField.text, text.contains(decimalSeparator) {
                return false
            }
        }
        // Ignore input if text have nore then 4 digits after decimal separator
        if Int(string) != nil {
            if let text = textField.text,
               text.split(separator: Character(decimalSeparator)).count >= 2,
               text.split(separator: Character(decimalSeparator))[1].count >= 4 {
                return false
            }
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didGetValue(textField, tableViewCell: self)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Clear text field if it's text equals 0
        if let value = Double(textField.text ?? ""), value == 0 {
            textField.text = ""
        }
        return true
    }

}
