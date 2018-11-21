//
//  AdResponse.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

struct AdResponse: Codable {
    let description: String
    let price: PriceResponse?
    let location: String
    let id: String
    let image: ImageResponse
    let adType: AdType

    enum CodingKeys: String, CodingKey {
        case description = "description"
        case price = "price"
        case location = "location"
        case id = "id"
        case image = "image"
        case adType = "ad-type"
    }
}
