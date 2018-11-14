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

    override func viewDidLoad() {
        super.viewDidLoad()
        [imageView, descriptionTextView].forEach { view.addSubview($0) }
        setup()
    }

    // MARK: - Private

    private func setup() {
        guard let ad = ad else { return }
        self.title = ad.title.limit(to: 25)
        self.view.backgroundColor = .white

        api?.image(for: ad, completion: { image in
            if let image = image {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        })


        let title = ad.title

        let attributedText = NSMutableAttributedString(string: ad.location, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        attributedText.append(NSAttributedString(string: "\n\(title)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
        descriptionTextView.attributedText = attributedText


        // Constraints for the image
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1)
            ])

        // Constraints for the location and title
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -6),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }

    // MARK: - User interaction

    @objc func pressRightItem() {

    }
}
