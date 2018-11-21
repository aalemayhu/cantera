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
}
