//
//  RequestHandler.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import UIKit

class RequestHandler {

    enum Endpoints {
        case json
        case image(String)

        func url() -> URL? {
            switch self {
            case .json:
                return URL(string: "https://gist.githubusercontent.com/3lvis/3799feea005ed49942dcb56386ecec2b/raw/63249144485884d279d55f4f3907e37098f55c74/discover.json")
            case .image(let id):
                return URL(string: "https://images.finncdn.no/dynamic/480x360c/\(id)")
            }
        }
    }

    private let cache = NSCache<AnyObject, AnyObject>()

    public var cacheLimit: Int {
        get { return cache.countLimit }
        set {
            cache.countLimit = newValue
        }
    }

    // MARK: - Private

    private func downloadImage(id: String, completion completionHandler: @escaping (UIImage?) -> Void) {
        guard let url = Endpoints.image(id).url() else {
            completionHandler(nil)
            return
        }

        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
            var image: UIImage?
            if let data = data {
                image = UIImage(data: data)
            }
            if let image = image {
                self.cache.setObject(image, forKey: id as AnyObject)
            }
            completionHandler(image)
        }).resume()
    }

    // MARK: - Public

    public func fetch(completion completionHandler: @escaping ([AdObject]) -> Void) {
        guard let url = Endpoints.json.url() else {
            // This call site is very unlikely to ever be reached, but just in case pass empty
            completionHandler([])
            return
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            var ads = [AdObject]()
            if let data = data {
                do {
                    let adsResponse =  try JSONDecoder().decode(AdsResponse.self, from: data)
                    ads = adsResponse.items.map { AdObject(adResponse: $0) }
                    // Drop all of the ads that are missing the price
                    ads.removeAll { $0.price == nil }
                } catch {}
            }

            // Note: we should do something useful with the error and response.
            // Maybe provide better titles / messages in the UI?
            if let error = error {
                DebugHandler.print_string("\(#function): error -> \(error)")
            }
            if let res = response {
                DebugHandler.print_string("\(#function): response -> \(res)")
            }

            DispatchQueue.main.async {
                completionHandler(ads)
            }
            }.resume()
    }

    public func image(for ad: AdObject, completion completionHandler: @escaping (UIImage?) -> Void) {
        let callback: (UIImage?) -> Void = { image in
            DispatchQueue.main.async {
                completionHandler(image)
            }
        }

        if let image = cache.object(forKey: ad.imageURL as AnyObject) as? UIImage {
            callback(image)
        } else {
            downloadImage(id: ad.imageURL) { (image) in
                callback(image)
            }
        }
    }

    public func freeUpResources() {
        self.cache.removeAllObjects()
    }
}
