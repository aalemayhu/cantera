//
//  AdsAPIHandler.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

class AdsAPIHandler {

    func fetch(completion completionHandler: @escaping (AdsResponse?) -> Void) {
        guard let url = Endpoints.json.url() else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                do {
                    let ads = try JSONDecoder().decode(AdsResponse.self, from: data)
                    completionHandler(ads)
                } catch {
                    completionHandler(nil)
                }
            }
        }
        task.resume()
    }
}
