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

    func fetch(completion completionHandler: @escaping (AdsResponse?) -> Void) {
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

    func downloadImage(id: String, completion completionHandler: @escaping (UIImage?) -> Void) {
        guard let url = Endpoints.image(id).url() else {
            completionHandler(nil)
            return
        }

        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
            var image: UIImage?
            if let data = data {
                image = UIImage(data: data)
            }
            completionHandler(image)
        }).resume()
    }
}
