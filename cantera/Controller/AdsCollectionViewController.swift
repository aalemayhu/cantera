//
//  CanteraViewController.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

class AdsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    enum States: String {
        case all = "Viser alle annonser"
        case favorites = "Viser kun favoritter"
    }

    private let api = AdsAPIHandler()
    private var ads = [Ad]()

    private let favoritesSwitch: UISwitch = {
       let favoritesSwitch = UISwitch(frame: .zero)
        favoritesSwitch.isOn = false
        return favoritesSwitch
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
                    self.ads = response.items
                    // Drop all of the ads that are still under construction
                    self.ads.removeAll { $0.price == nil }
                    self.collectionView.reloadData()
                }
            }
        }

        favoritesSwitch.addTarget(self, action: #selector(pressToggle), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoritesSwitch)
    }

    // MARK: - UICollectionView delegate and datasource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ads.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdViewCollectionViewCell.ReuseIdentifier, for: indexPath)
        if let cell = cell as? AdViewCollectionViewCell {
            let ad = ads[indexPath.item]
            cell.ad = ad            
            //   // NOTE: Check if image is already cached before download
            api.downloadImage(id: ad.image.url) { (image) in
                if let image = image {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }
                }
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ad = ads[indexPath.item]
        var width = 180, height = 136

        if  let imageHeigth = ad.image.height {
            height = max(imageHeigth / 8, height)
        }

        print("width: \(width) height: \(height)")
        return .init(width: width, height: height)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ad = ads[indexPath.item]
        print("Image is \(ad.image)")
    }

    // MARK: - User interaction

    @objc func pressToggle() {
        print("\(#function)")

        if favoritesSwitch.isOn {
            // TODO: only show favorites now
            self.title = States.favorites.rawValue
            return
        }

        // TODO: go back to showing all of them
        self.title = States.all.rawValue
    }
}