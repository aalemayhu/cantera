//
//  AdObject.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import Foundation

public class AdObject: Codable {

    public let price: Int?
    public let location: String
    public let title: String
    public let imageURL: String
    public let id: String?

    init(adResponse: AdResponse) {
        self.price = adResponse.price?.value
        self.location = adResponse.location
        self.title = adResponse.description
        self.imageURL = adResponse.image.url
        self.id = adResponse.id
    }
}
