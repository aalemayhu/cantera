//
//  AdViewCollectionViewCell.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

protocol AdViewCollectionViewCellDelegate {
    func toggleFavorite(for ad: AdObject, checked: Bool)
}

class AdViewCollectionViewCell: UICollectionViewCell {

    static let ReuseIdentifier = "AdCell"
    private var ad: AdObject? {
        didSet {
            guard let ad = ad else { return }
            // There is no guratenee that price is set
            if let price = ad.price {
                middleLabel.text = "\(ad.location) - \(price),-"
            } else {
                middleLabel.text = ad.location
            }

            // Unfortunately, I am having issues getting dynamic height stuff to work.
            // Instead of hitting my head against the wall for the rest of the night, I will
            // use a artificial limitation on the text and focus on a more extensive detail view instead
            let title = ad.title.limit(to: 25)
            descriptionTextView.text = title
        }
    }

    private var liked: Bool? {
        didSet {
            guard let liked = liked else { return }
            favoriteButton.isSelected = liked
        }
    }

    public var delegate: AdViewCollectionViewCellDelegate?

    private let imageView: UIImageView = {
        let image = UIImage(imageLiteralResourceName: "placeholder")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private let middleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Price"
        return label
    }()

    private let middleLabelContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .priceBackgroundColor
        return containerView
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        return textView
    }()

    private lazy var favoriteButton: FavoriteButton = {
        let favoriteButton = FavoriteButton(delegate: self)
        return favoriteButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        [imageView, middleLabelContainerView, descriptionTextView, favoriteButton].forEach { addSubview($0) }
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    public func configure(for ad: AdObject, image: UIImage, liked: Bool) {
        self.ad = ad
        self.imageView.image = image
        self.liked = liked
    }

    // MARK: - Private

    private func setup() {
        middleLabelContainerView.addSubview(middleLabel)

        // Constraints for the image
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
            ])

        // Constraints for the price
        NSLayoutConstraint.activate([
            middleLabelContainerView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            middleLabelContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            middleLabelContainerView.widthAnchor.constraint(equalTo: widthAnchor),
            middleLabelContainerView.heightAnchor.constraint(equalTo: middleLabel.heightAnchor, multiplier: 1.5),
            // The label
            middleLabel.leadingAnchor.constraint(equalTo: middleLabelContainerView.leadingAnchor, constant: 12),
            middleLabel.centerYAnchor.constraint(equalTo: middleLabelContainerView.centerYAnchor, constant: -3)
            ])

        // Constraints for the location and title
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: middleLabelContainerView.bottomAnchor, constant: -6),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])

        // Constraints for the favorite button
        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: topAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])

        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }

    // MARK: - User interaction

    @objc func pressFavorite() {
        guard let ad = self.ad else { return }
        self.favoriteButton.isSelected = !self.favoriteButton.isSelected
        self.delegate?.toggleFavorite(for: ad, checked: self.favoriteButton.isSelected)
    }
}

extension AdViewCollectionViewCell: FavoriteButtonDelegate {
    func selectorForPressedFavorite() -> Selector {
        return #selector(pressFavorite)
    }
}
