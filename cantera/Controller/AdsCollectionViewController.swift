//
//  CanteraViewController.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

class AdsCollectionViewController: UICollectionViewController, AdViewCollectionViewCellDelegate {

    enum States: String {
        case all = "Annonser"
        case favorites = "Favoritter"
    }

    private let api = AdsAPIHandler()
    private var favoritedAds = [AdObject]()
    private var allAds = [AdObject]()

    private lazy var leftBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: States.all.rawValue, style: .plain, target: self, action: #selector(pressedBackItem))
        return item
    }()

    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let rightBarButtonItem = UIBarButtonItem(title: "Favoritter", style: .plain, target: self, action: #selector(pressedFavoritesItem))
        rightBarButtonItem.tintColor = UIColor.red
        return rightBarButtonItem
    }()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionViewLayout.invalidateLayout()
    }

    // MARK: - Private

    private func setup() {

        self.title = States.all.rawValue
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.register(AdViewCollectionViewCell.self, forCellWithReuseIdentifier: AdViewCollectionViewCell.ReuseIdentifier)
        collectionView.backgroundColor = .white

        // todo should we use the safe guard?

        // Should we persist the ads?
        api.fetch { (response) in
            if let response = response {
                // We have to update UI in the main thread otherwise the main thread checker will kill us
                DispatchQueue.main.async {
                    self.allAds = response.items.map { AdObject(adResponse: $0) }
                    // Drop all of the ads that are still under construction
                    self.allAds.removeAll { $0.price == nil }
                    self.collectionView.reloadData()
                }
            }
        }
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }

    private func ad(for item: Int) -> AdObject {
        return States.favorites.rawValue == self.title ? favoritedAds[item] : allAds[item]
    }

    // MARK: - UICollectionView delegate and datasource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return States.favorites.rawValue == self.title ? favoritedAds.count : allAds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdViewCollectionViewCell.ReuseIdentifier, for: indexPath)
        if let cell = cell as? AdViewCollectionViewCell {
            let ad = self.ad(for: indexPath.item)
            cell.ad = ad
            //   // NOTE: Check if image is already cached before download
            api.downloadImage(id: ad.imageURL) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            }
            cell.delegate = self
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ad = self.ad(for: indexPath.item)
        print("Image is \(ad.imageURL)")
    }

    // MARK: - User interaction

    // TODO: should we run a animation when switching the navigation items

    @objc func pressedFavoritesItem() {
        self.title = States.favorites.rawValue
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.collectionView.reloadData()
    }

    @objc func pressedBackItem() {
        self.title = States.all.rawValue
        self.navigationItem.leftBarButtonItem = nil
        self.collectionView.reloadData()
    }

    func toogleFavorite(for ad: AdObject, checked: Bool) {
        ad.liked = checked
        self.favoritedAds = self.allAds.filter { $0.liked }

        // If the user is manipulating favorites, drop them from the immediately by triggering a reload
        if self.title == States.favorites.rawValue {
            self.collectionView.reloadData()
        }
    }
}
