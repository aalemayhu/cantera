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
        // Below strings are not visible in UI, should they be?
        case emptyFavorites = "Ingen favoritter enda?"
        case emptyAds = "Ingen annonser"
    }

    private var currentState: States {
        get {
            guard let title = title else { return .emptyFavorites }
            guard let state = States(rawValue: title) else { return .emptyFavorites }
            return state
        }
        set {
            emptyFavoritesView.isHidden = true
            emptyAdsView.isHidden = true

            // View being in empty favorites state should not affect the switch
            guard newValue != .emptyFavorites else { return }
            favoritesSwitch.isOn = newValue == .favorites
            title = newValue.rawValue
        }
    }

    private let storage = StorageHandler()
    private let api = RequestHandler()

    private var lastSelectedIndexPath: IndexPath?

    private let placeHolderImage = UIImage(imageLiteralResourceName: "placeholder")
    private let missingImage = UIImage(imageLiteralResourceName: "missing-image")

    private lazy var favoritesSwitch: UISwitch = {
        let favSwitch = UISwitch(frame: .zero)
        favSwitch.onTintColor = .red
        favSwitch.addTarget(self, action: #selector(pressedSwitch), for: .valueChanged)
        return favSwitch
    }()

    private let indicatorView = LoadingIndicatorView()
    private var adsToDisplay = [AdObject]()

    private let emptyFavoritesTitle = "Finner du noe du liker?"
    private let emptyFavoritesMessage = "Trykk på det lille hjertet i høyre hjørne ved annnonsen. Da legger annonsen seg under \"Favoritter\", slik at det blir lettere å finne den igjen"

    private lazy var emptyFavoritesView = EmptyCollectionView(title: emptyFavoritesTitle, message: emptyFavoritesMessage)

    private let emptyAdsTitle = "Frakoblet?"
    private let emptyAdsMessage = "Vi får ikke kontaktet serveren. Sjekk at du er koblet til trådløst nett eller mobildata."

    private lazy var emptyAdsView = EmptyCollectionView(title: emptyAdsTitle, message: emptyAdsMessage)

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        [indicatorView, emptyFavoritesView, emptyAdsView].forEach { self.view.addSubview($0) }
        emptyFavoritesView.isHidden = true
        emptyAdsView.isHidden = true
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = self.lastSelectedIndexPath {
            if currentState == .favorites {
                adsToDisplay.remove(at: selectedIndexPath.item)
                collectionView.deleteItems(at: [selectedIndexPath])
            } else {
                collectionView.reloadItems(at: [selectedIndexPath])
            }
            self.lastSelectedIndexPath = nil
        } else if currentState == .favorites && adsToDisplay.isEmpty {
            configure(for: .favorites)
        } else if adsToDisplay.isEmpty {
            loadRemoteAds(updateView: true)
        }
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoritesSwitch)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.backgroundColor = .white
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

        NSLayoutConstraint.activate([
            emptyAdsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyAdsView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyAdsView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
            emptyAdsView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1)
            ])

        api.cacheLimit = 50
        do {
            try storage.loadFavorites()

            adsToDisplay = storage.favoritedAds
        } catch {
            // Note: Still not sure what todo when this fails...
        }
    }

    private func loadRemoteAds(updateView: Bool = false) {
        indicatorView.animates = updateView
        api.fetch { (response) in
            self.storage.use(response)
            if updateView {
                self.indicatorView.animates = !updateView
                self.configure(for: .all)
            }
        }
    }

    private func configure(for newState: States) {
        currentState = newState

        switch newState {
        case .all:
            updateCollectionView(from: storage.favoritedAds, to: storage.allAds)
            // No Ads to display, fallback to empty view
            if storage.allAds.isEmpty {
                if emptyAdsView.isHidden {
                    fallthrough
                } else {
                    loadRemoteAds(updateView: true)
                }
            }
        case .emptyAds:
            emptyAdsView.isHidden = false
        case .favorites:
            updateCollectionView(from: storage.allAds, to: storage.favoritedAds)
            // No favorites on initial configuring, fallback to empty view
            if storage.favoritedAds.isEmpty {
                fallthrough
            }
        case .emptyFavorites:
            emptyFavoritesView.isHidden = false
        }
    }

    private func updateCollectionView(from: [AdObject], to: [AdObject]) {
        let toDeleteItems: [IndexPath?] =  from.enumerated().map { (index, element) in
            var indexPath: IndexPath?
            if !to.contains(where: { $0.id == element.id }) {
                adsToDisplay.removeAll(where: { $0.id == element.id })
                indexPath = IndexPath(item: index, section: 0)
            }
            return indexPath
        }

        let toAddItems: [IndexPath?] = to.enumerated().map { (index, element) in
            var indexPath: IndexPath?
            if !adsToDisplay.contains(where: { $0.id == element.id }) {
                adsToDisplay.append(element)
                indexPath = IndexPath(item: index, section: 0)
            }
            return indexPath
        }

        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: toDeleteItems.compactMap({ $0 }).reversed())
            collectionView.insertItems(at: toAddItems.compactMap({ $0 }))
        }, completion: nil)
    }

    // MARK: - UICollectionView delegate and datasource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return adsToDisplay.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdViewCollectionViewCell.ReuseIdentifier, for: indexPath)
        guard let adCell = cell as? AdViewCollectionViewCell else { return cell }

        let ad = adsToDisplay[indexPath.item]
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

    @objc func pressedSwitch() {
        if favoritesSwitch.isOn {
            configure(for: .favorites)
        } else {
            configure(for: .all)
        }
    }

    func toggleFavorite(for ad: AdObject, checked: Bool) {
        do {
            if checked {
                try storage.add(ad)
                // Handle the case where we have no favorites and going from empty view to populate the collection view
                if adsToDisplay.isEmpty {
                    adsToDisplay.append(ad)
                    collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
                }
                    // The ad is already visible we just need to trigger reload
                else  if currentState == .favorites, let index = adsToDisplay.firstIndex(where: { $0.id == ad.id }) {
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                } else if let index = storage.allAds.firstIndex(where: { $0.id == ad.id }) {
                    collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            } else if currentState == .favorites, let index = adsToDisplay.firstIndex(where: { $0.id == ad.id }) {
                try storage.remove(ad)
                adsToDisplay.remove(at: index)
                collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                // Last favorite was removed, show the empty view
                if storage.favoritedAds.isEmpty {
                    configure(for: .emptyFavorites)
                }
            } else if let item = storage.allAds.firstIndex(where: { $0.id == ad.id }) {
                // In the case of all ads, we don't need to remove the ad. Just reload.
                collectionView.reloadItems(at: [IndexPath(item: item, section: 0)])
            }
        } catch {
            // Note: we should let user know the operation failed..
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
        return adsToDisplay[indexPath.item]
    }

    // Delegate

    func pressedFavorite(for ad: AdObject, checked: Bool) {
        do {
            guard checked else {
                try storage.remove(ad)
                return
            }
            try storage.add(ad)
        } catch {
            // Note: let user know op failed
        }
    }
}
