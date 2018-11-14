//
//  Ad.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

struct AdResponse: Codable {
    let description: String
    // While the price only has 1 property, let's not make assumptions about the future and use a seperate struct for it.
    let price: PriceResponse?
    let location: String
    // We are really just interested in the url of the image, but in the unlikely case we want to access more properties use struct.
    let image: ImageResponse
}
