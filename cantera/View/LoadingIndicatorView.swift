//
//  LoadingIndicatorView.swift
//  cantera
//
//  Created by Alexander Alemayhu on 21/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

class LoadingIndicatorView: UIView {

    public var animates: Bool? {
        didSet {
            guard let animates = animates else { return }
            animates ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            self.isHidden = !animates
            activityIndicator.isHidden = !animates
        }
    }

    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .whiteLarge)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.color = .red
        return activity
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .red
        label.text = "Laster..."
        return label
    }()

    init() {
        super.init(frame: CGRect.zero)
        [activityIndicator, label].forEach { addSubview($0) }
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        self.animates = false

        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            activityIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
        ])

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
