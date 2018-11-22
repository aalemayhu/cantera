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
    private(set) var allAds = [AdObject]()

    // MARK: - Private

    private func persist (ads: [AdObject]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(ads)
        try data.write(to: persistedFileURL, options: .atomic)
    }

    private func savedAds() throws -> [AdObject]? {
        let data = try Data(contentsOf: persistedFileURL)
        let ads = try JSONDecoder().decode([AdObject].self, from: data)
        return ads
    }

    // MARK: - Public

    public func loadFavorites() throws {
        // Note: we should not assume this is guranteed to work but instead throw exception on error
        guard let ads = try savedAds() else { return }
        favoritedAds = ads
    }

    // Note: not a great name, pick a different one.
    public func use(_ ads: [AdObject]) {
        allAds = ads
    }

    public func purge() {
        do {
            try FileManager.default.removeItem(at: persistedFileURL)
        } catch { }
    }

    public func add(_ ad: AdObject) throws {
        let match = favoritedAds.filter { $0.id == ad.id }
        guard match.count == 0 else { return }

        favoritedAds.append(ad)
        // Note: this will trigger FS sycalls for every  change, should be optimized.
        try self.persist(ads: self.favoritedAds)
    }

   public func remove(_ ad: AdObject) throws {
        favoritedAds.removeAll { $0.id == ad.id }
        // Note: this will trigger FS sycalls for every  change, should be optimized.
        try self.persist(ads: self.favoritedAds)
    }
}
