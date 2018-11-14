//
//  Image.swift
//  cantera
//
//  Created by Alexander Alemayhu on 14/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

struct ImageResponse: Codable {
    let scalable: Bool
    let width: Int?
    let type: String
    let url: String
    let height: Int?
}
