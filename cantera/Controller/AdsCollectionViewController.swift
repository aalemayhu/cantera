//
//  AdsCollectionViewController.swift
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
        case emptyFavorites = "Tomt"
    }

    private let storage = StorageHandler()
    private let api = RequestHandler()

    private var lastSelectedIndexPath: IndexPath?

    private let placeHolderImage = UIImage(imageLiteralResourceName: "placeholder")
    private let missingImage = UIImage(imageLiteralResourceName: "missing-image")

    private lazy var leftBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: States.all.rawValue, style: .plain, target: self, action: #selector(pressedBackItem))
        return item
    }()

    private lazy var rightBarButtonItem: UIBarButtonItem = {
        let rightBarButtonItem = UIBarButtonItem(title: "Favoritter", style: .plain, target: self, action: #selector(pressedFavoritesItem))
        rightBarButtonItem.tintColor = UIColor.red
        return rightBarButtonItem
    }()

    private let indicatorView = LoadingIndicatorView()

    private var isShowingFavorites: Bool {
        return States.favorites.rawValue == self.title
    }

    let emptyFavoritesView = EmptyFavoritesView()

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        [indicatorView, emptyFavoritesView].forEach { self.view.addSubview($0) }
        setup()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // This is not ideal, but by keeping track of the selected one
        // we can update a single item instead of reloading the whole collection.
        guard let selectedIndexPath = self.lastSelectedIndexPath else {
            collectionView.reloadData()
            return
        }
        collectionView.reloadItems(at: [selectedIndexPath])
        self.lastSelectedIndexPath = nil
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.collectionViewLayout.invalidateLayout()
    }

    override func didReceiveMemoryWarning() {
        // In the unlikely case we get a memory warning, empty out the cache.
        api.freeUpResources()
        super.didReceiveMemoryWarning()
    }

    // MARK: - Private

    private func setup() {
        collectionView.register(AdViewCollectionViewCell.self, forCellWithReuseIdentifier: AdViewCollectionViewCell.ReuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.backgroundColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        title = States.all.rawValue

        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicatorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            indicatorView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1)
            ])

        NSLayoutConstraint.activate([
            emptyFavoritesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyFavoritesView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyFavoritesView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
            emptyFavoritesView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1)
            ])

        api.cacheLimit = 50
        do {
            try storage.loadFavorites()
            configure(for: .favorites)
        } catch {
            // Note: Still not sure what todo when this fails...
        }

        // If we have favorites, start there
        guard !storage.favoritedAds.isEmpty else {
            configure(for: .all)
            return
        }
    }

    private func ad(for item: Int) -> AdObject {
        guard !isShowingFavorites else {
            return storage.favoritedAds[item]
        }
        return storage.allAds[item]
    }

    private func loadRemoteAds() {
        indicatorView.animates = true
        api.fetch { (response) in
            guard response.count > 0 else {
                self.indicatorView.animates = false
                return
            }

            // Note: use diffing scheme and let UICollectionView perform animation
            self.storage.use(response)
            self.collectionView.reloadData()
            self.indicatorView.animates = false
        }
    }

    private func configure(for state: States) {
        emptyFavoritesView.isHidden = true

        switch state {
        case .all:
            navigationItem.leftBarButtonItem = nil
            title = States.all.rawValue

            guard storage.allAds.count > 0 else {
                loadRemoteAds()
                return
            }
            collectionView.reloadData()
        case .favorites:
            navigationItem.leftBarButtonItem = leftBarButtonItem
            title = States.favorites.rawValue
            collectionView.reloadData()

            // No favorites on initial configuring, fallback to empty
            if storage.favoritedAds.isEmpty {
                fallthrough
            }
        case .emptyFavorites:
            emptyFavoritesView.isHidden = false
        }
    }

    // MARK: - UICollectionView delegate and datasource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return !isShowingFavorites ? AdType.allCases.count : 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !isShowingFavorites else {
            return storage.favoritedAds.count
        }
        return storage.allAds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdViewCollectionViewCell.ReuseIdentifier, for: indexPath)
        guard let adCell = cell as? AdViewCollectionViewCell else { return cell }

        let ad = self.ad(for: indexPath.item)
        let liked = storage.favoritedAds.contains(where: { $0.id == ad.id})
        adCell.delegate = self
        adCell.configure(for: ad, image: self.placeHolderImage, liked: liked)

        api.image(for: ad, completion: { image in
            adCell.configure(for: ad, image: image ?? self.placeHolderImage, liked: liked)
        })
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.lastSelectedIndexPath = indexPath

        let detailViewController = AdsDetailViewController()
        detailViewController.datasource = self
        detailViewController.delegate = self
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

    // MARK: - User interaction

    @objc func pressedFavoritesItem() {
        configure(for: .favorites)
    }

    @objc func pressedBackItem() {
        configure(for: .all)
    }

    func toggleFavorite(for ad: AdObject, checked: Bool) {
        do {
            checked ? try storage.add(ad) : try storage.remove(ad)
        } catch {
            // Note: we should let user know the operation failed..
        }

        var item: Int?
        if isShowingFavorites {
            item = storage.favoritedAds.firstIndex(where: { $0.id == ad.id })
            if storage.favoritedAds.isEmpty {
                configure(for: .emptyFavorites)
            }
        } else {
            item = storage.allAds.firstIndex(where: { $0.id == ad.id })
        }

        // Try to only reload the item that changed
        if let item = item {
            collectionView.reloadItems(at: [IndexPath(item: item, section: 0)])
        } else {
            self.collectionView.reloadData()
        }
    }
}

extension AdsCollectionViewController: AdsDetailViewControllerDatasource, AdsDetailViewControllerDelegate {

    // Datasource

    func isItinFavorites(ad: AdObject) -> Bool {
        return storage.favoritedAds.contains(where: { $0.id == ad.id})
    }

    func retrieveImage(for ad: AdObject, completion: @escaping (UIImage?) -> Void) {
        api.image(for: ad, completion: completion)
    }

    func adForDetailViewController() -> AdObject? {
        guard let indexPath = self.lastSelectedIndexPath else { return nil }
        return ad(for: indexPath.item)
    }

    // Delegate

    func pressedFavorite(for ad: AdObject, checked: Bool) {
        do {
            guard checked else {
                lastSelectedIndexPath = nil /// Handle internal inconcistentcy
                try storage.remove(ad)
                return
            }
            try storage.add(ad)
        } catch {
            // Note: let user know op failed
        }
    }
}
