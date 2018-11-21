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
    }

    private let storage = StorageHandler()
    private let api = RequestHandler()

    private var lastSelectedIndexPath: IndexPath?

    private let placeHolderImage = UIImage(imageLiteralResourceName: "placeholder")

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

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(indicatorView)
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

        api.cacheLimit = 50
        do {
            try storage.loadFavorites()
            pressedFavoritesItem()
        } catch {
            // Note: Still not sure what todo when this fails...
        }

        // If we have favorites, start there
        guard !storage.favoritedAds.isEmpty else {
            loadRemoteAds()
            return
        }
    }

    private func ad(for item: Int) -> AdObject {
        guard !isShowingFavorites else {
            return storage.favoritedAds[item]
        }
        return api.allAds[item]
    }

    private func loadRemoteAds() {
        indicatorView.animates = true
        api.fetch { (response) in
            DispatchQueue.main.async {
                guard response > 0 else {
                    self.indicatorView.animates = false
                    return
                }
                self.collectionView.reloadData()
                self.indicatorView.animates = false
            }
        }
    }

    private func configure(for cell: AdViewCollectionViewCell?, with indexPath: IndexPath) {
        guard let cell = cell else { return }

        let ad = self.ad(for: indexPath.item)
        cell.ad = ad

        api.image(for: ad, completion: { image in
            DispatchQueue.main.async {
                cell.imageView.image = image ?? UIImage(imageLiteralResourceName: "missing-image")
            }
        })

        cell.liked = storage.favoritedAds.contains(where: { $0.id == ad.id})
        cell.imageView.image = self.placeHolderImage
        cell.delegate = self
    }

    // MARK: - UICollectionView delegate and datasource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return !isShowingFavorites ? AdType.allCases.count : 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !isShowingFavorites else {
            return storage.favoritedAds.count
        }
        return api.allAds.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdViewCollectionViewCell.ReuseIdentifier, for: indexPath)
        configure(for: cell as? AdViewCollectionViewCell, with: indexPath)
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

    // TODO: add a new function for configuring the view...
    @objc func pressedFavoritesItem() {
        self.title = States.favorites.rawValue
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.collectionView.reloadData()
    }

    @objc func pressedBackItem() {
        self.title = States.all.rawValue
        self.navigationItem.leftBarButtonItem = nil

        guard api.allAds.count > 0 else {
            loadRemoteAds()
            return
        }
        self.collectionView.reloadData()
    }

    func toggleFavorite(for ad: AdObject, checked: Bool) {
        do {
            checked ? try storage.add(ad) : try storage.remove(ad)
        } catch {
            // Note: we should let user know the operation failed..
        }
        // If the favorites are currently visible, reload immeditaley
        if isShowingFavorites {
            // TODO: remove this reloadData...
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
