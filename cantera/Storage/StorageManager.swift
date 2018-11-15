//
//  StorageManager.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

class StorageManager {

    private let persistedFilePath: String = {
        let dir = NSHomeDirectory()
        return "\(dir)/cached_payload.json"
    }()

    func persist (ads: [AdObject]) {
        let url = URL(fileURLWithPath: persistedFilePath)
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(ads)
            try data.write(to: url, options: .atomic)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func savedAds() -> [AdObject]? {
        let url = URL(fileURLWithPath: persistedFilePath)
        do {
            let data = try Data(contentsOf: url)
            let ads = try JSONDecoder().decode([AdObject].self, from: data)
            return ads
        } catch {
            return nil
        }
    }

    func purge() {
        let url = URL(fileURLWithPath: persistedFilePath)
        do {
            try FileManager.default.removeItem(at: url)
        } catch { }
    }
}
