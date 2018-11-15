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
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(imageLiteralResourceName: "unselected"), for: .normal)
        button.setImage(UIImage(imageLiteralResourceName: "selected"), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - UIKit

    override func viewDidLoad() {
        super.viewDidLoad()
        [imageView, descriptionTextView, favoriteButton].forEach { view.addSubview($0) }
        setup()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateViewConstraints()
    }

    // MARK: - Private

    private func setup() {
        guard let ad = ad else { return }
        self.view.backgroundColor = .white

        self.title = "\(ad.location)"

        let attributedText = NSMutableAttributedString(string: ad.location, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        attributedText.append(NSAttributedString(string: "\n\n\(ad.title)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
        if let price = ad.price {
            attributedText.append(NSAttributedString(string: "\n\n\(price),-", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)
            ]))
            self.title = "\(self.title!) - \(price),-"
        }
        descriptionTextView.attributedText = attributedText

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
            ])

        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])

        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])

        favoriteButton.isSelected = ad.liked
        favoriteButton.layer.cornerRadius = 6
        favoriteButton.layer.masksToBounds = true
        favoriteButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        favoriteButton.addTarget(self, action: #selector(pressFavorite), for: .touchUpInside)

        api?.image(for: ad, completion: { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.imageView.image = image
                } else {
                    // bad image, could be missing on server (404) or other bad HTTP code
                }
            }
        })
    }

    // MARK: - User interaction

    @objc func pressFavorite() {
        self.favoriteButton.isSelected = !self.favoriteButton.isSelected
        ad?.liked = self.favoriteButton.isSelected
    }
}
