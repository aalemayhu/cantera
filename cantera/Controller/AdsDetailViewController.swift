//
//  AdsDetailViewController.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

class AdsDetailViewController: UIViewController {

    public var ad: AdObject?
    public var api: AdsAPIHandler?

    private let imageView: UIImageView = {
        let image = UIImage(imageLiteralResourceName: "placeholder")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()

    private let activityIndicator: UIActivityIndicatorView  = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .red
        return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        [imageView, descriptionTextView, activityIndicator].forEach { view.addSubview($0) }
        setup()
    }

    // MARK: - Private

    private func setup() {
        guard let ad = ad else { return }
        self.view.backgroundColor = .white

        self.navigationItem.titleView = activityIndicator

        let attributedText = NSMutableAttributedString(string: ad.location, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        attributedText.append(NSAttributedString(string: "\n\(ad.title)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
        descriptionTextView.attributedText = attributedText

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
            ])

        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -6),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])

        activityIndicator.startAnimating()
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])

        api?.image(for: ad, completion: { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.imageView.image = image
                } else {
                    // bad image, could be missing on server (404) or other bad HTTP code
                }
                self.activityIndicator.stopAnimating()
            }
        })
    }

    // MARK: - User interaction

    @objc func pressRightItem() {

    }
}
