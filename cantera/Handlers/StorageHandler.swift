//
//  StorageHandler.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

class StorageHandler {

    private let persistedFileURL: URL = {
        let homeDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return homeDir.appendingPathComponent("cached_payload.json")
    }()

    private(set) var favoritedAds = [AdObject]()

    // MARK: - Private

    private func persist (ads: [AdObject]) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(ads)
            try data.write(to: persistedFileURL, options: .atomic)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func savedAds() -> [AdObject]? {
        do {
            let data = try Data(contentsOf: persistedFileURL)
            let ads = try JSONDecoder().decode([AdObject].self, from: data)
            return ads
        } catch {
            return nil
        }
    }

    // MARK: - Public

    func loadFavorites() {
        // Note: we should not assume this is guranteed to work but instead throw exception on error
        guard let ads = savedAds() else { return }
        favoritedAds = ads
    }

    func purge() {
        do {
            try FileManager.default.removeItem(at: persistedFileURL)
        } catch { }
    }

    func add(_ ad: AdObject) {
        let match = favoritedAds.filter { $0.id == ad.id }
        guard match.count == 0 else { return }

        favoritedAds.append(ad)
        // Note: this will trigger FS sycalls for every  change, should be optimized.
        self.persist(ads: self.favoritedAds)
    }

    func remove(_ ad: AdObject) {
        favoritedAds.removeAll { $0.id == ad.id }
        // Note: this will trigger FS sycalls for every  change, should be optimized.
        self.persist(ads: self.favoritedAds)
    }
}
