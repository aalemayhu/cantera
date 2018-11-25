//
//  EmptyFavoritesView.swift
//  cantera
//
//  Created by Alexander Alemayhu on 21/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

class EmptyCollectionView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 36)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()

    private let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = .clear
        return messageLabel
    }()

    private var title: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
        }
    }

    private var message: String? {
        get { return messageLabel.text }
        set {
            guard let text = newValue else { return }
            let attr = [
                NSAttributedString.Key.foregroundColor: UIColor.gray,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
            ]
            messageLabel.attributedText = NSMutableAttributedString(string: text, attributes: attr)
        }
    }

    init(title: String, message: String) {
        super.init(frame: CGRect.zero)
        [titleLabel, messageLabel].forEach { addSubview($0) }
        self.setup()
        self.title = title
        self.message = message
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
        ])

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            messageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
        ])
    }
}
