//
//  AdViewCollectionViewCell.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

protocol AdViewCollectionViewCellDelegate {
    func toogleFavorite(for ad: AdObject, checked: Bool)
}

class AdViewCollectionViewCell: UICollectionViewCell {

    static let ReuseIdentifier = "AdCell"
    public var ad: AdObject? {
        didSet {
            guard let ad = ad else { return }
            // There is no guratenee that price is set
            if let price = ad.price {
                priceLabel.text = "\(price),-"
                self.priceContainerView.isHidden = false
            } else {
                self.priceContainerView.isHidden = true
            }

            let attributedText = NSMutableAttributedString(string: ad.location, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            attributedText.append(NSAttributedString(string: "\n\(ad.title)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
            descriptionTextView.attributedText = attributedText

            favoriteButton.isSelected = ad.liked
        }
    }

    public var delegate: AdViewCollectionViewCellDelegate?

    public let imageView: UIImageView = {
        let image = UIImage(imageLiteralResourceName: "placeholder")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Price"
        return label
    }()

    private let priceContainerView: UIView = {
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

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(imageLiteralResourceName: "plainheart"), for: .normal)
        button.setImage(UIImage(imageLiteralResourceName: "plainredheart"), for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        [imageView, priceContainerView, descriptionTextView, favoriteButton].forEach { addSubview($0) }
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setup() {
        backgroundColor = .yellow

        priceContainerView.addSubview(priceLabel)

        // Constraints for the image
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
            ])

        // Constraints for the price
        NSLayoutConstraint.activate([
            priceContainerView.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            priceContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            priceContainerView.widthAnchor.constraint(equalTo: widthAnchor),
            priceContainerView.heightAnchor.constraint(equalTo: priceLabel.heightAnchor, multiplier: 1.5),
            // The label
            priceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor, constant: 12),
            priceLabel.centerYAnchor.constraint(equalTo: priceContainerView.centerYAnchor, constant: -3)
            ])

        // Constraints for the location and title
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: priceContainerView.bottomAnchor, constant: -6),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])

        // Constraints for the favorite button
        NSLayoutConstraint.activate([
            favoriteButton.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            favoriteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6)
            ])

        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true

        favoriteButton.addTarget(self, action: #selector(pressFavorite), for: .touchUpInside)
    }

    // MARK: - User interaction

    @objc func pressFavorite() {
        guard let ad = self.ad else { return }
        self.favoriteButton.isSelected = !self.isSelected
        delegate?.toogleFavorite(for: ad, checked: favoriteButton.isSelected)
    }
}
