//
//  AdsDetailViewController.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

protocol AdsDetailViewControllerDatasource {
    func adForDetailViewController() -> AdObject?
    func retrieveImage(for ad: AdObject, completion: @escaping (UIImage?) -> Void)
    func isItinFavorites(ad: AdObject) -> Bool
    func toggleFavorite(for ad: AdObject, checked: Bool)
}

class AdsDetailViewController: UIViewController {

    public var datasource: AdsDetailViewControllerDatasource?

    private var api: RequestHandler?

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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - View lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

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
        guard let ad = datasource?.adForDetailViewController() else { return }
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
            imageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1)
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

        favoriteButton.isSelected = datasource?.isItinFavorites(ad: ad) ?? false
        favoriteButton.layer.cornerRadius = 6
        favoriteButton.layer.masksToBounds = true
        favoriteButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        favoriteButton.addTarget(self, action: #selector(pressFavorite), for: .touchUpInside)

        datasource?.retrieveImage(for: ad, completion: { image in
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
        guard let ad = datasource?.adForDetailViewController() else { return }
        favoriteButton.isSelected = !favoriteButton.isSelected
        datasource?.toggleFavorite(for: ad, checked: favoriteButton.isSelected)
    }
}
