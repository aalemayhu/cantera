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

    private let bodyLabel: UILabel = {
        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        let text = "Trykk på det lille hjertet i høyre hjørne ved annnonsen. Da legger annonsen seg under \"Favoritter\", slik at det blir lettere å finne den igjen"
        let attr = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]
        bodyLabel.attributedText = NSMutableAttributedString(string: text, attributes: attr)
        bodyLabel.backgroundColor = .clear
        return bodyLabel
    }()

    init() {
        super.init(frame: CGRect.zero)
        [headerLabel, bodyLabel].forEach { addSubview($0) }
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
            headerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            headerLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
        ])

        NSLayoutConstraint.activate([
            bodyLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor),
            bodyLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
        ])
    }
}
