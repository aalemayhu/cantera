//
//  AdsAPIHandler.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation
import UIKit

class AdsAPIHandler {

    private let cache = NSCache<AnyObject, AnyObject>()

    public func fetch(completion completionHandler: @escaping (AdsResponse?) -> Void) {
        guard let url = Endpoints.json.url() else { return }

        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                do {
                    let ads = try JSONDecoder().decode(AdsResponse.self, from: data)
                    completionHandler(ads)
                } catch {
                    completionHandler(nil)
                }
            }
        }.resume()
    }

    private func downloadImage(id: String, completion completionHandler: @escaping (UIImage?) -> Void) {
        guard let url = Endpoints.image(id).url() else {
            completionHandler(nil)
            return
        }

        URLSession.shared.dataTask(with: url, completionHandler: { (data, res, err) in
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

    public func image(for ad: AdObject, completion completionHandler: @escaping (UIImage?) -> Void) {
        if let image = cache.object(forKey: ad.imageURL as AnyObject) as? UIImage {
            completionHandler(image)
        } else {
            downloadImage(id: ad.imageURL) { (image) in
                completionHandler(image)
            }
        }
    }

    public func freeUpResources() {
        self.cache.removeAllObjects()
    }
}
