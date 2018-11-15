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

    // MARK: - UIKit

    override func viewDidLoad() {
        super.viewDidLoad()
        [imageView, descriptionTextView].forEach { view.addSubview($0) }
        setup()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateViewConstraints()
    }

    // MARK: - Private

    private func setup() {
        guard let ad = ad else { return }
        self.view.backgroundColor = .white

        let attributedText = NSMutableAttributedString(string: ad.location, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        attributedText.append(NSAttributedString(string: "\n\n\(ad.title)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
        if let price = ad.price {
            attributedText.append(NSAttributedString(string: "\n\n\(price),-", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)
            ]))
        }
        descriptionTextView.attributedText = attributedText

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
            ])

        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])

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

    @objc func pressRightItem() {

    }
}
