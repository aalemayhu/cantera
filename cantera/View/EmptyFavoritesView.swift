//
//  EmptyFavoritesView.swift
//  cantera
//
//  Created by Alexander Alemayhu on 21/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

class EmptyFavoritesView: UIView {

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 36)
        label.textAlignment = .center
        label.textColor = .black
        label.text = "Finner du noe du liker?"
        return label
    }()

    private let bodyTextView: UITextView = {
        let bodyTextView = UITextView()
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        bodyTextView.isEditable = false
        bodyTextView.isScrollEnabled = false
        bodyTextView.textAlignment = .center
        let text = "Trykk på det lille hjertet i høyre hjørne ved annnonsen. Da legger\nannonsen seg under \"Favoritter\", slik at det blir\nlettere å finne den igjen"
        let attr = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]
        bodyTextView.attributedText = NSMutableAttributedString(string: text, attributes: attr)
        bodyTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        bodyTextView.backgroundColor = .clear
        return bodyTextView
    }()

    init() {
        super.init(frame: CGRect.zero)
        [headerLabel, bodyTextView].forEach { addSubview($0) }
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
        ])

        NSLayoutConstraint.activate([
            bodyTextView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            bodyTextView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            bodyTextView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
        ])
    }
}
